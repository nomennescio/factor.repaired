! Copyright (C) 2005 Chris Double. All Rights Reserved.
! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs concurrency.messaging
continuations destructors fry init io io.encodings.binary
io.servers io.sockets io.streams.duplex kernel namespaces
sequences serialize threads ;
FROM: concurrency.messaging => send ;
IN: concurrency.distributed

<PRIVATE

: registered-remote-threads ( -- hash )
   \ registered-remote-threads get-global ;

: thread-connections ( -- hash )
    \ thread-connections get-global ;

: get-thd-conn ( thread -- connection/f )
    thread-connections at ;

: set-thd-conn ( thread connection/f -- )
    [ swap thread-connections set-at ] [
        thread-connections delete-at
    ] if* ;

PRIVATE>

: register-remote-thread ( thread name -- )
    registered-remote-threads set-at ;

: unregister-remote-thread ( name -- )
    registered-remote-threads delete-at ;

: get-remote-thread ( name -- thread )
    dup registered-remote-threads at [ ] [ threads at ] ?if ;

SYMBOL: local-node

: handle-node-client ( -- )
    deserialize [
        first2 get-remote-thread send handle-node-client
    ] [ stop-this-server ] if* ;

: <node-server> ( addrspec -- threaded-server )
    binary <threaded-server>
        swap >>insecure
        "concurrency.distributed" >>name
        [ handle-node-client ] >>handler ;

: start-node ( addrspec -- )
    <node-server> start-server local-node set-global ;

TUPLE: remote-thread node id ;

C: <remote-thread> remote-thread

TUPLE: connection remote stream local ;

C: <connection> connection

: connect ( remote-thread -- )
    dup node>> dup binary <client> <connection> set-thd-conn ;

: disconnect ( remote-thread -- )
    dup get-thd-conn [ stream>> dispose ] when* f set-thd-conn ;

: with-connection ( remote-thread quot -- )
    '[ connect @ ] over [ disconnect ] curry [ ] cleanup ; inline

: send-remote-message ( message node -- )
    binary [ serialize ] with-client ;

: send-to-connection ( message connection -- )
    stream>> [ serialize flush ] with-stream* ;

M: remote-thread send ( message thread -- )
    [ id>> 2array ] [ node>> ] [ get-thd-conn ] tri
    [ nip send-to-connection ] [ send-remote-message ] if* ;

M: thread (serialize) ( obj -- )
    id>> [ local-node get insecure>> ] dip <remote-thread> (serialize) ;

: stop-node ( -- )
    f local-node get insecure>> send-remote-message ;

[
    H{ } clone \ registered-remote-threads set-global
    H{ } clone \ thread-connections set-global
] "remote-thread-registry" add-startup-hook
