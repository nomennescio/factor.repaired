! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types colors jamshred.game jamshred.oint jamshred.player jamshred.tunnel kernel math math.constants math.functions math.vectors opengl opengl.gl opengl.glu sequences ;
IN: jamshred.gl

: min-vertices 6 ; inline
: max-vertices 32 ; inline

: n-vertices ( -- n ) 32 ; inline

! render enough of the tunnel that it looks continuous
: n-segments-ahead ( -- n ) 60 ; inline
: n-segments-behind ( -- n ) 40 ; inline

: wall-drawing-offset ( -- n )
    #! so that we can't see through the wall, we draw it a bit further away
    0.15 ;

: wall-drawing-radius ( segment -- r )
    radius>> wall-drawing-offset + ;

: wall-up ( segment -- v )
    [ wall-drawing-radius ] [ up>> ] bi n*v ;

: wall-left ( segment -- v )
    [ wall-drawing-radius ] [ left>> ] bi n*v ;

: segment-vertex ( theta segment -- vertex )
    [
        [ wall-up swap sin v*n ] [ wall-left swap cos v*n ] 2bi v+
    ] [
        location>> v+
    ] bi ;

: segment-vertex-normal ( vertex segment -- normal )
    location>> swap v- normalize ;

: segment-vertex-and-normal ( segment theta -- vertex normal )
    swap [ segment-vertex ] keep dupd segment-vertex-normal ;

: equally-spaced-radians ( n -- seq )
    #! return a sequence of n numbers between 0 and 2pi
    dup [ / pi 2 * * ] curry map ;
: draw-segment-vertex ( segment theta -- )
    over segment-color gl-color segment-vertex-and-normal
    gl-normal gl-vertex ;

: draw-vertex-pair ( theta next-segment segment -- )
    rot tuck draw-segment-vertex draw-segment-vertex ;

: draw-segment ( next-segment segment -- )
    GL_QUAD_STRIP [
        [ draw-vertex-pair ] 2curry
        n-vertices equally-spaced-radians F{ 0.0 } append swap each
    ] do-state ;

: draw-segments ( segments -- )
    1 over length pick subseq swap [ draw-segment ] 2each ;

: segments-to-render ( player -- segments )
    dup player-nearest-segment segment-number dup n-segments-behind -
    swap n-segments-ahead + rot player-tunnel sub-tunnel ;

: draw-tunnel ( player -- )
    segments-to-render draw-segments ;

: init-graphics ( width height -- )
    GL_DEPTH_TEST glEnable
    GL_SCISSOR_TEST glDisable
    1.0 glClearDepth
    0.0 0.0 0.0 0.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_PROJECTION glMatrixMode glLoadIdentity
    dup 0 = [ 2drop ] [ / >float 45.0 swap 0.1 100.0 gluPerspective ] if
    GL_MODELVIEW glMatrixMode glLoadIdentity
    GL_LEQUAL glDepthFunc
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_FOG glEnable
    GL_FOG_DENSITY 0.09 glFogf
    GL_FRONT GL_AMBIENT_AND_DIFFUSE glColorMaterial
    GL_COLOR_MATERIAL glEnable
    GL_LIGHT0 GL_POSITION F{ 0.0 0.0 0.0 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_AMBIENT F{ 0.2 0.2 0.2 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_DIFFUSE F{ 1.0 1.0 1.0 1.0 } >c-float-array glLightfv
    GL_LIGHT0 GL_SPECULAR F{ 1.0 1.0 1.0 1.0 } >c-float-array glLightfv ;

: player-view ( player -- )
    [ location>> ]
    [ [ location>> ] [ forward>> ] bi v+ ]
    [ up>> ] tri gl-look-at ;

: draw-jamshred ( jamshred width height -- )
    init-graphics jamshred-player [ player-view ] [ draw-tunnel ] bi ;

