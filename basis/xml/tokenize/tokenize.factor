! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs combinators locals
combinators.short-circuit fry io.encodings io.encodings.iana
io.encodings.string io.encodings.utf16 io.encodings.utf8 kernel make
math math.parser namespaces sequences sets splitting xml.state
strings xml.char-classes xml.data xml.entities xml.errors hashtables
circular io sbufs ;
IN: xml.tokenize

! Originally from state-parser

SYMBOL: prolog-data

: version=1.0? ( -- ? )
    prolog-data get [ version>> "1.0" = ] [ t ] if* ;

: assure-good-char ( ch -- ch )
    [
        version=1.0? over text? not get-check and
        [ disallowed-char ] when
    ] [ f ] if* ;

! * Basic utility words

: record ( char -- )
    CHAR: \n =
    [ 0 get-line 1+ set-line ] [ get-column 1+ ] if
    set-column ;

! (next) normalizes \r\n and \r
: (next) ( -- char )
    get-next read1
    2dup swap CHAR: \r = [
        CHAR: \n =
        [ nip read1 ] [ nip CHAR: \n swap ] if
    ] [ drop ] if
    set-next dup set-char assure-good-char ;

: next ( -- )
    #! Increment spot.
    get-char [ unexpected-end ] unless (next) record ;

: skip-until ( quot: ( -- ? ) -- )
    get-char [
        [ call ] keep swap [ drop ] [
            next skip-until
        ] if
    ] [ drop ] if ; inline recursive

: take-until ( quot -- string )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    10 <sbuf> [
        '[ @ [ t ] [ get-char _ push f ] if ] skip-until
    ] keep >string ; inline

: take-char ( ch -- string )
    [ dup get-char = ] take-until nip ;

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ get-char blank? not ] skip-until ;

: string-matches? ( string circular -- ? )
    get-char over push-circular
    sequence= ;

: take-string ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head
    get-char [ missing-close ] unless next ;

: expect ( ch -- )
    get-char 2dup = [ 2drop ] [
        [ 1string ] bi@ expected
    ] if next ;

: expect-string ( string -- )
    dup [ get-char next ] replicate 2dup =
    [ 2drop ] [ expected ] if ;

: init-parser ( -- )
    0 1 0 f f <spot> spot set
    read1 set-next next ;

: state-parse ( stream quot -- )
    ! with-input-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-input-stream ; inline

! XML namespace processing: ns = namespace

! A stack of hashtables
SYMBOL: ns-stack

SYMBOL: depth

: attrs>ns ( attrs-alist -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            swap dup space>> "xmlns" =
            [ main>> set ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" set ] [ drop ] if
            ] if
        ] assoc-each
    ] { } make-assoc f like ;

: add-ns ( name -- )
    dup space>> dup ns-stack get assoc-stack
    [ nip ] [ nonexist-ns ] if* >>url drop ;

: push-ns ( hash -- )
    ns-stack get push ;

: pop-ns ( -- )
    ns-stack get pop* ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "http://www.w3.org/XML/1998/namespace" }
        { "xmlns" "http://www.w3.org/2000/xmlns" }
        { "" "" }
    } } clone
    ns-stack set ;

: tag-ns ( name attrs-alist -- name attrs )
    dup attrs>ns push-ns
    [ dup add-ns ] dip dup [ drop add-ns ] assoc-each <attrs> ;

! Parsing names

: valid-name? ( str -- ? )
    [ f ] [
        version=1.0? swap {
            [ first name-start? ]
            [ rest-slice [ name-char? ] with all? ]
        } 2&&
    ] if-empty ;

: prefixed-name ( str -- name/f )
    ":" split dup length 2 = [
        [ [ valid-name? ] all? ]
        [ first2 f <name> ] bi and
    ] [ drop f ] if ;

: interpret-name ( str -- name )
    dup prefixed-name [ ] [
        dup valid-name?
        [ <simple-name> ] [ bad-name ] if
    ] ?if ;

: take-name ( -- string )
    version=1.0? '[ _ get-char name-char? not ] take-until ;

: parse-name ( -- name )
    take-name interpret-name ;

: parse-name-starting ( string -- name )
    take-name append interpret-name ;

!   -- Parsing strings

: parse-named-entity ( string -- )
    dup entities at [ , ] [
        dup extra-entities get at
        [ % ] [ no-entity ] ?if
    ] ?if ;

: parse-entity ( -- )
    next CHAR: ; take-char next
    "#" ?head [
        "x" ?head 16 10 ? base> ,
    ] [ parse-named-entity ] if ;

SYMBOL: pe-table
SYMBOL: in-dtd?

: parse-pe ( -- )
    next CHAR: ; take-char dup next
    pe-table get at [ % ] [ no-entity ] ?if ;

