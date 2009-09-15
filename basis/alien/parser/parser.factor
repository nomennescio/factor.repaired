! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays assocs effects grouping kernel
parser sequences splitting words fry locals lexer namespaces
summary math ;
IN: alien.parser

: scan-c-type ( -- c-type )
    scan dup "{" =
    [ drop \ } parse-until >array ]
    [ parse-c-type ] if ; 

: normalize-c-arg ( type name -- type' name' )
    [ length ]
    [
        [ CHAR: * = ] trim-head
        [ length - CHAR: * <array> append ] keep
    ] bi
    [ parse-c-type ] dip ;

: parse-arglist ( parameters return -- types effect )
    [
        2 group [ first2 normalize-c-arg 2array ] map
        unzip [ "," ?tail drop ] map
    ]
    [ [ { } ] [ 1array ] if-void ]
    bi* <effect> ;

: function-quot ( return library function types -- quot )
    '[ _ _ _ _ alien-invoke ] ;

:: make-function ( return! library function! parameters -- word quot effect )
    return function normalize-c-arg function! return!
    function create-in dup reset-generic
    return library function
    parameters return parse-arglist [ function-quot ] dip ;

: (FUNCTION:) ( -- word quot effect )
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter
    make-function ;

: define-function ( return library function parameters -- )
    make-function define-declared ;
