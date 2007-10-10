! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel words sequences generic math namespaces
quotations assocs combinators math.bitfields inference.backend
inference.dataflow tuples.private ;
IN: inference.transforms

: pop-literals ( n -- rstate seq )
    dup zero? [
        drop recursive-state get { }
    ] [
        dup ensure-values
        f swap [ 2drop pop-literal ] map reverse
    ] if ;

: transform-quot ( quot n -- newquot )
    [ pop-literals [ ] each ] curry
    swap
    [ swap infer-quot ] 3compose ;

: define-transform ( word quot n -- )
    transform-quot "infer" set-word-prop ;

! Combinators
\ cond [
    cond>quot
] 1 define-transform

\ case [
    dup empty? [
        drop [ no-case ]
    ] [
        dup peek quotation? [
            dup peek swap 1 head*
        ] [
            [ no-case ] swap
        ] if hash-case>quot
    ] if
] 1 define-transform

! Bitfields
GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot) ( spec -- quot )
    [ swapd shift bitor ] curry ;

M: pair (bitfield-quot) ( spec -- quot )
    first2 over word? [ >r swapd execute r> ] [ ] ?
    [ shift bitor ] append 2curry ;

: bitfield-quot ( spec -- quot )
    [ (bitfield-quot) ] map [ 0 ] add* concat ;

\ bitfield [ bitfield-quot ] 1 define-transform

! Tuple operations
: [get-slots] ( slots -- quot )
    [ [ 1quotation , \ keep , ] each \ drop , ] [ ] make ;

\ get-slots [ [get-slots] ] 1 define-transform

\ set-slots [ <reversed> [get-slots] ] 1 define-transform

\ construct-boa [
    dup tuple-size [ <tuple-boa> ] 2curry
] 1 define-transform
