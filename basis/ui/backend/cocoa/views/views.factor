! Copyright (C) 2006, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs classes cocoa cocoa.application cocoa.classes
cocoa.pasteboard cocoa.runtime cocoa.subclassing cocoa.touchbar
cocoa.types cocoa.views combinators core-foundation.strings
core-graphics core-graphics.types core-text io.encodings.utf8
kernel literals locals math math.order math.parser
math.rectangles namespaces opengl sequences splitting threads
ui.commands ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.gestures ui.private words ;
IN: ui.backend.cocoa.views

: send-mouse-moved ( view event -- )
    [ mouse-location ] [ drop window ] 2bi
    [ move-hand fire-motion yield ] [ drop ] if* ;

! Issue #1453
: button ( event -- n )
    ! Cocoa send: Factor UI button mapping
    send: buttonNumber {
        { 0 [ 1 ] }
        { 1 [ 3 ] }
        { 2 [ 2 ] }
        [ ]
    } case ;

CONSTANT: NSAlphaShiftKeyMask 0x10000
CONSTANT: NSShiftKeyMask      0x20000
CONSTANT: NSControlKeyMask    0x40000
CONSTANT: NSAlternateKeyMask  0x80000
CONSTANT: NSCommandKeyMask    0x100000
CONSTANT: NSNumericPadKeyMask 0x200000
CONSTANT: NSHelpKeyMask       0x400000
CONSTANT: NSFunctionKeyMask   0x800000

CONSTANT: modifiers {
        { S+ $ NSShiftKeyMask }
        { C+ $ NSControlKeyMask }
        { A+ $ NSCommandKeyMask }
        { M+ $ NSAlternateKeyMask }
    }

CONSTANT: key-codes
    H{
        { 71 "CLEAR" }
        { 36 "RET" }
        { 76 "ENTER" }
        { 53 "ESC" }
        { 48 "TAB" }
        { 51 "BACKSPACE" }
        { 115 "HOME" }
        { 117 "DELETE" }
        { 119 "END" }
        { 122 "F1" }
        { 120 "F2" }
        { 99 "F3" }
        { 118 "F4" }
        { 96 "F5" }
        { 97 "F6" }
        { 98 "F7" }
        { 100 "F8" }
        { 123 "LEFT" }
        { 124 "RIGHT" }
        { 125 "DOWN" }
        { 126 "UP" }
        { 116 "PAGE_UP" }
        { 121 "PAGE_DOWN" }
    }

: key-code ( event -- string ? )
    dup send: keyCode key-codes at
    [ t ] [ send: charactersIgnoringModifiers CFString>string f ] ?if ;

: event-modifiers ( event -- modifiers )
    send: modifierFlags modifiers modifier ;

: key-event>gesture ( event -- modifiers keycode action? )
    [ event-modifiers ] [ key-code ] bi ;

: send-key-event ( view gesture -- )
    swap window [ propagate-key-gesture ] [ drop ] if* ;

: interpret-key-event ( view event -- )
    NSArray swap send: \arrayWithObject: send: \interpretKeyEvents: ;

: send-key-down-event ( view event -- )
    [ key-event>gesture <key-down> send-key-event ]
    [ interpret-key-event ]
    2bi ;

: send-key-up-event ( view event -- )
    key-event>gesture <key-up> send-key-event ;

: mouse-event>gesture ( event -- modifiers button )
    [ event-modifiers ] [ button ] bi ;

: send-button-down$ ( view event -- )
    [ nip mouse-event>gesture <button-down> ]
    [ mouse-location ]
    [ drop window ]
    2tri
    [ send-button-down ] [ 2drop ] if* ;

: send-button-up$ ( view event -- )
    [ nip mouse-event>gesture <button-up> ]
    [ mouse-location ]
    [ drop window ]
    2tri
    [ send-button-up ] [ 2drop ] if* ;

: send-scroll$ ( view event -- )
    [ nip [ send: deltaX ] [ send: deltaY ] bi [ neg ] bi@ 2array ]
    [ mouse-location ]
    [ drop window ]
    2tri
    [ send-scroll ] [ 2drop ] if* ;

