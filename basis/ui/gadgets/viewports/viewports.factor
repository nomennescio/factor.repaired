! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.borders
kernel math namespaces sequences models math.vectors
math.rectangles ;
IN: ui.gadgets.viewports

TUPLE: viewport < gadget { constraint initial: { 1 1 } } ;

: find-viewport ( gadget -- viewport )
    [ viewport? ] find-parent ;

: <viewport> ( content model -- viewport )
    viewport new
        swap >>model
        t >>clipped?
        swap add-gadget ;

M: viewport layout*
    [ gadget-child ]
    [ [ dim>> ] [ gadget-child pref-dim ] bi vmax ] bi >>dim drop ;

M: viewport focusable-child*
    gadget-child ;

: scroller-value ( scroller -- loc )
    model>> range-value [ >integer ] map ;

M: viewport model-changed
    nip
    [ relayout-1 ]
    [
        [ gadget-child ]
        [ scroller-value vneg ]
        [ constraint>> ]
        tri v* >>loc drop
    ] bi ;

: visible-dim ( gadget -- dim )
    dup parent>> viewport? [ parent>> ] when dim>> ;
