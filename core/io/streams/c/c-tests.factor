USING: tools.test io.files io io.streams.c io.encodings.ascii ;
IN: io.streams.c.tests

[ "hello world" ] [
    "test.txt" temp-file ascii [
        "hello world" write
    ] with-file-writer

    "test.txt" temp-file "rb" fopen <c-reader> contents
] unit-test