: send-action$ ( view event gesture -- )
    [ drop window ] dip over [ send-action ] [ 2drop ] if ;

: add-resize-observer ( observer object -- )
    [
        "updateFactorGadgetSize:"
        "NSViewFrameDidChangeNotification" <NSString>
    ] dip add-observer ;

: string-or-nil? ( NSString -- ? )
    [ CFString>string NSStringPboardType = ] [ t ] if* ;

: valid-service? ( gadget send-type return-type -- ? )
    2dup [ string-or-nil? ] [ string-or-nil? ] bi* and
    [ drop [ gadget-selection? ] [ drop t ] if ] [ 3drop f ] if ;

: NSRect>rect ( NSRect world -- rect )
    [ [ [ CGRect-x ] [ CGRect-y ] bi ] [ dim>> second ] bi* swap - 2array ]
    [ drop [ CGRect-w ] [ CGRect-h ] bi 2array ]
    2bi <rect> ;

: rect>NSRect ( rect world -- NSRect )
    [ [ loc>> first2 ] [ dim>> second ] bi* swap - ]
    [ drop dim>> first2 ]
    2bi <CGRect> ;

CONSTANT: selector>action H{
    { "undo:" undo-action }
    { "redo:" redo-action }
    { "cut:" cut-action }
    { "copy:" copy-action }
    { "paste:" paste-action }
    { "delete:" delete-action }
    { "selectAll:" select-all-action }
    { "newDocument:" new-action }
    { "openDocument:" open-action }
    { "saveDocument:" save-action }
    { "saveDocumentAs:" save-as-action }
    { "revertDocumentToSaved:" revert-action }
}

: validate-action ( world selector -- ? validated? )
    selector>action at
    [ swap world-focus parents-handle-gesture? t ] [ drop f f ] if* ;

: touchbar-commands ( -- commands/f gadget )
    world get-global [
        children>> [
            class-of "commands" word-prop
            "touchbar" of dup [ commands>> ] when
        ] map-find
    ] [ f f ] if* ;

TUPLE: send-touchbar-command target command ;

M: send-touchbar-command send-queued-gesture
    [ target>> ] [ command>> ] bi invoke-command ;

: touchbar-invoke-command ( n -- )
    [ touchbar-commands ] dip over [
        rot nth second
        send-touchbar-command queue-gesture notify-ui-thread
        yield
    ] [ 3drop ] if ;

