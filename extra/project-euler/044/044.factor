! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.ranges project-euler.common sequences ;
IN: project-euler.044

! http://projecteuler.net/index.php?section=problems&id=44

! DESCRIPTION
! -----------

! Pentagonal numbers are generated by the formula, Pn=n(3n−1)/2. The first ten
! pentagonal numbers are:

!     1, 5, 12, 22, 35, 51, 70, 92, 117, 145, ...

! It can be seen that P4 + P7 = 22 + 70 = 92 = P8. However, their difference,
! 70 − 22 = 48, is not pentagonal.

! Find the pair of pentagonal numbers, Pj and Pk, for which their sum and
! difference is pentagonal and D = |Pk − Pj| is minimised; what is the value of D?


! SOLUTION
! --------

! Brute force using a cartesian product and an arbitrarily chosen limit.

<PRIVATE

: nth-pentagonal ( n -- seq )
    dup 3 * 1- * 2 / ;

: sum-and-diff? ( m n -- ? )
    2dup + -rot - [ pentagonal? ] 2apply and ;

PRIVATE>

: euler044 ( -- answer )
    2500 [1,b] [ nth-pentagonal ] map dup cartesian-product
    [ first2 sum-and-diff? ] subset [ first2 - abs ] map infimum ;

! [ euler044 ] 10 ave-time
! 8924 ms run / 2872 ms GC ave time - 10 trials

! TODO: this solution is ugly and not very efficient...find a better algorithm

MAIN: euler044
