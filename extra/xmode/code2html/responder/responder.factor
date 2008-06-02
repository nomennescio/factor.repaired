! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.encodings.utf8 namespaces http.server
http.server.static http xmode.code2html kernel sequences
accessors fry ;
IN: xmode.code2html.responder

: <sources> ( root -- responder )
    [
        drop
        dup '[
            , utf8 [
                , file-name input-stream get htmlize-stream
            ] with-file-reader
        ] "text/html" <content>
    ] <file-responder> ;
