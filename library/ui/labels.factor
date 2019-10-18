! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl stdio
sequences ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    <empty-gadget> over set-delegate [ set-label-text ] keep ;

: label-size ( gadget text -- w h )
    >r font paint-prop r> size-string ;

M: label pref-size ( label -- w h )
    dup label-text label-size ;

M: label draw-shape ( label -- )
    [ label-text ] keep [ draw-string ] with-trans ;
