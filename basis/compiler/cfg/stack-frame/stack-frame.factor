! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.order namespaces accessors kernel layouts
combinators assocs sequences cpu.architecture
words compiler.cfg.instructions ;
IN: compiler.cfg.stack-frame

TUPLE: stack-frame
{ params integer }
{ return integer }
{ spill-area-size integer }
{ total-size integer } ;

! Stack frame utilities
: return-offset ( -- offset )
    stack-frame get params>> ;

: spill-offset ( n -- offset )
    stack-frame get [ params>> ] [ return>> ] bi + + ;

: (stack-frame-size) ( stack-frame -- n )
    [ params>> ] [ return>> ] [ spill-area-size>> ] tri + + ;

: max-stack-frame ( frame1 frame2 -- frame3 )
    [ stack-frame new ] 2dip
    {
        [ [ params>> ] bi@ max >>params ]
        [ [ return>> ] bi@ max >>return ]
        [ [ spill-area-size>> ] bi@ max >>spill-area-size ]
    } 2cleave ;
