! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit kernel locals math
math.functions math.ranges memoize sequences ;

IN: math.factorials

MEMO: factorial ( n -- n! )
    dup 1 > [ [1,b] product ] [ drop 1 ] if ;

:: factorial/ ( n k -- n!/k! )
    { [ k 0 < ] [ n 0 < ] [ k n > ] } 0||
    [ 0 ] [ k n (a,b] product ] if ;

: rising-factorial ( x n -- x(n) )
    {
        { 1 [ ] }
        { 0 [ drop 0 ] }
        [
            dup 0 < [ neg [ + ] keep t ] [ f ] if
            [ dupd + [a,b) product ] dip
            [ recip ] when
        ]
    } case ;

ALIAS: pochhammer rising-factorial

: falling-factorial ( x n -- (x)n )
    {
        { 1 [ ] }
        { 0 [ drop 0 ] }
        [
            dup 0 < [ neg [ + ] keep t ] [ f ] if
            [ dupd - swap (a,b] product ] dip
            [ recip ] when
        ]
    } case ;

: factorial-power ( x n h -- (x)n(h) )
    {
        { 1 [ falling-factorial ] }
        { 0 [ ^ ] }
        [
            over 0 < [
                [ [ nip + ] [ swap neg * + ] 3bi ] keep
                <range> product recip
            ] [
                neg [ [ dupd 1 - ] [ * ] bi* + ] keep
                <range> product
            ] if
        ]
    } case ;
