! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors formatting html.entities html.parser
html.parser.analyzer html.parser.printer http.client images.http
images.viewer images.viewer.prettyprint io io.streams.string
kernel parser prettyprint.custom prettyprint.sections regexp
sequences strings ui wrap.strings ;

IN: xkcd

<PRIVATE

: comic-image ( url -- image )
    http-get nip
    R" http://imgs\.xkcd\.com/comics/[^\.]+\.(png|jpg)"
    first-match >string load-http-image ;

: comic-image. ( url -- )
    comic-image image. ;

: comic-text ( url -- string )
    http-get nip parse-html
    "transcript" find-by-id-between
    [ html-text. ] with-string-writer
    html-unescape ;

: comic-text. ( url -- )
    comic-text 80 wrap-string print ;

: comic. ( url -- )
    ui-running? [ comic-image. ] [ comic-text. ] if ;

PRIVATE>

: xkcd-url ( n -- url )
    "http://xkcd.com/%s/" sprintf ;

: xkcd-image ( n -- image )
    xkcd-url comic-image ;

: xkcd. ( n -- )
    xkcd-url comic. ;

: random-xkcd. ( -- )
    "http://dynamic.xkcd.com/random/comic/" comic. ;

: latest-xkcd. ( -- )
    "http://xkcd.com" comic. ;

TUPLE: xkcd image ;

C: <xkcd> xkcd

SYNTAX: XKCD: scan-number xkcd-image <xkcd> suffix! ;

M: xkcd pprint* image>> <image-section> add-section ;
