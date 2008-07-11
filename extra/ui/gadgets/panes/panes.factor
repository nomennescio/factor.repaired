! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.paragraphs ui.gadgets.incremental ui.gadgets.packs
ui.gadgets.theme ui.clipboards ui.gestures ui.traverse ui.render
hashtables io kernel namespaces sequences io.styles strings
quotations math opengl combinators math.vectors
sorting splitting io.streams.nested assocs
ui.gadgets.presentations ui.gadgets.slots ui.gadgets.grids
ui.gadgets.grid-lines classes.tuple models continuations
destructors accessors ;
IN: ui.gadgets.panes

TUPLE: pane < pack
output current prototype scrolls?
selection-color caret mark selecting? ;

: clear-selection ( pane -- )
    f >>caret
    f >>mark
    drop ;

: add-output ( current pane -- )
    [ set-pane-output ] [ add-gadget ] 2bi ;

: add-current ( current pane -- )
    [ set-pane-current ] [ add-gadget ] 2bi ;

: prepare-line ( pane -- )
    [ clear-selection ]
    [ [ pane-prototype clone ] keep add-current ] bi ;

: pane-caret&mark ( pane -- caret mark )
    [ caret>> ] [ mark>> ] bi ;

: selected-children ( pane -- seq )
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection
    selected-children gadget-text ;

: pane-clear ( pane -- )
    [ clear-selection ]
    [ pane-output clear-incremental ]
    [ pane-current clear-gadget ]
    tri ;

: pane-theme ( pane -- pane )
    selection-color >>selection-color ; inline

: new-pane ( class -- pane )
    new-gadget
        { 0 1 } >>orientation
        <shelf> >>prototype
        <incremental> over add-output
        dup prepare-line
        pane-theme ;

: <pane> ( -- pane )
    pane new-pane ;

GENERIC: draw-selection ( loc obj -- )

: if-fits ( rect quot -- )
    >r clip get over intersects? r> [ drop ] if ; inline

M: gadget draw-selection ( loc gadget -- )
    swap offset-rect [ rect-extent gl-fill-rect ] if-fits ;

M: node draw-selection ( loc node -- )
    2dup node-value swap offset-rect [
        drop 2dup
        [ node-value rect-loc v+ ] keep
        node-children [ draw-selection ] with each
    ] if-fits 2drop ;

M: pane draw-gadget*
    dup gadget-selection? [
        dup pane-selection-color gl-color
        origin get over rect-loc v- swap selected-children
        [ draw-selection ] with each
    ] [
        drop
    ] if ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ scroll>bottom ] [ drop ] if ;

TUPLE: pane-stream pane ;

C: <pane-stream> pane-stream

: smash-line ( current -- gadget )
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        [ drop ]
    } cond ;

: smash-pane ( pane -- gadget ) pane-output smash-line ;

: pane-nl ( pane -- )
    dup pane-current dup unparent smash-line
    over pane-output add-incremental
    prepare-line ;

: pane-write ( pane seq -- )
    [ dup pane-nl ]
    [ over pane-current stream-write ]
    interleave drop ;

: pane-format ( style pane seq -- )
    [ dup pane-nl ]
    [ 2over pane-current stream-format ]
    interleave 2drop ;

GENERIC: write-gadget ( gadget stream -- )

M: pane-stream write-gadget
    pane-stream-pane pane-current add-gadget ;

M: style-stream write-gadget
    stream>> write-gadget ;

: print-gadget ( gadget stream -- )
    tuck write-gadget stream-nl ;

: gadget. ( gadget -- )
    output-stream get print-gadget ;

: ?nl ( stream -- )
    dup pane-stream-pane pane-current gadget-children empty?
    [ dup stream-nl ] unless drop ;

: with-pane ( pane quot -- )
    over scroll>top
    over pane-clear >r <pane-stream> r>
    over >r with-output-stream* r> ?nl ; inline

: make-pane ( quot -- gadget )
    <pane> [ swap with-pane ] keep smash-pane ; inline

: <scrolling-pane> ( -- pane )
    <pane> t over set-pane-scrolls? ;

TUPLE: pane-control < pane quot ;

M: pane-control model-changed
    swap model-value swap dup pane-control-quot with-pane ;

: <pane-control> ( model quot -- pane )
    pane-control new-pane
        swap >>quot
        swap >>model ;

: do-pane-stream ( pane-stream quot -- )
    >r pane-stream-pane r> keep scroll-pane ; inline

M: pane-stream stream-nl
    [ pane-nl ] do-pane-stream ;

M: pane-stream stream-write1
    [ pane-current stream-write1 ] do-pane-stream ;

M: pane-stream stream-write
    [ swap string-lines pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ rot string-lines pane-format ] do-pane-stream ;

M: pane-stream dispose drop ;

M: pane-stream stream-flush drop ;

M: pane-stream make-span-stream
    swap <style-stream> <ignore-close-stream> ;

! Character styles

: apply-style ( style gadget key quot -- style gadget )
    >r pick at r> when* ; inline

: apply-foreground-style ( style gadget -- style gadget )
    foreground [ over set-label-color ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ solid-interior ] apply-style ;

: specified-font ( style -- font )
    [ font swap at "monospace" or ] keep
    [ font-style swap at plain or ] keep
    font-size swap at 12 or 3array ;

: apply-font-style ( style gadget -- style gadget )
    over specified-font over set-label-font ;

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <presentation> ] apply-style ;

