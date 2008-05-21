IN: io.sockets.secure.tests
USING: accessors kernel namespaces io io.sockets
io.sockets.secure io.encodings.ascii io.streams.duplex
io.unix.backend classes words destructors threads tools.test
concurrency.promises byte-arrays locals calendar io.timeouts ;

\ <secure-config> must-infer
{ 1 0 } [ [ ] with-secure-context ] must-infer-as

[ ] [ <promise> "port" set ] unit-test

: with-test-context
    <secure-config>
        "resource:extra/openssl/test/server.pem" >>key-file
        "resource:extra/openssl/test/root.pem" >>ca-file
        "resource:extra/openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    swap with-secure-context ;

:: server-test ( quot -- )
    [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept [
                    quot call
                ] curry with-stream
            ] with-disposal
        ] with-test-context
    ] "SSL server test" spawn drop ;

: client-test
    <secure-config> [
        "127.0.0.1" "port" get ?promise <inet4> <secure> ascii <client> drop contents
    ] with-secure-context ;

[ ] [ [ class word-name write ] server-test ] unit-test

[ "secure" ] [ client-test ] unit-test

! Now, see what happens if the server closes the connection prematurely
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        drop
        input-stream get stream>> handle>> f >>connected drop
        "hello" write flush
    ] server-test
] unit-test

[ client-test ] [ premature-close? ] must-fail-with

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
[ ] [ <promise> "port" set ] unit-test

[ ] [ [ drop ] server-test ] unit-test

[
    <secure-config> [
        "localhost" "port" get ?promise <inet> <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with

! Client-side handshake timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        "127.0.0.1" 0 <inet4> ascii <server> [
            dup addr>> port>> "port" get fulfill
            accept drop 1 minutes sleep dispose
        ] with-disposal
    ] "Silly server" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        client-test
    ] with-variable
] [ io-timeout? ] must-fail-with

! Server-side handshake timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        "127.0.0.1" "port" get ?promise
        <inet4> ascii <client> drop 1 minutes sleep dispose
    ] "Silly client" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop dispose
            ] with-disposal
        ] with-test-context
    ] with-variable
] [ io-timeout? ] must-fail-with

! Client socket shutdown timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop 1 minutes sleep dispose
            ] with-disposal
        ] with-test-context
    ] "Silly server" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        <secure-config> [
            "127.0.0.1" "port" get ?promise <inet4> <secure>
            ascii <client> drop dispose
        ] with-secure-context
    ] with-variable
] [ io-timeout? ] must-fail-with

! Server socket shutdown timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        [
            "127.0.0.1" "port" get ?promise
            <inet4> <secure> ascii <client> drop 1 minutes sleep dispose
        ] with-test-context
    ] "Silly client" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop dispose
            ] with-disposal
        ] with-test-context
    ] with-variable
] [ io-timeout? ] must-fail-with
