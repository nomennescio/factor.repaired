! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences namespaces make math math.ranges
math.vectors vectors ;
IN: math.numerical-integration

SYMBOL: num-steps 180 num-steps set-global

: setup-simpson-range ( from to -- frange )
    2dup swap - num-steps get / <range> ;

: generate-simpson-weights ( seq -- seq )
    { 1 4 }
    swap length 2 / 2 - { 2 4 } <repetition> concat
    { 1 } 3append ;

: integrate-simpson ( from to f -- x )
    [ setup-simpson-range dup ] dip 
    map dup generate-simpson-weights
    v. swap [ third ] keep first - 6 / * ;
