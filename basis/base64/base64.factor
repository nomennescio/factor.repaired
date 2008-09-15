! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences io.binary splitting grouping
accessors ;
IN: base64

<PRIVATE

: count-end ( seq quot -- n )
    trim-right-slice [ seq>> length ] [ to>> ] bi - ; inline

: ch>base64 ( ch -- ch )
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" nth ;

: base64>ch ( ch -- ch )
    {
        f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f
        f f f f f f f f f f 62 f f f 63 52 53 54 55 56 57 58 59 60 61 f f
        f 0 f f f 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
        22 23 24 25 f f f f f f 26 27 28 29 30 31 32 33 34 35 36 37 38 39
        40 41 42 43 44 45 46 47 48 49 50 51
    } nth ;

: encode3 ( seq -- seq )
    be> 4 <reversed> [
        -6 * shift HEX: 3f bitand ch>base64
    ] with B{ } map-as ;

: decode4 ( str -- str )
    0 [ base64>ch swap 6 shift bitor ] reduce 3 >be ;

: >base64-rem ( str -- str )
    [ 3 0 pad-right encode3 ] [ length 1+ ] bi
    head-slice 4 CHAR: = pad-right ;

PRIVATE>

: >base64 ( seq -- base64 )
    #! cut string into two pieces, convert 3 bytes at a time
    #! pad string with = when not enough bits
    dup length dup 3 mod - cut
    [ 3 <groups> [ encode3 ] map concat ]
    [ [ "" ] [ >base64-rem ] if-empty ]
    bi* append ;

: base64> ( base64 -- seq )
    #! input length must be a multiple of 4
    [ 4 <groups> [ decode4 ] map concat ]
    [ [ CHAR: = = ] count-end ]
    bi head* ;