:: (parse-char) ( quot: ( ch -- ? ) -- )
    get-char :> char
    {
        { [ char not ] [ ] }
        { [ char quot call ] [ next ] }
        { [ char CHAR: & = ] [ parse-entity quot (parse-char) ] }
        { [ in-dtd? get char CHAR: % = and ] [ parse-pe quot (parse-char) ] }
        [ char , next quot (parse-char) ]
    } cond ; inline recursive

: parse-char ( quot: ( ch -- ? ) -- seq )
    [ (parse-char) ] "" make ; inline

: assure-no-]]> ( circular -- )
    "]]>" sequence= [ text-w/]]> ] when ;

:: parse-text ( -- string )
    3 f <array> <circular> :> circ
    depth get zero? :> no-text [| char |
        char circ push-circular
        circ assure-no-]]>
        no-text [ char blank? char CHAR: < = or [
            char 1string t pre/post-content
        ] unless ] when
        char CHAR: < =
    ] parse-char ;

! Parsing tags

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: normalize-quote ( str -- str )
    [ dup "\t\r\n" member? [ drop CHAR: \s ] when ] map ;

: (parse-quote) ( <-disallowed? ch -- string )
    swap '[
        dup _ = [ drop t ]
        [ CHAR: < = _ and [ attr-w/< ] [ f ] if ] if
    ] parse-char normalize-quote get-char
    [ unclosed-quote ] unless ; inline

: parse-quote* ( <-disallowed? -- seq )
    pass-blank get-char dup "'\"" member?
    [ next (parse-quote) ] [ quoteless-attr ] if ; inline

: parse-quote ( -- seq )
   f parse-quote* ;

: parse-attr ( -- )
    parse-name pass-blank CHAR: = expect pass-blank
    t parse-quote* 2array , ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start?
    [ parse-attr (middle-tag) ] when ;

: assure-no-duplicates ( attrs-alist -- attrs-alist )
    H{ } clone 2dup '[ swap _ push-at ] assoc-each
    [ nip length 2 >= ] assoc-filter >alist
    [ first first2 duplicate-attr ] unless-empty ;

: middle-tag ( -- attrs-alist )
    ! f make will make a vector if it has any elements
    [ (middle-tag) ] f make pass-blank
    assure-no-duplicates ;

: close ( -- )
    pass-blank CHAR: > expect ;

: end-tag ( name attrs-alist -- tag )
    tag-ns pass-blank get-char CHAR: / =
    [ pop-ns <contained> next CHAR: > expect ]
    [ depth inc <opener> close ] if ;

: take-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: take-cdata ( -- string )
    depth get zero? [ bad-cdata ] when
    "[CDATA[" expect-string "]]>" take-string ;

: take-word ( -- string )
    [ get-char blank? ] take-until ;

: take-decl-contents ( -- first second )
    pass-blank take-word pass-blank ">" take-string ;

: take-element-decl ( -- element-decl )
    take-decl-contents <element-decl> ;

: take-attlist-decl ( -- attlist-decl )
    take-decl-contents <attlist-decl> ;

: take-notation-decl ( -- notation-decl )
    take-decl-contents <notation-decl> ; 

: take-until-one-of ( seps -- str sep )
    '[ get-char _ member? ] take-until get-char ;

: take-system-id ( -- system-id )
    parse-quote <system-id> close ;

: take-public-id ( -- public-id )
    parse-quote parse-quote <public-id> close ;

DEFER: direct

: (take-internal-subset) ( -- )
    pass-blank get-char {
        { CHAR: ] [ next ] }
        [ drop "<!" expect-string direct , (take-internal-subset) ]
    } case ;

: take-internal-subset ( -- seq )
    [
        H{ } pe-table set
        t in-dtd? set
        (take-internal-subset)
    ] { } make ;

: (take-external-id) ( token -- external-id )
    pass-blank {
        { "SYSTEM" [ take-system-id ] }
        { "PUBLIC" [ take-public-id ] }
        [ bad-external-id ]
    } case ;

: take-external-id ( -- external-id )
    take-word (take-external-id) ;

: only-blanks ( str -- )
    [ blank? ] all? [ bad-decl ] unless ;

