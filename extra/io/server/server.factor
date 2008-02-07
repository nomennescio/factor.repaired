! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.sockets io.files continuations kernel math
math.parser namespaces parser sequences strings
prettyprint debugger quotations calendar qualified ;
QUALIFIED: concurrency

IN: io.server

SYMBOL: log-stream

: with-log-stream ( quot -- )
    log-stream get swap with-stream* ; inline

: log-message ( str -- )
    [
        "[" write now timestamp>string write "] " write
        print flush
    ] with-log-stream ;

: log-error ( str -- ) "Error: " swap append log-message ;

: log-client ( client -- )
    "Accepted connection from "
    swap client-stream-addr unparse append log-message ;

: log-file ( service -- path )
    ".log" append resource-path ;

: with-log-file ( file quot -- )
    >r <file-appender> r>
    [ log-stream swap with-variable ] curry
    with-disposal ; inline

: with-log-stdio ( quot -- )
    stdio get log-stream rot with-variable ; inline

: with-logging ( service quot -- )
    over [
        >r log-file
        "Writing log messages to " write dup print flush r>
        with-log-file
    ] [
        nip with-log-stdio
    ] if ; inline

: with-client ( quot client -- )
    dup log-client
    [ swap with-stream ] 2curry concurrency:spawn drop ; inline

: accept-loop ( server quot -- )
    [ swap accept with-client ] 2keep accept-loop ; inline

: server-loop ( server quot -- )
    [ accept-loop ] curry with-disposal ; inline

: spawn-server ( addrspec quot -- )
    "Waiting for connections on " pick unparse append
    log-message
    [
        >r <server> r> server-loop
    ] [
        "Cannot spawn server: " print
        print-error
        2drop
    ] recover ; inline

: local-server ( port -- seq )
    "localhost" swap t resolve-host ;

: internet-server ( port -- seq )
    f swap t resolve-host ;

: with-server ( seq service quot -- )
    [
        [ spawn-server ] curry concurrency:parallel-each
    ] curry with-logging ; inline

: log-datagram ( addrspec -- )
    "Received datagram from " swap unparse append log-message ;

: datagram-loop ( quot datagram -- )
    [
        [ receive dup log-datagram >r swap call r> ] keep
        pick [ send ] [ 3drop ] keep
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    "Waiting for datagrams on " over unparse append log-message
    <datagram> [ datagram-loop ] with-disposal ; inline

: with-datagrams ( seq service quot -- )
    [
        [ swap spawn-datagrams ] curry concurrency:parallel-each
    ] curry with-logging ; inline
