! Copyright (C) 2005, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.labels ui.render
kernel math namespaces sequences math.order math.geometry.rect
locals ;
IN: ui.gadgets.paragraphs

! A word break gadget
TUPLE: word-break-gadget < label ;

: <word-break-gadget> ( text -- gadget )
    word-break-gadget new-label ;

M: word-break-gadget draw-gadget* drop ;

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph < gadget margin ;

: <paragraph> ( margin -- gadget )
    paragraph new-gadget
    horizontal >>orientation
    swap >>margin ;

SYMBOL: x SYMBOL: max-x

SYMBOL: y SYMBOL: max-y

SYMBOL: line-height

SYMBOL: margin

: overrun? ( width -- ? ) x get + margin get > ;

: zero-vars ( seq -- ) [ 0 swap set ] each ;

: wrap-line ( -- )
    line-height get y +@
    { x line-height } zero-vars ;

: wrap-pos ( -- pos ) x get y get 2array ; inline

: advance-x ( x -- )
    x +@
    x get max-x [ max ] change ;

: advance-y ( y -- )
    dup line-height [ max ] change
    y get + max-y [ max ] change ;

:: wrap-step ( quot child -- )
    child pref-dim
    [
        child
        [
            word-break-gadget?
            [ drop ] [ first overrun? [ wrap-line ] when ] if
        ]
        [ wrap-pos quot call ] bi
    ]
    [ first advance-x ]
    [ second advance-y ]
    tri ; inline

: wrap-dim ( -- dim ) max-x get max-y get 2array ;

: init-wrap ( paragraph -- )
    margin>> margin set
    { x max-x y max-y line-height } zero-vars ;

: do-wrap ( paragraph quot -- dim )
    [
        swap dup init-wrap
        [ wrap-step ] with each-child wrap-dim
    ] with-scope ; inline

M: paragraph pref-dim*
    [ 2drop ] do-wrap ;

M: paragraph layout*
    [ swap dup prefer (>>loc) ] do-wrap drop ;
