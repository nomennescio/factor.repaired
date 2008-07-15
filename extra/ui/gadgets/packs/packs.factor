! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences ui.gadgets kernel math math.functions
math.vectors namespaces math.order accessors math.geometry.rect ;
IN: ui.gadgets.packs

TUPLE: pack < gadget
{ align initial: 0 }
{ fill initial: 0 }
{ gap initial: { 0 0 } } ;

: packed-dim-2 ( gadget sizes -- list )
    [ over rect-dim over v- rot pack-fill v*n v+ ] with map ;

: packed-dims ( gadget sizes -- seq )
    2dup packed-dim-2 swap orient ;

: gap-locs ( gap sizes -- seq )
    { 0 0 } [ v+ over v+ ] accumulate 2nip ;

: aligned-locs ( gadget sizes -- seq )
    [ >r dup pack-align swap rect-dim r> v- n*v ] with map ;

: packed-locs ( gadget sizes -- seq )
    over pack-gap over gap-locs >r dupd aligned-locs r> orient ;

: round-dims ( seq -- newseq )
    { 0 0 } swap
    [ swap v- dup [ ceiling >fixnum ] map [ swap v- ] keep ] map
    nip ;

: pack-layout ( pack sizes -- )
    round-dims over gadget-children
    >r dupd packed-dims r> 2dup [ set-layout-dim ] 2each
    >r packed-locs r> [ set-rect-loc ] 2each ;

: <pack> ( orientation -- pack )
    pack new-gadget
        swap >>orientation ;

: <pile> ( -- pack ) { 0 1 } <pack> ;

: <filled-pile> ( -- pack ) <pile> 1 over set-pack-fill ;

: <shelf> ( -- pack ) { 1 0 } <pack> ;

: gap-dims ( gap sizes -- seeq )
    [ dim-sum ] keep length 1 [-] rot n*v v+ ;

: pack-pref-dim ( gadget sizes -- dim )
    over pack-gap over gap-dims >r max-dim r>
    rot gadget-orientation set-axis ;

M: pack pref-dim*
    dup gadget-children pref-dims pack-pref-dim ;

M: pack layout*
    dup gadget-children pref-dims pack-layout ;

M: pack children-on ( rect gadget -- seq )
    dup gadget-orientation swap gadget-children
    [ fast-children-on ] keep <slice> ;
