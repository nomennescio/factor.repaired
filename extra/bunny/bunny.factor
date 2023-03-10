USING: accessors arrays bunny.cel-shaded bunny.fixed-pipeline
bunny.model bunny.outlined destructors kernel literals math
opengl.demo-support opengl.gl sequences ui ui.gadgets
ui.gadgets.worlds ui.gestures ui.pixel-formats ;
IN: bunny

TUPLE: bunny-world < demo-world model-triangles geom draw-seq draw-n ;

: get-draw ( gadget -- draw )
    [ draw-n>> ] [ draw-seq>> ] bi nth ;

: next-draw ( gadget -- )
    dup [ draw-seq>> ] [ draw-n>> ] bi
    1 + swap length mod
    >>draw-n relayout-1 ;

: make-draws ( gadget -- draw-seq )
    [ <bunny-fixed-pipeline> ]
    [ <bunny-cel-shaded> ]
    [ <bunny-outlined> ] tri 3array
    sift ;

M: bunny-world begin-world
    GL_DEPTH_TEST glEnable
    0.0 0.0 0.375 set-demo-orientation
    download-bunny read-model
    [ >>model-triangles ] [ <bunny-geom> >>geom ] bi
    dup make-draws >>draw-seq
    0 >>draw-n
    drop ;

M: bunny-world end-world
    dup find-gl-context
    [ geom>> [ dispose ] when* ]
    [ draw-seq>> [ [ dispose ] when* ] each ] bi ;

M: bunny-world draw-world*
    dup draw-seq>> empty? [ drop ] [
        0.15 0.15 0.15 1.0 glClearColor
        flags{ GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT } glClear
        dup demo-world-set-matrix
        GL_MODELVIEW glMatrixMode
        0.02 -0.105 0.0 glTranslatef
        [ geom>> ] [ get-draw ] bi draw-bunny
    ] if ;

bunny-world H{
    { T{ key-down f f "TAB" } [ next-draw ] }
} set-gestures

MAIN-WINDOW: bunny-window {
    { world-class bunny-world }
    { title "Bunny" }
    { pixel-format-attributes {
        windowed
        double-buffered
        T{ depth-bits { value 16 } }
    } }
    { pref-dim { 640 480 } }
} ;
