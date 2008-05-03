USING: cairo ui.render kernel opengl.gl opengl
math byte-arrays ui.gadgets accessors arrays 
namespaces ;

IN: cairo.gadget

TUPLE: cairo-gadget width height quot ;
: <cairo-gadget> ( width height quot -- cairo-gadget )
    cairo-gadget construct-gadget 
    swap >>quot
    swap >>height
    swap >>width ;

: (with-surface) ( surface quot -- surface )
    >r dup cairo_create dup r> call cairo_destroy ;
    
: with-surface ( surface quot -- )
    (with-surface) cairo_surface_destroy ;

: cairo>bytes ( width height quot -- byte-array )
    >r over 4 *
    [ * nip <byte-array> dup CAIRO_FORMAT_ARGB32 ]
    [ cairo_image_surface_create_for_data ] 3bi
    r> with-surface ;

: cairo>png ( width height quot path -- )
    >r >r CAIRO_FORMAT_ARGB32 -rot
    cairo_image_surface_create
    r> (with-surface) dup r> cairo_surface_write_to_png
    drop cairo_surface_destroy ;

M: cairo-gadget draw-gadget* ( gadget -- )
    origin get [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
        [ width>> ] [ height>> ] [ quot>> ] tri
        [ drop GL_BGRA GL_UNSIGNED_BYTE ] [ cairo>bytes ] 3bi
        glDrawPixels
    ] with-translation ;

M: cairo-gadget pref-dim* ( gadget -- rect )
    [ width>> ] [ height>> ] bi 2array ;