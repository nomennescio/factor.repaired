! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs debugger ui.tools.workspace
ui.tools.operations ui.tools.traceback ui.tools.browser
ui.tools.inspector ui.tools.listener ui.tools.profiler
ui.tools.operations inspector io kernel math models namespaces
prettyprint quotations sequences ui ui.commands ui.gadgets
ui.gadgets.books ui.gadgets.buttons ui.gadgets.labelled
ui.gadgets.scrollers ui.gadgets.tracks ui.gadgets.worlds
ui.gadgets.presentations ui.gestures words vocabs.loader
tools.test tools.vocabs ui.gadgets.buttons ui.gadgets.status-bar
mirrors ;
IN: ui.tools

: <workspace-tabs> ( -- tabs )
    g gadget-model
    "tool-switching" workspace command-map
    [ command-string ] { } assoc>map <enum> >alist
    <toggle-buttons> ;

: <workspace-book> ( -- gadget )
    [
        <stack-display> ,
        <browser-gadget> ,
        <inspector-gadget> ,
        <profiler-gadget> ,
    ] { } make g gadget-model <book> ;

: <workspace> ( -- workspace )
    { 0 1 } workspace new-track
        0 <model> >>model
    [
        [
            <listener-gadget> g set-workspace-listener
            <workspace-book> g set-workspace-book
            <workspace-tabs> f track,
            g workspace-book 1/5 track,
            g workspace-listener 4/5 track,
            toolbar,
        ] with-gadget
    ] keep ;

: resize-workspace ( workspace -- )
    dup track-sizes over control-value zero? [
        1/5 1 pick set-nth
        4/5 2 rot set-nth
    ] [
        2/3 1 pick set-nth
        1/3 2 rot set-nth
    ] if relayout ;

M: workspace model-changed
    nip
    dup workspace-listener listener-gadget-output scroll>bottom
    dup resize-workspace
    request-focus ;

[ workspace-window ] ui-hook set-global

: com-listener ( workspace -- ) stack-display select-tool ;

: com-browser ( workspace -- ) browser-gadget select-tool ;

: com-inspector ( workspace -- ) inspector-gadget select-tool ;

: com-profiler ( workspace -- ) profiler-gadget select-tool ;

workspace "tool-switching" f {
    { T{ key-down f { A+ } "1" } com-listener }
    { T{ key-down f { A+ } "2" } com-browser }
    { T{ key-down f { A+ } "3" } com-inspector }
    { T{ key-down f { A+ } "4" } com-profiler }
} define-command-map

workspace "multi-touch" f {
    { T{ zoom-out-action } com-listener }
    { T{ up-action } refresh-all }
} define-command-map

\ workspace-window
H{ { +nullary+ t } } define-command

\ refresh-all
H{ { +nullary+ t } { +listener+ t } } define-command

workspace "workflow" f {
    { T{ key-down f { C+ } "n" } workspace-window }
    { T{ key-down f f "ESC" } hide-popup }
    { T{ key-down f f "F2" } refresh-all }
} define-command-map

[
    <workspace> dup "Factor workspace" open-status-window
] workspace-window-hook set-global

: inspect-continuation ( traceback -- )
    control-value [ inspect ] curry call-listener ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map
