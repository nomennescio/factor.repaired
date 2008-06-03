! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: lists.lazy math math.primes ;
IN: project-euler.007

! http://projecteuler.net/index.php?section=problems&id=7

! DESCRIPTION
! -----------

! By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see
! that the 6th prime is 13.

! What is the 10001st prime number?


! SOLUTION
! --------

: nth-prime ( n -- n )
    1- lprimes lnth ;

: euler007 ( -- answer )
    10001 nth-prime ;

! [ euler007 ] 100 ave-time
! 10 ms run / 0 ms GC ave time - 100 trials

MAIN: euler007
