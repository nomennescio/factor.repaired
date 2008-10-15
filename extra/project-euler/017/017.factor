! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.ranges math.text.english sequences strings
    ascii combinators.short-circuit ;
IN: project-euler.017

! http://projecteuler.net/index.php?section=problems&id=17

! DESCRIPTION
! -----------

! If the numbers 1 to 5 are written out in words: one, two, three, four, five;
! there are 3 + 3 + 5 + 4 + 4 = 19 letters used in total.

! If all the numbers from 1 to 1000 (one thousand) inclusive were written out
! in words, how many letters would be used?

! NOTE: Do not count spaces or hyphens. For example, 342 (three hundred and
! forty-two) contains 23 letters and 115 (one hundred and fifteen) contains
! 20 letters.


! SOLUTION
! --------

: euler017 ( -- answer )
    1000 [1,b] SBUF" " clone [ number>text over push-all ] reduce [ Letter? ] count ;

! [ euler017a ] 100 ave-time
! 14 ms run / 0 ms GC ave time - 100 trials

MAIN: euler017