<CLASS: FactorView < NSOpenGLView
    COCOA-PROTOCOL: NSTextInput

    COCOA-METHOD: void prepareOpenGL [

        self selector: \setWantsBestResolutionOpenGLSurface:
        send: \respondsToSelector: c-bool> [

            self 1 { void { id SEL char } } ?send: setWantsBestResolutionOpenGLSurface:

            self { double { id SEL } } ?send: backingScaleFactor

            dup 1.0 > [
                gl-scale-factor set-global t retina? set-global
                cached-lines get-global clear-assoc
            ] [ drop ] if

            self send: update
        ] when
    ] ;

    ! TouchBar
    COCOA-METHOD: void touchBarCommand0 [ 0 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand1 [ 1 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand2 [ 2 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand3 [ 3 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand4 [ 4 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand5 [ 5 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand6 [ 6 touchbar-invoke-command ] ;
    COCOA-METHOD: void touchBarCommand7 [ 7 touchbar-invoke-command ] ;

    COCOA-METHOD: id makeTouchBar [
        touchbar-commands drop [
            length 8 min <iota> [ number>string ] map
        ] [ { } ] if* self make-touchbar
    ] ;

    COCOA-METHOD: id touchBar: id touchbar makeItemForIdentifier: id string [
        touchbar-commands drop [
            [ self string CFString>string dup string>number ] dip nth
            second name>> "com-" ?head drop over
            "touchBarCommand" prepend make-NSTouchBar-button
        ] [ f ] if*
    ] ;

    ! Rendering
    COCOA-METHOD: void drawRect: NSRect rect [ self window [ draw-world ] when* ] ;

    ! Events
    COCOA-METHOD: char acceptsFirstMouse: id event [ 0 ] ;

    COCOA-METHOD: void mouseEntered: id event [ self event send-mouse-moved ] ;

    COCOA-METHOD: void mouseExited: id event [ forget-rollover ] ;

    COCOA-METHOD: void mouseMoved: id event [ self event send-mouse-moved ] ;

    COCOA-METHOD: void mouseDragged: id event [ self event send-mouse-moved ] ;

    COCOA-METHOD: void rightMouseDragged: id event [ self event send-mouse-moved ] ;

    COCOA-METHOD: void otherMouseDragged: id event [ self event send-mouse-moved ] ;

    COCOA-METHOD: void mouseDown: id event [ self event send-button-down$ ] ;

    COCOA-METHOD: void mouseUp: id event [ self event send-button-up$ ] ;

    COCOA-METHOD: void rightMouseDown: id event [ self event send-button-down$ ] ;

    COCOA-METHOD: void rightMouseUp: id event [ self event send-button-up$ ] ;

    COCOA-METHOD: void otherMouseDown: id event [ self event send-button-down$ ] ;

    COCOA-METHOD: void otherMouseUp: id event [ self event send-button-up$ ] ;

    COCOA-METHOD: void scrollWheel: id event [ self event send-scroll$ ] ;

    COCOA-METHOD: void keyDown: id event [ self event send-key-down-event ] ;

    COCOA-METHOD: void keyUp: id event [ self event send-key-up-event ] ;

    COCOA-METHOD: char validateUserInterfaceItem: id event
    [
        self window [
            event send: action utf8 alien>string validate-action
            [ >c-bool ] [ drop self event super: \validateUserInterfaceItem: ] if
        ] [ 0 ] if*
    ] ;

    COCOA-METHOD: id undo: id event [ self event undo-action send-action$ f ] ;

    COCOA-METHOD: id redo: id event [ self event redo-action send-action$ f ] ;

    COCOA-METHOD: id cut: id event [ self event cut-action send-action$ f ] ;

    COCOA-METHOD: id copy: id event [ self event copy-action send-action$ f ] ;

    COCOA-METHOD: id paste: id event [ self event paste-action send-action$ f ] ;

    COCOA-METHOD: id delete: id event [ self event delete-action send-action$ f ] ;

    COCOA-METHOD: id selectAll: id event [ self event select-all-action send-action$ f ] ;

    COCOA-METHOD: id newDocument: id event [ self event new-action send-action$ f ] ;

    COCOA-METHOD: id openDocument: id event [ self event open-action send-action$ f ] ;

    COCOA-METHOD: id saveDocument: id event [ self event save-action send-action$ f ] ;

    COCOA-METHOD: id saveDocumentAs: id event [ self event save-as-action send-action$ f ] ;

    COCOA-METHOD: id revertDocumentToSaved: id event [ self event revert-action send-action$ f ] ;

    ! Multi-touch gestures
    COCOA-METHOD: void magnifyWithEvent: id event
    [
        self event
        dup send: deltaZ sgn {
            {  1 [ zoom-in-action send-action$ ] }
            { -1 [ zoom-out-action send-action$ ] }
            {  0 [ 2drop ] }
        } case
    ] ;

    COCOA-METHOD: void swipeWithEvent: id event
    [
        self event
        dup send: deltaX sgn {
            {  1 [ left-action send-action$ ] }
            { -1 [ right-action send-action$ ] }
            {  0
                [
                    dup send: deltaY sgn {
                        {  1 [ up-action send-action$ ] }
                        { -1 [ down-action send-action$ ] }
                        {  0 [ 2drop ] }
                    } case
                ]
            }
        } case
    ] ;

    COCOA-METHOD: char acceptsFirstResponder [ 1 ] ;

    ! Services
    COCOA-METHOD: id validRequestorForSendType: id sendType returnType: id returnType
    [
        ! We return either self or nil
        self window [
            world-focus sendType returnType
            valid-service? [ self ] [ f ] if
        ] [ f ] if*
    ] ;

    COCOA-METHOD: char writeSelectionToPasteboard: id pboard types: id types
    [
        NSStringPboardType types CFString>string-array member? [
            self window [
                world-focus gadget-selection
                [ pboard set-pasteboard-string 1 ] [ 0 ] if*
            ] [ 0 ] if*
        ] [ 0 ] if
    ] ;

    COCOA-METHOD: char readSelectionFromPasteboard: id pboard
    [
        self window :> window
        window [
            pboard pasteboard-string
            [ window user-input 1 ] [ 0 ] if*
        ] [ 0 ] if
    ] ;

    ! Text input
    COCOA-METHOD: void insertText: id text
    [
        self window :> window
        window [
            text CFString>string window user-input
        ] when
    ] ;

    COCOA-METHOD: char hasMarkedText [ 0 ] ;

    COCOA-METHOD: NSRange markedRange [ 0 0 <NSRange> ] ;

    COCOA-METHOD: NSRange selectedRange [ 0 0 <NSRange> ] ;

    COCOA-METHOD: void setMarkedText: id text selectedRange: NSRange range [ ] ;

    COCOA-METHOD: void unmarkText [ ] ;

    COCOA-METHOD: id validAttributesForMarkedText [ NSArray send: array ] ;

    COCOA-METHOD: id attributedSubstringFromRange: NSRange range [ f ] ;

    COCOA-METHOD: NSUInteger characterIndexForPoint: NSPoint point [ 0 ] ;

    COCOA-METHOD: NSRect firstRectForCharacterRange: NSRange range [ 0 0 0 0 <CGRect> ] ;

    COCOA-METHOD: NSInteger conversationIdentifier [ self alien-address ] ;

    ! Initialization
    COCOA-METHOD: void updateFactorGadgetSize: id notification
    [
        self window :> window
        window [
            self view-dim window dim<< yield
        ] when
    ] ;

    COCOA-METHOD: void doCommandBySelector: SEL selector [ ] ;

    COCOA-METHOD: id initWithFrame: NSRect frame pixelFormat: id pixelFormat
    [
        self frame pixelFormat super: \initWithFrame:pixelFormat:
        dup dup add-resize-observer
    ] ;

    COCOA-METHOD: char isOpaque [ 0 ] ;

    COCOA-METHOD: void dealloc
    [
        self remove-observer
        self super: dealloc
    ] ;
;CLASS>

: sync-refresh-to-screen ( GLView -- )
    send: openGLContext send: CGLContextObj NSOpenGLCPSwapInterval 1 int <ref>
    CGLSetParameter drop ;

: <FactorView> ( dim pixel-format -- view )
    [ FactorView ] 2dip <GLView> [ sync-refresh-to-screen ] keep ;

: save-position ( world window -- )
    send: frame CGRect-top-left 2array >>window-loc drop ;

<CLASS: FactorWindowDelegate < NSObject

    COCOA-METHOD: void windowDidMove: id notification
    [
        notification send: object send: contentView window
        [ notification send: object save-position ] when*
    ] ;

    COCOA-METHOD: void windowDidBecomeKey: id notification
    [
        notification send: object send: contentView window
        [ focus-world ] when*
    ] ;

    COCOA-METHOD: void windowDidResignKey: id notification
    [
        forget-rollover
        notification send: object send: contentView :> view
        view window :> window
        window [
            view send: isInFullScreenMode 0 =
            [ window unfocus-world ] when
        ] when
    ] ;

    COCOA-METHOD: char windowShouldClose: id notification [ 1 ] ;

    COCOA-METHOD: void windowWillClose: id notification
    [
        notification send: object send: contentView
        [ window ungraft ] [ unregister-window ] bi
    ] ;

    COCOA-METHOD: void windowDidChangeBackingProperties: id notification
    [

        notification send: object dup selector: backingScaleFactor
        send: \respondsToSelector: c-bool> [
            { double { id SEL } } ?send: backingScaleFactor

            [ [ 1.0 > ] keep f ? gl-scale-factor set-global ]
            [ 1.0 > retina? set-global ] bi
        ] [ drop ] if
    ] ;
;CLASS>

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
