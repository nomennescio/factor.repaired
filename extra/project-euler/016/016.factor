! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.functions math.parser project-euler.common sequences ;
IN: project-euler.016

! http://projecteuler.net/index.php?section=problems&id=16

! DESCRIPTION
! -----------

! 2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.

! What is the sum of the digits of the number 2^1000?


! SOLUTION
! --------

: euler016 ( -- answer )
    2 1000 ^ number>digits sum ;

! [ euler016 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler016
