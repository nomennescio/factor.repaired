! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors io.backend kernel quotations
sequences system alien alien.accessors accessors
sequences.private system vocabs.loader combinators
specialized-arrays.direct functors alien.c-types
io.mmap.functor ;
IN: io.mmap

TUPLE: mapped-file address handle length disposed ;

M: mapped-file length dup check-disposed length>> ;

M: mapped-file nth-unsafe
    dup check-disposed address>> swap alien-unsigned-1 ;

M: mapped-file set-nth-unsafe
    dup check-disposed address>> swap set-alien-unsigned-1 ;

INSTANCE: mapped-file sequence

HOOK: (mapped-file) io-backend ( path length -- address handle )

: <mapped-file> ( path length -- mmap )
    [ [ normalize-path ] dip (mapped-file) ] keep
    f mapped-file boa ;

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose* ( mmap -- ) close-mapped-file ;

: with-mapped-file ( path length quot -- )
    [ <mapped-file> ] dip with-disposal ; inline

APPLY: mapped-array-functor primitive-types

{
    { [ os unix? ] [ "io.unix.mmap" require ] }
    { [ os winnt? ] [ "io.windows.mmap" require ] }
} cond
