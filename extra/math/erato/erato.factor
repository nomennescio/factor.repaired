! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: bit-arrays kernel lists.lazy math math.functions math.primes.list
       math.ranges sequences accessors ;
IN: math.erato

<PRIVATE

TUPLE: erato limit bits latest ;

: ind ( n -- i )
  2/ 1- ; inline

: is-prime ( n limit -- bool )
  [ ind ] [ bits>> ] bi* nth ; inline

: indices ( n erato -- range )
  limit>> ind over 3 * ind swap rot <range> ;

: mark-multiples ( n erato -- )
  over sq over limit>> <=
  [ [ indices ] keep bits>> [ f -rot set-nth ] curry each ] [ 2drop ] if ;

: <erato> ( n -- erato )
  dup ind 1+ <bit-array> 1 over set-bits erato boa ;

: next-prime ( erato -- prime/f )
  [ 2 + ] change-latest [ latest>> ] keep
  2dup limit>> <=
  [
    2dup is-prime [ dupd mark-multiples ] [ nip next-prime ] if
  ] [
    2drop f
  ] if ;

PRIVATE>

: lerato ( n -- lazy-list )
  dup 1000003 < [
    0 primes-under-million seq>list swap [ <= ] curry lwhile
  ] [
    <erato> 2 [ drop next-prime ] with lfrom-by [ ] lwhile
  ] if ;
