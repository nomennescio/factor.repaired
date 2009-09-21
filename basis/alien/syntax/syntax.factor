! Copyright (C) 2005, 2009 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays alien alien.c-types alien.structs
alien.arrays alien.strings kernel math namespaces parser
sequences words quotations math.parser splitting grouping
effects assocs combinators lexer strings.parser alien.parser 
fry vocabs.parser words.constant alien.libraries ;
IN: alien.syntax

SYNTAX: DLL" lexer get skip-blank parse-string dlopen parsed ;

SYNTAX: ALIEN: 16 scan-base <alien> parsed ;

SYNTAX: BAD-ALIEN <bad-alien> parsed ;

SYNTAX: LIBRARY: scan "c-library" set ;

SYNTAX: FUNCTION:
    (FUNCTION:) define-declared ;

SYNTAX: CALLBACK:
    "cdecl" (CALLBACK:) define-inline ;

SYNTAX: STDCALL-CALLBACK:
    "stdcall" (CALLBACK:) define-inline ;

SYNTAX: TYPEDEF:
    scan-c-type CREATE-C-TYPE typedef ;

SYNTAX: C-STRUCT:
    scan current-vocab parse-definition define-struct ; deprecated

SYNTAX: C-UNION:
    scan parse-definition define-union ; deprecated

SYNTAX: C-ENUM:
    ";" parse-tokens
    [ [ create-in ] dip define-constant ] each-index ;

SYNTAX: C-TYPE:
    "Primitive C type definition not supported" throw ;

ERROR: no-such-symbol name library ;

: address-of ( name library -- value )
    2dup load-library dlsym [ 2nip ] [ no-such-symbol ] if* ;

SYNTAX: &:
    scan "c-library" get '[ _ _ address-of ] over push-all ;
