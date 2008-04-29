USING: math math.order math.parser kernel sequences io
accessors arrays io.streams.string splitting
combinators accessors debugger
calendar calendar.format.macros ;
IN: calendar.format

: pad-00 number>string 2 CHAR: 0 pad-left ;

: pad-0000 number>string 4 CHAR: 0 pad-left ;

: pad-00000 number>string 5 CHAR: 0 pad-left ;

: write-00 pad-00 write ;

: write-0000 pad-0000 write ;

: write-00000 pad-00000 write ;

: hh hour>> write-00 ;

: mm minute>> write-00 ;

: ss second>> >integer write-00 ;

: D day>> number>string write ;

: DD day>> write-00 ;

: DAY day-of-week day-abbreviations3 nth write ;

: MM month>> write-00 ;

: MONTH month>> month-abbreviations nth write ;

: YYYY year>> write-0000 ;

: YYYYY year>> write-00000 ;

: expect ( str -- )
    read1 swap member? [ "Parse error" throw ] unless ;

: read-00 2 read string>number ;

: read-000 3 read string>number ;

: read-0000 4 read string>number ;

GENERIC: day. ( obj -- )

M: integer day. ( n -- )
    number>string dup length 2 < [ bl ] when write ;

M: timestamp day. ( timestamp -- )
    day>> day. ;

GENERIC: month. ( obj -- )

M: array month. ( pair -- )
    first2
    [ month-names nth write bl number>string print ] 2keep
    [ 1 zeller-congruence ] 2keep
    2array days-in-month day-abbreviations2 " " join print
    over "   " <repetition> concat write
    [
        [ 1+ day. ] keep
        1+ + 7 mod zero? [ nl ] [ bl ] if
    ] with each nl ;

M: timestamp month. ( timestamp -- )
    [ year>> ] [ month>> ] bi 2array month. ;

GENERIC: year. ( obj -- )

M: integer year. ( n -- )
    12 [ 1+ 2array month. nl ] with each ;

M: timestamp year. ( timestamp -- )
    year>> year. ;

: (timestamp>string) ( timestamp -- )
    { DAY ", " D " " MONTH " " YYYY " " hh ":" mm ":" ss } formatted ;

: timestamp>string ( timestamp -- str )
    [ (timestamp>string) ] with-string-writer ;

: (write-gmt-offset) ( duration -- )
    [ hh ] [ mm ] bi ;

: write-gmt-offset ( gmt-offset -- )
    dup instant <=> {
        { +eq+ [ drop "GMT" write ] }
        { +lt+ [ "-" write before (write-gmt-offset) ] }
        { +gt+ [ "+" write (write-gmt-offset) ] }
    } case ;

: timestamp>rfc822 ( timestamp -- str )
    #! RFC822 timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 +0200
    [
        [ (timestamp>string) " " write ]
        [ gmt-offset>> write-gmt-offset ]
        bi
    ] with-string-writer ;

: timestamp>http-string ( timestamp -- str )
    #! http timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 GMT
    >gmt timestamp>rfc822 ;

: (timestamp>cookie-string) ( timestamp -- )
    >gmt
    { DAY ", " DD "-" MONTH "-" YYYY " " hh ":" mm ":" ss " GMT" } formatted ;

: timestamp>cookie-string ( timestamp -- str )
    [ (timestamp>cookie-string) ] with-string-writer ;

: (write-rfc3339-gmt-offset) ( duration -- )
    [ hh ":" write ] [ mm ] bi ;

: write-rfc3339-gmt-offset ( duration -- )
    dup instant <=> {
        { +eq+ [ drop "Z" write ] }
        { +lt+ [ "-" write before (write-rfc3339-gmt-offset) ] }
        { +gt+ [ "+" write (write-rfc3339-gmt-offset) ] }
    } case ;
    
: (timestamp>rfc3339) ( timestamp -- )
    {
        YYYY "-" MM "-" DD "T" hh ":" mm ":" ss
        [ gmt-offset>> write-rfc3339-gmt-offset ]
    } formatted ;

: timestamp>rfc3339 ( timestamp -- str )
    [ (timestamp>rfc3339) ] with-string-writer ;

