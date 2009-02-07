! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax byte-arrays combinators
kernel math math.functions sequences system accessors
libc ;
QUALIFIED: zlib.ffi
IN: zlib

TUPLE: compressed data length ;

: <compressed> ( data length -- compressed )
    compressed new
        swap >>length
        swap >>data ;

ERROR: zlib-failed n string ;

: zlib-error-message ( n -- * )
    dup zlib.ffi:Z_ERRNO = [
        drop errno "native libc error"
    ] [
        dup {
            "no error" "libc_error"
            "stream error" "data error"
            "memory error" "buffer error" "zlib version error"
        } ?nth
    ] if zlib-failed ;

: zlib-error ( n -- )
    dup zlib.ffi:Z_OK = [ drop ] [ dup zlib-error-message zlib-failed ] if ;

! Compressed size is up to .001% larger plus 12

: compressed-size ( byte-array -- n )
    length 1001/1000 * ceiling 12 + ;

: compress ( byte-array -- compressed )
    [
        [ compressed-size <byte-array> dup length <ulong> ] keep [
            dup length zlib.ffi:compress zlib-error
        ] 3keep drop *ulong head
    ] keep length <compressed> ;

: uncompress ( compressed -- byte-array )
    [
        length>> [ <byte-array> ] keep <ulong> 2dup
    ] [
        data>> dup length
        zlib.ffi:uncompress zlib-error
    ] bi *ulong head ;
