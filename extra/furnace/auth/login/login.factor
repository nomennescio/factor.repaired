! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces sequences math.parser
calendar validators urls html.forms
http http.server http.server.dispatchers
furnace
furnace.auth
furnace.flash
furnace.asides
furnace.actions
furnace.sessions
furnace.utilities
furnace.redirection
furnace.auth.login.permits ;
IN: furnace.auth.login

SYMBOL: permit-id

: permit-id-key ( realm -- string )
    [ >hex 2 CHAR: 0 pad-left ] { } map-as concat
    "__p_" prepend ;

: client-permit-id ( realm -- id/f )
    permit-id-key client-state dup [ string>number ] when ;

TUPLE: login-realm < realm timeout domain ;

M: login-realm call-responder*
    [ name>> client-permit-id permit-id set ]
    [ call-next-method ]
    bi ;

M: login-realm logged-in-username
    drop permit-id get dup [ get-permit-uid ] when ;

M: login-realm modify-form ( responder -- )
    drop permit-id get realm get name>> permit-id-key hidden-form-field ;

: <permit-cookie> ( -- cookie )
    permit-id get realm get name>> permit-id-key <cookie>
        "$login-realm" resolve-base-path >>path
        realm get
        [ domain>> >>domain ]
        [ secure>> >>secure ]
        bi ;

: put-permit-cookie ( response -- response' )
    <permit-cookie> put-cookie ;

: successful-login ( user -- response )
    [ username>> make-permit permit-id set ] [ init-user ] bi
    URL" $realm" end-aside
    put-permit-cookie ;

: logout ( -- )
    permit-id get [ delete-permit ] when*
    URL" $realm" end-aside ;

SYMBOL: description
SYMBOL: capabilities

: flashed-variables { description capabilities } ;

: login-failed ( -- * )
    "invalid username or password" validation-error
    validation-failed ;

: <login-action> ( -- action )
    <page-action>
        [
            flashed-variables restore-flash
            description get "description" set-value
            capabilities get words>strings "capabilities" set-value
        ] >>init

        { login-realm "login" } >>template

        [
            {
                { "username" [ v-required ] }
                { "password" [ v-required ] }
            } validate-params

            "password" value
            "username" value check-login
            [ successful-login ] [ login-failed ] if*
        ] >>submit
    <auth-boilerplate>
    <secure-realm-only> ;

: <logout-action> ( -- action )
    <action>
        [ logout ] >>submit
    <protected>
        "logout" >>description ;

M: login-realm login-required*
    drop
    begin-aside
    protected get description>> description set
    protected get capabilities>> capabilities set
    URL" $realm/login" >secure-url flashed-variables <flash-redirect> ;

: <login-realm> ( responder name -- auth )
    login-realm new-realm
        <login-action> "login" add-responder
        <logout-action> "logout" add-responder
        20 minutes >>timeout ;