: nontrivial-doctype ( -- external-id internal-subset )
    pass-blank get-char CHAR: [ = [
        next take-internal-subset f swap close
    ] [
        " >" take-until-one-of {
            { CHAR: \s [ (take-external-id) ] }
            { CHAR: > [ only-blanks f ] }
        } case f
    ] if ;

: take-doctype-decl ( -- doctype-decl )
    pass-blank " >" take-until-one-of {
        { CHAR: \s [ nontrivial-doctype ] }
        { CHAR: > [ f f ] }
    } case <doctype-decl> ;

: take-entity-def ( var -- entity-name entity-def )
    take-word pass-blank get-char {
        { CHAR: ' [ parse-quote ] }
        { CHAR: " [ parse-quote ] }
        [ drop take-external-id ]
    } case [ spin [ ?set-at ] change ] 2keep ;

: take-entity-decl ( -- entity-decl )
    pass-blank get-char {
        { CHAR: % [ next pass-blank pe-table take-entity-def ] }
        [ drop extra-entities take-entity-def ]
    } case
    close <entity-decl> ;

: take-directive ( -- directive )
    take-name {
        { "ELEMENT" [ take-element-decl ] }
        { "ATTLIST" [ take-attlist-decl ] }
        { "DOCTYPE" [ take-doctype-decl ] }
        { "ENTITY" [ take-entity-decl ] }
        { "NOTATION" [ take-notation-decl ] }
        [ bad-directive ]
    } case ;

: direct ( -- object )
    get-char {
        { CHAR: - [ take-comment ] }
        { CHAR: [ [ take-cdata ] }
        [ drop take-directive ]
    } case ;

: assure-no-extra ( seq -- )
    [ first ] map {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } diff
    [ extra-attrs ] unless-empty ; 

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ bad-version ] unless ;

: prolog-version ( alist -- version )
    T{ name f "" "version" f } swap at
    [ good-version ] [ versionless-prolog ] if* ;

: prolog-encoding ( alist -- encoding )
    T{ name f "" "encoding" f } swap at "UTF-8" or ;

: yes/no>bool ( string -- t/f )
    {
        { "yes" [ t ] }
        { "no" [ f ] }
        [ not-yes/no ]
    } case ;

: prolog-standalone ( alist -- version )
    T{ name f "" "standalone" f } swap at
    [ yes/no>bool ] [ f ] if* ;

: prolog-attrs ( alist -- prolog )
    [ prolog-version ]
    [ prolog-encoding ]
    [ prolog-standalone ]
    tri <prolog> ;

SYMBOL: string-input?
: decode-input-if ( encoding -- )
    string-input? get [ drop ] [ decode-input ] if ;

: parse-prolog ( -- prolog )
    pass-blank middle-tag "?>" expect-string
    dup assure-no-extra prolog-attrs
    dup encoding>> dup "UTF-16" =
    [ drop ] [ name>encoding [ decode-input-if ] when* ] if
    dup prolog-data set ;

: instruct ( -- instruction )
    take-name {
        { [ dup "xml" = ] [ drop parse-prolog ] }
        { [ dup >lower "xml" = ] [ capitalized-prolog ] }
        { [ dup valid-name? not ] [ bad-name ] }
        [ "?>" take-string append <instruction> ]
    } cond ;

: make-tag ( -- tag )
    {
        { [ get-char dup CHAR: ! = ] [ drop next direct ] }
        { [ CHAR: ? = ] [ next instruct ] }
        [
            start-tag [ dup add-ns pop-ns <closer> depth dec close ]
            [ middle-tag end-tag ] if
        ]
    } cond ;

! Autodetecting encodings

: continue-make-tag ( str -- tag )
    parse-name-starting middle-tag end-tag ;

: start-utf16le ( -- tag )
    utf16le decode-input-if
    CHAR: ? expect
    0 expect check instruct ;

: 10xxxxxx? ( ch -- ? )
    -6 shift 3 bitand 2 = ;
          
: start<name ( ch -- tag )
    ascii?
    [ utf8 decode-input-if next make-tag ] [
        next
        [ get-next 10xxxxxx? not ] take-until
        get-char suffix utf8 decode
        utf8 decode-input-if next
        continue-make-tag
    ] if ;
          
: start< ( -- tag )
    get-next {
        { 0 [ next next start-utf16le ] }
        { CHAR: ? [ check next next instruct ] } ! XML prolog parsing sets the encoding
        { CHAR: ! [ check utf8 decode-input next next direct ] }
        [ check start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-input
    CHAR: < expect check make-tag ;

: decode-expecting ( encoding string -- tag )
    [ decode-input-if next ] [ expect-string ] bi* check make-tag ;

: start-utf16be ( -- tag )
    utf16be "<" decode-expecting ;

: skip-utf16le-bom ( -- tag )
    utf16le "\u0000fe<" decode-expecting ;

: skip-utf16be-bom ( -- tag )
    utf16be "\u0000ff<" decode-expecting ;

: start-document ( -- tag )
    get-char {
        { CHAR: < [ start< ] }
        { 0 [ start-utf16be ] }
        { HEX: EF [ skip-utf8-bom ] }
        { HEX: FF [ skip-utf16le-bom ] }
        { HEX: FE [ skip-utf16be-bom ] }
        { f [ "" ] }
        [ drop utf8 decode-input-if f ]
        ! Same problem as with <e`>, in the case of XML chunks?
    } case check ;
