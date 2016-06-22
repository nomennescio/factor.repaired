! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.static
DEFER: file-responder ! necessary for cgi-docs
DEFER: <static> ! necessary for cgi-docs
USING: calendar kernel math math.order math.parser namespaces
parser sequences strings assocs hashtables debugger mime.types
sorting logging calendar.format accessors splitting io io.files
io.files.info io.directories io.pathnames io.encodings.binary
fry xml.entities destructors urls html xml.syntax
html.templates.fhtml http http.server http.server.responses
http.server.redirection xml.writer locals ;
QUALIFIED: sets

TUPLE: file-responder root hook special index-names allow-listings ;

: modified-since ( request -- date )
    "if-modified-since" header ";" split1 drop
    dup [ rfc822>timestamp ] when ;

: modified-since? ( filename -- ? )
    request get modified-since dup
    [ [ file-info modified>> ] dip after? ] [ 2drop t ] if ;

: <file-responder> ( root hook -- responder )
    file-responder new
        swap >>hook
        swap >>root
        H{ } clone >>special
        V{ "index.html" } >>index-names ;

: (serve-static) ( path mime-type -- response )
    [
        [ binary <file-reader> &dispose ] dip <content>
        binary >>content-encoding
    ]
    [ drop file-info [ size>> ] [ modified>> ] bi ] 2bi
    [ "content-length" set-header ]
    [ "last-modified" set-header ] bi* ;

: <static> ( root -- responder )
    [ (serve-static) ] <file-responder> ;

: serve-static ( filename mime-type -- response )
    over modified-since?
    [ file-responder get hook>> call( filename mime-type -- response ) ]
    [ 2drop <304> ]
    if ;

: serving-path ( filename -- filename )
    [ file-responder get root>> trim-tail-separators ] dip
    [ "/" swap trim-head-separators 3append ] unless-empty ;

: serve-file ( filename -- response )
    dup mime-type
    dup file-responder get special>> at
    [ call( filename -- response ) ] [ serve-static ] ?if ;

\ serve-file NOTICE add-input-logging

:: file-html-template ( href size modified -- xml )
    [XML
        <tr>
            <td><a href=<-href->><-href-></a></td>
            <td align="right"><-modified-></td>
            <td align="right"><-size-></td>
        </tr>
    XML] ;

: file>html ( name -- xml )
    dup link-info [
        dup directory?
        [ drop "/" append "-" ]
        [ size>> number>string ] if
    ] [ modified>> ] bi file-html-template ;

: parent-dir-link ( -- xml )
    "../" "" "" file-html-template ;

: ?parent-dir-link ( -- xml/f )
    url get [ path>> "/" = [ "" ] [ parent-dir-link ] if ] [ "" ] if* ;

: listing-title ( -- title )
    url get [ path>> "Index of " prepend ] [ "" ] if* ;

:: listing-html-template ( title listing ?parent -- xml )
    [XML <h1><-title-></h1>
        <table>
            <tr>
                <th>Name</th>
                <th>Last modified</th>
                <th>Size</th>
            </tr>
            <tr><th colspan="5"><hr/></th></tr>
            <-?parent->
            <-listing->
            <tr><th colspan="5"><hr/></th></tr>
        </table>
    XML] ;

: listing ( path -- seq-xml )
    [ natural-sort [ file>html ] map ] with-directory-files ;

: listing-body ( title path -- xml )
    listing ?parent-dir-link listing-html-template ;

: directory>html ( path -- xml )
    [ listing-title f over ] dip listing-body simple-page ;

: list-directory ( directory -- response )
    file-responder get allow-listings>> [
        directory>html <html-content>
    ] [
        drop <403>
    ] if ;

: find-index ( filename -- path )
    file-responder get index-names>>
    [ append-path dup exists? [ drop f ] unless ] with map-find
    drop ;

: serve-directory ( filename -- response )
    url get path>> "/" tail? [
        dup
        find-index [ serve-file ] [ list-directory ] ?if
    ] [
        drop
        url get clone [ "/" append ] change-path <permanent-redirect>
    ] if ;

: serve-object ( filename -- response )
    serving-path dup exists?
    [ dup file-info directory? [ serve-directory ] [ serve-file ] if ]
    [ drop <404> ]
    if ;

M: file-responder call-responder* ( path responder -- response )
    file-responder set
    ".." over member?
    [ drop <400> ] [ "/" join serve-object ] if ;

: add-index ( name responder -- )
    index-names>> sets:adjoin ;

: serve-fhtml ( path -- response )
    <fhtml> <html-content> ;

: enable-fhtml ( responder -- responder )
    [ serve-fhtml ] "application/x-factor-server-page" pick special>> set-at
    "index.fhtml" over add-index ;
