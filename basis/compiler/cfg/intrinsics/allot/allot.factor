! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order sequences accessors arrays
byte-arrays layouts classes.tuple.private fry locals
compiler.tree.propagation.info compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.stacks
compiler.cfg.utilities ;
IN: compiler.cfg.intrinsics.allot

: ##set-slots ( regs obj class -- )
    '[ _ swap 1+ _ tag-number ##set-slot-imm ] each-index ;

: emit-simple-allot ( node -- )
    [ in-d>> length ] [ node-output-infos first class>> ] bi
    [ drop ds-load ] [ [ 1+ cells ] dip ^^allot ] [ nip ] 2tri
    [ ##set-slots ] [ [ drop ] [ ds-push ] [ drop ] tri* ] 3bi ;

: tuple-slot-regs ( layout -- vregs )
    [ second ds-load ] [ ^^load-literal ] bi prefix ;

: emit-<tuple-boa> ( node -- )
    dup node-input-infos peek literal>>
    dup array? [
        nip
        ds-drop
        [ tuple-slot-regs ] [ second ^^allot-tuple ] bi
        [ tuple ##set-slots ] [ ds-push drop ] 2bi
    ] [ drop emit-primitive ] if ;

: store-length ( len reg -- )
    [ ^^load-literal ] dip 1 object tag-number ##set-slot-imm ;

: store-initial-element ( elt reg len -- )
    [ 2 + object tag-number ##set-slot-imm ] with with each ;

: expand-<array>? ( obj -- ? )
    dup integer? [ 0 8 between? ] [ drop f ] if ;

:: emit-<array> ( node -- )
    [let | len [ node node-input-infos first literal>> ] |
        len expand-<array>? [
            [let | elt [ ds-pop ]
                   reg [ len ^^allot-array ] |
                ds-drop
                len reg store-length
                elt reg len store-initial-element
                reg ds-push
            ]
        ] [ node emit-primitive ] if
    ] ;

: expand-<byte-array>? ( obj -- ? )
    dup integer? [ 0 32 between? ] [ drop f ] if ;

: bytes>cells ( m -- n ) cell align cell /i ;

:: emit-<byte-array> ( node -- )
    [let | len [ node node-input-infos first literal>> ] |
        len expand-<byte-array>? [
            [let | elt [ 0 ^^load-literal ]
                   reg [ len ^^allot-byte-array ] |
                ds-drop
                len reg store-length
                elt reg len bytes>cells store-initial-element
                reg ds-push
            ]
        ] [ node emit-primitive ] if
    ] ;
