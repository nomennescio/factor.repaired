! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.miller-rabin ;
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
    2 swap 1- [ next-prime ] times ;

: euler007 ( -- answer )
    10001 nth-prime ;

! [ euler007 ] time
! 19230 ms run / 487 ms GC time

MAIN: euler007
