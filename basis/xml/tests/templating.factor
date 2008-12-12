USING: kernel xml sequences assocs tools.test io arrays namespaces
accessors xml.data xml.utilities xml.writer generic sequences.deep ;
IN: xml.tests

: sub-tag
    T{ name f f "sub" "http://littledan.onigirihouse.com/namespaces/replace" } ;

SYMBOL: ref-table

GENERIC: (r-ref) ( xml -- )
M: tag (r-ref)
    sub-tag over at* [
        ref-table get at
        >>children drop
    ] [ 2drop ] if ;
M: object (r-ref) drop ;

: template ( xml -- )
    [ (r-ref) ] deep-each ;

! Example

: sample-doc ( -- string )
    {
        "<html xmlns:f='http://littledan.onigirihouse.com/namespaces/replace'>"
        "<body>"
        "<span f:sub='foo'/>"
        "<div f:sub='bar'/>"
        "<p f:sub='baz'>paragraph</p>"
        "</body></html>"
    } concat ;

: test-refs ( -- string )
    [
        H{
            { "foo" { "foo" } }
            { "bar" { "blah" T{ tag f T{ name f "" "a" "" } f f } } }
            { "baz" f }
        } ref-table set
        sample-doc string>xml dup template xml>string
    ] with-scope ;

[ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><html xmlns:f=\"http://littledan.onigirihouse.com/namespaces/replace\"><body><span f:sub=\"foo\">foo</span><div f:sub=\"bar\">blah<a/></div><p f:sub=\"baz\"/></body></html>" ] [ test-refs ] unit-test
