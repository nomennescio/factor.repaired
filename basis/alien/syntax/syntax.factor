! Copyright (C) 2005, 2008 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays alien alien.c-types alien.structs
alien.arrays alien.strings kernel math namespaces parser
sequences words quotations math.parser splitting grouping
effects assocs combinators lexer strings.parser alien.parser ;
IN: alien.syntax

: DLL" lexer get skip-blank parse-string dlopen parsed ; parsing

: ALIEN: scan string>number <alien> parsed ; parsing

: BAD-ALIEN <bad-alien> parsed ; parsing

: LIBRARY: scan "c-library" set ; parsing

: FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter
    define-function ; parsing

: TYPEDEF:
    scan scan typedef ; parsing

: C-STRUCT:
    scan in get parse-definition define-struct ; parsing

: C-UNION:
    scan parse-definition define-union ; parsing

: C-ENUM:
    ";" parse-tokens
    dup length
    [ [ create-in ] dip 1quotation define ] 2each ;
    parsing
