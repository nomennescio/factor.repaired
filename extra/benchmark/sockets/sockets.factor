USING: io.sockets io kernel math threads io.encodings.ascii
io.streams.duplex debugger tools.time prettyprint
concurrency.count-downs namespaces arrays continuations
destructors ;
IN: benchmark.sockets

SYMBOL: counter

: number-of-requests 1000 ;

: server-addr ( -- addr ) "127.0.0.1" 7777 <inet4> ;

: server-loop ( server -- )
    dup accept drop [
        [
            read1 CHAR: x = [
                "server" get dispose
            ] [
                number-of-requests
                [ read1 write1 flush ] times
                counter get count-down
            ] if
        ] with-stream
    ] curry "Client handler" spawn drop server-loop ;

: simple-server ( -- )
    [
        server-addr ascii <server> dup "server" set [
            server-loop
        ] with-disposal
    ] ignore-errors ;

: simple-client ( -- )
    [
        server-addr ascii [
            CHAR: b write1 flush
            number-of-requests
            [ CHAR: a dup write1 flush read1 assert= ] times
        ] with-client
    ] try
    counter get count-down ;

: stop-server ( -- )
    server-addr ascii [
        CHAR: x write1
    ] with-client ;

: clients ( n -- )
    dup pprint " clients: " write [
        dup 2 * <count-down> counter set
        [ simple-server ] "Simple server" spawn drop
        yield yield
        [ [ simple-client ] "Simple client" spawn drop ] times
        counter get await
        stop-server
        yield yield
    ] benchmark . flush ;

: socket-benchmarks ( -- )
    1 clients
    10 clients
    20 clients
    40 clients
    100 clients ;

MAIN: socket-benchmarks
