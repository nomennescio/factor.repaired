! Copyright (C) 2007, 2010 Slava Pestov, Doug Coleman,
! Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: generic kernel io.backend namespaces continuations sequences
arrays io.encodings io.ports io.streams.duplex io.encodings.ascii
alien.strings io.binary accessors destructors classes byte-arrays
parser alien.c-types math.parser splitting grouping math assocs
summary system vocabs.loader combinators present fry vocabs.parser
classes.struct alien.data strings ;
IN: io.sockets

<< {
    { [ os windows? ] [ "windows.winsock" ] }
    { [ os unix? ] [ "unix.ffi" ] }
} cond use-vocab >>

! Addressing
<PRIVATE

GENERIC: protocol-family ( addrspec -- af )

GENERIC: sockaddr-size ( addrspec -- n )

GENERIC: make-sockaddr ( addrspec -- sockaddr )

GENERIC: empty-sockaddr ( addrspec -- sockaddr )

GENERIC: address-size ( addrspec -- n )

GENERIC: inet-ntop ( data addrspec -- str )

GENERIC: inet-pton ( str addrspec -- data )

GENERIC# with-port 1 ( addrspec port -- addrspec )

: make-sockaddr/size ( addrspec -- sockaddr size )
    [ make-sockaddr ] [ sockaddr-size ] bi ;

: empty-sockaddr/size ( addrspec -- sockaddr size )
    [ empty-sockaddr ] [ sockaddr-size ] bi ;

GENERIC: parse-sockaddr ( sockaddr addrspec -- newaddrspec )

M: f parse-sockaddr nip ;

HOOK: sockaddr-of-family os ( alien af -- sockaddr )

HOOK: addrspec-of-family os ( af -- addrspec )

PRIVATE>

TUPLE: local path ;

: <local> ( path -- addrspec )
    normalize-path local boa ;

M: local present path>> "Unix domain socket: " prepend ;

SLOT: port

TUPLE: ipv4 { host string read-only } ;

C: <ipv4> ipv4

M: ipv4 inet-ntop ( data addrspec -- str )
    drop 4 memory>byte-array [ number>string ] { } map-as "." join ;

<PRIVATE

ERROR: malformed-ipv4 sequence ;

ERROR: bad-ipv4-component string ;

: parse-ipv4 ( string -- seq )
    "." split dup length 4 = [ malformed-ipv4 ] unless
    [ dup string>number [ ] [ bad-ipv4-component ] ?if ] B{ } map-as ;

ERROR: invalid-ipv4 string reason ;

M: invalid-ipv4 summary drop "Invalid IPv4 address" ;

PRIVATE>

M: ipv4 inet-pton ( str addrspec -- data )
    drop [ parse-ipv4 ] [ invalid-ipv4 ] recover ;

M: ipv4 address-size drop 4 ;

M: ipv4 protocol-family drop PF_INET ;

M: ipv4 sockaddr-size drop sockaddr-in heap-size ;

M: ipv4 empty-sockaddr drop sockaddr-in <struct> ;

M: ipv4 make-sockaddr ( inet -- sockaddr )
    sockaddr-in <struct>
        AF_INET >>family
        swap
        [ port>> htons >>port ]
        [ host>> "0.0.0.0" or ]
        [ inet-pton *uint >>addr ] tri ;

M: ipv4 parse-sockaddr ( sockaddr-in addrspec -- newaddrspec )
    [ addr>> <uint> ] dip inet-ntop <ipv4> ;

TUPLE: inet4 < ipv4 { port integer read-only } ;

C: <inet4> inet4

M: ipv4 with-port [ host>> ] dip <inet4> ;

M: inet4 parse-sockaddr ( sockaddr-in addrspec -- newaddrspec )
    [ call-next-method ] [ drop port>> ntohs ] 2bi with-port ;

M: inet4 present
    [ host>> ] [ port>> number>string ] bi ":" glue ;

TUPLE: ipv6 { host string read-only } ;

C: <ipv6> ipv6

