! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays freetype generic hashtables
io kernel math namespaces opengl sequences strings
styles vectors ;
IN: gadgets

SYMBOL: clip

: init-gl ( dim -- )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    { 0 0 } over <rect> clip set
    dup first2 0 0 2swap glViewport
    0 over first2 0 gluOrtho2D
    first2 0 0 2swap glScissor
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_SCISSOR_TEST glEnable
    1.0 1.0 1.0 1.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* ( gadget -- ) drop ;

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

: visible-children ( gadget -- seq ) clip get swap children-on ;

DEFER: draw-gadget

: with-translation ( loc quot -- )
    over translate over gl-translate
    swap slip
    vneg dup translate gl-translate ; inline

: (draw-gadget) ( gadget -- )
    dup rect-loc [
        dup dup gadget-interior draw-interior
        dup dup gadget-boundary draw-boundary
        dup draw-gadget*
        visible-children [ draw-gadget ] each
    ] with-translation ;

: change-clip ( gadget -- )
    >absolute clip [ rect-intersect ] change ;

: clip-x/y ( loc dim -- x y )
    >r [ first ] keep r>
    [ second ] 2apply + world get rect-dim second swap - ;

: clip-w/h ( dim -- w h )
    first2 1- ;

: gl-set-clip ( loc dim -- )
    dup clip-w/h >r >r clip-x/y r> r> glScissor ;

: do-clip ( -- ) clip get rect-bounds gl-set-clip ;

: with-clipping ( gadget quot -- )
    clip get >r
    over change-clip do-clip call
    r> clip set do-clip ; inline

: draw-gadget ( gadget -- )
    dup gadget-clipped? [
        [ (draw-gadget) ] with-clipping
    ] [
        (draw-gadget)
    ] if ;

: draw-world ( world -- )
    [
        dup world-handle [
            dup rect-dim init-gl
            dup world set
            draw-gadget
        ] with-gl-context
    ] with-scope ;

! Pen paint properties
M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid color ;

! Solid pen
M: solid draw-interior
    solid-color gl-color rect-dim gl-fill-rect ;

M: solid draw-boundary
    solid-color gl-color rect-dim gl-rect ;

! Gradient pen
TUPLE: gradient colors ;

M: gradient draw-interior ( gadget gradient -- )
    over gadget-orientation swap gradient-colors rot rect-dim
    gl-gradient ;

! Polygon pen
TUPLE: polygon color points ;

: draw-polygon ( polygon quot -- )
    >r dup polygon-color gl-color polygon-points r> each ; inline

M: polygon draw-boundary ( gadget polygon -- )
    [ gl-poly ] draw-polygon drop ;

M: polygon draw-interior ( gadget polygon -- )
    [ gl-fill-poly ] draw-polygon drop ;

: arrow-up    { { { 3 0 } { 6 6 } { 0 6 } } } ;
: arrow-right { { { 0 0 } { 6 3 } { 0 6 } } } ;
: arrow-down  { { { 0 0 } { 6 0 } { 3 6 } } } ;
: arrow-left  { { { 0 3 } { 6 0 } { 6 6 } } } ;
: close-box
    {
        { { 0 0 } { 6 6 } }
        { { 0 6 } { 6 0 } }
    } ;

: <polygon-gadget> ( color points -- gadget )
    dup { 0 0 } [ max-dim vmax ] reduce
    >r <polygon> <gadget> r> over set-rect-dim
    [ set-gadget-interior ] keep ;
