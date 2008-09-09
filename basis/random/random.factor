! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math namespaces sequences
io.backend io.binary combinators system vocabs.loader
summary math.bitwise ;
IN: random

SYMBOL: system-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC: seed-random ( tuple seed -- )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- byte-array )

M: object random-bytes* ( n tuple -- byte-array )
    swap [ drop random-32* ] with map >c-uint-array ;

M: object random-32* ( tuple -- r ) 4 random-bytes* le> ;

ERROR: no-random-number-generator ;

M: no-random-number-generator summary
    drop "Random number generator is not defined." ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;

: random-bytes ( n -- byte-array )
    [
        dup 3 mask zero? [ 1+ ] unless
        random-generator get random-bytes*
    ] keep head ;

: random ( seq -- elt )
    [ f ] [
        [
            length [
                log2 8 + 8 /i
                random-bytes byte-array>bignum
            ] keep wrap
        ] keep nth
    ] if-empty ;

: delete-random ( seq -- elt )
    [ length random ] keep [ nth ] 2keep delete-nth ;

: random-bits ( n -- r ) 2^ random ;

: with-random ( tuple quot -- )
    random-generator swap with-variable ; inline

: with-system-random ( quot -- )
    system-random-generator get swap with-random ; inline

: with-secure-random ( quot -- )
    secure-random-generator get swap with-random ; inline
