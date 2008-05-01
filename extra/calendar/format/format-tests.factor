USING: calendar.format calendar kernel math tools.test
io.streams.string accessors io math.order ;
IN: calendar.format.tests

[ 0 ] [
    "Z" [ read1 read-rfc3339-gmt-offset ] with-string-reader dt>hours
] unit-test

[ 1 ] [
    "+01" [ read1 read-rfc3339-gmt-offset ] with-string-reader dt>hours
] unit-test

[ -1 ] [
    "-01" [ read1 read-rfc3339-gmt-offset ] with-string-reader dt>hours
] unit-test

[ -1-1/2 ] [
    "-01:30" [ read1 read-rfc3339-gmt-offset ] with-string-reader dt>hours
] unit-test

[ 1+1/2 ] [
    "+01:30" [ read1 read-rfc3339-gmt-offset ] with-string-reader dt>hours
] unit-test

[ ] [ now timestamp>rfc3339 drop ] unit-test
[ ] [ now timestamp>rfc822 drop ] unit-test

[ 8/1000 -4 ] [
    "2008-04-19T04:56:00.008-04:00" rfc3339>timestamp
    [ second>> ] [ gmt-offset>> hour>> ] bi
] unit-test

[ T{ duration f 0 0 0 0 0 0 } ] [
    "GMT" parse-rfc822-gmt-offset
] unit-test

[ T{ duration f 0 0 0 -5 0 0 } ] [
    "-0500" parse-rfc822-gmt-offset
] unit-test

[ T{ timestamp f 2008 4 22 14 36 12 T{ duration f 0 0 0 0 0 0 } } ] [
    "Tue, 22 Apr 2008 14:36:12 GMT" rfc822>timestamp
] unit-test

[ t ] [ now dup timestamp>rfc822 rfc822>timestamp time- 1 seconds before? ] unit-test

[ t ] [ now dup timestamp>cookie-string cookie-string>timestamp time- 1 seconds before? ] unit-test

[ "Sun, 4 May 2008 07:00:00" ] [
    "Sun May 04 07:00:00 2008 GMT" cookie-string>timestamp
    timestamp>string
] unit-test