: signed-gmt-offset ( dt ch -- dt' )
    { { CHAR: + [ 1 ] } { CHAR: - [ -1 ] } } case time* ;

: read-rfc3339-gmt-offset ( ch -- dt )
    dup CHAR: Z = [ drop instant ] [
        >r
        read-00 hours
        read1 { { CHAR: : [ read-00 ] } { f [ 0 ] } } case minutes
        time+
        r> signed-gmt-offset
    ] if ;

: read-ymd ( -- y m d )
    read-0000 "-" expect read-00 "-" expect read-00 ;

: read-hms ( -- h m s )
    read-00 ":" expect read-00 ":" expect read-00 ;

: (rfc3339>timestamp) ( -- timestamp )
    read-ymd
    "Tt" expect
    read-hms
    read1 { { CHAR: . [ read-000 1000 / + read1 ] } [ ] } case
    read-rfc3339-gmt-offset
    <timestamp> ;

: rfc3339>timestamp ( str -- timestamp )
    [ (rfc3339>timestamp) ] with-string-reader ;

ERROR: invalid-timestamp-format ;

: check-timestamp ( obj/f -- obj )
    [ invalid-timestamp-format ] unless* ;

: read-token ( seps -- token )
    [ read-until ] keep member? check-timestamp drop ;

: read-sp ( -- token ) " " read-token ;

: checked-number ( str -- n )
    string>number check-timestamp ;

: parse-rfc822-gmt-offset ( string -- dt )
    dup "GMT" = [ drop instant ] [
        unclip >r
        2 cut [ string>number ] bi@ [ hours ] [ minutes ] bi* time+
        r> signed-gmt-offset
    ] if ;

: (rfc822>timestamp) ( -- timestamp )
    timestamp new
        "," read-token day-abbreviations3 member? check-timestamp drop
        read1 CHAR: \s assert=
        read-sp checked-number >>day
        read-sp month-abbreviations index check-timestamp >>month
        read-sp checked-number >>year
        ":" read-token checked-number >>hour
        ":" read-token checked-number >>minute
        " " read-token checked-number >>second
        readln parse-rfc822-gmt-offset >>gmt-offset ;

: rfc822>timestamp ( str -- timestamp )
    [ (rfc822>timestamp) ] with-string-reader ;

: (cookie-string>timestamp-1) ( -- timestamp )
    timestamp new
        "," read-token day-abbreviations3 member? check-timestamp drop
        read1 CHAR: \s assert=
        "-" read-token checked-number >>day
        "-" read-token month-abbreviations index check-timestamp >>month
        read-sp checked-number >>year
        ":" read-token checked-number >>hour
        ":" read-token checked-number >>minute
        " " read-token checked-number >>second
        readln parse-rfc822-gmt-offset >>gmt-offset ;

: cookie-string>timestamp-1 ( str -- timestamp )
    [ (cookie-string>timestamp-1) ] with-string-reader ;

: (cookie-string>timestamp-2) ( -- timestamp )
    timestamp new
        read-sp day-abbreviations3 member? check-timestamp drop
        read-sp month-abbreviations index check-timestamp >>month
        read-sp checked-number >>day
        ":" read-token checked-number >>hour
        ":" read-token checked-number >>minute
        " " read-token checked-number >>second
        read-sp checked-number >>year
        readln parse-rfc822-gmt-offset >>gmt-offset ;

: cookie-string>timestamp-2 ( str -- timestamp )
    [ (cookie-string>timestamp-2) ] with-string-reader ;

: cookie-string>timestamp ( str -- timestamp )
    {
        [ cookie-string>timestamp-1 ]
        [ cookie-string>timestamp-2 ]
        [ rfc822>timestamp ]
    } attempt-all-quots ;

: (ymdhms>timestamp) ( -- timestamp )
    read-ymd " " expect read-hms instant <timestamp> ;

: ymdhms>timestamp ( str -- timestamp )
    [ (ymdhms>timestamp) ] with-string-reader ;

: (hms>timestamp) ( -- timestamp )
    f f f read-hms instant <timestamp> ;

: hms>timestamp ( str -- timestamp )
    [ (hms>timestamp) ] with-string-reader ;

: (ymd>timestamp) ( -- timestamp )
    read-ymd f f f instant <timestamp> ;

: ymd>timestamp ( str -- timestamp )
    [ (ymd>timestamp) ] with-string-reader ;

: (timestamp>ymd) ( timestamp -- )
    { YYYY "-" MM "-" DD } formatted ;

: timestamp>ymd ( timestamp -- str )
    [ (timestamp>ymd) ] with-string-writer ;

: (timestamp>hms)
    { hh ":" mm ":" ss } formatted ;

: timestamp>hms ( timestamp -- str )
    [ (timestamp>hms) ] with-string-writer ;

: timestamp>ymdhms ( timestamp -- str )
    [
        >gmt
        { (timestamp>ymd) " " (timestamp>hms) } formatted
    ] with-string-writer ;

: file-time-string ( timestamp -- string )
    [
        {
            MONTH " " DD " "
            [
                dup now [ year>> ] bi@ =
                [ [ hh ":" write ] [ mm ] bi ] [ YYYYY ] if
            ]
        } formatted
    ] with-string-writer ;
