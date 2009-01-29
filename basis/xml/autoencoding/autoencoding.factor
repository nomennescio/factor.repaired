! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces xml.name io.encodings.utf8 xml.elements
io.encodings.utf16 xml.tokenize xml.state math ascii sequences
io.encodings.string io.encodings combinators accessors
xml.data io.encodings.iana ;
IN: xml.autoencoding

: continue-make-tag ( str -- tag )
    parse-name-starting middle-tag end-tag ;

: start-utf16le ( -- tag )
    utf16le decode-input
    "?\0" expect
    check instruct ;

: 10xxxxxx? ( ch -- ? )
    -6 shift 3 bitand 2 = ;
          
: start<name ( ch -- tag )
    ! This is unfortunate, and exists for the corner case
    ! that the first letter of the document is < and second is
    ! not ASCII
    ascii?
    [ utf8 decode-input next make-tag ] [
        next
        [ get-next 10xxxxxx? not ] take-until
        get-char suffix utf8 decode
        utf8 decode-input next
        continue-make-tag
    ] if ;

: prolog-encoding ( prolog -- )
    encoding>> dup "UTF-16" =
    [ drop ] [ name>encoding [ decode-input ] when* ] if ;

: instruct-encoding ( instruct/prolog -- )
    dup prolog?
    [ prolog-encoding ]
    [ drop utf8 decode-input ] if ;

: something ( -- )
    check utf8 decode-input next next ;

: start< ( -- tag )
    ! What if first letter of processing instruction is non-ASCII?
    get-next {
        { 0 [ next next start-utf16le ] }
        { CHAR: ? [ something instruct dup instruct-encoding ] }
        { CHAR: ! [ something direct ] }
        [ check start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-input
    "<" expect check make-tag ;

: decode-expecting ( encoding string -- tag )
    [ decode-input next ] [ expect ] bi* check make-tag ;

: start-utf16be ( -- tag )
    utf16be "<" decode-expecting ;

: skip-utf16le-bom ( -- tag )
    utf16le "\u0000fe<" decode-expecting ;

: skip-utf16be-bom ( -- tag )
    utf16be "\u0000ff<" decode-expecting ;

: start-document ( -- tag )
    get-char {
        { CHAR: < [ start< ] }
        { 0 [ start-utf16be ] }
        { HEX: EF [ skip-utf8-bom ] }
        { HEX: FF [ skip-utf16le-bom ] }
        { HEX: FE [ skip-utf16be-bom ] }
        [ drop utf8 decode-input check f ]
    } case ;

