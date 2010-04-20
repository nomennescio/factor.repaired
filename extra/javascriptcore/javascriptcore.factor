! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data byte-arrays continuations fry
io.encodings.string io.encodings.utf8 io.files
javascriptcore.ffi javascriptcore.ffi.hack kernel namespaces
sequences ;
IN: javascriptcore

: with-javascriptcore ( quot -- )
    set-callstack-bounds
    call ; inline

SYMBOL: js-context

: with-global-context ( quot -- )
    [
        [ f JSGlobalContextCreate ] dip
        [ '[ _ @ ] ]
        [ drop '[ _ JSGlobalContextRelease ] ] 2bi
        [ ] cleanup
    ] with-scope ; inline

: JSString>string ( JSString -- string )
    dup JSStringGetMaximumUTF8CStringSize [ <byte-array> ] keep
    [ JSStringGetUTF8CString drop ] [ drop ] 2bi
    utf8 decode [ 0 = ] trim-tail ;

: JSValueRef>string ( ctx JSValueRef/f -- string/f )
    [
        f JSValueToStringCopy
        [ JSString>string ] [ JSStringRelease ] bi
    ] [
        drop f
    ] if* ;

: eval-js ( string -- ret/f exception/f )
    [
        [
            [
                swap JSStringCreateWithUTF8CString f f 0 JSValueRef <c-object>
                [ JSEvaluateScript ] keep *void*
            ]
            [ '[ [ _ ] dip JSValueRef>string ] bi@ ] bi
        ] with-global-context
    ] with-javascriptcore ;

: eval-js-path ( path -- ret/f exception/f ) utf8 file-contents eval-js ;

