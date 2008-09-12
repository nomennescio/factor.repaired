USING: alien alien.c-types arrays destructors generic io.mmap
io.ports io.windows io.windows.files io.windows.privileges
kernel libc math math.bitwise namespaces quotations sequences
windows windows.advapi32 windows.kernel32 io.backend system
accessors locals ;
IN: io.windows.mmap

: create-file-mapping ( hFile lpAttributes flProtect dwMaximumSizeHigh dwMaximumSizeLow lpName -- HANDLE )
    CreateFileMapping [ win32-error=0/f ] keep <win32-handle> ;

: map-view-of-file ( hFileMappingObject dwDesiredAccess dwFileOffsetHigh dwFileOffsetLow dwNumberOfBytesToMap -- HANDLE )
    MapViewOfFile [ win32-error=0/f ] keep ;

:: mmap-open ( path length access-mode create-mode protect access -- handle handle address )
    [let | lo [ length HEX: ffffffff bitand ]
           hi [ length -32 shift HEX: ffffffff bitand ] |
        { "SeCreateGlobalPrivilege" "SeLockMemoryPrivilege" } [
            path access-mode create-mode 0 open-file |dispose
            dup handle>> f protect hi lo f create-file-mapping |dispose
            dup handle>> access 0 0 0 map-view-of-file
        ] with-privileges
    ] ;

TUPLE: win32-mapped-file file mapping ;

M: win32-mapped-file dispose
    [ file>> dispose ] [ mapping>> dispose ] bi ;

C: <win32-mapped-file> win32-mapped-file

M: windows (mapped-file)
    [
        { GENERIC_WRITE GENERIC_READ } flags
        OPEN_ALWAYS
        { PAGE_READWRITE SEC_COMMIT } flags
        FILE_MAP_ALL_ACCESS mmap-open
        -rot <win32-mapped-file>
    ] with-destructors ;

M: windows close-mapped-file ( mapped-file -- )
    [
        [ handle>> &dispose drop ]
        [ address>> UnmapViewOfFile win32-error=0/f ] bi
    ] with-destructors ;
