! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel assocs combinators
validators http hashtables namespaces fry continuations locals
io arrays math boxes splitting urls
xml.entities
http.server
http.server.responses
furnace
furnace.redirection
furnace.conversations
html.forms
html.elements
html.components
html.components
html.templates.chloe
html.templates.chloe.syntax ;
IN: furnace.actions

SYMBOL: params

SYMBOL: rest

: render-validation-messages ( -- )
    form get errors>>
    [
        <ul "errors" =class ul>
            [ <li> escape-string write </li> ] each
        </ul>
    ] unless-empty ;

CHLOE: validation-messages drop render-validation-messages ;

TUPLE: action rest authorize init display validate submit ;

: new-action ( class -- action )
    new [ ] >>init [ ] >>validate [ ] >>authorize ; inline

: <action> ( -- action )
    action new-action ;

: merge-forms ( form -- )
    form get
    [ [ errors>> ] bi@ push-all ]
    [ [ values>> ] bi@ swap update ]
    [ swap validation-failed>> >>validation-failed drop ]
    2tri ;

: set-nested-form ( form name -- )
    [
        merge-forms
    ] [
        unclip [ set-nested-form ] nest-form
    ] if-empty ;

: restore-validation-errors ( -- )
    form cget [
        nested-forms cget set-nested-form
    ] when* ;

: handle-get ( action -- response )
    '[
        _ dup display>> [
            {
                [ init>> call ]
                [ authorize>> call ]
                [ drop restore-validation-errors ]
                [ display>> call ]
            } cleave
        ] [ drop <400> ] if
    ] with-exit-continuation ;

: param ( name -- value )
    params get at ;

: revalidate-url-key "__u" ;

: revalidate-url ( -- url/f )
    revalidate-url-key param
    dup [ >url [ same-host? ] keep and ] when ;

: validation-failed ( -- * )
    post-request? revalidate-url and [
        begin-conversation
        nested-forms-key param " " split harvest nested-forms cset
        form get form cset
        <redirect>
    ] [ <400> ] if*
    exit-with ;

: handle-post ( action -- response )
    '[
        _ dup submit>> [
            [ validate>> call ]
            [ authorize>> call ]
            [ submit>> call ]
            tri
        ] [ drop <400> ] if
    ] with-exit-continuation ;

: handle-rest ( path action -- assoc )
    rest>> dup [ [ "/" join ] dip associate ] [ 2drop f ] if ;

: init-action ( path action -- )
    begin-form
    handle-rest
    request get request-params assoc-union params set ;

M: action call-responder* ( path action -- response )
    [ init-action ] keep
    request get method>> {
        { "GET" [ handle-get ] }
        { "HEAD" [ handle-get ] }
        { "POST" [ handle-post ] }
    } case ;

M: action modify-form
    drop url get revalidate-url-key hidden-form-field ;

: check-validation ( -- )
    validation-failed? [ validation-failed ] when ;

: validate-params ( validators -- )
    params get swap validate-values check-validation ;

: validate-integer-id ( -- )
    { { "id" [ v-number ] } } validate-params ;

TUPLE: page-action < action template ;

: <chloe-content> ( path -- response )
    resolve-template-path <chloe> "text/html" <content> ;

: <page-action> ( -- page )
    page-action new-action
        dup '[ _ template>> <chloe-content> ] >>display ;
