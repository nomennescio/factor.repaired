! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators init boxes ;

SYMBOL: initial-thread

TUPLE: thread
name quot exit-handler
id
continuation state
mailbox variables sleep-entry ;

: self ( -- thread ) 40 getenv ; inline

! Thread-local storage
: tnamespace ( -- assoc )
    self dup thread-variables
    [ ] [ H{ } clone dup rot set-thread-variables ] ?if ;

: tget ( key -- value )
    self thread-variables at ;

: tset ( value key -- )
    tnamespace set-at ;

: tchange ( key quot -- )
    tnamespace change-at ; inline

: threads 41 getenv ;

threads global [ H{ } assoc-like ] change-at

: thread ( id -- thread ) threads at ;

: thread-registered? ( thread -- ? )
    thread-id threads key? ;

: check-unregistered
    dup thread-registered?
    [ "Thread already stopped" throw ] when ;

: check-registered
    dup thread-registered?
    [ "Thread is not running" throw ] unless ;

<PRIVATE

: register-thread ( thread -- )
    check-unregistered dup thread-id threads set-at ;

: unregister-thread ( thread -- )
    check-registered thread-id threads delete-at ;

: set-self ( thread -- ) 40 setenv ; inline

PRIVATE>

: <thread> ( quot name -- thread )
    \ thread counter <box> [ ] {
        set-thread-quot
        set-thread-name
        set-thread-id
        set-thread-continuation
        set-thread-exit-handler
    } \ thread construct ;

: run-queue 42 getenv ;

: sleep-queue 43 getenv ;

: resume ( thread -- )
    f over set-thread-state
    check-registered run-queue push-front ;

: resume-now ( thread -- )
    f over set-thread-state
    check-registered run-queue push-back ;

: resume-with ( obj thread -- )
    f over set-thread-state
    check-registered 2array run-queue push-front ;

: sleep-time ( -- ms/f )
    {
        { [ run-queue dlist-empty? not ] [ 0 ] }
        { [ sleep-queue heap-empty? ] [ f ] }
        { [ t ] [ sleep-queue heap-peek nip millis [-] ] }
    } cond ;

<PRIVATE

: schedule-sleep ( thread ms -- )
    >r check-registered dup r> sleep-queue heap-push*
    swap set-thread-sleep-entry ;

: expire-sleep? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip millis <= ] if ;

: expire-sleep ( thread -- )
    f over set-thread-sleep-entry resume ;

: expire-sleep-loop ( -- )
    sleep-queue
    [ dup expire-sleep? ]
    [ dup heap-pop drop expire-sleep ]
    [ ] while
    drop ;

: next ( -- * )
    expire-sleep-loop
    run-queue dup dlist-empty? [
        ! We should never be in a state where the only threads
        ! are sleeping; the I/O wait thread is always runnable.
        ! However, if it dies, we handle this case
        ! semi-gracefully.
        !
        ! And if sleep-time outputs f, there are no sleeping
        ! threads either... so WTF.
        drop sleep-time [ die 0 ] unless* (sleep) next
    ] [
        pop-back
        dup array? [ first2 ] [ f swap ] if dup set-self
        f over set-thread-state
        thread-continuation box>
        continue-with
    ] if ;

PRIVATE>

: stop ( -- )
    self dup thread-exit-handler call
    unregister-thread next ;

: suspend ( quot state -- obj )
    [
        self thread-continuation >box
        self set-thread-state
        self swap call next
    ] callcc1 2nip ; inline

: yield ( -- ) [ resume ] f suspend drop ;

GENERIC: sleep-until ( time/f -- )

M: integer sleep-until
    [ schedule-sleep ] curry "sleep" suspend drop ;

M: f sleep-until
    drop [ drop ] "interrupt" suspend drop ;

GENERIC: sleep ( ms -- )

M: real sleep
    millis + >integer sleep-until ;

: interrupt ( thread -- )
    dup thread-state [
        dup thread-sleep-entry [ sleep-queue heap-delete ] when*
        f over set-thread-sleep-entry
        dup resume
    ] when drop ;

: (spawn) ( thread -- )
    [
        resume-now [
            dup set-self
            dup register-thread
            V{ } set-catchstack
            { } set-retainstack
            >r { } set-datastack r>
            thread-quot [ call stop ] call-clear
        ] 1 (throw)
    ] "spawn" suspend 2drop ;

: spawn ( quot name -- thread )
    <thread> [ (spawn) ] keep ;

: spawn-server ( quot name -- thread )
    >r [ [ ] [ ] while ] curry r> spawn ;

: in-thread ( quot -- )
    >r datastack namestack r>
    [ >r set-namestack set-datastack r> call ] 3curry
    "Thread" spawn drop ;

GENERIC: error-in-thread ( error thread -- )

<PRIVATE

: init-threads ( -- )
    H{ } clone 41 setenv
    <dlist> 42 setenv
    <min-heap> 43 setenv
    initial-thread global
    [ drop f "Initial" <thread> ] cache
    <box> over set-thread-continuation
    f over set-thread-state
    dup register-thread
    set-self ;

[ self error-in-thread stop ]
thread-error-hook set-global

PRIVATE>

[ init-threads ] "threads" add-init-hook
