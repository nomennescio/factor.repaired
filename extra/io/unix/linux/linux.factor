! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.backend io.monitor io.monitor.private io.files
io.buffers io.nonblocking io.unix.backend io.unix.select
io.unix.launcher unix.linux.inotify assocs namespaces threads
continuations init math alien.c-types alien ;
IN: io.unix.linux

TUPLE: linux-io ;

INSTANCE: linux-io unix-io

TUPLE: linux-monitor path wd callback ;

: <linux-monitor> ( path wd -- monitor )
    f (monitor) {
        set-linux-monitor-path
        set-linux-monitor-wd
        set-delegate
    } linux-monitor construct ;

TUPLE: inotify watches ;

: wd>path ( wd -- path )
    inotify get-global inotify-watches at linux-monitor-path ;

: <inotify> ( -- port )
    H{ } clone
    inotify_init dup io-error inotify <buffered-port>
    { set-inotify-watches set-delegate } inotify construct ;

: inotify-fd inotify get-global port-handle ;

: watches inotify get-global inotify-watches ;

: (add-watch) ( path mask -- wd )
    inotify-fd -rot inotify_add_watch dup io-error ;

: check-existing ( wd -- )
    watches key? [
        "Cannot open multiple monitors for the same file" throw
    ] when ;

: add-watch ( path mask -- monitor )
    dupd (add-watch)
    dup check-existing
    [ <linux-monitor> dup ] keep watches set-at ;

: remove-watch ( monitor -- )
    dup linux-monitor-wd watches delete-at
    linux-monitor-wd inotify-fd swap inotify_rm_watch io-error ;

M: linux-io <monitor> ( path recursive? -- monitor )
    drop IN_CHANGE_EVENTS add-watch ;

: notify-callback ( assoc monitor -- )
    linux-monitor-callback dup
    [ schedule-thread-with ] [ 2drop ] if ;

M: linux-io fill-queue ( monitor -- assoc )
    dup linux-monitor-callback [
        "Cannot wait for changes on the same file from multiple threads" throw
    ] when
    [ swap set-linux-monitor-callback stop ] callcc1
    swap check-monitor ;

M: linux-monitor dispose ( monitor -- )
    dup check-monitor
    t over set-monitor-closed?
    H{ } over notify-callback
    remove-watch ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;

: parse-action ( mask -- changed )
    [
        IN_CREATE +add-file+ ?flag
        IN_DELETE +remove-file+ ?flag
        IN_DELETE_SELF +remove-file+ ?flag
        IN_MODIFY +modify-file+ ?flag
        IN_ATTRIB +modify-file+ ?flag
        IN_MOVED_FROM +rename-file+ ?flag
        IN_MOVED_TO +rename-file+ ?flag
        IN_MOVE_SELF +rename-file+ ?flag
        drop
    ] { } make ;

: parse-file-notify ( buffer -- changed path )
    {
        inotify-event-wd
        inotify-event-name
        inotify-event-mask
    } get-slots
    parse-action -rot alien>char-string >r wd>path r> path+ ;

: events-exhausted? ( i buffer -- ? )
    buffer-fill >= ;

: inotify-event@ ( i buffer -- alien )
    buffer-ptr <displaced-alien> ;

: next-event ( i buffer -- i buffer )
    2dup inotify-event@
    inotify-event-len "inotify-event" heap-size +
    swap >r + r> ;

: parse-file-notifications ( i buffer -- )
    2dup events-exhausted? [ 2drop ] [
        2dup inotify-event@ parse-file-notify changed-file
        next-event parse-file-notifications
    ] if ;

: read-notifications ( port -- )
    dup refill drop
    0 over parse-file-notifications
    0 swap buffer-reset ;

TUPLE: inotify-task ;

: <inotify-task> ( port -- task )
    f inotify-task <input-task> ;

: init-inotify ( mx -- )
    <inotify>
    dup inotify set-global
    <inotify-task> swap register-io-task ;

M: inotify-task do-io-task ( task -- )
    io-task-port read-notifications f ;

M: linux-io init-io ( -- )
    <select-mx> mx set-global ; ! init-inotify ;

T{ linux-io } set-io-backend

[ start-wait-thread ] "io.unix.linux" add-init-hook