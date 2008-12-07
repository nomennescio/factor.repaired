IN: ui.cocoa.views.tests
USING: ui.cocoa.views tools.test kernel math.geometry.rect
namespaces ;

[ t ] [
    T{ rect
        { loc { 0 0 } }
        { dim { 1000 1000 } }
    } "world" set

    T{ rect
        { loc { 1.5 2.25 } }
        { dim { 13.0 14.0 } }
    } dup "world" get rect>NSRect "world" get NSRect>rect =
] unit-test
