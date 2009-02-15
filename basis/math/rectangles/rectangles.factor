! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math math.vectors accessors ;
IN: math.rectangles

TUPLE: rect { loc initial: { 0 0 } } { dim initial: { 0 0 } } ;

: <rect> ( loc dim -- rect ) rect boa ; inline

: <zero-rect> ( -- rect ) rect new ; inline

: point>rect ( loc -- rect ) { 0 0 } <rect> ; inline

: rect-bounds ( rect -- loc dim ) [ loc>> ] [ dim>> ] bi ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: with-rect-extents ( rect1 rect2 loc-quot: ( loc1 loc2 -- ) ext-quot: ( ext1 ext2 -- ) -- )
    [ [ rect-extent ] bi@ ] 2dip bi-curry* bi* ; inline

: <extent-rect> ( loc ext -- rect ) over [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over loc>> v+ swap dim>> <rect> ;

: (rect-intersect) ( rect rect -- array array )
    [ vmax ] [ vmin ] with-rect-extents ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

GENERIC: contains-rect? ( rect1 rect2 -- ? )

M: rect contains-rect?
    (rect-intersect) [v-] { 0 0 } = ;

GENERIC: contains-point? ( point rect -- ? )

M: rect contains-point?
    [ point>rect ] dip contains-rect? ;

: (rect-union) ( rect rect -- array array )
    [ vmin ] [ vmax ] with-rect-extents ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

: rect-containing ( points -- rect )
    [ vsupremum ] [ vinfimum ] bi
    [ nip ] [ v- ] 2bi <rect> ;

: rect-min ( rect dim -- rect' )
    [ rect-bounds ] dip vmin <rect> ;