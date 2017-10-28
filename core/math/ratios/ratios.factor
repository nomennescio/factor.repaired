! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ;
IN: math.ratios

: 2fraction>parts ( a/b c/d -- a c b d )
    [ fraction>parts ] bi@ swapd ; inline

<PRIVATE

: parts>fraction ( a b -- a/b )
    dup 1 number= [ drop ] [ ratio boa ] if ; inline

: (scale) ( a b c d -- a*d b*c )
    [ * swap ] dip * swap ; inline

: scale ( a/b c/d -- a*d b*c )
    2fraction>parts (scale) ; inline

: scale+d ( a/b c/d -- a*d b*c b*d )
    2fraction>parts [ (scale) ] 2keep * ; inline

PRIVATE>

ERROR: division-by-zero x ;

M: integer /
    [
        division-by-zero
    ] [
        dup 0 < [ [ neg ] bi@ ] when
        2dup simple-gcd [ /i ] curry bi@ parts>fraction
    ] if-zero ;

M: integer recip
    1 swap [
        division-by-zero
    ] [
        dup 0 < [ [ neg ] bi@ ] when parts>fraction
    ] if-zero ;

M: ratio recip
    fraction>parts swap dup 0 < [ [ neg ] bi@ ] when parts>fraction ;

M: ratio hashcode*
    nip fraction>parts [ hashcode ] bi@ bitxor ;

M: ratio equal?
    over ratio? [
        2fraction>parts = [ = ] [ 2drop f ] if
    ] [ 2drop f ] if ;

M: ratio number=
    2fraction>parts number= [ number= ] [ 2drop f ] if ;

M: ratio >fixnum fraction>parts /i >fixnum ;
M: ratio >bignum fraction>parts /i >bignum ;
M: ratio >float fraction>parts /f ;

M: ratio numerator numerator>> ; inline
M: ratio denominator denominator>> ; inline
M: ratio fraction>parts [ numerator ] [ denominator ] bi ; inline

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + scale+d [ + ] [ / ] bi* ;
M: ratio - scale+d [ - ] [ / ] bi* ;
M: ratio * 2fraction>parts [ * ] 2bi@ / ;
M: ratio / scale / ;
M: ratio /i scale /i ;
M: ratio /f scale /f ;
M: ratio mod scale+d [ mod ] [ / ] bi* ;
M: ratio /mod scale+d [ /mod ] [ / ] bi* ;
M: ratio abs dup neg? [ fraction>parts [ neg ] dip parts>fraction ] when ;
M: ratio neg? numerator neg? ; inline
