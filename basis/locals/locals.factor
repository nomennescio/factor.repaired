! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer macros memoize parser sequences vocabs
vocabs.loader words kernel namespaces locals.parser locals.types
locals.errors ;
IN: locals

SYNTAX: :>
    scan locals get [ :>-outside-lambda-error ] unless*
    [ make-local ] bind <def> suffix! ;

SYNTAX: [| parse-lambda append! ;

SYNTAX: [let parse-let append! ;

SYNTAX: [let* parse-let* append! ;

SYNTAX: [wlet parse-wlet append! ;

SYNTAX: :: (::) define-declared ;

SYNTAX: M:: (M::) define ;

SYNTAX: MACRO:: (::) define-macro ;

SYNTAX: MEMO:: (::) define-memoized ;

{
    "locals.macros"
    "locals.fry"
} [ require ] each

"prettyprint" vocab [
    "locals.definitions" require
    "locals.prettyprint" require
] when
