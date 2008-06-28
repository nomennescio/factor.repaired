! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math models namespaces
sequences words strings system hashtables math.parser
math.vectors classes.tuple classes ui.gadgets boxes
calendar alarms symbols combinators sets columns ;
IN: ui.gestures

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

GENERIC: handle-gesture* ( gadget gesture delegate -- ? )

: default-gesture-handler ( gadget gesture delegate -- ? )
    class "gestures" word-prop at dup
    [ call f ] [ 2drop t ] if ;

M: object handle-gesture* default-gesture-handler ;

: handle-gesture ( gesture gadget -- ? )
    tuck delegates [ >r 2dup r> handle-gesture* ] all? 2nip ;

: send-gesture ( gesture gadget -- ? )
    [ dupd handle-gesture ] each-parent nip ;

: user-input ( str gadget -- )
    over empty?
    [ [ dupd user-input* ] each-parent ] unless
    2drop ;

! Gesture objects
TUPLE: motion ;             C: <motion> motion
TUPLE: drag # ;             C: <drag> drag
TUPLE: button-up mods # ;   C: <button-up> button-up
TUPLE: button-down mods # ; C: <button-down> button-down
TUPLE: mouse-scroll ;       C: <mouse-scroll> mouse-scroll
TUPLE: mouse-enter ;        C: <mouse-enter> mouse-enter
TUPLE: mouse-leave ;        C: <mouse-leave> mouse-leave
TUPLE: lose-focus ;         C: <lose-focus> lose-focus
TUPLE: gain-focus ;         C: <gain-focus> gain-focus

! Higher-level actions
TUPLE: cut-action ;         C: <cut-action> cut-action
TUPLE: copy-action ;        C: <copy-action> copy-action
TUPLE: paste-action ;       C: <paste-action> paste-action
TUPLE: delete-action ;      C: <delete-action> delete-action
TUPLE: select-all-action ;  C: <select-all-action> select-all-action

TUPLE: left-action ;        C: <left-action> left-action
TUPLE: right-action ;       C: <right-action> right-action
TUPLE: up-action ;          C: <up-action> up-action
TUPLE: down-action ;        C: <down-action> down-action

TUPLE: zoom-in-action ;  C: <zoom-in-action> zoom-in-action
TUPLE: zoom-out-action ; C: <zoom-out-action> zoom-out-action

: generalize-gesture ( gesture -- newgesture )
    tuple>array but-last >tuple ;

! Modifiers
SYMBOLS: C+ A+ M+ S+ ;

TUPLE: key-down mods sym ;

: <key-gesture> ( mods sym action? class -- mods' sym' )
    >r [ S+ rot remove swap ] unless r> boa ; inline

: <key-down> ( mods sym action? -- key-down )
    key-down <key-gesture> ;

TUPLE: key-up mods sym ;

: <key-up> ( mods sym action? -- key-up )
    key-up <key-gesture> ;

! Hand state

! Note that these are only really useful inside an event
! handler, and that the locations hand-loc and hand-click-loc
! are in the co-ordinate system of the world which contains
! the gadget in question.
SYMBOL: hand-gadget
SYMBOL: hand-world
SYMBOL: hand-loc
{ 0 0 } hand-loc set-global

SYMBOL: hand-clicked
SYMBOL: hand-click-loc
SYMBOL: hand-click#
SYMBOL: hand-last-button
SYMBOL: hand-last-time
0 hand-last-button set-global
0 hand-last-time set-global

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

SYMBOL: scroll-direction
{ 0 0 } scroll-direction set-global

SYMBOL: double-click-timeout
300 double-click-timeout set-global

: hand-moved? ( -- ? )
    hand-loc get hand-click-loc get = not ;

: button-gesture ( gesture -- )
    hand-clicked get-global 2dup send-gesture [
        >r generalize-gesture r> send-gesture drop
    ] [
        2drop
    ] if ;

: drag-gesture ( -- )
    hand-buttons get-global
    dup empty? [ drop ] [ first <drag> button-gesture ] if ;

SYMBOL: drag-timer

<box> drag-timer set-global

