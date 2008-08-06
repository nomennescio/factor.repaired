! Copyright � 2008 Reginald Keith Ford II
! Newton's Method of approximating roots

USING: kernel math math.derivatives ;
IN: math.newtons-method

<PRIVATE
: newton-step ( x function -- x2 ) dupd [ call ] [ derivative ] 2bi / - ;
: newton-precision ( -- n ) 13 ;
PRIVATE>
: newtons-method ( guess function -- x ) newton-precision [ [ newton-step ] keep ] times drop ;
