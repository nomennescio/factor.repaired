! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order sequences
combinators.short-circuit ;
IN: ascii

: blank? ( ch -- ? ) " \t\n\r" member? ; inline

: letter? ( ch -- ? ) CHAR: a CHAR: z between? ; inline

: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ; inline

: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ; inline

: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ; inline

: control? ( ch -- ? )
    "\0\e\r\n\t\u000008\u00007f" member? ; inline

: quotable? ( ch -- ? )
    dup printable? [ "\"\\" member? not ] [ drop f ] if ; inline

: Letter? ( ch -- ? )
    [ [ letter? ] [ LETTER? ] ] 1|| ;

: alpha? ( ch -- ? )
    [ [ Letter? ] [ digit? ] ] 1|| ;
