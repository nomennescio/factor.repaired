! Copyright (C) 2009 Joe Groff, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel combinators sequences
math windows.gdi32 windows.types images destructors
accessors fry locals ;
IN: windows.offscreen

: (bitmap-info) ( dim -- BITMAPINFO )
    "BITMAPINFO" <c-object> [
        BITMAPINFO-bmiHeader {
            [ nip "BITMAPINFOHEADER" heap-size swap set-BITMAPINFOHEADER-biSize ]
            [ [ first ] dip set-BITMAPINFOHEADER-biWidth ]
            [ [ second ] dip set-BITMAPINFOHEADER-biHeight ]
            [ nip 1 swap set-BITMAPINFOHEADER-biPlanes ]
            [ nip 32 swap set-BITMAPINFOHEADER-biBitCount ]
            [ nip BI_RGB swap set-BITMAPINFOHEADER-biCompression ]
            [ [ first2 * 4 * ] dip set-BITMAPINFOHEADER-biSizeImage ]
            [ nip 72 swap set-BITMAPINFOHEADER-biXPelsPerMeter ]
            [ nip 72 swap set-BITMAPINFOHEADER-biYPelsPerMeter ]
            [ nip 0 swap set-BITMAPINFOHEADER-biClrUsed ]
            [ nip 0 swap set-BITMAPINFOHEADER-biClrImportant ]
        } 2cleave
    ] keep ;

: make-bitmap ( dim dc -- hBitmap bits )
    [ nip ]
    [
        swap (bitmap-info) DIB_RGB_COLORS f <void*>
        [ f 0 CreateDIBSection ] keep *void*
    ] 2bi
    [ [ SelectObject drop ] keep ] dip ;

: make-offscreen-dc-and-bitmap ( dim -- dc hBitmap bits )
    [ f CreateCompatibleDC ] dip over make-bitmap ;

: bitmap>byte-array ( bits dim -- byte-array )
    product 4 * memory>byte-array ;

: bitmap>image ( bits dim -- image )
    [ bitmap>byte-array ] keep
    <image>
        swap >>dim
        swap >>bitmap
        BGRX >>component-order
        ubyte-components >>component-type
        t >>upside-down? ;

: with-memory-dc ( quot: ( hDC -- ) -- )
    [ [ f CreateCompatibleDC &DeleteDC ] dip call ] with-destructors ; inline

:: make-bitmap-image ( dim dc quot -- image )
    dim dc make-bitmap [ &DeleteObject drop ] dip
    quot dip
    dim bitmap>image ; inline
