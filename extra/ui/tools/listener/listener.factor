! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector ui.tools.interactor ui.tools.inspector
ui.tools.workspace help.markup io io.streams.duplex io.styles
kernel models namespaces parser quotations sequences ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.operations vocabs words
prettyprint listener debugger threads boxes concurrency.flags
math arrays generic accessors combinators ;
IN: ui.tools.listener

TUPLE: listener-gadget input output stack ;

: listener-output, ( -- )
    <scrolling-pane> g-> set-listener-gadget-output
    <scroller> "Output" <labelled-gadget> 1 track, ;

: listener-stream ( listener -- stream )
    dup listener-gadget-input
    swap listener-gadget-output <pane-stream>
    <duplex-stream> ;

: <listener-input> ( listener -- gadget )
    listener-gadget-output <pane-stream> <interactor> ;

TUPLE: input-scroller ;

: <input-scroller> ( interactor -- scroller )
    <scroller>
    input-scroller new
    [ set-gadget-delegate ] keep ;

M: input-scroller pref-dim*
    drop { 0 100 } ;

: listener-input, ( -- )
    g <listener-input> g-> set-listener-gadget-input
    <input-scroller> "Input" <labelled-gadget> f track, ;

: welcome. ( -- )
   "If this is your first time with Factor, please read the " print
   "cookbook" ($link) "." print nl ;

M: listener-gadget focusable-child*
    listener-gadget-input ;

M: listener-gadget call-tool* ( input listener -- )
    >r input-string r> listener-gadget-input set-editor-string ;

M: listener-gadget tool-scroller
    listener-gadget-output find-scroller ;

: wait-for-listener ( listener -- )
    #! Wait for the listener to start.
    listener-gadget-input interactor-flag wait-for-flag ;

: workspace-busy? ( workspace -- ? )
    workspace-listener listener-gadget-input interactor-busy? ;

: listener-input ( string -- )
    get-workspace
    workspace-listener
    listener-gadget-input set-editor-string ;

: (call-listener) ( quot listener -- )
    listener-gadget-input interactor-call ;

: call-listener ( quot -- )
    [ workspace-busy? not ] get-workspace* workspace-listener
    [ dup wait-for-listener (call-listener) ] 2curry
    "Listener call" spawn drop ;

M: listener-command invoke-command ( target command -- )
    command-quot call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ operation-hook call ] keep operation-quot call-listener ;

: eval-listener ( string -- )
    get-workspace
    workspace-listener
    listener-gadget-input [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry call-listener
    ] if ;

: com-end ( listener -- )
    listener-gadget-input interactor-eof ;

: clear-output ( listener -- )
    listener-gadget-output pane-clear ;

\ clear-output H{ { +listener+ t } } define-command

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

GENERIC: word-completion-string ( word -- string )

M: word word-completion-string
    word-name ;

M: method-body word-completion-string
    "method-generic" word-prop word-completion-string ;

USE: generic.standard.engines.tuple

M: engine-word word-completion-string
    "engine-generic" word-prop word-completion-string ;

: use-if-necessary ( word seq -- )
    >r word-vocabulary vocab-words r>
    {
        { [ dup not ] [ 2drop ] }
        { [ 2dup memq? ] [ 2drop ] }
        [ push ]
    } cond ;

: insert-word ( word -- )
    get-workspace workspace-listener input>>
    [ >r word-completion-string r> user-input ]
    [ interactor-use use-if-necessary ]
    2bi ;

: quot-action ( interactor -- lines )
    dup control-value
    dup "\n" join pick add-interactor-history
    swap select-all ;

TUPLE: stack-display ;

: <stack-display> ( -- gadget )
    stack-display new
    g workspace-listener swap [
        dup <toolbar> f track,
        listener-gadget-stack [ stack. ]
        t "Data stack" <labelled-pane> 1 track,
    ] { 0 1 } build-track ;

M: stack-display tool-scroller
    find-workspace workspace-listener tool-scroller ;

: ui-listener-hook ( listener -- )
    >r datastack r> listener-gadget-stack set-model ;

: ui-error-hook ( error listener -- )
    find-workspace debugger-popup ;

: ui-inspector-hook ( obj listener -- )
    find-workspace inspector-gadget
    swap show-tool inspect-object ;

: listener-thread ( listener -- )
    dup listener-stream [
        dup [ ui-listener-hook ] curry listener-hook set
        dup [ ui-error-hook ] curry error-hook set
        [ ui-inspector-hook ] curry inspector-hook set
        welcome.
        listener
    ] with-stream* ;

: start-listener-thread ( listener -- )
    [ listener-thread ] curry "Listener" spawn drop ;

: restart-listener ( listener -- )
    #! Returns when listener is ready to receive input.
    dup com-end dup clear-output
    dup start-listener-thread
    wait-for-listener ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

: <listener-gadget> ( -- gadget )
    listener-gadget new dup init-listener
    [ listener-output, listener-input, ] { 0 1 } build-track ;

: listener-help "ui-listener" help-window ;

\ listener-help H{ { +nullary+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f f "CLEAR" } clear-output }
    { T{ key-down f { C+ } "CLEAR" } clear-stack }
    { T{ key-down f { C+ } "d" } com-end }
    { T{ key-down f f "F1" } listener-help }
} define-command-map

M: listener-gadget handle-gesture* ( gadget gesture delegate -- ? )
    3dup drop swap find-workspace workspace-page handle-gesture
    [ default-gesture-handler ] [ 3drop f ] if ;

M: listener-gadget graft*
    dup delegate graft*
    dup listener-gadget-input interactor-thread ?box 2drop
    restart-listener ;

M: listener-gadget ungraft*
    dup com-end
    delegate ungraft* ;
