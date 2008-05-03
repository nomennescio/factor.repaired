! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences combinators kernel namespaces
classes.tuple assocs splitting words arrays memoize
io io.files io.encodings.utf8 io.streams.string
unicode.case tuple-syntax html html.elements
multiline xml xml.data xml.writer xml.utilities
http.server
http.server.auth
http.server.flows
http.server.actions
http.server.components
http.server.sessions
http.server.templating
http.server.boilerplate ;
IN: http.server.templating.chloe

! Chloe is Ed's favorite web designer

TUPLE: chloe path ;

C: <chloe> chloe

DEFER: process-template

: chloe-ns "http://factorcode.org/chloe/1.0" ; inline

: chloe-attrs-only ( assoc -- assoc' )
    [ drop name-url chloe-ns = ] assoc-filter ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ drop name-url chloe-ns = not ] assoc-filter ;

: chloe-tag? ( tag -- ? )
    {
        { [ dup tag? not ] [ f ] }
        { [ dup url>> chloe-ns = not ] [ f ] }
        [ t ]
    } cond nip ;

SYMBOL: tags

MEMO: chloe-name ( string -- name )
    name new
        swap >>tag
        chloe-ns >>url ;

: required-attr ( tag name -- value )
    dup chloe-name rot at*
    [ nip ] [ drop " attribute is required" append throw ] if ;

: optional-attr ( tag name -- value )
    chloe-name swap at ;

: children>string ( tag -- string )
    [ [ process-template ] each ] with-string-writer ;

: title-tag ( tag -- )
    children>string set-title ;

: write-title-tag ( tag -- )
    drop
    "head" tags get member? "title" tags get member? not and
    [ <title> write-title </title> ] [ write-title ] if ;

: style-tag ( tag -- )
    dup "include" optional-attr dup [
        swap children>string empty? [
            "style tag cannot have both an include attribute and a body" throw
        ] unless
        utf8 file-contents
    ] [
        drop children>string
    ] if add-style ;

: write-style-tag ( tag -- )
    drop <style> write-style </style> ;

: atom-tag ( tag -- )
    [ "title" required-attr ]
    [ "href" required-attr ]
    bi set-atom-feed ;

: write-atom-tag ( tag -- )
    drop
    "head" tags get member? [
        write-atom-feed
    ] [
        atom-feed get value>> second write
    ] if ;

: component-attr ( tag -- name )
    "component" required-attr ;

: view-tag ( tag -- )
    component-attr component render-view ;

: edit-tag ( tag -- )
    component-attr component render-edit ;

: summary-tag ( tag -- )
    component-attr component render-summary ;

: parse-query-attr ( string -- assoc )
    dup empty?
    [ drop f ] [ "," split [ dup value ] H{ } map>assoc ] if ;

: flow-attr ( tag -- )
    "flow" optional-attr {
        { "none" [ flow-id off ] }
        { "begin" [ begin-flow ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

: session-attr ( tag -- )
    "session" optional-attr {
        { "none" [ session off flow-id off ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

: a-start-tag ( tag -- )
    [
        <a
        dup flow-attr
        dup session-attr
        dup "value" optional-attr [ value f ] [
            [ "href" required-attr ]
            [ "query" optional-attr parse-query-attr ]
            bi
        ] ?if link>string =href
        a>
    ] with-scope ;

: process-tag-children ( tag -- )
    [ process-template ] each ;

: a-tag ( tag -- )
    [ a-start-tag ]
    [ process-tag-children ]
    [ drop </a> ]
    tri ;

: form-start-tag ( tag -- )
    [
        [
            <form
            "POST" =method
            {
                [ flow-attr ]
                [ session-attr ]
                [ "action" required-attr resolve-base-path =action ]
                [ tag-attrs non-chloe-attrs-only print-attrs ]
            } cleave
            form>
        ] [
            hidden-form-field
            "for" optional-attr [ component render-edit ] when*
        ] bi
    ] with-scope ;

: form-tag ( tag -- )
    [ form-start-tag ]
    [ process-tag-children ]
    [ drop </form> ]
    tri ;

DEFER: process-chloe-tag

STRING: button-tag-markup
<t:form class="inline" xmlns:t="http://factorcode.org/chloe/1.0">
    <button type="submit"></button>
</t:form>
;

: add-tag-attrs ( attrs tag -- )
    tag-attrs swap update ;

: button-tag ( tag -- )
    button-tag-markup string>xml delegate
    {
        [ >r tag-attrs chloe-attrs-only r> add-tag-attrs ]
        [ >r tag-attrs non-chloe-attrs-only r> "button" tag-named add-tag-attrs ]
        [ >r children>string 1array r> "button" tag-named set-tag-children ]
        [ nip ]
    } 2cleave process-chloe-tag ;

: attr>word ( value -- word/f )
    dup ":" split1 swap lookup
    [ ] [ "No such word: " swap append throw ] ?if ;

: attr>var ( value -- word/f )
    attr>word dup symbol? [
        "Must be a symbol: " swap append throw
    ] unless ;

: if-satisfied? ( tag -- ? )
    t swap
    {
        [ "code"  optional-attr [ attr>word execute and ] when* ]
        [  "var"  optional-attr [ attr>var      get and ] when* ]
        [ "svar"  optional-attr [ attr>var     sget and ] when* ]
        [ "uvar"  optional-attr [ attr>var     uget and ] when* ]
        [ "value" optional-attr [ value             and ] when* ]
    } cleave ;

: if-tag ( tag -- )
    dup if-satisfied? [ process-tag-children ] [ drop ] if ;

: error-message-tag ( tag -- )
    children>string render-error ;

: process-chloe-tag ( tag -- )
    dup name-tag {
        { "chloe" [ [ process-template ] each ] }
        { "title" [ title-tag ] }
        { "write-title" [ write-title-tag ] }
        { "style" [ style-tag ] }
        { "write-style" [ write-style-tag ] }
        { "atom" [ atom-tag ] }
        { "write-atom" [ write-atom-tag ] }
        { "view" [ view-tag ] }
        { "edit" [ edit-tag ] }
        { "summary" [ summary-tag ] }
        { "a" [ a-tag ] }
        { "form" [ form-tag ] }
        { "button" [ button-tag ] }
        { "error-message" [ error-message-tag ] }
        { "validation-message" [ drop render-validation-message ] }
        { "if" [ if-tag ] }
        { "comment" [ drop ] }
        { "call-next-template" [ drop call-next-template ] }
        [ "Unknown chloe tag: " swap append throw ]
    } case ;

: process-tag ( tag -- )
    {
        [ name-tag >lower tags get push ]
        [ write-start-tag ]
        [ process-tag-children ]
        [ write-end-tag ]
        [ drop tags get pop* ]
    } cleave ;

: process-template ( xml -- )
    {
        { [ dup [ chloe-tag? ] is? ] [ process-chloe-tag ] }
        { [ dup [ tag? ] is? ] [ process-tag ] }
        { [ t ] [ write-item ] }
    } cond ;

: process-chloe ( xml -- )
    [
        V{ } clone tags set

        nested-template? get [
            process-template
        ] [
            {
                [ xml-prolog write-prolog ]
                [ xml-before write-chunk  ]
                [ process-template        ]
                [ xml-after write-chunk   ]
            } cleave
        ] if
    ] with-scope ;

M: chloe call-template*
    path>> utf8 <file-reader> read-xml process-chloe ;

INSTANCE: chloe template
