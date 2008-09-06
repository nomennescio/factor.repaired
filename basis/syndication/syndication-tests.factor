USING: syndication io kernel io.files tools.test io.encodings.utf8
calendar urls ;
IN: syndication.tests

\ download-feed must-infer
\ feed>xml must-infer

: load-news-file ( filename -- feed )
    #! Load an news syndication file and process it, returning
    #! it as an feed tuple.
    utf8 file-contents read-feed ;

[ T{
    feed
    f
    "Meerkat"
    URL" http://meerkat.oreillynet.com"
    {
        T{
            entry
            f
            "XML: A Disruptive Technology"
            URL" http://c.moreover.com/click/here.pl?r123"
            "\n      XML is placing increasingly heavy loads on the existing technical\n      infrastructure of the Internet.\n    "
            f
        }
    }
} ] [ "resource:basis/syndication/test/rss1.xml" load-news-file ] unit-test
[ T{
    feed
    f
    "dive into mark"
    URL" http://example.org/"
    {
        T{
            entry
            f
            "Atom draft-07 snapshot"
            URL" http://example.org/2005/04/02/atom"
            "\n         <div xmlns=\"http://www.w3.org/1999/xhtml\">\n           <p><i>[Update: The Atom draft is finished.]</i></p>\n         </div>\n       "

            T{ timestamp f 2003 12 13 8 29 29 T{ duration f 0 0 0 -4 0 0 } }
        }
    }
} ] [ "resource:basis/syndication/test/atom.xml" load-news-file ] unit-test
