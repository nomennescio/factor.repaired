USING:
    arrays
    ascii
    assocs
    base64
    byte-arrays
    fry
    io
    io.encodings io.encodings.string io.encodings.utf16
    kernel
    math math.functions
    namespaces
    sequences
    splitting
    strings ;
IN: io.encodings.utf7

SINGLETON: utf7
SINGLETON: utf7imap4

! This map encodes the difference between standard utf7 and the
! dialect used by IMAP which wants slashes repladed with commas when
! encoding and uses '&' instead of '+' as the escaping character.
CONSTANT: dialect-data {
    { utf7 { { "" "" } { "+" "-" } } }
    { utf7imap4 { { "/" "," } { "&" "-" } } }
}

: >raw-base64 ( byte-array -- str )
    >string utf16be encode >base64 [ CHAR: = = ] trim-tail ;

: raw-base64> ( str -- str' )
    dup length 4 / ceiling 4 * CHAR: = pad-tail base64> utf16be decode ;

: (group-by-loop) ( elt key groups -- groups' )
    2dup [ nip empty? ] [ ?last ?first = not ] 2bi or [
        -rot swap 1array
    ] [
        nip unclip-last rot [ first2 ] dip suffix
    ] if 2array suffix ;

: group-by ( seq quot: ( elt -- key ) -- groups )
    '[ dup _ call( x -- y ) rot (group-by-loop) ] { } swap reduce ;

: encode-chunk ( repl-pair surround-pair chunk ascii? -- byte-array )
    [ swap [ first ] [ concat ] bi replace nip ]
    [ >raw-base64 -rot [ first2 replace ] [ first2 surround ] bi* ] if ;

: encode-utf7-string ( str dialect -- byte-array )
    [ [ printable? ] group-by ] dip
    dialect-data at first2 '[ _ _ rot first2 swap encode-chunk ] map concat ;

: stream-write-utf7 ( string stream encoding -- )
    swapd encode-utf7-string >byte-array swap stream-write ;

M: utf7 encode-string stream-write-utf7 ;
M: utf7imap4 encode-string stream-write-utf7 ;

! UTF-7 decoding is stateful, hence this ugly workaround is needed.
SYMBOL: decoding-buffer

: emit-next-char ( buffer -- ch buffer' )
    [
        read1 dup CHAR: + = [
            drop { CHAR: - } read-until drop
            [ CHAR: + { } ] [ raw-base64> emit-next-char ] if-empty
        ] [ { } ] if
    ] [ unclip swap ] if-empty ;

: decode-utf7 ( stream encoding -- char/f )
    drop [
        decoding-buffer [ [ { } ] unless* emit-next-char ] change-global
    ] with-input-stream ;

M: utf7 decode-char decode-utf7 ;
M: utf7imap4 decode-char decode-utf7 ;
