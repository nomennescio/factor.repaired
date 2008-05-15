! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.encodings math.order io.backend
continuations debugger classes byte-arrays namespaces splitting
dlists assocs io.encodings.binary inspector accessors
destructors ;
IN: io.ports

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

TUPLE: port handle error timeout closed ;

M: port timeout timeout>> ;

M: port set-timeout (>>timeout) ;

GENERIC: init-handle ( handle -- )

GENERIC: close-handle ( handle -- )

TUPLE: handle-destructor handle ;

C: <handle-destructor> handle-destructor

M: handle-destructor dispose ( obj -- )
    handle>> close-handle ;

: &close-handle ( handle -- handle )
    <handle-destructor> <only-once> &dispose ; inline

: |close-handle ( handle -- handle )
    <handle-destructor> <only-once> |dispose ; inline

: <port> ( handle class -- port )
    new
        swap dup init-handle >>handle ; inline

: pending-error ( port -- )
    [ f ] change-error drop [ throw ] when* ;

ERROR: port-closed-error port ;

M: port-closed-error summary
    drop "Port has been closed" ;

: check-closed ( port -- port )
    dup closed>> [ port-closed-error ] when ;

TUPLE: buffered-port < port buffer ;

: <buffered-port> ( handle class -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ; inline

TUPLE: input-port < buffered-port eof ;

: <input-port> ( handle -- input-port )
    input-port <buffered-port> ;

HOOK: (wait-to-read) io-backend ( port -- )

: wait-to-read ( port -- )
    dup buffer>> buffer-empty? [ (wait-to-read) ] [ drop ] if ;

: unless-eof ( port quot -- value )
    >r dup buffer>> buffer-empty? over eof>> and
    [ f >>eof drop f ] r> if ; inline

M: input-port stream-read1
    check-closed
    dup wait-to-read [ buffer>> buffer-pop ] unless-eof ;

: read-step ( count port -- byte-array/f )
    [ wait-to-read ] keep
    [ dupd buffer>> buffer-read ] unless-eof nip ;

M: input-port stream-read-partial ( max stream -- byte-array/f )
    check-closed
    >r 0 max >integer r> read-step ;

: read-loop ( count port accum -- )
    pick over length - dup 0 > [
        pick read-step dup [
            over push-all read-loop
        ] [
            2drop 2drop
        ] if
    ] [
        2drop 2drop
    ] if ;

M: input-port stream-read
    check-closed
    >r 0 max >fixnum r>
    2dup read-step dup [
        pick over length > [
            pick <byte-vector>
            [ push-all ] keep
            [ read-loop ] keep
            B{ } like
        ] [ 2nip ] if
    ] [ 2nip ] if ;

TUPLE: output-port < buffered-port ;

: <output-port> ( handle -- output-port )
    output-port <buffered-port> ;

: can-write? ( len buffer -- ? )
    [ buffer-fill + ] keep buffer-capacity <= ;

: wait-to-write ( len port -- )
    tuck buffer>> can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    check-closed
    1 over wait-to-write
    buffer>> byte>buffer ;

M: output-port stream-write
    check-closed
    over length over buffer>> buffer-size > [
        [ buffer>> buffer-size <groups> ]
        [ [ stream-write ] curry ] bi
        each
    ] [
        [ >r length r> wait-to-write ]
        [ buffer>> >buffer ] 2bi
    ] if ;

HOOK: (wait-to-write) io-backend ( port -- )

: flush-port ( port -- )
    dup buffer>> buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: output-port stream-flush ( port -- )
    check-closed
    [ flush-port ] [ pending-error ] bi ;

GENERIC: close-port ( port -- )

M: output-port close-port
    [ flush-port ] [ call-next-method ] bi ;

M: buffered-port close-port
    [ call-next-method ]
    [ [ [ buffer-free ] when* f ] change-buffer drop ]
    bi ;

HOOK: cancel-io io-backend ( port -- )

M: port timed-out cancel-io ;

M: port close-port
    [ cancel-io ] [ handle>> close-handle ] bi ;

M: port dispose
    dup closed>> [ drop ] [ t >>closed close-port ] if ;

: <ports> ( read-handle write-handle -- input-port output-port )
    [
        [ <input-port> |dispose ]
        [ <output-port> |dispose ] bi*
    ] with-destructors ;
