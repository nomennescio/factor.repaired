! Copyright (C) 2005, 2008 Slava Pestov.
! Portions copyright (C) 2007 Eduardo Cavazos.
! Portions copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types continuations kernel libc math macros
namespaces math.vectors math.constants math.functions
math.parser opengl.gl opengl.glu combinators arrays sequences
splitting words byte-arrays assocs colors accessors
generalizations locals memoize ;
IN: opengl

: color>raw ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ; inline

: gl-color ( color -- ) color>raw glColor4d ; inline

: gl-clear-color ( color -- ) color>raw glClearColor ;

: gl-clear ( color -- )
    gl-clear-color GL_COLOR_BUFFER_BIT glClear ;

: gl-error ( -- )
    glGetError dup zero? [
        "GL error: " over gluErrorString append throw
    ] unless drop ;

: do-enabled ( what quot -- )
    over glEnable dip glDisable ; inline

: do-enabled-client-state ( what quot -- )
    over glEnableClientState dip glDisableClientState ; inline

: words>values ( word/value-seq -- value-seq )
    [ dup word? [ execute ] [ ] if ] map ;

: (all-enabled) ( seq quot -- )
    over [ glEnable ] each dip [ glDisable ] each ; inline

: (all-enabled-client-state) ( seq quot -- )
    [ dup [ glEnableClientState ] each ] dip
    dip
    [ glDisableClientState ] each ; inline

MACRO: all-enabled ( seq quot -- )
    >r words>values r> [ (all-enabled) ] 2curry ;

MACRO: all-enabled-client-state ( seq quot -- )
    >r words>values r> [ (all-enabled-client-state) ] 2curry ;

: do-matrix ( mode quot -- )
    swap [ glMatrixMode glPushMatrix call ] keep
    glMatrixMode glPopMatrix ; inline

: gl-material ( face pname params -- )
    >c-float-array glMaterialfv ;

: gl-vertex-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip glVertexPointer ; inline

: gl-color-pointer ( seq -- )
    [ 4 GL_FLOAT 0 ] dip glColorPointer ; inline

: gl-texture-coord-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip glTexCoordPointer ; inline

: line-vertices ( a b -- )
    append >c-float-array gl-vertex-pointer ;

: gl-line ( a b -- )
    line-vertices GL_LINES 0 2 glDrawArrays ;

: (rect-vertices) ( dim -- vertices )
    {
        [ drop 0 1 ]
        [ first 1- 1 ]
        [ [ first 1- ] [ second ] bi ]
        [ second 0 swap ]
    } cleave 8 narray >c-float-array ;

: rect-vertices ( dim -- )
    (rect-vertices) gl-vertex-pointer ;

: (gl-rect) ( -- )
    GL_LINE_LOOP 0 4 glDrawArrays ;

: gl-rect ( dim -- )
    rect-vertices (gl-rect) ;

: (fill-rect-vertices) ( dim -- vertices )
    {
        [ drop 0 0 ]
        [ first 0 ]
        [ first2 ]
        [ second 0 swap ]
    } cleave 8 narray >c-float-array ;

: fill-rect-vertices ( dim -- )
    (fill-rect-vertices) gl-vertex-pointer ;

: (gl-fill-rect) ( -- )
    GL_QUADS 0 4 glDrawArrays ;

: gl-fill-rect ( dim -- )
    fill-rect-vertices (gl-fill-rect) ;

: circle-steps ( steps -- angles )
    dup length v/n 2 pi * v*n ;

: unit-circle ( angles -- points1 points2 )
    [ [ sin ] map ] [ [ cos ] map ] bi ;

: adjust-points ( points1 points2 -- points1' points2' )
    [ [ 1 + 0.5 * ] map ] bi@ ;

: scale-points ( loc dim points1 points2 -- points )
    zip [ v* ] with map [ v+ ] with map ;

: circle-points ( loc dim steps -- points )
    circle-steps unit-circle adjust-points scale-points ;

: circle-vertices ( loc dim steps -- vertices )
    circle-points concat >c-float-array ;

: (gen-gl-object) ( quot -- id )
    >r 1 0 <uint> r> keep *uint ; inline

: gen-texture ( -- id )
    [ glGenTextures ] (gen-gl-object) ;

