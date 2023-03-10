USING: editors io.standard-paths kernel make math.parser
namespaces sequences ;
IN: editors.notepad++

SINGLETON: notepad++

editor-class [ notepad++ ] initialize

: notepad++-path ( -- path )
    \ notepad++-path get [
        { "notepad++" } "notepad++.exe" find-in-applications
        [ "notepad++.exe" ] unless*
    ] unless* ;

M: notepad++ editor-command
    [
        notepad++-path ,
        number>string "-n" prepend , ,
    ] { } make ;
