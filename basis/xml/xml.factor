! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays io io.encodings.binary io.files
io.streams.string kernel namespaces sequences state-parser strings
xml.backend xml.data xml.errors xml.tokenize ascii
xml.writer ;
IN: xml

!   -- Overall parser with data tree

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml ( object -- )
    V{ } clone 2array xml-stack get push ;

: pop-xml ( -- object )
    xml-stack get pop ;

GENERIC: process ( object -- )

M: object process add-child ;

M: prolog process
    xml-stack get V{ { f V{ } } } =
    [ bad-prolog ] unless drop ;

M: instruction process
    xml-stack get length 1 =
    [ bad-instruction ] unless
    add-child ;

M: directive process
    xml-stack get dup length 1 =
    swap first second [ tag? ] contains? not and
    [ misplaced-directive ] unless
    add-child ;

M: contained process
    [ name>> ] [ attrs>> ] bi
    <contained-tag> add-child ;

M: opener process push-xml ;

: check-closer ( name opener -- name opener )
    dup [ unopened ] unless
    2dup name>> =
    [ name>> swap mismatched ] unless ;

M: closer process
    name>> pop-xml first2
    [ check-closer attrs>> ] dip
    <tag> add-child ;

: init-xml-stack ( -- )
    V{ } clone xml-stack set f push-xml ;

: default-prolog ( -- prolog )
    "1.0" "UTF-8" f <prolog> ;

: reset-prolog ( -- )
    default-prolog prolog-data set ;

: init-xml ( -- )
    reset-prolog init-xml-stack init-ns-stack ;

: assert-blanks ( seq pre? -- )
    swap [ string? ] filter
    [
        dup [ blank? ] all?
        [ drop ] [ swap pre/post-content ] if
    ] each drop ;

: no-pre/post ( pre post -- pre post/* )
    ! this does *not* affect the contents of the stack
    [ dup t assert-blanks ] [ dup f assert-blanks ] bi* ;

: no-post-tags ( post -- post/* )
    ! this does *not* affect the contents of the stack
    dup [ tag? ] contains? [ multitags ] when ; 

: assure-tags ( seq -- seq )
    ! this does *not* affect the contents of the stack
    [ notags ] unless* ;

: make-xml-doc ( prolog seq -- xml-doc )
    dup [ tag? ] find
    [ assure-tags cut rest no-pre/post no-post-tags ] dip
    swap <xml> ;

! * Views of XML

SYMBOL: text-now?

TUPLE: pull-xml scope ;
: <pull-xml> ( -- pull-xml )
    [
        input-stream [ ] change ! bring var in this scope
        init-parser reset-prolog init-ns-stack
        text-now? on
    ] H{ } make-assoc
    pull-xml boa ;
! pull-xml needs to call start-document somewhere

: pull-event ( pull -- xml-event/f )
    scope>> [
        text-now? get [ parse-text f ] [
            get-char [ make-tag t ] [ f f ] if
        ] if text-now? set
    ] bind ;

: done? ( -- ? )
    xml-stack get length 1 = ;

: (pull-elem) ( pull -- xml-elem/f )
    dup pull-event dup closer? done? and [ nip ] [
        process done?
        [ drop xml-stack get first second ]
        [ (pull-elem) ] if
    ] if ;

: pull-elem ( pull -- xml-elem/f )
    [ init-xml-stack (pull-elem) ] with-scope ;

: call-under ( quot object -- quot )
    swap dup slip ; inline

: sax-loop ( quot: ( xml-elem -- ) -- )
    parse-text call-under
    get-char [ make-tag call-under sax-loop ]
    [ drop ] if ; inline recursive

: sax ( stream quot: ( xml-elem -- ) -- )
    swap [
        reset-prolog init-ns-stack
        start-document call-under
        sax-loop
    ] state-parse ; inline recursive

: (read-xml) ( -- )
    start-document process
    [ process ] sax-loop ; inline

: (read-xml-chunk) ( stream -- prolog seq )
    [
        init-xml (read-xml)
        done? [ unclosed ] unless
        xml-stack get first second
        prolog-data get swap
    ] state-parse ;

: read-xml ( stream -- xml )
    #! Produces a tree of XML nodes
    (read-xml-chunk) make-xml-doc ;

: read-xml-chunk ( stream -- seq )
    (read-xml-chunk) nip ;

: string>xml ( string -- xml )
    <string-reader> read-xml ;

: string>xml-chunk ( string -- xml )
    t string-input?
    [ <string-reader> read-xml-chunk ] with-variable ;

: file>xml ( filename -- xml )
    ! Autodetect encoding!
    binary <file-reader> read-xml ;

: xml-reprint ( string -- )
    string>xml print-xml ;

