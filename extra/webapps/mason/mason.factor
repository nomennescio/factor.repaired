! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.db http.server.dispatchers mason.server
webapps.mason.grids webapps.mason.package webapps.mason.release
webapps.mason.report ;
IN: webapps.mason

TUPLE: mason-app < dispatcher ;

: <mason-app> ( -- dispatcher )
    mason-app new-dispatcher
    <build-report-action> "report" add-responder
    <download-package-action>
        { mason-app "download-package" } >>template
        "package" add-responder

    <package-grid-action> "packages" add-responder

    <download-release-action>
        { mason-app "download-release" } >>template
        "release" add-responder

    <release-grid-action> "releases" add-responder
    mason-db <db-persistence> ;
