USING: alien.c-types continuations kernel
opengl opengl.gl bunny.model ;
IN: bunny.fixed-pipeline

TUPLE: bunny-fixed-pipeline ;

: <bunny-fixed-pipeline> ( gadget -- draw )
    drop
    { } bunny-fixed-pipeline construct ;

M: bunny-fixed-pipeline draw-bunny
    drop
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_COLOR_MATERIAL glEnable
    GL_LIGHT0 GL_POSITION { 1.0 -1.0 1.0 1.0 } >c-float-array glLightfv
    GL_FRONT_AND_BACK GL_SHININESS 100.0 glMaterialf
    GL_FRONT_AND_BACK GL_SPECULAR glColorMaterial
    GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE glColorMaterial
    0.6 0.5 0.5 1.0 glColor4f
    bunny-geom ;

M: bunny-fixed-pipeline dispose
    drop ;

