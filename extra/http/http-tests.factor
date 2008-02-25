USING: http tools.test multiline tuple-syntax
io.streams.string kernel arrays splitting sequences     ;
IN: temporary

[ "hello%20world" ] [ "hello world" url-encode ] unit-test
[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ "~hello world" ] [ "%7ehello+world" url-decode ] unit-test
[ "" ] [ "%XX%XX%XX" url-decode ] unit-test
[ "" ] [ "%XX%XX%X" url-decode ] unit-test

[ "hello world"   ] [ "hello+world"    url-decode ] unit-test
[ "hello world"   ] [ "hello%20world"  url-decode ] unit-test
[ " ! "           ] [ "%20%21%20"      url-decode ] unit-test
[ "hello world"   ] [ "hello world%"   url-decode ] unit-test
[ "hello world"   ] [ "hello world%x"  url-decode ] unit-test
[ "hello%20world" ] [ "hello world"    url-encode ] unit-test
[ "%20%21%20"     ] [ " ! "            url-encode ] unit-test

[ "\u001234hi\u002045" ] [ "\u001234hi\u002045" url-encode url-decode ] unit-test

STRING: read-request-test-1
GET http://foo/bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4

blah
;

[
    TUPLE{ request
        method: "GET"
        path: "bar"
        query: f
        version: "1.1"
        header: H{ { "some-header" V{ "1" "2" } } { "content-length" V{ "4" } } }
        post-data: "blah"
    }
] [
    read-request-test-1 [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-1'
GET bar HTTP/1.1
content-length: 4
some-header: 1
some-header: 2

blah
;

read-request-test-1' 1array [
    read-request-test-1
    [ read-request ] with-string-reader
    [ write-request ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test

STRING: read-request-test-2
HEAD  http://foo/bar   HTTP/1.0
Host: www.sex.com
;

[
    TUPLE{ request
        method: "HEAD"
        path: "bar"
        query: f
        version: "1.0"
        header: H{ { "host" V{ "www.sex.com" } } }
        host: "www.sex.com"
    }
] [
    read-request-test-2 [
        read-request
    ] with-string-reader
] unit-test

STRING: read-response-test-1
HTTP/1.0 404 not found
Content-Type: text/html

blah
;

[
    TUPLE{ response
        version: "1.0"
        code: 404
        message: "not found"
        header: H{ { "content-type" V{ "text/html" } } }
    }
] [
    read-response-test-1
    [ read-response ] with-string-reader
] unit-test


STRING: read-response-test-1'
HTTP/1.0 404 not found
content-type: text/html


;

read-response-test-1' 1array [
    read-response-test-1
    [ read-response ] with-string-reader
    [ write-response ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test
