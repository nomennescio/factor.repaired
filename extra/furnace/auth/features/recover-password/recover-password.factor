! Copyright (c) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors kernel assocs arrays io.sockets threads
fry urls smtp validators html.forms
http http.server.responses http.server.dispatchers
furnace furnace.actions furnace.auth furnace.auth.providers ;
IN: furnace.auth.features.recover-password

SYMBOL: lost-password-from

: current-host ( -- string )
    request get url>> host>> host-name or ;

: new-password-url ( user -- url )
    "recover-3"
    swap [
        [ username>> "username" set ]
        [ ticket>> "ticket" set ]
        bi
    ] H{ } make-assoc
    derive-url ;

: password-email ( user -- email )
    <email>
        [ "[ " % current-host % " ] password recovery" % ] "" make >>subject
        lost-password-from get >>from
        over email>> 1array >>to
        [
            "This e-mail was sent by the application server on " % current-host % "\n" %
            "because somebody, maybe you, clicked on a ``recover password'' link in the\n" %
            "login form, and requested a new password for the user named ``" %
            over username>> % "''.\n" %
            "\n" %
            "If you believe that this request was legitimate, you may click the below link in\n" %
            "your browser to set a new password for your account:\n" %
            "\n" %
            swap new-password-url %
            "\n\n" %
            "Love,\n" %
            "\n" %
            "  FactorBot\n" %
        ] "" make >>body ;

: send-password-email ( user -- )
    '[ , password-email send-email ]
    "E-mail send thread" spawn drop ;

: <recover-action-1> ( -- action )
    <page-action>
        { realm "recover-1" } >>template

        [
            {
                { "username" [ v-username ] }
                { "email" [ v-email ] }
                { "captcha" [ v-captcha ] }
            } validate-params
        ] >>validate

        [
            "email" value "username" value
            users issue-ticket [
                send-password-email
            ] when*

            URL" $login/recover-2" <redirect>
        ] >>submit ;

: <recover-action-2> ( -- action )
    <page-action>
        { realm "recover-2" } >>template ;

: <recover-action-3> ( -- action )
    <page-action>
        [
            {
                { "username" [ v-username ] }
                { "ticket" [ v-required ] }
            } validate-params
        ] >>init

        { realm "recover-3" } >>template

        [
            {
                { "username" [ v-username ] }
                { "ticket" [ v-required ] }
                { "new-password" [ v-password ] }
                { "verify-password" [ v-password ] }
            } validate-params

            same-password-twice
        ] >>validate

        [
            "ticket" value
            "username" value
            users claim-ticket [
                "new-password" value >>encoded-password
                users update-user

                URL" $login/recover-4" <redirect>
            ] [
                <403>
            ] if*
        ] >>submit ;

: <recover-action-4> ( -- action )
    <page-action>
        { realm "recover-4" } >>template ;

: allow-password-recovery ( login -- login )
    <recover-action-1> <auth-boilerplate>
        "recover-password" add-responder
    <recover-action-2> <auth-boilerplate>
        "recover-2" add-responder
    <recover-action-3> <auth-boilerplate>
        "recover-3" add-responder
    <recover-action-4> <auth-boilerplate>
        "recover-4" add-responder ;

: allow-password-recovery? ( -- ? )
    realm get responders>> "recover-password" swap key? ;
