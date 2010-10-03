! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax arrays assocs
byte-arrays calendar combinators combinators.smart constructors
destructors fry grouping io io.binary io.buffers
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.ports io.sockets io.sockets.private
io.streams.byte-array io.timeouts kernel make math math.bitwise
math.parser math.ranges math.statistics memoize namespaces
nested-comments random sequences slots.syntax splitting strings
system unicode.categories vectors vocabs.loader ;
IN: dns

GENERIC: stream-peek1 ( stream -- byte/f )

M: input-port stream-peek1
    dup check-disposed dup wait-to-read
    [ drop f ] [ buffer>> buffer-peek ] if ; inline

M: byte-reader stream-peek1
    [ i>> ] [ underlying>> ] bi ?nth ;

: peek1 ( -- byte ) input-stream get stream-peek1 ;

: with-temporary-input-seek ( n seek-type quot -- )
    tell-input [
        [ seek-input ] dip call
    ] dip seek-absolute seek-input ; inline

ENUM: dns-type
{ A 1 } { NS 2 } { MD 3 } { MF 4 }
{ CNAME 5 } { SOA 6 } { MB 7 } { MG 8 }
{ MR 9 } { NULL 10 } { WKS 11 } { PTR 12 }
{ HINFO 13 } { MINFO 14 } { MX 15 } { TXT 16 }
{ RP 17 } { AFSDB 18 } { SIG 24 } { KEY 25 }
{ AAAA 28 } { LOC 29 } { SVR 33 } { NAPTR 35 }
{ KX 36 } { CERT 37 } { DNAME 39 } { OPT 41 }
{ APL 42 } { DS 43 } { SSHFP 44 } { IPSECKEY 45 }
{ RRSIG 46 } { NSEC 47 } { DNSKEY 48 } { DHCID 49 }
{ NSEC3 50 } { NSEC3PARAM 51 } { HIP 55 } { SPF 99 }
{ TKEY 249 } { TSIG 250 } { IXFR 251 }
{ TA 32768 } { DLV 32769 } ;

ENUM: dns-class { IN 1 } { CS 2 } { CH 3 } { HS 4 } ;

ENUM: dns-opcode QUERY IQUERY STATUS ;

ENUM: dns-rcode NO-ERROR FORMAT-ERROR SERVER-FAILURE
NAME-ERROR NOT-IMPLEMENTED REFUSED ;

SYMBOL: dns-servers

: add-dns-server ( string -- )
    dns-servers get push ;

: remove-dns-server ( string -- )
    dns-servers get remove! drop ;

: clear-dns-servers ( -- )
    V{ } clone dns-servers set-global ;

