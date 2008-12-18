USING: editors.gvim io.files kernel namespaces sequences
windows.shell32 io.directories.search.windows system
io.pathnames ;
IN: editors.gvim.windows

M: windows gvim-path
    \ gvim-path get-global [
        "vim" t [ "gvim.exe" tail? ] find-in-program-files
    ] unless* ;
