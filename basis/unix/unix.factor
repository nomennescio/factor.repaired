! Copyright (C) 2005, 2010 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.syntax byte-vectors classes.struct combinators
combinators.short-circuit combinators.smart continuations
generalizations io kernel libc locals macros math namespaces
sequences sequences.generalizations stack-checker strings system
unix.time unix.types vocabs vocabs.loader unix.ffi ;
IN: unix

ERROR: unix-system-call-error args errno message word ;

: unix-call-failed? ( ret -- ? )
    {
        [ { [ integer? ] [ 0 < ] } 1&& ]
        [ not ]
    } 1|| ;

MACRO:: unix-system-call ( quot -- quot )
    quot inputs :> n
    quot first :> word
    0 :> ret!
    f :> failed!
    [
        [
            n ndup quot call ret!
            ret {
                [ unix-call-failed? dup failed! ]
                [ drop errno EINTR = ]
            } 1&&
        ] loop
        failed [
            n narray
            errno dup strerror
            word unix-system-call-error
        ] [
            n ndrop
            ret
        ] if
    ] ;

MACRO:: unix-system-call-allow-eintr ( quot -- quot )
    quot inputs :> n
    quot first :> word
    0 :> ret!
    [
        n ndup quot call ret!
        ret unix-call-failed? [
            ! Bug #908
            ! Allow EINTR for close(2)
            errno EINTR = [
                n narray
                errno dup strerror
                word unix-system-call-error
            ] unless
        ] [
            n ndrop
            ret
        ] if
    ] ;

HOOK: open-file os ( path flags mode -- fd )

: close-file ( fd -- ) [ close ] unix-system-call-allow-eintr drop ;

FUNCTION: int _exit ( int status ) ;

M: unix open-file [ open ] unix-system-call ;

: make-fifo ( path mode -- ) [ mkfifo ] unix-system-call drop ;

: truncate-file ( path n -- ) [ truncate ] unix-system-call drop ;

: touch ( filename -- ) f [ utime ] unix-system-call drop ;

: change-file-times ( filename access modification -- )
    utimbuf <struct>
        swap >>modtime
        swap >>actime
        [ utime ] unix-system-call drop ;

: read-symbolic-link ( path -- path )
    PATH_MAX <byte-vector> [
        underlying>> PATH_MAX
        [ readlink ] unix-system-call
    ] keep swap >>length >string ;

: unlink-file ( path -- ) [ unlink ] unix-system-call drop ;

<<

{ "unix" "debugger" } "unix.debugger" require-when

>>
