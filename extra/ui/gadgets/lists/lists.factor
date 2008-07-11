! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ui.commands ui.gestures ui.render ui.gadgets
ui.gadgets.labels ui.gadgets.scrollers
kernel sequences models opengl math math.order namespaces
ui.gadgets.presentations ui.gadgets.viewports ui.gadgets.packs
math.vectors classes.tuple ;
IN: ui.gadgets.lists

TUPLE: list < pack index presenter color hook ;

: list-theme ( list -- list )
    { 0.8 0.8 1.0 1.0 } >>color ; inline

: <list> ( hook presenter model -- gadget )
    list new-gadget
        { 0 1 } >>orientation
        1 >>fill
        0 >>index
        swap >>model
        swap >>presenter
        swap >>hook
        list-theme ;

: calc-bounded-index ( n list -- m )
    control-value length 1- min 0 max ;

: bound-index ( list -- )
    dup list-index over calc-bounded-index
    swap set-list-index ;

: list-presentation-hook ( list -- quot )
    hook>> [ [ [ list? ] is? ] find-parent ] prepend ;

: <list-presentation> ( hook elt presenter -- gadget )
    keep >r >label text-theme r>
    <presentation>
    swap >>hook ; inline

: <list-items> ( list -- seq )
    [ list-presentation-hook ]
    [ presenter>> ]
    [ control-value ]
    tri [
        >r 2dup r> swap <list-presentation>
    ] map 2nip ;

M: list model-changed
    nip
    dup clear-gadget
    dup <list-items> over add-gadgets
    bound-index ;

: selected-rect ( list -- rect )
    dup list-index swap gadget-children ?nth ;

M: list draw-gadget*
    origin get [
        dup list-color gl-color
        selected-rect [ rect-extent gl-fill-rect ] when*
    ] with-translation ;

M: list focusable-child* drop t ;

: list-value ( list -- object )
    dup list-index swap control-value ?nth ;

: scroll>selected ( list -- )
    #! We change the rectangle's width to zero to avoid
    #! scrolling right.
    [ selected-rect rect-bounds { 0 1 } v* <rect> ] keep
    scroll>rect ;

: list-empty? ( list -- ? ) control-value empty? ;

: select-index ( n list -- )
    dup list-empty? [
        2drop
    ] [
        [ control-value length rem ] keep
        [ set-list-index ] keep
        [ relayout-1 ] keep
        scroll>selected
    ] if ;

: select-previous ( list -- )
    dup list-index 1- swap select-index ;

: select-next ( list -- )
    dup list-index 1+ swap select-index ;

: invoke-value-action ( list -- )
    dup list-empty? [
        dup list-hook call
    ] [
        dup list-index swap nth-gadget invoke-secondary
    ] if ;

: select-gadget ( gadget list -- )
    swap over gadget-children index
    [ swap select-index ] [ drop ] if* ;

: clamp-loc ( point max -- point )
    vmin { 0 0 } vmax ;

: select-at ( point list -- )
    [ rect-dim clamp-loc ] keep
    [ pick-up ] keep
    select-gadget ;

: list-page ( list vec -- )
    >r dup selected-rect rect-bounds 2 v/n v+
    over visible-dim r> v* v+ swap select-at ;

: list-page-up ( list -- ) { 0 -1 } list-page ;

: list-page-down ( list -- ) { 0 1 } list-page ;

list "keyboard-navigation" "Lists can be navigated from the keyboard." {
    { T{ button-down } request-focus }
    { T{ key-down f f "UP" } select-previous }
    { T{ key-down f f "DOWN" } select-next }
    { T{ key-down f f "PAGE_UP" } list-page-up }
    { T{ key-down f f "PAGE_DOWN" } list-page-down }
    { T{ key-down f f "RET" } invoke-value-action }
} define-command-map
