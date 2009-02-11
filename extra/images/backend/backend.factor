! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel grouping fry sequences combinators
math ;
IN: images.backend

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR ;

TUPLE: image dim component-order bitmap ;

TUPLE: normalized-image < image ;

GENERIC: load-image* ( path tuple -- image )

GENERIC: >image ( object -- image )

: no-op ( -- ) ;

: normalize-component-order ( image -- image )
    dup component-order>>
    {
        { RGBA [ no-op ] }
        { BGRA [
            [
                [ 4 <sliced-groups> [ [ 0 3 ] dip <slice> reverse-here ] each ]
                [ RGBA >>component-order ] bi
            ] change-bitmap
        ] }
        { RGB [
            [ 3 <sliced-groups> [ 255 suffix ] map concat ] change-bitmap
        ] }
        { BGR [
            [
                3 <sliced-groups> dup [ [ 0 3 ] dip <slice> reverse-here ] each
                [ 255 suffix ] map concat
            ] change-bitmap
        ] }
    } case RGBA >>component-order ;

GENERIC: normalize-scan-line-order ( image -- image )

M: image normalize-scan-line-order ;
: normalize-image ( image -- image )
    normalize-component-order
    normalize-scan-line-order ;

: new-image ( dim component-order bitmap class -- image )
    new 
        swap >>bitmap
        swap >>component-order
        swap >>dim ; inline
