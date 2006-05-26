! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme generic hashtables inspector io
jedit kernel listener math namespaces parser prettyprint
sequences styles threads words ;

TUPLE: listener-gadget scroller stack ;

: listener-gadget-pane ( listener -- pane )
    listener-gadget-scroller scroller-gadget ;

: usable-words ( -- words )
    use get hash-concat hash-values ;

: word-completion ( pane -- )
    usable-words swap pane-input set-possibilities ;

: show-stack ( seq pack -- )
    dup clear-gadget [
        dup empty? [
            "Empty stack" write drop
        ] [
            "Stack top: " write <reversed>
            [ [ unparse-short ] keep simple-object bl ] each bl
        ] if
    ] with-stream* ;

: ui-listener-hook ( listener -- )
    [
        >r datastack-hook get call r>
        listener-gadget-stack show-stack
    ] keep
    listener-gadget-pane word-completion ;

: listener-thread ( listener -- )
    dup listener-gadget-pane [
        [ ui-listener-hook ] curry listener-hook set
        print-banner listener
    ] with-stream* ;

: <stack-bar> ( -- gadget ) <shelf> dup highlight-theme ;

: start-listener ( listener -- )
    [ >r clear r> listener-thread ] in-thread drop ;

C: listener-gadget ( -- gadget )
    {
        { [ <stack-bar> ] set-listener-gadget-stack @top }
        { [ <input-pane> <scroller> ] set-listener-gadget-scroller @center }
    } make-frame* dup start-listener ;

M: listener-gadget pref-dim* drop { 600 600 0 } ;

M: listener-gadget focusable-child* ( listener -- gadget )
    listener-gadget-pane ;

M: listener-gadget gadget-title drop "Listener" ;

: listener-window ( -- ) <listener-gadget> open-window ;

: call-listener ( quot/string listener -- )
    listener-gadget-pane over quotation?
    [ pane-call ] [ replace-input ] if ;

: listener-tool
    [ listener-gadget? ]
    [ <listener-gadget> ]
    [ call-listener ] ;

: listener-run-files ( seq -- )
    [ [ run-file ] each ] curry listener-tool open-tool ;

M: input show-object ( input button -- )
    >r input-string r> listener-tool call-tool ;

M: object show-object ( object button -- )
    >r [ inspect ] curry r> listener-tool call-tool ;