M: ipv6 inet-ntop ( data addrspec -- str )
    drop 16 memory>byte-array 2 <groups> [ be> >hex ] map ":" join ;

ERROR: invalid-ipv6 string reason ;

<PRIVATE

ERROR: bad-ipv6-component obj ;

ERROR: bad-ipv4-embedded-prefix obj ;

ERROR: more-than-8-components ;

: parse-ipv6-component ( seq -- seq' )
    [ dup hex> [ nip ] [ bad-ipv6-component ] if* ] { } map-as ;

: parse-ipv6 ( string -- seq )
    [ f ] [
        ":" split CHAR: . over last member? [
            unclip-last
            [ parse-ipv6-component ] [ parse-ipv4 ] bi* append
        ] [
            parse-ipv6-component
        ] if
    ] if-empty ;

: pad-ipv6 ( string1 string2 -- seq )
    2dup [ length ] bi@ + 8 swap -
    dup 0 < [ more-than-8-components ] when
    <byte-array> glue ;

: ipv6-bytes ( seq -- bytes )
    [ 2 >be ] { } map-as B{ } concat-as ;

PRIVATE>

M: ipv6 inet-pton ( str addrspec -- data )
    drop
    [ "::" split1 [ parse-ipv6 ] bi@ pad-ipv6 ipv6-bytes ]
    [ invalid-ipv6 ]
    recover ;

M: ipv6 address-size drop 16 ;

M: ipv6 protocol-family drop PF_INET6 ;

M: ipv6 sockaddr-size drop sockaddr-in6 heap-size ;

M: ipv6 empty-sockaddr drop sockaddr-in6 <struct> ;

M: ipv6 make-sockaddr ( inet -- sockaddr )
    sockaddr-in6 <struct>
        AF_INET6 >>family
        swap
        [ port>> htons >>port ]
        [ host>> "::" or ]
        [ inet-pton >>addr ] tri ;

M: ipv6 parse-sockaddr
    [ addr>> ] dip inet-ntop <ipv6> ;

TUPLE: inet6 < ipv6 { port integer read-only } ;

C: <inet6> inet6

M: ipv6 with-port [ host>> ] dip <inet6> ;

M: inet6 parse-sockaddr
    [ call-next-method ] [ drop port>> ntohs ] 2bi with-port ;

M: inet6 present
    [ host>> ] [ port>> number>string ] bi ":" glue ;

<PRIVATE

GENERIC: (get-local-address) ( handle remote -- sockaddr )

: get-local-address ( handle remote -- local )
    [ (get-local-address) ] keep parse-sockaddr ;

GENERIC: (get-remote-address) ( handle remote -- sockaddr )

: get-remote-address ( handle local -- remote )
    [ (get-remote-address) ] keep parse-sockaddr ;

: <ports> ( handle -- input-port output-port )
    [
        [ <input-port> |dispose ] [ <output-port> |dispose ] bi
    ] with-destructors ;

SYMBOL: bind-local-address

GENERIC: establish-connection ( client-out remote -- )

GENERIC: ((client)) ( remote -- handle )

GENERIC: (client) ( remote -- client-in client-out local )

M: array (client) [ (client) 3array ] attempt-all first3 ;

M: object (client) ( remote -- client-in client-out local )
    [
        [ ((client)) ] keep
        [
            [ <ports> [ |dispose ] bi@ dup ] dip
            establish-connection
        ]
        [ get-local-address ]
        2bi
    ] with-destructors ;

TUPLE: server-port < port addr encoding ;

: check-server-port ( port -- port )
    dup check-disposed
    dup server-port? [ "Not a server port" throw ] unless ; inline

GENERIC: (server) ( addrspec -- handle )

GENERIC: (accept) ( server addrspec -- handle sockaddr )

TUPLE: datagram-port < port addr ;

HOOK: (datagram) io-backend ( addr -- datagram )

: check-datagram-port ( port -- port )
    dup check-disposed
    dup datagram-port? [ "Not a datagram port" throw ] unless ; inline

HOOK: (receive) io-backend ( datagram -- packet addrspec )

: check-datagram-send ( packet addrspec port -- packet addrspec port )
    check-datagram-port
    2dup addr>> [ class ] bi@ assert=
    pick class byte-array assert= ;

HOOK: (send) io-backend ( packet addrspec datagram -- )

: addrinfo>addrspec ( addrinfo -- addrspec )
    [ [ addr>> ] [ family>> ] bi sockaddr-of-family ]
    [ family>> addrspec-of-family ] bi
    parse-sockaddr ;

: parse-addrinfo-list ( addrinfo -- seq )
    [ next>> ] follow
    [ addrinfo>addrspec ] map
    sift ;

HOOK: addrinfo-error io-backend ( n -- )

: prepare-addrinfo ( -- addrinfo )
    addrinfo <struct>
        PF_UNSPEC >>family
        IPPROTO_TCP >>protocol ;

PRIVATE>

: <client> ( remote encoding -- stream local )
    [ (client) ] dip swap [ <encoder-duplex> ] dip ;

SYMBOL: local-address

SYMBOL: remote-address

: with-client ( remote encoding quot -- )
    [
        [
            over remote-address set
            <client> local-address set
        ] dip with-stream
    ] with-scope ; inline

: <server> ( addrspec encoding -- server )
    [
        [ (server) ] keep
        [ drop server-port <port> ] [ get-local-address ] 2bi
        >>addr
    ] dip >>encoding ;

: accept ( server -- client remote )
    [
        dup addr>>
        [ (accept) ] keep
        parse-sockaddr swap
        <ports>
    ] keep encoding>> <encoder-duplex> swap ;

: <datagram> ( addrspec -- datagram )
    [
        [ (datagram) |dispose ] keep
        [ drop datagram-port <port> ] [ get-local-address ] 2bi
        >>addr
    ] with-destructors ;

: receive ( datagram -- packet addrspec )
    check-datagram-port
    [ (receive) ] [ addr>> ] bi parse-sockaddr ;

: send ( packet addrspec datagram -- )
    check-datagram-send (send) ;

GENERIC: resolve-host ( addrspec -- seq )

TUPLE: hostname host ;

TUPLE: inet < hostname port ;

M: inet present
    [ host>> ] [ port>> number>string ] bi ":" glue ;

C: <inet> inet

M: string resolve-host
    f prepare-addrinfo f <void*>
    [ getaddrinfo addrinfo-error ] keep *void* addrinfo memory>struct
    [ parse-addrinfo-list ] keep freeaddrinfo ;

M: hostname resolve-host
    host>> resolve-host ;

M: inet resolve-host
    [ call-next-method ] [ port>> ] bi '[ _ with-port ] map ;

M: inet4 resolve-host 1array ;

M: inet6 resolve-host 1array ;

M: local resolve-host 1array ;

M: f resolve-host
    drop { T{ ipv6 f "::" } T{ ipv4 f "0.0.0.0" } } ;

: host-name ( -- string )
    256 <byte-array> dup dup length gethostname
    zero? [ "gethostname failed" throw ] unless
    ascii alien>string ;

M: inet (client) resolve-host (client) ;

ERROR: invalid-inet-server addrspec ;

M: invalid-inet-server summary
    drop "Cannot use <server> with <inet>; use <inet4> or <inet6> instead" ;

M: inet (server)
    invalid-inet-server ;

ERROR: invalid-local-address addrspec ;

M: invalid-local-address summary
    drop "Cannot use with-local-address with <inet>; use <inet4> or <inet6> instead" ;

: with-local-address ( addr quot -- )
    [
        [ ] [ inet4? ] [ inet6? ] tri or
        [ bind-local-address ]
        [ invalid-local-address ] if
    ] dip with-variable ; inline

{
    { [ os unix? ] [ "io.sockets.unix" require ] }
    { [ os winnt? ] [ "io.sockets.windows.nt" require ] }
} cond
