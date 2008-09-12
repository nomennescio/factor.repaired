! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes continuations help help.topics kernel models
       sequences ui ui.backend ui.tools.debugger ui.gadgets
       ui.gadgets.books ui.gadgets.buttons ui.gadgets.labelled
       ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.tracks
       ui.gadgets.worlds ui.gadgets.presentations ui.gadgets.status-bar
       ui.commands ui.gestures assocs arrays namespaces accessors ;

IN: ui.tools.workspace

TUPLE: workspace < track book listener popup ;

: find-workspace ( gadget -- workspace ) [ workspace? ] find-parent ;

SYMBOL: workspace-window-hook

: workspace-window* ( -- workspace ) workspace-window-hook get call ;

: workspace-window ( -- ) workspace-window* drop ;

GENERIC: call-tool* ( arg tool -- )

GENERIC: tool-scroller ( tool -- scroller )

M: gadget tool-scroller drop f ;

: find-tool ( class workspace -- index tool )
  book>> children>> [ class eq? ] with find ;

: show-tool ( class workspace -- tool )
    [ find-tool swap ] keep book>> model>>
    set-model ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: get-workspace* ( quot -- workspace )
    [ >r dup workspace? r> [ drop f ] if ] curry find-window
    [ dup raise-window gadget-child ]
    [ workspace-window* ] if* ; inline

: get-workspace ( -- workspace ) [ drop t ] get-workspace* ;

: call-tool ( arg class -- )
    get-workspace show-tool call-tool* ;

: get-tool ( class -- gadget )
    get-workspace find-tool nip ;

: help-window ( topic -- )
    [
        <pane> [ [ help ] with-pane ] keep
        { 550 700 } <limited-scroller>
    ] keep
    article-title open-window ;

: hide-popup ( workspace -- )
  dup popup>> track-remove
  f >>popup
  request-focus ;

: show-popup ( gadget workspace -- )
  dup hide-popup
  over >>popup
  over f track-add drop
  request-focus ;

: show-titled-popup ( workspace gadget title -- )
    [ find-workspace hide-popup ] <closable-gadget>
    swap show-popup ;

: debugger-popup ( error workspace -- )
    swap dup compute-restarts
    [ find-workspace hide-popup ] <debugger>
    "Error" show-titled-popup ;

SYMBOL: workspace-dim

{ 600 700 } workspace-dim set-global

M: workspace pref-dim* drop workspace-dim get ;

M: workspace focusable-child*
    dup popup>> [ ] [ listener>> ] ?if ;

: workspace-page ( workspace -- gadget )
    book>> current-page ;

M: workspace tool-scroller ( workspace -- scroller )
    workspace-page tool-scroller ;

: com-scroll-up ( workspace -- )
    tool-scroller [ scroll-up-page ] when* ;

: com-scroll-down ( workspace -- )
    tool-scroller [ scroll-down-page ] when* ;

workspace "scrolling"
"The current tool's scroll pane can be scrolled from the keyboard."
{
    { T{ key-down f { C+ } "PAGE_UP" } com-scroll-up }
    { T{ key-down f { C+ } "PAGE_DOWN" } com-scroll-down }
} define-command-map