: >dotted ( domain -- domain' )
    dup "." tail? [ "." append ] unless ;

: dotted> ( string -- string' )
    "." ?tail drop ;

TUPLE: query name type class ;
CONSTRUCTOR: query ( name type class -- obj )
    [ >dotted ] change-name ;

TUPLE: rr name type class ttl rdata ;

TUPLE: hinfo cpu os ;

TUPLE: mx preference exchange ;

TUPLE: soa mname rname serial refresh retry expire minimum ;

TUPLE: a name ;
CONSTRUCTOR: a ( name -- obj ) ;

TUPLE: aaaa name ;
CONSTRUCTOR: aaaa ( name -- obj ) ;

TUPLE: cname name ;
CONSTRUCTOR: cname ( name -- obj ) ;

TUPLE: ptr name ;
CONSTRUCTOR: ptr ( name -- obj ) ;

TUPLE: ns name ;
CONSTRUCTOR: ns ( name -- obj ) ;

TUPLE: message id qr opcode aa tc rd ra z rcode
query answer-section authority-section additional-section ;

CONSTRUCTOR: message ( query -- obj )
    16 2^ random >>id
    0 >>qr
    QUERY >>opcode
    0 >>aa
    0 >>tc
    1 >>rd
    0 >>ra
    0 >>z
    NO-ERROR >>rcode
    [ dup sequence? [ 1array ] unless ] change-query
    { } >>answer-section
    { } >>authority-section
    { } >>additional-section ;

: message>header ( message -- n )
    [
        {
            [ qr>> 15 shift ]
            [ opcode>> enum>number 11 shift ]
            [ aa>> 10 shift ]
            [ tc>> 9 shift ]
            [ rd>> 8 shift ]
            [ ra>> 7 shift ]
            [ z>> 4 shift ]
            [ rcode>> enum>number 0 shift ]
        } cleave
    ] sum-outputs ;

: header>message-parts ( n -- qr opcode aa tc rd ra z rcode )
    {
        [ -15 shift BIN: 1 bitand ]
        [ -11 shift BIN: 111 bitand <dns-opcode> ]
        [ -10 shift BIN: 1 bitand ]
        [ -9 shift BIN: 1 bitand ]
        [ -8 shift BIN: 1 bitand ]
        [ -7 shift BIN: 1 bitand ]
        [ -4 shift BIN: 111 bitand ]
        [ BIN: 1111 bitand <dns-rcode> ]
    } cleave ;

: byte-array>ipv4 ( byte-array -- string )
    [ number>string ] { } map-as "." join ;

: byte-array>ipv6 ( byte-array -- string )
    2 group [ be> >hex ] { } map-as ":" join ;

: ipv4>byte-array ( string -- byte-array )
    "." split [ string>number ] B{ } map-as ;

: ipv6>byte-array ( string -- byte-array )
    T{ inet6 } inet-pton ;

: expand-ipv6 ( ipv6 -- ipv6' ) ipv6>byte-array byte-array>ipv6 ;

: reverse-ipv4 ( string -- string )
    ipv4>byte-array reverse byte-array>ipv4 ;

CONSTANT: ipv4-arpa-suffix ".in-addr.arpa"

: ipv4>arpa ( string -- string )
    reverse-ipv4 ipv4-arpa-suffix append ;

CONSTANT: ipv6-arpa-suffix ".ip6.arpa"

: ipv6>arpa ( string -- string )
    ipv6>byte-array [ [ -4 shift 4 bits ] [ 4 bits ] bi 2array ] { } map-as
    B{ } concat-as reverse
    [ >hex ] { } map-as "." join ipv6-arpa-suffix append ;

: trim-ipv4-arpa ( string -- string' )
    dotted> ipv4-arpa-suffix ?tail drop ;

: trim-ipv6-arpa ( string -- string' )
    dotted> ipv6-arpa-suffix ?tail drop ;
 
: arpa>ipv4 ( string -- ip ) trim-ipv4-arpa reverse-ipv4 ;

: arpa>ipv6 ( string -- ip )
    trim-ipv6-arpa "." split 2 group reverse
    [
        first2 swap [ hex> ] bi@ [ 4 shift ] [ ] bi* bitor
    ] B{ } map-as byte-array>ipv6 ;

: parse-length-bytes ( -- seq ) read1 read utf8 decode ;

: (parse-name) ( -- )
    peek1 [
        read1 drop
    ] [
        HEX: C0 mask? [
            2 read be> HEX: 3fff bitand
            seek-absolute [ parse-length-bytes , (parse-name) ] with-temporary-input-seek
        ] [
            parse-length-bytes , (parse-name)
        ] if
    ] if-zero ;

: parse-name ( -- seq )
    [ (parse-name) ] { } make "." join ;

: parse-query ( -- query )
    parse-name
    2 read be> <dns-type>
    2 read be> <dns-class> <query> ;

: parse-soa ( -- soa )
    soa new
        parse-name >>mname
        parse-name >>rname
        4 read be> >>serial
        4 read be> >>refresh
        4 read be> >>retry
        4 read be> >>expire
        4 read be> >>minimum ;

: parse-mx ( -- mx )
    mx new
        2 read be> >>preference
        parse-name >>exchange ;

GENERIC: parse-rdata ( n type -- obj )

M: object parse-rdata drop read ;
M: A parse-rdata 2drop 4 read byte-array>ipv4 <a> ;
M: AAAA parse-rdata 2drop 16 read byte-array>ipv6 <aaaa> ;
M: CNAME parse-rdata 2drop parse-name <cname> ;
M: MX parse-rdata 2drop parse-mx ;
M: NS parse-rdata 2drop parse-name <ns> ;
M: PTR parse-rdata 2drop parse-name <ptr> ;
M: SOA parse-rdata 2drop parse-soa ;

: parse-rr ( -- rr )
    rr new
        parse-name >>name
        2 read be> <dns-type> >>type
        2 read be> <dns-class> >>class
        4 read be> >>ttl
        2 read be> over type>> parse-rdata >>rdata ;

: parse-message ( ba -- message )
    [ message new ] dip
    binary [
        2 read be> >>id
        2 read be> header>message-parts set-slots[ qr opcode aa tc rd ra z rcode ]
        2 read be> >>query
        2 read be> >>answer-section
        2 read be> >>authority-section
        2 read be> >>additional-section
        [ [ parse-query ] replicate ] change-query
        [ [ parse-rr ] replicate ] change-answer-section
        [ [ parse-rr ] replicate ] change-authority-section
        [ [ parse-rr ] replicate ] change-additional-section
    ] with-byte-reader ;

: >n/label ( string -- ba )
    [ length 1array ] [ utf8 encode ] bi B{ } append-as ;

: >name ( dn -- ba ) "." split [ >n/label ] map concat ;

: query>byte-array ( query -- ba )
    [
        {
            [ name>> >name ]
            [ type>> enum>number 2 >be ]
            [ class>> enum>number 2 >be ]
        } cleave
    ] B{ } append-outputs-as ;

GENERIC: rdata>byte-array ( rdata type -- obj )

M: A rdata>byte-array drop ipv4>byte-array ;

M: CNAME rdata>byte-array drop >name ;

M: HINFO rdata>byte-array
    drop
    [ cpu>> >name ]
    [ os>> >name ] bi append ;

M: MX rdata>byte-array
    drop 
    [ preference>> 2 >be ]
    [ exchange>> >name ] bi append ;

M: NS rdata>byte-array drop >name ;

M: PTR rdata>byte-array drop >name ;

M: SOA rdata>byte-array
    drop
    [
        {
            [ mname>> >name ]
            [ rname>> >name ]
            [ serial>> 4 >be ]
            [ refresh>> 4 >be ]
            [ retry>> 4 >be ]
            [ expire>> 4 >be ]
            [ minimum>> 4 >be ]
        } cleave
    ] B{ } append-outputs-as ;

: rr>byte-array ( rr -- ba )
    [
        {
            [ name>> >name ]
            [ type>> enum>number 2 >be ]
            [ class>> enum>number 2 >be ]
            [ ttl>> 4 >be ]
            [
                [ rdata>> ] [ type>> ] bi rdata>byte-array
                [ length 2 >be ] [ ] bi append
            ]
        } cleave
    ] B{ } append-outputs-as ;

: message>byte-array ( message -- ba )
    [
        {
            [ id>> 2 >be ]
            [ message>header 2 >be ]
            [ query>> length 2 >be ]
            [ answer-section>> length 2 >be ]
            [ authority-section>> length 2 >be ]
            [ additional-section>> length 2 >be ]
            [ query>> [ query>byte-array ] map concat ]
            [ answer-section>> [ rr>byte-array ] map concat ]
            [ authority-section>> [ rr>byte-array ] map concat ]
            [ additional-section>> [ rr>byte-array ] map concat ]
        } cleave
    ] B{ } append-outputs-as ;

: udp-query ( bytes server -- bytes' )
    f 0 <inet4> <datagram>
    30 seconds over set-timeout [
        [ send ] [ receive drop ] bi
    ] with-disposal ;

: <dns-inet4> ( -- inet4 )
    dns-servers get random 53 <inet4> ;

: dns-query ( query -- message )
    <message> message>byte-array
    <dns-inet4> udp-query parse-message ;

: dns-A-query ( domain -- message ) A IN <query> dns-query ;
: dns-AAAA-query ( domain -- message ) AAAA IN <query> dns-query ;
: dns-MX-query ( domain -- message ) MX IN <query> dns-query ;
: dns-NS-query ( domain -- message ) NS IN <query> dns-query ;

: reverse-lookup ( reversed-ip -- message )
    PTR IN <query> dns-query ;

: reverse-ipv4-lookup ( ip -- message )
    ipv4>arpa reverse-lookup ;

: reverse-ipv6-lookup ( ip -- message )
    ipv6>arpa reverse-lookup ;

: message>names ( message -- names )
    answer-section>> [ rdata>> name>> ] map ;

: message>a-names ( message -- names )
    answer-section>>
    [ rdata>> ] map [ a? ] filter [ name>> ] map ;

: message>mxs ( message -- assoc )
    answer-section>> [ rdata>> [ preference>> ] [ exchange>> ] bi 2array ] map ;

: messages>names ( messages -- names ) 
    [ message>names ] map concat ;

: forward-confirmed-reverse-dns-ipv4? ( ipv4-string -- ? )
    dup reverse-ipv4-lookup message>names
    [ dns-A-query ] map messages>names member? ;

: forward-confirmed-reverse-dns-ipv6? ( ipv6-string -- ? )
    expand-ipv6
    dup reverse-ipv6-lookup message>names
    [ dns-AAAA-query ] map messages>names member? ;

: message>query-name ( message -- string )
    query>> first name>> dotted> ;

: a-line. ( host ip -- )
    [ write " has address " write ] [ print ] bi* ;

: a-message. ( message -- )
    [ message>query-name ] [ message>names ] bi
    [ a-line. ] with each ;

: mx-line. ( host pair -- )
    [ write " mail is handled by " write ]
    [ first2 [ number>string write bl ] [ print ] bi* ] bi* ;

: mx-message. ( message -- )
    [ message>query-name ] [ message>mxs ] bi
    [ mx-line. ] with each ;

: host ( domain -- )
    [ dns-A-query a-message. ]
    [ dns-AAAA-query a-message. ]
    [ dns-MX-query mx-message. ] tri ;

! M: string resolve-host dns-A-query message>a-names [ <ipv4> ] map ;
    
HOOK: initial-dns-servers os ( -- seq )

{
    { [ os windows? ] [ "dns.windows" ] }
    { [ os unix? ] [ "dns.unix" ] }
} cond require
    
dns-servers [ initial-dns-servers >vector ] initialize
