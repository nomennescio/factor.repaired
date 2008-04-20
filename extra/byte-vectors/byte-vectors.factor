! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable byte-arrays prettyprint.backend
parser accessors ;
IN: byte-vectors

TUPLE: byte-vector underlying fill ;

M: byte-vector underlying underlying>> { byte-array } declare ;

M: byte-vector set-underlying (>>underlying) ;

M: byte-vector length fill>> { array-capacity } declare ;

M: byte-vector set-fill (>>fill) ;

<PRIVATE

: byte-array>vector ( byte-array length -- byte-vector )
    byte-vector boa ; inline

PRIVATE>

: <byte-vector> ( n -- byte-vector )
    <byte-array> 0 byte-array>vector ; inline

: >byte-vector ( seq -- byte-vector )
    T{ byte-vector f B{ } 0 } clone-like ;

M: byte-vector like
    drop dup byte-vector? [
        dup byte-array?
        [ dup length byte-array>vector ] [ >byte-vector ] if
    ] unless ;

M: byte-vector new-sequence
    drop [ <byte-array> ] keep >fixnum byte-array>vector ;

M: byte-vector equal?
    over byte-vector? [ sequence= ] [ 2drop f ] if ;

M: byte-array new-resizable drop <byte-vector> ;

INSTANCE: byte-vector growable

: BV{ \ } [ >byte-vector ] parse-literal ; parsing

M: byte-vector >pprint-sequence ;

M: byte-vector pprint-delims drop \ BV{ \ } ;
