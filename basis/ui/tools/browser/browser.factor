! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger help help.topics kernel models compiler.units
assocs words vocabs accessors fry combinators.short-circuit
models models.history tools.apropos ui.tools.workspace
ui.commands ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.editors ui.gadgets.labels ui ;
IN: ui.tools.browser

TUPLE: browser-gadget < track pane scroller search-field ;

: show-help ( link browser-gadget -- )
    model>> dup add-history
    [ >link ] dip set-model ;

: <help-pane> ( browser-gadget -- gadget )
    model>> [ '[ _ print-topic ] try ] <pane-control> ;

: search-browser ( string browser -- )
    [ <apropos> ] dip show-help ;

: <search-field> ( browser -- field )
    '[ _ search-browser ] <action-field>
        10 >>min-width
        10 >>max-width ;

: <browser-toolbar> ( browser -- toolbar )
    <shelf>
        { 5 5 } >>gap
        over <toolbar> add-gadget
        "Search:" <label> add-gadget
        swap search-field>> add-gadget ;

: <help-pane-scroller> ( browser -- scroller )
    pane>> <limited-scroller>
        { 550 700 } >>max-dim
        { 550 700 } >>min-dim ;

: <browser-gadget> ( link -- gadget )
    { 0 1 } browser-gadget new-track
        swap <history> >>model
        dup <search-field> >>search-field
        dup <browser-toolbar> f track-add
        dup <help-pane> >>pane
        dup <help-pane-scroller> >>scroller
        dup scroller>> 1 track-add ;

M: browser-gadget graft*
    [ add-definition-observer ] [ call-next-method ] bi ;

M: browser-gadget ungraft*
    [ call-next-method ] [ remove-definition-observer ] bi ;

: showing-definition? ( defspec assoc -- ? )
    {
        [ key? ]
        [ [ dup word-link? [ name>> ] when ] dip key? ]
        [ [ dup vocab-link? [ vocab ] when ] dip key? ]
    } 2|| ;

M: browser-gadget definitions-changed ( assoc browser -- )
    model>> tuck value>> swap showing-definition?
    [ notify-connections ] [ drop ] if ;

M: browser-gadget focusable-child* search-field>> ;

: open-browser-window ( link -- )
    <browser-gadget> "Browser" open-window ;

: browser-window ( link -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-help ] bi ]
    [ open-browser-window ] if* ;

: com-follow ( link -- ) browser-window ;

: com-back ( browser -- ) model>> go-back ;

: com-forward ( browser -- ) model>> go-forward ;

: com-documentation ( browser -- ) "handbook" swap show-help ;

: browser-help ( -- ) "ui-browser" browser-window ;

\ browser-help H{ { +nullary+ t } } define-command

: com-page-up ( browser -- )
    scroller>> scroll-up-page ;

: com-page-down ( browser -- )
    scroller>> scroll-down-page ;

: com-scroll-up ( browser -- )
    scroller>> scroll-up-line ;

: com-scroll-down ( browser -- )
    scroller>> scroll-down-line ;

browser-gadget "toolbar" f {
    { T{ key-down f { A+ } "LEFT" } com-back }
    { T{ key-down f { A+ } "RIGHT" } com-forward }
    { f com-documentation }
    { T{ key-down f f "F1" } browser-help }
} define-command-map

browser-gadget "multi-touch" f {
    { T{ left-action } com-back }
    { T{ right-action } com-forward }
} define-command-map

browser-gadget "scrolling"
"The browser's scroll pane can be scrolled from the keyboard."
{
    { T{ key-down f f "UP" } com-scroll-up }
    { T{ key-down f f "DOWN" } com-scroll-down }
    { T{ key-down f f "PAGE_UP" } com-page-up }
    { T{ key-down f f "PAGE_DOWN" } com-page-down }
} define-command-map