USING: tools.test io.streams.byte-array io.encodings.binary
io.encodings.utf8 io kernel arrays strings namespaces math
specialized-arrays alien.c-types io.encodings.ascii ;
SPECIALIZED-ARRAY: int
IN: io.streams.byte-array.tests

[ B{ } ] [ B{ } binary [ contents ] with-byte-reader ] unit-test

! Issue #70 github
[ f ] [ B{ } binary [ 0 read ] with-byte-reader ] unit-test
[ f ] [ B{ } binary [ 1 read ] with-byte-reader ] unit-test
[ f ] [ B{ } ascii [ 0 read ] with-byte-reader ] unit-test
[ f ] [ B{ } ascii [ readln ] with-byte-reader ] unit-test
[ f f ] [ B{ } ascii [ "a" read-until ] with-byte-reader ] unit-test
[ f f ] [ B{ } binary [ { 2 } read-until ] with-byte-reader ] unit-test


[ B{ 1 2 3 } ] [ binary [ B{ 1 2 3 } write ] with-byte-writer ] unit-test
[ B{ 1 2 3 4 5 6 } ] [ binary [ B{ 1 2 3 } write B{ 4 5 6 } write ] with-byte-writer ] unit-test
[ B{ 1 2 3 } ] [ { 1 2 3 } binary [ 3 read ] with-byte-reader ] unit-test

[ B{ BIN: 11110101 BIN: 10111111 BIN: 10000000 BIN: 10111111 BIN: 11101111 BIN: 10000000 BIN: 10111111 BIN: 11011111 BIN: 10000000 CHAR: x } ]
[ { BIN: 101111111000000111111 BIN: 1111000000111111 BIN: 11111000000 CHAR: x } >string utf8 [ write ] with-byte-writer ] unit-test
[ { BIN: 1111111000000111111 } t ] [ { BIN: 11110001 BIN: 10111111 BIN: 10000000 BIN: 10111111 } utf8 <byte-reader> stream-contents dup >array swap string? ] unit-test

[ B{ 121 120 } 0 ] [
    B{ 0 121 120 0 0 0 0 0 0 } binary
    [ 1 read drop "\0" read-until ] with-byte-reader
] unit-test

[ 1 1 4 11 f ] [
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 } binary
    [
        read1
        0 seek-absolute input-stream get stream-seek
        read1
        2 seek-relative input-stream get stream-seek
        read1
        -2 seek-end input-stream get stream-seek
        read1
        0 seek-end input-stream get stream-seek
        read1
    ] with-byte-reader
] unit-test

[ 0 ] [
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 } binary [ tell-input ] with-byte-reader
] unit-test

! Overly aggressive compiler optimizations
[ B{ 123 } ] [
    binary [ 123 >bignum write1 ] with-byte-writer
] unit-test

! Writing specialized arrays to byte writers
[ int-array{ 1 2 3 } ] [
    binary [ int-array{ 1 2 3 } write ] with-byte-writer
    int-array-cast
] unit-test
