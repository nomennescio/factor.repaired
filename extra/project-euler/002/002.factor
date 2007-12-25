! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: project-euler.002

! http://projecteuler.net/index.php?section=problems&id=2

! DESCRIPTION
! -----------

! Each new term in the Fibonacci sequence is generated by adding the previous
! two terms. By starting with 1 and 2, the first 10 terms will be:

!     1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...

! Find the sum of all the even-valued terms in the sequence which do not exceed one million.


! SOLUTION
! --------

: last2 ( seq -- elt last )
    reverse first2 swap ;

: fib-up-to ( n -- seq )
    { 0 } 1 [ pick dupd < ] [ add dup last2 + ] [ ] while drop nip ;

: euler002 ( -- answer )
    1000000 fib-up-to [ even? ] subset sum ;

! [ euler002 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler002
