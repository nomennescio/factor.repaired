! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit hints kernel math math.order
sequences strings ;
IN: ascii

: ascii? ( ch -- ? ) 0 127 between? ; inline
: blank? ( ch -- ? ) " \t\n\r" member? ; inline
: letter? ( ch -- ? ) char: a char: z between? ; inline
: LETTER? ( ch -- ? ) char: A char: Z between? ; inline
: digit? ( ch -- ? ) char: 0 char: 9 between? ; inline
: printable? ( ch -- ? ) char: \s char: ~ between? ; inline
: control? ( ch -- ? ) { [ 0 0x1F between? ] [ 0x7F = ] } 1|| ; inline
: quotable? ( ch -- ? ) { [ printable? ] [ "\"\\" member? not ] } 1&& ; inline
: Letter? ( ch -- ? ) { [ letter? ] [ LETTER? ] } 1|| ; inline
: alpha? ( ch -- ? ) { [ Letter? ] [ digit? ] } 1|| ; inline
: ch>lower ( ch -- lower ) dup LETTER? [ 0x20 + ] when ; inline
: >lower ( str -- lower ) [ ch>lower ] map ;
: ch>upper ( ch -- upper ) dup letter? [ 0x20 - ] when ; inline
: >upper ( str -- upper ) [ ch>upper ] map ;
: >words ( str -- words )
    [ dup empty? not ] [
        dup [ blank? ] find drop
        [ [ 1 ] when-zero cut-slice swap ]
        [ f 0 rot [ length ] keep <slice> ] if*
    ] produce nip ;
: capitalize ( str -- str' ) >lower 0 over [ ch>upper ] change-nth ;
: >title ( str -- title ) >words [ capitalize ] map concat ;

HINTS: >lower string ;
HINTS: >upper string ;
