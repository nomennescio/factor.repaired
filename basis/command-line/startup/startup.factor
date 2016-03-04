! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line eval io io.pathnames kernel namespaces
sequences system vocabs.loader ;
IN: command-line.startup

: cli-usage ( -- )
"Usage: " write vm-path file-name write " [Factor arguments] [script] [script arguments]

Common arguments:
    -help               print this message and exit
    -i=<image>          load Factor image file <image> (default " write vm-path file-stem write ".image)
    -run=<vocab>        run the MAIN: entry point of <vocab>
        -run=listener   run terminal listener
        -run=ui.tools   run Factor development UI
    -e=<code>           evaluate <code>
    -no-user-init       suppress loading of .factor-rc
    -datastack=<int>    datastack size in KB
    -retainstack=<int>  retainstack size in KB
    -callstack=<int>    callstack size in KB
    -callbacks=<int>    callback heap size in KB
    -young=<int>        young gc generation 0 size in MB
    -aging=<int>        aging gc generation 1 size in MB
    -tenured=<int>      tenured gc generation 2 size in MB
    -codeheap=<int>     codeheap size in MB
    -pic=<int>          max pic size
    -fep                enter fep mode immediately
    -nosignals          turn off OS signal handling
    -console            open console if possible

Enter
    \"command-line\" help
from within Factor for more information.

" write ;

: help? ( -- ? )
    "help" get "-help" get or "h" get or
    os windows? [ script get "/?" = ] [ f ] if or ;

: command-line-startup ( -- )
    (command-line) parse-command-line
    help? [ cli-usage ] [
        load-vocab-roots
        run-user-init
        "e" get script get or [
            "e" get [ eval( -- ) ] when*
            script get [ run-script ] when*
        ] [
            "run" get run
        ] if
    ] if

    output-stream get [ stream-flush ] when*
    0 exit ;
