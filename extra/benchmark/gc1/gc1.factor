! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math sequences kernel ;
IN: benchmark.gc1

: gc1 ( -- ) 10 [ 600000 [ >bignum 1 + ] map drop ] times ;

MAIN: gc1
