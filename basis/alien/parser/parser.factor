! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays assocs effects grouping kernel
parser sequences splitting words fry locals lexer namespaces
summary ;
IN: alien.parser

ERROR: invalid-c-name name ;

M: invalid-c-name summary
    drop "The C pointer asterisk must be part of the type string." ;

: check-c-name ( string -- string )
    dup [ CHAR: * = ] any? [ invalid-c-name ] when ;

: parse-arglist ( parameters return -- types effect )
    [ 2 group unzip [ "," ?tail drop check-c-name ] map ]
    [ [ { } ] [ 1array ] if-void ]
    bi* <effect> ;

: function-quot ( return library function types -- quot )
    '[ _ _ _ _ alien-invoke ] ;

:: make-function ( return library function parameters -- word quot effect )
    function check-c-name create-in dup reset-generic
    return library function
    parameters return parse-arglist [ function-quot ] dip ;

: (FUNCTION:) ( -- word quot effect )
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter
    make-function ;

: define-function ( return library function parameters -- )
    make-function define-declared ;
