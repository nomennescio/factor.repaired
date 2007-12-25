! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.functions math.ranges namespaces
    project-euler.common sequences ;
IN: project-euler.021

! http://projecteuler.net/index.php?section=problems&id=21

! DESCRIPTION
! -----------

! Let d(n) be defined as the sum of proper divisors of n (numbers less than n
! which divide evenly into n).

! If d(a) = b and d(b) = a, where a != b, then a and b are an amicable pair and
! each of a and b are called amicable numbers.

! For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20, 22, 44,
! 55 and 110; therefore d(220) = 284. The proper divisors of 284 are 1, 2, 4,
! 71 and 142; so d(284) = 220.

! Evaluate the sum of all the amicable numbers under 10000.


! SOLUTION
! --------

<PRIVATE

: d ( n -- sum )
    dup sqrt >fixnum 2 swap [a,b] [
        [ 2dup divisor? [ 2dup / + , ] [ drop ] if ] each drop
    ] { } make sum 1+ ;

PRIVATE>

: amicable? ( n -- ? )
    dup d { [ 2dup = not ] [ 2dup d = ] } && 2nip ;

: euler021 ( -- answer )
    10000 [1,b] [ dup amicable? [ drop 0 ] unless ] sigma ;

! [ euler021 ] 100 ave-time
! 328 ms run / 10 ms GC ave time - 100 trials

MAIN: euler021
