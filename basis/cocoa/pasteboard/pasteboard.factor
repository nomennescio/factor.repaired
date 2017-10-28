! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.accessors arrays cocoa cocoa.application
core-foundation.arrays core-foundation.strings kernel sequences
;
IN: cocoa.pasteboard

CONSTANT: NSStringPboardType "NSStringPboardType"

: pasteboard-string? ( pasteboard -- ? )
    NSStringPboardType swap send: types CFString>string-array member? ;

: pasteboard-string ( pasteboard -- str )
    NSStringPboardType <NSString> send: \stringForType:
    dup [ CFString>string ] when ;

: set-pasteboard-types ( seq pasteboard -- )
    swap <CFArray> send: autorelease f send: \declareTypes:owner: drop ;

: set-pasteboard-string ( str pasteboard -- )
    NSStringPboardType <NSString>
    dup 1array pick set-pasteboard-types
    [ swap <NSString> ] dip send: \setString:forType: drop ;

: pasteboard-error ( error -- f )
    "Pasteboard does not hold a string" <NSString>
    0 set-alien-cell f ;

: ?pasteboard-string ( pboard error -- str/f )
    over pasteboard-string? [
        swap pasteboard-string [ ] [ pasteboard-error ] ?if
    ] [
        nip pasteboard-error
    ] if ;
