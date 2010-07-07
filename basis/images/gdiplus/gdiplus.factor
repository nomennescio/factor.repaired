! (c)2010 Joe Groff bsd license
USING: accessors alien.c-types alien.data alien.enums
classes.struct destructors images images.loader
io.streams.limited kernel locals math windows.com
windows.gdiplus windows.streams windows.types typed
byte-arrays grouping sequences ;
IN: images.gdiplus

SINGLETON: gdi+-image
"png" gdi+-image register-image-class
"tif" gdi+-image register-image-class
"tiff" gdi+-image register-image-class
"gif" gdi+-image register-image-class
"jpg" gdi+-image register-image-class
"jpeg" gdi+-image register-image-class
"bmp" gdi+-image register-image-class
"ico" gdi+-image register-image-class

<PRIVATE
: <GpRect> ( x y w h -- rect )
    GpRect <struct-boa> ; inline

: stream>gdi+-bitmap ( stream -- bitmap )
    stream>IStream &com-release
    { void* } [ GdipCreateBitmapFromStream check-gdi+-status ]
    [ ] with-out-parameters &GdipFree ;

: gdi+-bitmap-width ( bitmap -- w )
    { UINT } [ GdipGetImageWidth check-gdi+-status ]
    [ ] with-out-parameters ;
: gdi+-bitmap-height ( bitmap -- w )
    { UINT } [ GdipGetImageHeight check-gdi+-status ]
    [ ] with-out-parameters ;
: gdi+-lock-bitmap ( bitmap rect mode format -- data )
    { BitmapData } [ GdipBitmapLockBits check-gdi+-status ]
    [ clone ] with-out-parameters ;

:: gdi+-bitmap>data ( bitmap -- w h pixels )
    bitmap [ gdi+-bitmap-width ] [ gdi+-bitmap-height ] bi :> ( w h )
    bitmap 0 0 w h <GpRect> ImageLockModeRead enum>number
    PixelFormat32bppARGB gdi+-lock-bitmap :> bitmap-data
    bitmap-data [ Scan0>> ] [ Stride>> ] [ Height>> * ] tri
    memory>byte-array :> pixels
    bitmap bitmap-data GdipBitmapUnlockBits check-gdi+-status
    w h pixels ;
    
:: data>image ( w h pixels -- image )
    image new
        { w h } >>dim
        pixels >>bitmap
        BGRA >>component-order
        ubyte-components >>component-type
        f >>upside-down? ;

PRIVATE>

M: gdi+-image stream>image
    drop
    dup limited-stream? [ stream-eofs >>mode ] when [
        start-gdi+ &stop-gdi+ drop
        stream>gdi+-bitmap
        gdi+-bitmap>data
        data>image
    ] with-destructors ;
