! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel words sequences generic math
namespaces quotations assocs combinators
inference.backend inference.dataflow inference.state
classes.tuple classes.tuple.private effects summary hashtables
classes generic sets definitions generic.standard slots.private ;
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
            dup peek swap but-last
        ] [
            [ no-case ] swap
        ] if case>quot
    ] if
] 1 define-transform

\ cleave [ cleave>quot ] 1 define-transform

\ 2cleave [ 2cleave>quot ] 1 define-transform

\ 3cleave [ 3cleave>quot ] 1 define-transform

\ spread [ spread>quot ] 1 define-transform

! Tuple operations
: [get-slots] ( slots -- quot )
    [ [ 1quotation , \ keep , ] each \ drop , ] [ ] make ;

\ get-slots [ [get-slots] ] 1 define-transform

ERROR: duplicated-slots-error names ;

M: duplicated-slots-error summary
    drop "Calling set-slots with duplicate slot setters" ;

\ set-slots [
    dup all-unique?
    [ <reversed> [get-slots] ] [ duplicated-slots-error ] if
] 1 define-transform

\ boa [
    dup tuple-class? [
        dup +inlined+ depends-on
        [ "boa-check" word-prop ]
        [ tuple-layout [ <tuple-boa> ] curry ]
        bi append
    ] [
        \ boa \ no-method boa time-bomb
    ] if
] 1 define-transform

\ (call-next-method) [
    [ [ +inlined+ depends-on ] bi@ ] [ next-method-quot ] 2bi
] 2 define-transform
