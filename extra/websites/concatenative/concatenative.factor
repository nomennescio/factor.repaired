! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.sockets
io.sockets.secure io.servers.connection
namespaces db db.tuples db.sqlite smtp urls
logging.insomniac
html.templates.chloe
http.server
http.server.dispatchers
http.server.redirection
furnace.alloy
furnace.auth.login
furnace.auth.providers.db
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration
furnace.auth.features.deactivate-user
furnace.boilerplate
furnace.redirection
webapps.pastebin
webapps.planet
webapps.wiki
webapps.user-admin ;
IN: websites.concatenative

: test-db ( -- params db ) "resource:test.db" sqlite-db ;

: init-factor-db ( -- )
    test-db [
        init-furnace-tables

        {
            paste annotation
            blog posting
            article revision
        } ensure-tables
    ] with-db ;

TUPLE: factor-website < dispatcher ;

: <factor-boilerplate> ( responder -- responder' )
    <boilerplate>
        { factor-website "page" } >>template ;

: <configuration> ( responder -- responder' )
    "Factor website" <login-realm>
        "Factor website" >>name
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation
    test-db <alloy> ;

: <factor-website> ( -- responder )
    factor-website new-dispatcher
        <wiki> "wiki" add-responder
        <user-admin> "user-admin" add-responder
        URL" /wiki/view/Front Page" <redirect-responder> "" add-responder ;

SYMBOL: key-password
SYMBOL: key-file
SYMBOL: dh-file

: common-configuration ( -- )
    "concatenative.org" 25 <inet> smtp-server set-global
    "noreply@concatenative.org" lost-password-from set-global
    "website@concatenative.org" insomniac-sender set-global
    "slava@factorcode.org" insomniac-recipients set-global
    init-factor-db ;

: init-testing ( -- )
    "resource:basis/openssl/test/dh1024.pem" dh-file set-global
    "resource:basis/openssl/test/server.pem" key-file set-global
    "password" key-password set-global
    common-configuration
    <factor-website>
        <pastebin> "pastebin" add-responder
        <planet> "planet" add-responder
    <factor-boilerplate>
    <configuration>
    main-responder set-global ;

: init-production ( -- )
    common-configuration
    <vhost-dispatcher>
        <factor-website> <factor-boilerplate> "concatenative.org" add-responder
        <pastebin> <factor-boilerplate> "paste.factorcode.org" add-responder
        <planet> <factor-boilerplate> "planet.factorcode.org" add-responder
    <configuration>
    main-responder set-global ;

: <factor-secure-config> ( -- config )
    <secure-config>
        key-file get >>key-file
        dh-file get >>dh-file
        key-password get >>password ;

: <factor-website-server> ( -- threaded-server )
    <http-server>
        <factor-secure-config> >>secure-config
        8080 >>insecure
        8431 >>secure ;

: start-website ( -- )
    test-db start-expiring
    test-db start-update-task
    http-insomniac
    <factor-website-server> start-server ;
