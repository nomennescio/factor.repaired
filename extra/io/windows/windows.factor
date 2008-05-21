! Copyright (C) 2004, 2008 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend
io.buffers io.files io.ports io.sockets io.binary
io.sockets windows.errors strings
kernel math namespaces sequences windows windows.kernel32
windows.shell32 windows.types windows.winsock splitting
continuations math.bitfields system accessors ;
IN: io.windows

TUPLE: win32-handle handle disposed ;

: new-win32-handle ( handle class -- win32-handle )
    new swap >>handle ;

: <win32-handle> ( handle -- win32-handle )
    win32-handle new-win32-handle ;

M: win32-handle dispose* ( handle -- )
    handle>> CloseHandle drop ;

TUPLE: win32-file < win32-handle ptr ;

: <win32-file> ( handle -- win32-file )
    win32-file new-win32-handle ;

M: win32-file dispose*
    [ cancel-io ] [ call-next-method ] bi ;

HOOK: CreateFile-flags io-backend ( DWORD -- DWORD )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

: opened-file ( handle -- win32-file )
    dup invalid-handle?
    <win32-file> |dispose
    dup add-completion ;

: share-mode ( -- fixnum )
    {
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    } flags ; foldable

: default-security-attributes ( -- obj )
    "SECURITY_ATTRIBUTES" <c-object>
    "SECURITY_ATTRIBUTES" heap-size
    over set-SECURITY_ATTRIBUTES-nLength ;

: security-attributes-inherit ( -- obj )
    default-security-attributes
    TRUE over set-SECURITY_ATTRIBUTES-bInheritHandle ; foldable
