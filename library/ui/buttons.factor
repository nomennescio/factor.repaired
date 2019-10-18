! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces prettyprint sdl
sequences stdio sequences ;

: button-down? ( n -- ? ) hand hand-buttons contains? ;

: mouse-over? ( gadget -- ? ) hand hand-gadget child? ;

: button-pressed? ( button -- ? )
    #! Return true if the mouse was clicked on the button, and
    #! is currently over the button.
    dup mouse-over? [
        1 button-down? [
            hand hand-clicked child?
        ] [
            drop f
        ] ifte
    ] [
        drop f
    ] ifte ;

: button-update ( button -- )
    dup dup mouse-over? rollover? set-paint-prop
    dup dup button-pressed? reverse-video set-paint-prop
    redraw ;

: button-clicked ( button -- )
    #! If the mouse is released while still inside the button,
    #! fire an action gesture.
    dup mouse-over? [
        [ action ] swap handle-gesture drop
    ] [
        drop
    ] ifte ;

: button-action ( action -- quot )
    [ [ swap handle-gesture drop ] cons ] [ [ drop ] ] ifte* ;

: button-gestures ( button quot -- )
    over f reverse-video set-paint-prop
    dupd [ action ] set-action
    dup [ dup button-update button-clicked ] [ button-up 1 ] set-action
    dup [ button-update ] [ button-down 1 ] set-action
    dup [ button-update ] [ mouse-leave ] set-action
    dup [ button-update ] [ mouse-enter ] set-action
    [ drop ] [ drag 1 ] set-action ;

: <button> ( label action -- button )
    >r <label> line-border dup r> button-action button-gestures ;

: roll-border ( child -- border )
    0 0 0 0 <roll-rect> <gadget> 1 <border> ;

: <roll-button> ( label quot -- gadget )
    #! Thinner border that is only visible when the mouse is
    #! over the button.
    >r <label> roll-border dup r> button-action button-gestures ;
