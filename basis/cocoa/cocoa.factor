! Copyright (C) 2006, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: compiler io kernel cocoa.runtime cocoa.subclassing
cocoa.messages cocoa.types sequences words vocabs parser
core-foundation.bundles namespaces assocs hashtables
compiler.units lexer init macros quotations fry alien.c-types
arrays combinators ;
IN: cocoa

: (remember-send) ( selector variable -- )
    [ dupd ?set-at ] change-global ;

SYMBOL: sent-messages

: remember-send ( selector -- )
    sent-messages (remember-send) ;

SYNTAX: -> scan [ remember-send ] [ suffix! ] bi \ send suffix! ;

SYMBOL: super-sent-messages

: remember-super-send ( selector -- )
    super-sent-messages (remember-send) ;

SYNTAX: SUPER-> scan dup remember-super-send suffix! \ super-send suffix! ;

SYMBOL: frameworks

frameworks [ V{ } clone ] initialize

[ frameworks get [ load-framework ] each ] "cocoa" add-startup-hook

SYNTAX: FRAMEWORK: scan [ load-framework ] [ frameworks get push ] bi ;

SYNTAX: IMPORT: scan [ ] import-objc-class ;

MACRO: objc-class-case ( alist -- quot )
    "isKindOfClass:" remember-send
    [
        dup callable?
        [ first2 [ '[ dup _ execute "isKindOfClass:" send c-bool> ] ] dip 2array ]
        unless
    ] map '[ _ cond ] ;

"Importing Cocoa classes..." print

"cocoa.classes" create-vocab drop

[
    {
        "NSApplication"
        "NSArray"
        "NSAutoreleasePool"
        "NSBundle"
        "NSData"
        "NSDictionary"
        "NSError"
        "NSEvent"
        "NSException"
        "NSMenu"
        "NSMenuItem"
        "NSMutableDictionary"
        "NSNib"
        "NSNotification"
        "NSNotificationCenter"
        "NSNumber"
        "NSObject"
        "NSOpenGLContext"
        "NSOpenGLPixelFormat"
        "NSOpenGLView"
        "NSOpenPanel"
        "NSPanel"
        "NSPasteboard"
        "NSPropertyListSerialization"
        "NSResponder"
        "NSSavePanel"
        "NSScreen"
        "NSString"
        "NSView"
        "NSWindow"
        "NSWorkspace"
    } [
        [ ] import-objc-class
    ] each
] with-compilation-unit
