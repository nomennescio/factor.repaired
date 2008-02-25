! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math arrays cocoa cocoa.application command-line
kernel memory namespaces cocoa.messages cocoa.runtime
cocoa.subclassing cocoa.pasteboard cocoa.types cocoa.windows
cocoa.classes cocoa.application sequences system ui ui.backend
ui.clipboards ui.gadgets ui.gadgets.worlds ui.cocoa.views
core-foundation threads ;
IN: ui.cocoa

TUPLE: cocoa-ui-backend ;

SYMBOL: stop-after-last-window?

: event-loop? ( -- ? )
    stop-after-last-window? get-global
    [ windows get-global empty? not ] [ t ] if ;

: event-loop ( -- )
    event-loop? [
        [
            [ NSApp do-events ui-wait ] ui-try
        ] with-autorelease-pool event-loop
    ] when ;

TUPLE: pasteboard handle ;

C: <pasteboard> pasteboard

M: pasteboard clipboard-contents
    pasteboard-handle pasteboard-string ;

M: pasteboard set-clipboard-contents
    pasteboard-handle set-pasteboard-string ;

: init-clipboard ( -- )
    NSPasteboard -> generalPasteboard <pasteboard>
    clipboard set-global
    <clipboard> selection set-global ;

: world>NSRect ( world -- NSRect )
    dup world-loc first2 rot rect-dim first2 <NSRect> ;

: gadget-window ( world -- )
    [
        dup <FactorView>
        dup rot world>NSRect <ViewWindow>
        dup install-window-delegate
        over -> release
        2array
    ] keep set-world-handle ;

M: cocoa-ui-backend set-title ( string world -- )
    world-handle second swap <NSString> -> setTitle: ;

: enter-fullscreen ( world -- )
    world-handle first NSScreen -> mainScreen f -> enterFullScreenMode:withOptions: drop ;

: exit-fullscreen ( world -- )
    world-handle first f -> exitFullScreenModeWithOptions: ;

M: cocoa-ui-backend set-fullscreen* ( ? world -- )
    swap [ enter-fullscreen ] [ exit-fullscreen ] if ;

M: cocoa-ui-backend fullscreen* ( world -- ? )
    world-handle first -> isInFullScreenMode zero? not ;

: auto-position ( world -- )
    dup world-loc { 0 0 } = [
        world-handle second -> center
    ] [
        drop
    ] if ;

M: cocoa-ui-backend (open-window) ( world -- )
    dup gadget-window
    dup auto-position
    world-handle second f -> makeKeyAndOrderFront: ;

M: cocoa-ui-backend (close-window) ( handle -- )
    first unregister-window ;

M: cocoa-ui-backend close-window ( gadget -- )
    find-world [
        world-handle second f -> performClose:
    ] when* ;

M: cocoa-ui-backend raise-window* ( world -- )
    world-handle [
        second dup f -> orderFront: -> makeKeyWindow
        NSApp 1 -> activateIgnoringOtherApps:
    ] when* ;

M: cocoa-ui-backend select-gl-context ( handle -- )
    first -> openGLContext -> makeCurrentContext ;

M: cocoa-ui-backend flush-gl-context ( handle -- )
    first -> openGLContext -> flushBuffer ;

SYMBOL: cocoa-init-hook

M: cocoa-ui-backend ui
    "UI" assert.app [
        [
            init-clipboard
            cocoa-init-hook get [ call ] when*
            start-ui
            finish-launching
            event-loop
        ] ui-running
    ] with-cocoa ;

T{ cocoa-ui-backend } ui-backend set-global

[ running.app? "ui" "listener" ? ] main-vocab-hook set-global
