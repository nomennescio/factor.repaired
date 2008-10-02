! Copyright (C) 2005, 2008 Slava Pestov.
! Portions copyright (C) 2007 Eduardo Cavazos.
! Portions copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types continuations kernel libc math macros
       namespaces math.vectors math.constants math.functions
       math.parser opengl.gl opengl.glu combinators arrays sequences
       splitting words byte-arrays assocs colors accessors ;

IN: opengl

: coordinates ( point1 point2 -- x1 y2 x2 y2 )
    [ first2 ] bi@ ;

: fix-coordinates ( point1 point2 -- x1 y2 x2 y2 )
    [ first2 [ >fixnum ] bi@ ] bi@ ;

: gl-color ( color -- ) first4 glColor4d ; inline

: gl-clear-color ( color -- )
    first4 glClearColor ;

: gl-clear ( color -- )
    gl-clear-color GL_COLOR_BUFFER_BIT glClear ;

: color>raw ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ;

: set-color ( object -- ) color>raw glColor4d ;
: set-clear-color ( object -- ) color>raw glClearColor ;

: gl-error ( -- )
    glGetError dup zero? [
        "GL error: " over gluErrorString append throw
    ] unless drop ;

: do-state ( mode quot -- )
    swap glBegin call glEnd ; inline

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

: gl-vertex ( point -- )
    dup length {
        { 2 [ first2 glVertex2d ] }
        { 3 [ first3 glVertex3d ] }
        { 4 [ first4 glVertex4d ] }
    } case ;

: gl-normal ( normal -- ) first3 glNormal3d ;

: gl-material ( face pname params -- )
    >c-float-array glMaterialfv ;

: gl-line ( a b -- )
    GL_LINES [ gl-vertex gl-vertex ] do-state ;

: gl-fill-rect ( loc ext -- )
    coordinates glRectd ;

: gl-rect ( loc ext -- )
    GL_FRONT_AND_BACK GL_LINE glPolygonMode
    >r { 0.5 0.5 } v+ r> { 0.5 0.5 } v- gl-fill-rect
    GL_FRONT_AND_BACK GL_FILL glPolygonMode ;

: (gl-poly) ( points state -- )
    [ [ gl-vertex ] each ] do-state ;

: gl-fill-poly ( points -- )
    dup length 2 > GL_POLYGON GL_LINES ? (gl-poly) ;

: gl-poly ( points -- )
    GL_LINE_LOOP (gl-poly) ;

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

: gl-circle ( loc dim steps -- )
    circle-points gl-poly ;

: gl-fill-circle ( loc dim steps -- )
    circle-points gl-fill-poly ;

: prepare-gradient ( direction dim -- v1 v2 )
    tuck v* [ v- ] keep ;

: gl-gradient ( direction colors dim -- )
    GL_QUAD_STRIP [
        swap >r prepare-gradient r>
        [ length dup 1- v/n ] keep [
            >r >r 2dup r> r> set-color v*n
            dup gl-vertex v+ gl-vertex
        ] 2each 2drop
    ] do-state ;

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

<PRIVATE

: top-left drop 0 0 glTexCoord2i 0.0 0.0 glVertex2d ; inline

: top-right 1 0 glTexCoord2i first 0.0 glVertex2d ; inline

: bottom-left 0 1 glTexCoord2i second 0.0 swap glVertex2d ; inline

: bottom-right 1 1 glTexCoord2i gl-vertex ; inline

PRIVATE>

: four-sides ( dim -- )
    dup top-left dup top-right dup bottom-right bottom-left ;

: draw-sprite ( sprite -- )
    dup loc>> gl-translate
    GL_TEXTURE_2D over texture>> glBindTexture
    init-texture
    GL_QUADS [ dim2>> four-sides ] do-state
    GL_TEXTURE_2D 0 glBindTexture ;

: rect-vertices ( lower-left upper-right -- )
    GL_QUADS [
        over first2 glVertex2d
        dup first pick second glVertex2d
        dup first2 glVertex2d
        swap first swap second glVertex2d
    ] do-state ;

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

: gl-set-clip ( loc dim -- )
    fix-coordinates glScissor ;

: gl-viewport ( loc dim -- )
    fix-coordinates glViewport ;

: init-matrices ( -- )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;
