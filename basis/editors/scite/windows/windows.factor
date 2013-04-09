! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.launcher kernel namespaces io.directories.search.windows
math math.parser editors sequences system unicode.case ;
IN: editors.scite.windows

M: windows scite-path ( -- path )
    \ scite-path get-global [
        "Scintilla Text Editor"
        [ >lower "scite.exe" tail? ] find-in-program-files

        [
            "SciTE Source Code Editor"
            [ >lower "scite.exe" tail? ] find-in-program-files
        ] unless*
        [ "scite.exe" ] unless*
    ] unless* ;

