! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make assocs io sequences
sorting continuations math math.parser ;
IN: compiler.errors

SYMBOL: +error+
SYMBOL: +warning+
SYMBOL: +linkage+

GENERIC: compiler-error-type ( error -- ? )

M: object compiler-error-type drop +error+ ;

GENERIC# compiler-error. 1 ( error word -- )

SYMBOL: compiler-errors

SYMBOL: with-compiler-errors?

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ >r nip compiler-error-type r> eq? ] curry
    assoc-filter ;

: compiler-errors. ( type -- )
    errors-of-type >alist sort-keys
    [ swap compiler-error. ] assoc-each ;

: (compiler-report) ( what type word -- )
    over errors-of-type assoc-empty? [ 3drop ] [
        [
            ":" %
            %
            " - print " %
            errors-of-type assoc-size #
            " " %
            %
            "." %
        ] "" make print
    ] if ;

: compiler-report ( -- )
    "semantic errors" +error+ "errors" (compiler-report)
    "semantic warnings" +warning+ "warnings" (compiler-report)
    "linkage errors" +linkage+ "linkage" (compiler-report) ;

: :errors ( -- ) +error+ compiler-errors. ;

: :warnings ( -- ) +warning+ compiler-errors. ;

: :linkage ( -- ) +linkage+ compiler-errors. ;

: compiler-error ( error word -- )
    with-compiler-errors? get [
        compiler-errors get pick
        [ set-at ] [ delete-at drop ] if
    ] [ 2drop ] if ;

: with-compiler-errors ( quot -- )
    with-compiler-errors? get "quiet" get or [ call ] [
        [
            with-compiler-errors? on
            V{ } clone compiler-errors set-global
            [ compiler-report ] [ ] cleanup
        ] with-scope
    ] if ; inline
