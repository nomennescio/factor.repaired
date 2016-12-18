! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: io.pathnames kernel present system webbrowser windows.shell32
windows.user32 ;
IN: webbrowser.windows

M: windows open-item ( item -- )
    absolute-path [ f "open" ] dip present f f
    SW_SHOWNORMAL ShellExecute drop ;
