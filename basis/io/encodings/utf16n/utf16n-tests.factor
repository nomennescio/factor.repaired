USING: accessors alien.c-type kernel io.streams.byte-array tools.test ;
IN: io.encodings.utf16n

: correct-endian
    code>> little-endian? [ utf16le = ] [ utf16be = ] if ;

[ t ] [ B{ } utf16n <byte-reader> correct-endian ] unit-test
[ t ] [ utf16n <byte-writer> correct-endian ] unit-test
