IN: io.servers.connection
USING: tools.test io.servers.connection io.sockets namespaces
io.servers.connection.private kernel accessors sequences
concurrency.promises io.encodings.ascii io threads calendar ;

[ t ] [ <threaded-server> listen-on empty? ] unit-test

[ f ] [
    <threaded-server>
        25 internet-server >>insecure
    listen-on
    empty?
] unit-test

[ t ] [
    T{ inet4 f "1.2.3.4" 1234 } T{ inet4 f "1.2.3.5" 1235 }
    [ log-connection ] 2keep
    [ remote-address get = ] [ local-address get = ] bi*
    and
] unit-test

[ ] [ <threaded-server> init-server drop ] unit-test

[ 10 ] [
    <threaded-server>
        10 >>max-connections
    init-server semaphore>> count>> 
] unit-test

[ ] [ <promise> "p" set ] unit-test

[ ] [
    <threaded-server>
        5 >>max-connections
        1237 >>insecure
        [ "Hello world." write stop-server ] >>handler
    "server" set
] unit-test

[ ] [
    [
        "server" get start-server
        t "p" get fulfill
    ] in-thread
] unit-test

[ ] [ "server" get wait-for-server ] unit-test

[ "Hello world." ] [ "localhost" 1237 <inet> ascii <client> drop contents ] unit-test

[ t ] [ "p" get 2 seconds ?promise-timeout ] unit-test
