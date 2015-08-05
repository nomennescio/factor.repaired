! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors fry help.markup help.stylesheet
io.styles kernel math math.ranges models namespaces parser
sequences ui ui.gadgets ui.gadgets.books ui.gadgets.panes
ui.gestures ui.pens.gradient ;
IN: slides

CONSTANT: stylesheet
    H{
        { default-span-style
            H{
                { font-name "sans-serif" }
                { font-size 36 }
            }
        }
        { default-block-style
            H{
                { wrap-margin 1100 }
            }
        }
        { code-char-style
            H{
                { font-name "monospace" }
                { font-size 36 }
            }
        }
        { code-style
            H{
                { page-color T{ rgba f 0.4 0.4 0.4 0.3 } }
            }
        }
        { snippet-style
            H{
                { font-name "monospace" }
                { font-size 36 }
                { foreground T{ rgba f 0.1 0.1 0.4 1 } }
            }
        }
        { table-content-style
            H{ { wrap-margin 1000 } }
        }
        { list-style
            H{ { table-gap { 10 20 } } }
        }
    }

: $title ( string -- )
    [
        H{
            { font-name "sans-serif" }
            { font-size 48 }
        } format
    ] ($block) ;

: $divider ( -- )
    [
        <gadget>
            {
                T{ rgba f 0.25 0.25 0.25 1.0 }
                T{ rgba f 1.0 1.0 1.0 0.0 }
            } <gradient> >>interior
            { 800 10 } >>dim
            { 1 0 } >>orientation
        gadget.
    ] ($block) ;

: page-theme ( gadget -- gadget )
    {
        T{ rgba f 0.8 0.8 1.0 1.0 }
        T{ rgba f 0.8 1.0 1.0 1.0 }
    } <gradient> >>interior ;

: <page> ( list -- gadget )
    [
        stylesheet clone [
            [ print-element ] with-default-style
        ] with-variables
    ] make-pane page-theme ;

: $slide ( element -- )
    unclip $title $divider $list ;

TUPLE: slides < book ;

: <slides> ( slides -- gadget )
    0 <model> slides new-book [ <page> add-gadget ] reduce ;

: change-page ( book n -- )
    over control-value + over children>> length rem
    swap set-control-value ;

: next-page ( book -- ) 1 change-page ;

: prev-page ( book -- ) -1 change-page ;

: strip-tease ( data -- seq )
    first3 2 over length [a,b] [ head 3array ] with with with map ;

SYNTAX: STRIP-TEASE:
    parse-definition strip-tease append! ;

\ slides H{
    { T{ button-down } [ request-focus ] }
    { T{ key-down f f "DOWN" } [ next-page ] }
    { T{ key-down f f "UP" } [ prev-page ] }
    { T{ key-down f f "f" } [ toggle-fullscreen ] }
} set-gestures

: slides-window ( slides -- )
    '[ _ <slides> "Slides" open-window ] with-ui ;