: style-label ( style gadget -- gadget )
    apply-foreground-style
    apply-background-style
    apply-font-style
    apply-presentation-style
    nip ; inline

: <styled-label> ( style text -- gadget )
    <label> style-label ;

! Paragraph styles

: apply-wrap-style ( style pane -- style pane )
    wrap-margin [
        2dup <paragraph> >>prototype drop
        <paragraph> >>current
    ] apply-style ;

: apply-border-color-style ( style gadget -- style gadget )
    border-color [ solid-boundary ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [ solid-interior ] apply-style ;

: apply-path-style ( style gadget -- style gadget )
    presented-path [ <editable-slot> ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ <border> ] apply-style ;

: apply-printer-style ( style gadget -- style gadget )
    presented-printer [ [ make-pane ] curry >>printer ] apply-style ;

: style-pane ( style pane -- pane )
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    apply-path-style
    apply-printer-style
    nip ;

TUPLE: nested-pane-stream < pane-stream style parent ;

: new-nested-pane-stream ( style parent class -- stream )
    new
        swap >>parent
        swap <pane> apply-wrap-style [ >>style ] [ >>pane ] bi* ;
    inline

: unnest-pane-stream ( stream -- child parent )
    dup ?nl
    dup style>>
    over pane>> smash-pane style-pane
    swap parent>> ;

TUPLE: pane-block-stream < nested-pane-stream ;

M: pane-block-stream dispose
    unnest-pane-stream write-gadget ;

M: pane-stream make-block-stream
    pane-block-stream new-nested-pane-stream ;

! Tables
: apply-table-gap-style ( style grid -- style grid )
    table-gap [ over set-grid-gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> over set-gadget-boundary ]
    apply-style ;

: styled-grid ( style grid -- grid )
    <grid>
    f over set-grid-fill?
    apply-table-gap-style
    apply-table-border-style
    nip ;

TUPLE: pane-cell-stream < nested-pane-stream ;

M: pane-cell-stream dispose ?nl ;

M: pane-stream make-cell-stream
    pane-cell-stream new-nested-pane-stream ;

M: pane-stream stream-write-table
    >r
    swap [ [ pane-stream-pane smash-pane ] map ] map
    styled-grid
    r> print-gadget ;

! Stream utilities
M: pack dispose drop ;

M: paragraph dispose drop ;

: gadget-write ( string gadget -- )
    over empty?
    [ 2drop ] [ >r <label> text-theme r> add-gadget ] if ;

M: pack stream-write gadget-write ;

: gadget-bl ( style stream -- )
    >r " " <word-break-gadget> style-label r> add-gadget ;

M: paragraph stream-write
    swap " " split
    [ H{ } over gadget-bl ] [ over gadget-write ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    >r 1string r> stream-write ;

M: pack stream-write1 gadget-write1 ;

M: paragraph stream-write1
    over CHAR: \s =
    [ H{ } swap gadget-bl drop ] [ gadget-write1 ] if ;

: gadget-format ( string style stream -- )
    pick empty?
    [ 3drop ] [ >r swap <styled-label> r> add-gadget ] if ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    presented pick at [
        gadget-format
    ] [
        rot " " split
        [ 2dup gadget-bl ]
        [ 2over gadget-format ] interleave
        2drop
    ] if ;

: caret>mark ( pane -- )
    dup pane-caret over set-pane-mark relayout-1 ;

GENERIC: sloppy-pick-up* ( loc gadget -- n )

M: pack sloppy-pick-up*
    dup gadget-orientation
    swap gadget-children
    (fast-children-on) ;

M: gadget sloppy-pick-up*
    gadget-children [ inside? ] with find-last drop ;

M: f sloppy-pick-up*
    2drop f ;

: wet-and-sloppy ( loc gadget n -- newloc newgadget )
    swap nth-gadget [ rect-loc v- ] keep ;

: sloppy-pick-up ( loc gadget -- path )
    2dup sloppy-pick-up* dup
    [ [ wet-and-sloppy sloppy-pick-up ] keep prefix ]
    [ 3drop { } ]
    if ;

: move-caret ( pane -- )
    dup hand-rel
    over sloppy-pick-up
    over set-pane-caret
    relayout-1 ;

: begin-selection ( pane -- )
    dup move-caret f swap set-pane-mark ;

: extend-selection ( pane -- )
    hand-moved? [
        dup selecting?>> [
            dup move-caret
        ] [
            dup hand-clicked get child? [
                t >>selecting?
                dup hand-clicked set-global
                dup move-caret
                dup caret>mark
            ] when
        ] if
        dup dup pane-caret gadget-at-path scroll>gadget
    ] when drop ;

: end-selection ( pane -- )
    f >>selecting?
    hand-moved? [
        [ com-copy-selection ] [ request-focus ] bi
    ] [
        relayout-1
    ] if ;

: select-to-caret ( pane -- )
    dup pane-mark [ dup caret>mark ] unless
    dup move-caret
    dup request-focus
    com-copy-selection ;

pane H{
    { T{ button-down } [ begin-selection ] }
    { T{ button-down f { S+ } 1 } [ select-to-caret ] }
    { T{ button-up f { S+ } 1 } [ drop ] }
    { T{ button-up } [ end-selection ] }
    { T{ drag } [ extend-selection ] }
    { T{ copy-action } [ com-copy ] }
} set-gestures
