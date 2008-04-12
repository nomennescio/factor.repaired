! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types libc destructors locals
kernel math assocs namespaces continuations sequences hashtables
sorting arrays combinators math.bitfields strings system
io.windows io.windows.nt.backend io.monitors io.nonblocking
io.buffers io.files io.timeouts io
windows windows.kernel32 windows.types ;
IN: io.windows.nt.monitors

: open-directory ( path -- handle )
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    { FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED } flags
    f
    CreateFile
    dup invalid-handle?
    dup close-later
    dup add-completion
    f <win32-file> ;

TUPLE: win32-monitor < monitor port path recursive ;

: begin-reading-changes ( port -- overlapped )
    {
        [ handle>> handle>> ]
        [ buffer>> buffer-ptr ]
        [ buffer>> buffer-size ]
        [ recursive>> 1 0 ? ]
    } cleave
    FILE_NOTIFY_CHANGE_ALL
    0 <uint>
    (make-overlapped)
    [ f ReadDirectoryChangesW win32-error=0/f ] keep ;

: read-changes ( port -- bytes )
    [
        [
            dup begin-reading-changes
            swap [ save-callback ] 2keep
            check-closed ! we may have closed it...
            get-overlapped-result
        ] with-timeout
    ] with-destructors ;

: parse-action ( action -- changed )
    {
        { FILE_ACTION_ADDED [ +add-file+ ] }
        { FILE_ACTION_REMOVED [ +remove-file+ ] }
        { FILE_ACTION_MODIFIED [ +modify-file+ ] }
        { FILE_ACTION_RENAMED_OLD_NAME [ +rename-file+ ] }
        { FILE_ACTION_RENAMED_NEW_NAME [ +rename-file+ ] }
        [ drop +modify-file+ ]
    } case ;

: memory>u16-string ( alien len -- string )
    [ memory>byte-array ] [ 2/ ] bi c-ushort-array> >string ;

: parse-notify-record ( buffer -- changed path )
    [ FILE_NOTIFY_INFORMATION-Action parse-action ]
    [ FILE_NOTIFY_INFORMATION-FileName ]
    [ FILE_NOTIFY_INFORMATION-FileNameLength ]
    tri memory>u16-string ;

: file-notify-records ( buffer -- seq )
    [ dup FILE_NOTIFY_INFORMATION-NextEntryOffset 0 > ]
    [ [ [ FILE_NOTIFY_INFORMATION-NextEntryOffset ] keep <displaced-alien> ] keep ]
    [ ] unfold nip ;

: parse-notify-records ( monitor buffer -- )
    file-notify-records
    [ parse-notify-record rot queue-change ] with each ;

: fill-queue ( monitor -- )
    dup port>> [ buffer>> buffer-ptr ] [ read-changes zero? ] bi
    [ 2dup parse-notify-records ] unless 2drop ;

: fill-queue-thread ( monitor -- )
    dup fill-queue fill-queue ;

M:: winnt (monitor) ( path recursive? mailbox -- monitor )
    [
        path mailbox win32-monitor construct-monitor
            path open-directory <buffered-port> >>port
            recursive? >>recursive
        dup port>> [ fill-queue-thread ] curry spawn drop
    ] with-destructors ;

M: win32-monitor dispose
    port>> dispose ;
