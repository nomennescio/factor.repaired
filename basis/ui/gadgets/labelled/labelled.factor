! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets.buttons ui.gadgets.borders
ui.gadgets.labels ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gadgets.theme ui.gadgets.frames
ui.gadgets.grids io kernel math models namespaces prettyprint
sequences sequences words classes.tuple ui.gadgets ui.render
colors accessors ;
IN: ui.gadgets.labelled

TUPLE: labelled-gadget < track content ;

: <labelled-gadget> ( gadget title -- newgadget )
    { 0 1 } labelled-gadget new-track
        swap <label> reverse-video-theme f track-add
        swap >>content
        dup content>> 1 track-add ;

M: labelled-gadget focusable-child* content>> ;

: <labelled-scroller> ( gadget title -- gadget )
    >r <scroller> r> <labelled-gadget> ;

: <labelled-pane> ( model quot scrolls? title -- gadget )
    >r >r <pane-control> r> >>scrolls? r>
    <labelled-scroller> ;

: <close-box> ( quot -- button/f )
    gray close-box <polygon-gadget> swap <bevel-button> ;

: title-theme ( gadget -- gadget )
    { 1 0 } >>orientation
    {
        T{ rgba f 0.65 0.65 1.0 1.0 }
        T{ rgba f 0.65 0.45 1.0 1.0 }
    } <gradient> >>interior ;

: <title-label> ( text -- label ) <label> title-theme ;

: <title-bar> ( title quot -- gadget )
    <frame>
        swap [ <close-box> @left grid-add ] when*
        swap <title-label> @center grid-add ;

TUPLE: closable-gadget < frame content ;

: find-closable-gadget ( parent -- child )
    [ closable-gadget? ] find-parent ;

: <closable-gadget> ( gadget title quot -- gadget )
    closable-gadget new-frame
        -rot <title-bar> @top grid-add
        swap >>content
        dup content>> @center grid-add ;
    
M: closable-gadget focusable-child* content>> ;
