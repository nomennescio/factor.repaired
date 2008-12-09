! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math arrays cocoa cocoa.application
command-line kernel memory namespaces cocoa.messages
cocoa.runtime cocoa.subclassing cocoa.pasteboard cocoa.types
cocoa.windows cocoa.classes cocoa.application sequences system
ui ui.backend ui.clipboards ui.gadgets ui.gadgets.worlds
ui.cocoa.views core-foundation threads math.geometry.rect fry
libc generalizations ;
IN: ui.cocoa

TUPLE: handle ;
TUPLE: window-handle < handle view window ;
TUPLE: offscreen-handle < handle context buffer ;

C: <window-handle> window-handle
C: <offscreen-handle> offscreen-handle

M: offscreen-handle window>> f ;
M: offscreen-handle view>>   f ;

SINGLETON: cocoa-ui-backend

M: cocoa-ui-backend do-events ( -- )
    [ NSApp '[ _ do-event ] loop ui-wait ] with-autorelease-pool ;

TUPLE: pasteboard handle ;

C: <pasteboard> pasteboard

M: pasteboard clipboard-contents
    handle>> pasteboard-string ;

M: pasteboard set-clipboard-contents
    handle>> set-pasteboard-string ;

: init-clipboard ( -- )
    NSPasteboard -> generalPasteboard <pasteboard>
    clipboard set-global
    <clipboard> selection set-global ;

: world>NSRect ( world -- NSRect )
    [ window-loc>> ] [ dim>> ] bi [ first2 ] bi@ <NSRect> ;

: gadget-window ( world -- )
    dup <FactorView>
    2dup swap world>NSRect <ViewWindow>
    [ [ -> release ] [ install-window-delegate ] bi* ]
    [ <window-handle> ] 2bi
    >>handle drop ;

M: cocoa-ui-backend set-title ( string world -- )
    handle>> window>> swap <NSString> -> setTitle: ;

: enter-fullscreen ( world -- )
    handle>> view>>
    NSScreen -> mainScreen
    f -> enterFullScreenMode:withOptions:
    drop ;

: exit-fullscreen ( world -- )
    handle>> view>> f -> exitFullScreenModeWithOptions: ;

M: cocoa-ui-backend set-fullscreen* ( ? world -- )
    swap [ enter-fullscreen ] [ exit-fullscreen ] if ;

M: cocoa-ui-backend fullscreen* ( world -- ? )
    handle>> view>> -> isInFullScreenMode zero? not ;

: auto-position ( world -- )
    dup window-loc>> { 0 0 } = [
        handle>> window>> -> center
    ] [
        drop
    ] if ;

M: cocoa-ui-backend (open-window) ( world -- )
    dup gadget-window
    dup auto-position
    handle>> window>> f -> makeKeyAndOrderFront: ;

M: cocoa-ui-backend (close-window) ( handle -- )
    window>> -> release ;

M: cocoa-ui-backend close-window ( gadget -- )
    find-world [
        handle>> [
            window>> f -> performClose:
        ] when*
    ] when* ;

M: cocoa-ui-backend raise-window* ( world -- )
    handle>> [
        window>> dup f -> orderFront: -> makeKeyWindow
        NSApp 1 -> activateIgnoringOtherApps:
    ] when* ;

: pixel-size ( pixel-format -- size )
    0 <int> [ NSOpenGLPFAColorSize 0 -> getValues:forAttribute:forVirtualScreen: ]
    keep *int -3 shift ;

: offscreen-buffer ( world pixel-format -- alien w h pitch )
    [ dim>> first2 ] [ pixel-size ] bi*
    { [ * * malloc ] [ 2drop ] [ drop nip ] [ nip * ] } cleave ;

: gadget-offscreen-context ( world -- context buffer )
    { NSOpenGLPFAOffscreen } <PixelFormat>
    [ NSOpenGLContext -> alloc swap f -> initWithFormat:shareContext: ]
    [ offscreen-buffer ] bi
    4 npick [ setOffScreen:width:height:rowbytes: ] dip ;

M: cocoa-ui-backend (open-offscreen-buffer) ( world -- )
    dup gadget-offscreen-context <offscreen-handle> >>handle drop ;

M: cocoa-ui-backend (close-offscreen-buffer) ( handle -- )
    [ context>> -> release ]
    [ buffer>> free ] bi ;

GENERIC: gl-context ( handle -- context )
M: window-handle gl-context view>> -> openGLContext ;
M: offscreen-handle gl-context context>> ;

M: handle select-gl-context ( handle -- )
    gl-context -> makeCurrentContext ;

M: handle flush-gl-context ( handle -- )
    gl-context -> flushBuffer ;

M: cocoa-ui-backend beep ( -- )
    NSBeep ;

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

cocoa-ui-backend ui-backend set-global

[ running.app? "ui" "listener" ? ] main-vocab-hook set-global
