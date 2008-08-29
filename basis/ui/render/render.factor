! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays hashtables io kernel math namespaces opengl
opengl.gl opengl.glu sequences strings io.styles vectors
combinators math.vectors ui.gadgets colors
math.order math.geometry.rect ;
IN: ui.render

SYMBOL: clip

SYMBOL: viewport-translation

: flip-rect ( rect -- loc dim )
    rect-bounds [
        >r { 1 -1 } v* r> { 0 -1 } v* v+
        viewport-translation get v+
    ] keep ;

: do-clip ( -- ) clip get flip-rect gl-set-clip ;

: init-clip ( clip-rect rect -- )
    GL_SCISSOR_TEST glEnable
    [ rect-intersect ] keep
    rect-dim dup { 0 1 } v* viewport-translation set
    { 0 0 } over gl-viewport
    0 swap first2 0 gluOrtho2D
    clip set
    do-clip ;

: init-gl ( clip-rect rect -- )
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    init-matrices
    init-clip
    ! white gl-clear is broken w.r.t window resizing
    ! Linux/PPC Radeon 9200
    white set-color
    clip get rect-extent gl-fill-rect ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* drop ;

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

SYMBOL: origin

{ 0 0 } origin set-global

: visible-children ( gadget -- seq )
    clip get origin get vneg offset-rect swap children-on ;

: translate ( rect/point -- ) rect-loc origin [ v+ ] change ;

DEFER: draw-gadget

: (draw-gadget) ( gadget -- )
    [
        dup translate
        dup dup interior>> draw-interior
        dup draw-gadget*
        dup visible-children [ draw-gadget ] each
        dup gadget-boundary draw-boundary
    ] with-scope ;

: >absolute ( rect -- rect )
    origin get offset-rect ;

: change-clip ( gadget -- )
    >absolute clip [ rect-intersect ] change ;

: with-clipping ( gadget quot -- )
    clip get >r
    over change-clip do-clip call
    r> clip set do-clip ; inline

: draw-gadget ( gadget -- )
    {
        { [ dup visible?>> not ] [ drop ] }
        { [ dup clipped?>> not ] [ (draw-gadget) ] }
        [ [ (draw-gadget) ] with-clipping ]
    } cond ;

! Pen paint properties
M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid color ;

C: <solid> solid

! Solid pen
: (solid) ( gadget paint -- loc dim )
    solid-color set-color rect-dim >r origin get dup r> v+ ;

M: solid draw-interior (solid) gl-fill-rect ;

M: solid draw-boundary (solid) gl-rect ;

! Gradient pen
TUPLE: gradient colors ;

C: <gradient> gradient

M: gradient draw-interior
    origin get [
        over orientation>>
        swap gradient-colors
        rot rect-dim
        gl-gradient
    ] with-translation ;

! Polygon pen
TUPLE: polygon color points ;

C: <polygon> polygon

: draw-polygon ( polygon quot -- )
    origin get [
        >r dup polygon-color set-color polygon-points r> call
    ] with-translation ; inline

M: polygon draw-boundary
    [ gl-poly ] draw-polygon drop ;

M: polygon draw-interior
    [ gl-fill-poly ] draw-polygon drop ;

: arrow-up    { { 3 0 } { 6 6 } { 0 6 } } ;
: arrow-right { { 0 0 } { 6 3 } { 0 6 } } ;
: arrow-down  { { 0 0 } { 6 0 } { 3 6 } } ;
: arrow-left  { { 0 3 } { 6 0 } { 6 6 } } ;
: close-box   { { 0 0 } { 6 0 } { 6 6 } { 0 6 } } ;

: <polygon-gadget> ( color points -- gadget )
    dup max-dim
    >r <polygon> <gadget> r> over set-rect-dim
    [ (>>interior) ] keep ;

! Font rendering
SYMBOL: font-renderer

HOOK: open-font font-renderer ( font -- open-font )

HOOK: string-width font-renderer ( open-font string -- w )

HOOK: string-height font-renderer ( open-font string -- h )

HOOK: draw-string font-renderer ( font string loc -- )

HOOK: x>offset font-renderer ( x open-font string -- n )

HOOK: free-fonts font-renderer ( world -- )

: text-height ( open-font text -- n )
    dup string? [
        string-height
    ] [
        [ string-height ] with map sum
    ] if ;

: text-width ( open-font text -- n )
    dup string? [
        string-width
    ] [
        0 -rot [ string-width max ] with each
    ] if ;

: text-dim ( open-font text -- dim )
    [ text-width ] 2keep text-height 2array ;

: draw-text ( font text loc -- )
    over string? [
        draw-string
    ] [
        [
            [
                2dup { 0 0 } draw-string
                >r open-font r> string-height
                0.0 swap 0.0 glTranslated
            ] with each
        ] with-translation
    ] if ;
