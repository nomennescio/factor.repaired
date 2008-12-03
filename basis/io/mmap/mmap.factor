! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors io.files io.backend kernel
quotations system alien alien.accessors accessors system
vocabs.loader combinators alien.c-types ;
IN: io.mmap

TUPLE: mapped-file address handle length disposed ;

HOOK: (mapped-file) io-backend ( path length -- address handle )

: <mapped-file> ( path -- mmap )
    [ normalize-path ] [ file-info size>> ] bi [ (mapped-file) ] keep
    f mapped-file boa ;

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose* ( mmap -- ) close-mapped-file ;

: with-mapped-file ( path quot -- )
    [ <mapped-file> ] dip with-disposal ; inline

{
    { [ os unix? ] [ "io.unix.mmap" require ] }
    { [ os winnt? ] [ "io.windows.mmap" require ] }
} cond
