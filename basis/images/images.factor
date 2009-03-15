! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors grouping sequences combinators
math specialized-arrays.direct.uint byte-arrays fry
specialized-arrays.direct.ushort specialized-arrays.uint
specialized-arrays.ushort specialized-arrays.float ;
IN: images

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
R16G16B16 R32G32B32 R16G16B16A16 R32G32B32A32 ;

: bytes-per-pixel ( component-order -- n )
    {
        { BGR [ 3 ] }
        { RGB [ 3 ] }
        { BGRA [ 4 ] }
        { RGBA [ 4 ] }
        { ABGR [ 4 ] }
        { ARGB [ 4 ] }
        { RGBX [ 4 ] }
        { XRGB [ 4 ] }
        { BGRX [ 4 ] }
        { XBGR [ 4 ] }
        { R16G16B16 [ 6 ] }
        { R32G32B32 [ 12 ] }
        { R16G16B16A16 [ 8 ] }
        { R32G32B32A32 [ 16 ] }
    } case ;

TUPLE: image dim component-order upside-down? bitmap ;

: <image> ( -- image ) image new ; inline

GENERIC: load-image* ( path tuple -- image )

: add-dummy-alpha ( seq -- seq' )
    3 <groups> [ 255 suffix ] map concat ;

: normalize-floats ( byte-array -- byte-array )
    byte-array>float-array [ 255.0 * >integer ] B{ } map-as ;

GENERIC: normalize-component-order* ( image component-order -- image )

: normalize-component-order ( image -- image )
    dup component-order>> '[ _ normalize-component-order* ] change-bitmap ;

M: RGBA normalize-component-order* drop ;

M: R32G32B32A32 normalize-component-order*
    drop normalize-floats ;

M: R32G32B32 normalize-component-order*
    drop normalize-floats add-dummy-alpha ;

: RGB16>8 ( bitmap -- bitmap' )
    byte-array>ushort-array [ -8 shift ] B{ } map-as ; inline

M: R16G16B16A16 normalize-component-order*
    drop RGB16>8 ;

M: R16G16B16 normalize-component-order*
    drop RGB16>8 add-dummy-alpha ;

: BGR>RGB ( bitmap -- pixels )
    3 <sliced-groups> [ <reversed> ] map B{ } join ; inline

: BGRA>RGBA ( bitmap -- pixels )
    4 <sliced-groups>
    [ unclip-last-slice [ <reversed> ] dip suffix ] map concat ; inline

M: BGRA normalize-component-order*
    drop BGRA>RGBA ;

M: RGB normalize-component-order*
    drop add-dummy-alpha ;

M: BGR normalize-component-order*
    drop BGR>RGB add-dummy-alpha ;

: ARGB>RGBA ( bitmap -- bitmap' )
    4 <groups> [ unclip suffix ] map B{ } join ; inline

M: ARGB normalize-component-order*
    drop ARGB>RGBA ;

M: ABGR normalize-component-order*
    drop ARGB>RGBA BGRA>RGBA ;

: normalize-scan-line-order ( image -- image )
    dup upside-down?>> [
        dup dim>> first 4 * '[
            _ <groups> reverse concat
        ] change-bitmap
        f >>upside-down?
    ] when ;

: normalize-image ( image -- image )
    [ >byte-array ] change-bitmap
    normalize-component-order
    normalize-scan-line-order
    RGBA >>component-order ;
