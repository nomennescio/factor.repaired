USING: kernel system windows.kernel32 io.backend.windows
io.files.windows io.ports windows destructors environment
io.files.unique ;
IN: io.files.unique.windows

M: windows touch-unique-file ( path -- )
    GENERIC_WRITE CREATE_NEW 0 open-file dispose ;

M: windows temporary-path ( -- path )
    "TEMP" os-env ;