: gen-gl-buffer ( -- id )
    [ glGenBuffers ] (gen-gl-object) ;

: (delete-gl-object) ( id quot -- )
    >r 1 swap <uint> r> call ; inline

: delete-texture ( id -- )
    [ glDeleteTextures ] (delete-gl-object) ;

: delete-gl-buffer ( id -- )
    [ glDeleteBuffers ] (delete-gl-object) ;

: with-gl-buffer ( binding id quot -- )
    -rot dupd glBindBuffer
    [ slip ] [ 0 glBindBuffer ] [ ] cleanup ; inline

: with-array-element-buffers ( array-buffer element-buffer quot -- )
    -rot GL_ELEMENT_ARRAY_BUFFER swap [
        swap GL_ARRAY_BUFFER -rot with-gl-buffer
    ] with-gl-buffer ; inline

: <gl-buffer> ( target data hint -- id )
    pick gen-gl-buffer [ [
        >r dup byte-length swap r> glBufferData
    ] with-gl-buffer ] keep ;

: buffer-offset ( int -- alien )
    <alien> ; inline

: bind-texture-unit ( id target unit -- )
    glActiveTexture swap glBindTexture gl-error ;

: (set-draw-buffers) ( buffers -- )
    dup length swap >c-uint-array glDrawBuffers ;

MACRO: set-draw-buffers ( buffers -- )
    words>values [ (set-draw-buffers) ] curry ;

: do-attribs ( bits quot -- )
    swap glPushAttrib call glPopAttrib ; inline

: gl-look-at ( eye focus up -- )
    [ first3 ] tri@ gluLookAt ;

TUPLE: sprite loc dim dim2 dlist texture ;

: <sprite> ( loc dim dim2 -- sprite )
    f f sprite boa ;

: sprite-size2 ( sprite -- w h ) dim2>> first2 ;

: sprite-width ( sprite -- w ) dim>> first ;

: gray-texture ( sprite pixmap -- id )
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            >r >r GL_TEXTURE_2D 0 GL_RGBA r>
            sprite-size2 0 GL_LUMINANCE_ALPHA
            GL_UNSIGNED_BYTE r> glTexImage2D
        ] do-attribs
    ] keep ;
    
: gen-dlist ( -- id ) 1 glGenLists ;

: make-dlist ( type quot -- id )
    gen-dlist [ rot glNewList call glEndList ] keep ; inline

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameterf
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameterf ;

: gl-translate ( point -- ) first2 0.0 glTranslated ;

MEMO: (rect-texture-coords) ( -- seq )
    { 0 0 1 0 1 1 0 1 } >c-float-array ;

: rect-texture-coords ( -- )
    (rect-texture-coords) gl-texture-coord-pointer ;

: draw-sprite ( sprite -- )
    GL_TEXTURE_COORD_ARRAY [
        dup loc>> gl-translate
        GL_TEXTURE_2D over texture>> glBindTexture
        init-texture rect-texture-coords
        dim2>> fill-rect-vertices
        (gl-fill-rect)
        GL_TEXTURE_2D 0 glBindTexture
    ] do-enabled-client-state ;

: make-sprite-dlist ( sprite -- id )
    GL_MODELVIEW [
        GL_COMPILE [ draw-sprite ] make-dlist
    ] do-matrix ;

: init-sprite ( texture sprite -- )
    swap >>texture
    dup make-sprite-dlist >>dlist drop ;

: delete-dlist ( id -- ) 1 glDeleteLists ;

: free-sprite ( sprite -- )
    [ dlist>> delete-dlist ]
    [ texture>> delete-texture ] bi ;

: free-sprites ( sprites -- )
    [ nip [ free-sprite ] when* ] assoc-each ;

: with-translation ( loc quot -- )
    GL_MODELVIEW [ >r gl-translate r> call ] do-matrix ; inline

: fix-coordinates ( point1 point2 -- x1 y2 x2 y2 )
    [ first2 [ >fixnum ] bi@ ] bi@ ;

: gl-set-clip ( loc dim -- )
    fix-coordinates glScissor ;

: gl-viewport ( loc dim -- )
    fix-coordinates glViewport ;

: init-matrices ( -- )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;