: start-drag-timer ( -- )
    hand-buttons get-global empty? [
        [ drag-gesture ]
        300 milliseconds from-now
        100 milliseconds
        add-alarm drag-timer get-global >box
    ] when ;

: stop-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global ?box
        [ cancel-alarm ] [ drop ] if
    ] when ;

: fire-motion ( -- )
    hand-buttons get-global empty? [
        T{ motion } hand-gadget get-global send-gesture drop
    ] [
        drag-gesture
    ] if ;

: each-gesture ( gesture seq -- )
    [ handle-gesture drop ] with each ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    T{ mouse-leave } swap each-gesture
    T{ mouse-enter } swap each-gesture ;

: forget-rollover ( -- )
    f hand-world set-global
    hand-gadget get-global >r
    f hand-gadget set-global
    f r> parents hand-gestures ;

: send-lose-focus ( gadget -- )
    T{ lose-focus } swap handle-gesture drop ;

: send-gain-focus ( gadget -- )
    T{ gain-focus } swap handle-gesture drop ;

: focus-child ( child gadget ? -- )
    [
        dup gadget-focus [
            dup send-lose-focus
            f swap t focus-child
        ] when*
        dupd set-gadget-focus [
            send-gain-focus
        ] when*
    ] [
        set-gadget-focus
    ] if ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] with filter
    0 <column> prune dup empty? [ drop f ] [ >array ] if ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global swap screen-loc v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global swap screen-loc v- ;

: multi-click-timeout? ( -- ? )
    millis hand-last-time get - double-click-timeout get <= ;

: multi-click-button? ( button -- button ? )
    dup hand-last-button get = ;

: multi-click-position? ( -- ? )
    hand-loc get hand-click-loc get v- norm 10 <= ;

: multi-click? ( button -- ? )
    {
        { [ multi-click-timeout?  not ] [ f ] }
        { [ multi-click-button?   not ] [ f ] }
        { [ multi-click-position? not ] [ f ] }
        { [ multi-click-position? not ] [ f ] }
        [ t ]
    } cond nip ;

: update-click# ( button -- )
    global [
        dup multi-click? [
            hand-click# inc
        ] [
            1 hand-click# set
        ] if
        hand-last-button set
        millis hand-last-time set
    ] bind ;

: update-clicked ( -- )
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global ;

: under-hand ( -- seq )
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    dup hand-world set-global
    under-hand >r over hand-loc set-global
    pick-up hand-gadget set-global
    under-hand r> hand-gestures ;

: send-button-down ( gesture loc world -- )
    move-hand
    start-drag-timer
    dup button-down-#
    dup update-click# hand-buttons get-global push
    update-clicked
    button-gesture ;

: send-button-up ( gesture loc world -- )
    move-hand
    dup button-up-# hand-buttons get-global delete
    stop-drag-timer
    button-gesture ;

: send-wheel ( direction loc world -- )
    move-hand
    scroll-direction set-global
    T{ mouse-scroll } hand-gadget get-global send-gesture
    drop ;

: world-focus ( world -- gadget )
    dup gadget-focus [ world-focus ] [ ] ?if ;

: send-action ( world gesture -- )
    swap world-focus send-gesture drop ;

: resend-button-down ( gesture world -- )
    hand-loc get-global swap send-button-down ;

: resend-button-up  ( gesture world -- )
    hand-loc get-global swap send-button-up ;

GENERIC: gesture>string ( gesture -- string/f )

: modifiers>string ( modifiers -- string )
    [ name>> ] map concat >string ;

M: key-down gesture>string
    dup key-down-mods modifiers>string
    swap key-down-sym append ;

M: button-up gesture>string
    [
        dup button-up-mods modifiers>string %
        "Click Button" %
        button-up-# [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup button-down-mods modifiers>string %
        "Press Button" %
        button-down-# [ " " % # ] when*
    ] "" make ;

M: left-action gesture>string drop "Swipe left" ;

M: right-action gesture>string drop "Swipe right" ;

M: up-action gesture>string drop "Swipe up" ;

M: down-action gesture>string drop "Swipe down" ;

M: zoom-in-action gesture>string drop "Zoom in" ;

M: zoom-out-action gesture>string drop "Zoom out (pinch)" ;

M: object gesture>string drop f ;
