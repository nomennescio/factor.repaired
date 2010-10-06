USING: accessors io io.encodings io.encodings.ascii
io.encodings.utf8 io.files io.streams.byte-array
io.streams.string kernel namespaces tools.test ;
IN: io.encodings.tests

[ { } ]
[ "vocab:io/test/empty-file.txt" ascii file-lines ]
unit-test

: lines-test ( file encoding -- line1 line2 )
    [ readln readln ] with-file-reader ;

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/windows-eol.txt"
    ascii lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/mac-os-eol.txt"
    ascii lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/unix-eol.txt"
    ascii lines-test
] unit-test

[
    "1234"
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     4 swap stream-read
] unit-test

[
    "1234"
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     4 swap stream-read-partial
] unit-test

[
    CHAR: 1
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     stream-read1
] unit-test

[ utf8 ascii ] [
    "foo" utf8 [
        input-stream get code>>
        ascii decode-input
        input-stream get code>>
    ] with-byte-reader
] unit-test

[ utf8 ascii ] [
    utf8 [
        output-stream get code>>
        ascii encode-output
        output-stream get code>>
    ] with-byte-writer drop
] unit-test

[ t ] [
    "vocab:io/test/mac-os-eol.txt"
    ascii [ 10 peek 10 peek = ] with-file-reader
] unit-test

[ t ] [
    "vocab:io/test/mac-os-eol.txt"
    ascii [ peek1 peek1 = ] with-file-reader
] unit-test
