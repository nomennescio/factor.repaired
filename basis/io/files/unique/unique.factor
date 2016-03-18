! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators continuations fry io.backend io.directories
io.directories.hierarchy io.pathnames kernel locals namespaces
random.data sequences system vocabs ;
IN: io.files.unique

<PRIVATE

HOOK: (touch-unique-file) io-backend ( path -- )

PRIVATE>

: touch-unique-file ( path -- )
    normalize-path (touch-unique-file) ;

SYMBOL: unique-length
SYMBOL: unique-retries

10 unique-length set-global
10 unique-retries set-global

<PRIVATE

: random-file-name ( -- string )
    unique-length get random-string ;

: retry ( quot: ( -- ? ) n -- )
    iota swap [ drop ] prepose attempt-all ; inline

PRIVATE>

: unique-file ( prefix suffix -- path )
    '[
        current-directory get
        _ _ random-file-name glue append-path
        dup touch-unique-file
    ] unique-retries get retry ;

:: cleanup-unique-file ( prefix suffix quot: ( path -- ) -- )
    prefix suffix unique-file :> path
    [ path quot call ] [ path delete-file ] [ ] cleanup ; inline

: unique-directory ( -- path )
    [
        current-directory get
        random-file-name append-path
        dup make-directory
    ] unique-retries get retry ;

:: with-unique-directory ( quot -- path )
    unique-directory :> path
    path quot with-directory
    path ; inline

:: cleanup-unique-directory ( quot -- )
    unique-directory :> path
    [ path quot with-directory ]
    [ path delete-tree ] [ ] cleanup ; inline

{
    { [ os unix? ] [ "io.files.unique.unix" ] }
    { [ os windows? ] [ "io.files.unique.windows" ] }
} cond require
