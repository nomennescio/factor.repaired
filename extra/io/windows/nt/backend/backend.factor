USING: alien alien.c-types arrays assocs combinators
continuations destructors io io.backend io.ports
io.windows libc kernel math namespaces sequences
threads classes.tuple.lib windows windows.errors
windows.kernel32 strings splitting io.files qualified ascii
combinators.lib system accessors ;
QUALIFIED: windows.winsock
IN: io.windows.nt.backend

SYMBOL: io-hash

TUPLE: io-callback port thread ;

C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object &free ;

: make-overlapped ( port -- overlapped-ext )
    >r (make-overlapped)
    r> handle>> ptr>> [ over set-OVERLAPPED-offset ] when* ;

: <completion-port> ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

SYMBOL: master-completion-port

: <master-completion-port> ( -- handle )
    INVALID_HANDLE_VALUE f <completion-port> ;

M: winnt add-completion ( handle -- )
    master-completion-port get-global <completion-port> drop ;

: eof? ( error -- ? )
    dup ERROR_HANDLE_EOF = swap ERROR_BROKEN_PIPE = or ;

: overlapped-error? ( port n -- ? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ 2drop t ] }
            { [ dup eof? ] [ drop t >>eof drop f ] }
            [ (win32-error-string) throw ]
        } cond
    ] [
        drop t
    ] if ;

: get-overlapped-result ( overlapped port -- bytes-transferred )
    dup handle>> handle>> rot 0 <uint>
    [ 0 GetOverlappedResult overlapped-error? drop ] keep *uint ;

: save-callback ( overlapped port -- )
    [
        <io-callback> swap
        dup alien? [ "bad overlapped in save-callback" throw ] unless
        io-hash get-global set-at
    ] "I/O" suspend 3drop ;

: twiddle-thumbs ( overlapped port -- bytes-transferred )
    [ save-callback ]
    [ get-overlapped-result ]
    [ nip pending-error ]
    2tri ;

:: wait-for-overlapped ( ms -- overlapped ? )
    master-completion-port get-global
    r> INFINITE or ! timeout
    0 <int> ! bytes
    f <void*> ! key
    f <void*> ! overlapped
    [
        ms INFINITE or ! timeout
        GetQueuedCompletionStatus
    ] keep *void* swap zero? ;

: lookup-callback ( overlapped -- callback )
    io-hash get-global delete-at* drop
    dup io-callback? [ "no callback in io-hash" throw ] unless ;

: handle-overlapped ( timeout -- ? )
    wait-for-overlapped [
        GetLastError dup expected-io-error? [ 2drop f ] [
            >r lookup-callback [ thread>> ] [ port>> ] bi r>
            dup eof?
            [ drop t >>eof drop ]
            [ (win32-error-string) >>error drop ] if
            thread>> resume t
        ] if
    ] [
        lookup-callback
        thread>> resume t
    ] if ;

M: winnt cancel-io
    handle>> handle>> CancelIo drop ;

M: winnt io-multiplex ( ms -- )
    handle-overlapped [ 0 io-multiplex ] when ;

M: winnt init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone io-hash set-global
    windows.winsock:init-winsock ;

: finish-flush ( n port -- )
    [ update-file-ptr ] [ buffer>> buffer-consume ] 2bi ;

: ((wait-to-write)) ( port -- )
    dup make-FileArgs
    tuck setup-write WriteFile
    dupd overlapped-error? [
        >r lpOverlapped>> r>
        [ twiddle-thumbs ] keep
        [ finish-flush ] keep
        dup buffer>> buffer-empty? [ drop ] [ ((wait-to-write)) ] if
    ] [
        2drop
    ] if ;

M: winnt (wait-to-write)
    [ [ ((wait-to-write)) ] with-timeout ] with-destructors ;

: finish-read ( n port -- )
    over zero? [
        t >>eof 2drop
    ] [
        [ buffer>> n>buffer ] [ update-file-ptr ] bi
    ] if ;

: ((wait-to-read)) ( port -- )
    dup make-FileArgs
    tuck setup-read ReadFile
    dupd overlapped-error? [
        >r lpOverlapped>> r>
        [ twiddle-thumbs ] [ finish-read ] bi
    ] [ 2drop ] if ;

M: winnt (wait-to-read) ( port -- )
    [ [ ((wait-to-read)) ] with-timeout ] with-destructors ;
