! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry kernel
opengl opengl.gl combinators images images.tesselation grouping
specialized-arrays.float locals sequences math math.vectors
math.matrices generalizations fry columns arrays ;
IN: opengl.textures

: gen-texture ( -- id ) [ glGenTextures ] (gen-gl-object) ;

: delete-texture ( id -- ) [ glDeleteTextures ] (delete-gl-object) ;

GENERIC: component-order>format ( component-order -- format type )

M: RGB component-order>format drop GL_RGB GL_UNSIGNED_BYTE ;
M: BGR component-order>format drop GL_BGR GL_UNSIGNED_BYTE ;
M: RGBA component-order>format drop GL_RGBA GL_UNSIGNED_BYTE ;
M: ARGB component-order>format drop GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV ;
M: BGRA component-order>format drop GL_BGRA_EXT GL_UNSIGNED_BYTE ;
M: BGRX component-order>format drop GL_BGRA_EXT GL_UNSIGNED_BYTE ;

GENERIC: draw-texture ( texture -- )

GENERIC: draw-scaled-texture ( dim texture -- )

<PRIVATE

TUPLE: single-texture image loc dim texture-coords texture display-list disposed ;

: repeat-last ( seq n -- seq' )
    over peek pad-tail concat ;

: power-of-2-bitmap ( rows dim size -- bitmap dim )
    '[
        first2
        [ [ _ ] dip '[ _ group _ repeat-last ] map ]
        [ repeat-last ]
        bi*
    ] keep ;

: image-rows ( image -- rows )
    [ bitmap>> ]
    [ dim>> first ]
    [ component-order>> bytes-per-pixel ]
    tri * group ; inline

: power-of-2-image ( image -- image )
    dup dim>> [ [ 0 = ] [ power-of-2? ] bi or ] all? [
        clone dup
        [ image-rows ]
        [ dim>> [ next-power-of-2 ] map ]
        [ component-order>> bytes-per-pixel ] tri
        power-of-2-bitmap
        [ >>bitmap ] [ >>dim ] bi*
    ] unless ;

:: make-texture ( image -- id )
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            GL_TEXTURE_2D
            0
            GL_RGBA
            image dim>> first2
            0
            image component-order>> component-order>format
            image bitmap>>
            glTexImage2D
        ] do-attribs
    ] keep ;

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT glTexParameteri ;

: with-texturing ( quot -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                COLOR: white gl-color
                call
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ; inline

: (draw-textured-rect) ( dim texture -- )
    [ loc>> ]
    [ [ GL_TEXTURE_2D ] dip texture>> glBindTexture ]
    [ init-texture texture-coords>> gl-texture-coord-pointer ] tri
    swap gl-fill-rect ;

: draw-textured-rect ( dim texture -- )
    [
        [ image>> has-alpha? [ GL_BLEND glDisable ] unless ]
        [ (draw-textured-rect) GL_TEXTURE_2D 0 glBindTexture ]
        [ image>> has-alpha? [ GL_BLEND glEnable ] unless ]
        tri
    ] with-texturing ;

: texture-coords ( texture -- coords )
    [
        [ dim>> ] [ image>> dim>> ] bi v/
        { { 0 0 } { 1 0 } { 1 1 } { 0 1 } }
        [ v* ] with map
    ] keep
    image>> upside-down?>> [ [ first2 1 swap - 2array ] map ] when
    float-array{ } join ;

: make-texture-display-list ( texture -- dlist )
    GL_COMPILE [ [ dim>> ] keep draw-textured-rect ] make-dlist ;

: <single-texture> ( image loc dim -- texture )
    [ power-of-2-image ] 2dip
    single-texture new swap >>dim swap >>loc swap >>image
    dup image>> dim>> product 0 = [
        dup texture-coords >>texture-coords
        dup image>> make-texture >>texture
        dup make-texture-display-list >>display-list
    ] unless ;

M: single-texture dispose*
    [ texture>> [ delete-texture ] when* ]
    [ display-list>> [ delete-dlist ] when* ] bi ;

M: single-texture draw-texture display-list>> [ glCallList ] when* ;

M: single-texture draw-scaled-texture
    dup texture>> [ draw-textured-rect ] [ 2drop ] if ;

TUPLE: multi-texture grid display-list loc disposed ;

: image-locs ( image-grid -- loc-grid )
    [ first [ dim>> first ] map ] [ 0 <column> [ dim>> second ] map ] bi
    [ 0 [ + ] accumulate nip ] bi@
    cross-zip flip ;

: <texture-grid> ( image-grid loc -- grid )
    [ dup image-locs ] dip
    '[ [ _ v+ over dim>> <single-texture> |dispose ] 2map ] 2map ;

: draw-textured-grid ( grid -- )
    [ [ [ dim>> ] keep (draw-textured-rect) ] each ] each ;

: grid-has-alpha? ( grid -- ? )
    first first image>> has-alpha? ;

: make-textured-grid-display-list ( grid -- dlist )
    GL_COMPILE [
        [
            [ grid-has-alpha? [ GL_BLEND glDisable ] unless ]
            [ [ [ [ dim>> ] keep (draw-textured-rect) ] each ] each ]
            [ grid-has-alpha? [ GL_BLEND glEnable ] unless ] tri
            GL_TEXTURE_2D 0 glBindTexture
        ] with-texturing
    ] make-dlist ;

: <multi-texture> ( image-grid loc -- multi-texture )
    [
        [
            <texture-grid> dup
            make-textured-grid-display-list
        ] keep
        f multi-texture boa
    ] with-destructors ;

M: multi-texture draw-texture display-list>> [ glCallList ] when* ;

M: multi-texture dispose* grid>> [ [ dispose ] each ] each ;

CONSTANT: max-texture-size { 512 512 }

PRIVATE>

: small-texture? ( dim -- ? )
    max-texture-size [ <= ] 2all? ;

: <texture> ( image loc dim -- texture )
    pick dim>> small-texture?
    [ <single-texture> ]
    [ drop [ max-texture-size tesselate ] dip <multi-texture> ] if ;