! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-outliner
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-layouts gadgets-panes generic io kernel
lists sequences ;

! Outliner gadget.
TUPLE: outliner quot ;

: outliner-expanded? ( outliner -- ? )
    #! If the outliner is expanded, it has a center gadget.
    @center frame-child >boolean ;

DEFER: <expand-button>

: set-outliner-expanded? ( expanded? outliner -- )
    #! Call the expander quotation if expanding.
    over not <expand-button> over @top-left frame-add
    swap [ dup outliner-quot make-pane ] [ f ] if
    swap @center frame-add ;

: find-outliner ( gadget -- outliner )
    [ outliner? ] find-parent ;

: <expand-arrow> ( ? -- gadget )
    arrow-right arrow-down ? <polygon-gadget>
    <gadget> @{ 5 0 0 }@ make-border ;

: <expand-button> ( ? -- gadget )
    #! If true, the button expands, otherwise it collapses.
    dup [ swap find-outliner set-outliner-expanded? ] curry
    >r <expand-arrow> r>
    <highlight-button> ;

C: outliner ( gadget quot -- gadget )
    #! The quotation generates child gadgets.
    <frame> over set-delegate
    [ set-outliner-quot ] keep
    [ >r 1array make-shelf r> @top frame-add ] keep
    f over set-outliner-expanded? ;
