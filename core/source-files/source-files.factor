! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math namespaces
sequences strings vectors words quotations io
combinators sorting splitting math.parser effects continuations
io.files checksums checksums.crc32 vocabs hashtables graphs
compiler.units io.encodings.utf8 accessors ;
IN: source-files

SYMBOL: source-files

TUPLE: source-file
path
checksum
uses definitions ;

: record-checksum ( lines source-file -- )
    [ crc32 checksum-lines ] dip (>>checksum) ;

: (xref-source) ( source-file -- pathname uses )
    [ path>> <pathname> ]
    [ uses>> [ crossref? ] filter ] bi ;

: xref-source ( source-file -- )
    (xref-source) crossref get add-vertex ;

: unxref-source ( source-file -- )
    (xref-source) crossref get remove-vertex ;

: xref-sources ( -- )
    source-files get [ nip xref-source ] assoc-each ;

: record-form ( quot source-file -- )
    tuck unxref-source
    quot-uses keys >>uses
    xref-source ;

: record-definitions ( file -- )
    new-definitions get >>definitions drop ;

: <source-file> ( path -- source-file )
    \ source-file new
        swap >>path
        <definitions> >>definitions ;

ERROR: invalid-source-file-path path ;

: source-file ( path -- source-file )
    dup string? [ invalid-source-file-path ] unless
    source-files get [ <source-file> ] cache ;

: reset-checksums ( -- )
    source-files get [
        swap dup exists? [
            utf8 file-lines swap record-checksum
        ] [ 2drop ] if
    ] assoc-each ;

M: pathname where pathname-string 1 2array ;

: forget-source ( path -- )
    [
        source-file
        [ unxref-source ]
        [ definitions>> [ keys forget-all ] each ]
        bi
    ]
    [ source-files get delete-at ]
    bi ;

M: pathname forget*
    pathname-string forget-source ;

: rollback-source-file ( file -- )
    [
        new-definitions get [ assoc-union ] 2map
    ] change-definitions drop ;

SYMBOL: file

TUPLE: source-file-error file error ;

: <source-file-error> ( msg -- error )
    \ source-file-error new
        file get >>file
        swap >>error ;

: with-source-file ( name quot -- )
    #! Should be called from inside with-compilation-unit.
    [
        swap source-file
        dup file set
        definitions>> old-definitions set
        [
            file get rollback-source-file
            <source-file-error> rethrow
        ] recover
    ] with-scope ; inline
