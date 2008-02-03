! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types destructors io.windows
io.windows.nt.backend kernel math windows windows.kernel32
windows.types libc assocs alien namespaces continuations
io.monitor io.monitor.private io.nonblocking io.buffers io.files
io sequences hashtables sorting arrays combinators ;
IN: io.windows.nt.monitor

: open-directory ( path -- handle )
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED bitor
    f
    CreateFile
    dup invalid-handle?
    dup close-later
    dup add-completion
    f <win32-file> ;

TUPLE: win32-monitor path recursive? ;

: <win32-monitor> ( path recursive? port -- monitor )
    (monitor) {
        set-win32-monitor-path
        set-win32-monitor-recursive?
        set-delegate
    } win32-monitor construct ;

M: windows-nt-io <monitor> ( path recursive? -- monitor )
    [
        over open-directory win32-monitor <buffered-port>
        <win32-monitor>
    ] with-destructors ;

: begin-reading-changes ( monitor -- overlapped )
    dup port-handle win32-file-handle
    over buffer-ptr
    pick buffer-size
    roll win32-monitor-recursive? 1 0 ?
    FILE_NOTIFY_CHANGE_ALL
    0 <uint>
    (make-overlapped)
    [ f ReadDirectoryChangesW win32-error=0/f ] keep ;

: read-changes ( monitor -- bytes )
    [
        [
            dup begin-reading-changes
            swap [ save-callback ] 2keep
            dup check-monitor ! we may have closed it...
            get-overlapped-result
        ] with-port-timeout
    ] with-destructors ;

: parse-action ( action -- changed )
    {
        { [ dup FILE_ACTION_ADDED = ] [ +add-file+ ] }
        { [ dup FILE_ACTION_REMOVED = ] [ +remove-file+ ] }
        { [ dup FILE_ACTION_MODIFIED = ] [ +modify-file+ ] }
        { [ dup FILE_ACTION_RENAMED_OLD_NAME = ] [ +rename-file+ ] }
        { [ dup FILE_ACTION_RENAMED_NEW_NAME = ] [ +rename-file+ ] }
        { [ t ] [ +modify-file+ ] }
    } cond nip ;

: parse-file-notify ( directory buffer -- changed path )
    {
        FILE_NOTIFY_INFORMATION-FileName
        FILE_NOTIFY_INFORMATION-FileNameLength
        FILE_NOTIFY_INFORMATION-Action
    } get-slots parse-action 1array -rot
    memory>u16-string path+ ;

: (changed-files) ( directory buffer -- )
    2dup parse-file-notify changed-file
    dup FILE_NOTIFY_INFORMATION-NextEntryOffset dup zero?
    [ 3drop ] [ swap <displaced-alien> (changed-files) ] if ;

M: windows-nt-io fill-queue ( monitor -- assoc )
    dup win32-monitor-path over buffer-ptr rot read-changes
    [ zero? [ 2drop ] [ (changed-files) ] if ] H{ } make-assoc ;
