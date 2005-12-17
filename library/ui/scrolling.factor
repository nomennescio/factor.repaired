! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-layouts kernel math namespaces
sequences ;

! A viewport can be scrolled.
TUPLE: viewport ;

! A scroller combines a viewport with two x and y sliders.
! The follows slot is set by scroll-to.
TUPLE: scroller viewport x y follows ;

: scroller-origin ( scroller -- { x y 0 } )
    dup scroller-x slider-value
    swap scroller-y slider-value
    0 3array ;

: find-scroller [ scroller? ] find-parent ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim gadget-child pref-dim ;

C: viewport ( content -- viewport )
    dup delegate>gadget
    t over set-gadget-root?
    [ add-gadget ] keep ;

M: viewport pref-dim gadget-child pref-dim ;

: set-slider ( page max value slider -- )
    #! page/max/value are 3-vectors.
    [ [ gadget-orientation v. ] keep set-slider-value ] keep
    [ [ gadget-orientation v. ] keep set-slider-max ] keep
    [ [ gadget-orientation v. ] keep set-slider-page ] keep
    fix-slider ;

: update-slider ( scroller value slider -- )
    >r >r scroller-viewport dup rect-dim swap viewport-dim
    r> r> set-slider ;

: scroll ( scroller value -- )
    2dup over scroller-x update-slider
    over scroller-y update-slider ;

: pop-follows ( scroller -- follows )
    dup scroller-follows f rot set-scroller-follows ;

: (do-scroll) ( gadget viewport -- point )
    [ [ swap relative-rect ] keep rect-union ] keep
    [ rect-extent v+ ] 2apply v- ;

: do-scroll ( scroller -- delta )
    dup pop-follows dup [
        swap scroller-viewport (do-scroll)
    ] [
        2drop { 0 0 0 }
    ] if ;

: update-scroller ( scroller -- )
    [ dup do-scroll ] keep scroller-origin v+ scroll ;

: position-viewport ( viewport scroller -- )
    scroller-origin vneg swap gadget-child set-rect-loc ;

M: viewport layout* ( viewport -- )
    dup gadget-child dup prefer layout
    dup find-scroller dup update-scroller position-viewport ;

M: viewport focusable-child* ( viewport -- gadget )
    gadget-child ;

: add-viewport 2dup set-scroller-viewport @center frame-add ;

: add-x-slider 2dup set-scroller-x @bottom frame-add ;

: add-y-slider 2dup set-scroller-y @right frame-add ;

: scroll-to ( gadget -- )
    #! Scroll the scroller that contains this gadget, if any, so
    #! that the gadget becomes visible.
    dup find-scroller dup
    [ [ set-scroller-follows ] keep relayout ] [ 2drop ] if ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

: scroller-actions ( scroller -- )
    dup [ scroll-up-line ] [ wheel-up ] set-action
    dup [ scroll-down-line ] [ wheel-down ] set-action
    [ scroller-viewport relayout-1 ] [ slider-changed ] set-action ;

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    dup delegate>frame
    [ >r <viewport> r> add-viewport ] keep
    <x-slider> over add-x-slider
    <y-slider> over add-y-slider
    dup scroller-actions ;

M: scroller focusable-child* ( scroller -- viewport )
    scroller-viewport ;
