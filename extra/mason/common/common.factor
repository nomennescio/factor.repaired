! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences splitting system accessors
math.functions make io io.files io.launcher io.encodings.utf8
prettyprint combinators.short-circuit parser combinators
calendar calendar.format arrays mason.config ;
IN: mason.common

: short-running-process ( command -- )
    #! Give network operations at most 15 minutes to complete.
    <process>
        swap >>command
        15 minutes >>timeout
    try-process ;

: eval-file ( file -- obj )
    dup utf8 file-lines parse-fresh
    [ "Empty file: " swap append throw ] [ nip first ] if-empty ;

: cat ( file -- ) utf8 file-contents print ;

: cat-n ( file n -- ) [ utf8 file-lines ] dip short tail* [ print ] each ;

: to-file ( object file -- ) utf8 [ . ] with-file-writer ;

: datestamp ( timestamp -- string )
    [
        {
            [ year>> , ]
            [ month>> , ]
            [ day>> , ]
            [ hour>> , ]
            [ minute>> , ]
        } cleave
    ] { } make [ pad-00 ] map "-" join ;

: milli-seconds>time ( n -- string )
    millis>timestamp
    [ hour>> ] [ minute>> ] [ second>> floor ] tri 3array
    [ pad-00 ] map ":" join ;

SYMBOL: stamp

: builds/factor ( -- path ) builds-dir get "factor" append-path ;
: build-dir ( -- path ) builds-dir get stamp get append-path ;

: prepare-build-machine ( -- )
    builds-dir get make-directories
    builds-dir get
    [ { "git" "clone" "git://factorcode.org/git/factor.git" } try-process ]
    with-directory ;

: git-id ( -- id )
    { "git" "show" } utf8 <process-reader> [ readln ] with-input-stream
    " " split second ;

: ?prepare-build-machine ( -- )
    builds/factor exists? [ prepare-build-machine ] unless ;

: load-everything-vocabs-file "load-everything-vocabs" ;
: load-everything-errors-file "load-everything-errors" ;

: test-all-vocabs-file "test-all-vocabs" ;
: test-all-errors-file "test-all-errors" ;

: help-lint-vocabs-file "help-lint-vocabs" ;
: help-lint-errors-file "help-lint-errors" ;

: boot-time-file "boot-time" ;
: load-time-file "load-time" ;
: test-time-file "test-time" ;
: help-lint-time-file "help-lint-time" ;
: benchmark-time-file "benchmark-time" ;

: benchmarks-file "benchmarks" ;

SYMBOL: status

SYMBOL: status-error ! didn't bootstrap, or crashed
SYMBOL: status-dirty ! bootstrapped but not all tests passed
SYMBOL: status-clean ! everything good
