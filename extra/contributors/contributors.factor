! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.launcher io.styles io.encodings.ascii
prettyprint io hashtables kernel sequences assocs system sorting
math.parser sets ;
IN: contributors

: changelog ( -- authors )
    image parent-directory [
        "git log --pretty=format:%an" ascii <process-reader> lines
    ] with-directory ;

: patch-counts ( authors -- assoc )
    dup prune
    [ dup rot [ = ] with count ] with
    { } map>assoc ;

: contributors ( -- )
    changelog patch-counts
    sort-values <reversed>
    simple-table. ;

MAIN: contributors
