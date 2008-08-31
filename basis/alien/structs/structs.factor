! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic hashtables kernel kernel.private
math namespaces parser sequences strings words libc slots
slots.deprecated alien.c-types cpu.architecture ;
IN: alien.structs

: align-offset ( offset type -- offset )
    c-type-align align ;

: struct-offsets ( specs -- size )
    0 [
        [ class>> align-offset ] keep
        [ (>>offset) ] 2keep
        class>> heap-size +
    ] reduce ;

: define-struct-slot-word ( spec word quot -- )
    rot offset>> prefix define-inline ;

: define-getter ( type spec -- )
    [ set-reader-props ] keep
    [ ]
    [ reader>> ]
    [
        class>>
        [ c-getter ] [ c-type-boxer-quot ] bi append
    ] tri
    define-struct-slot-word ;

: define-setter ( type spec -- )
    [ set-writer-props ] keep
    [ ]
    [ writer>> ]
    [ class>> c-setter ] tri
    define-struct-slot-word ;

: define-field ( type spec -- )
    2dup define-getter define-setter ;

: if-value-structs? ( ctype true false -- )
    value-structs?
    [ drop call ] [ >r 2drop "void*" r> call ] if ; inline

TUPLE: struct-type size align fields ;

M: struct-type heap-size size>> ;

M: struct-type c-type-align align>> ;

M: struct-type c-type-stack-align? drop f ;

M: struct-type unbox-parameter
    [ heap-size %unbox-struct ]
    [ unbox-parameter ]
    if-value-structs? ;

M: struct-type unbox-return
    f swap heap-size %unbox-struct ;

M: struct-type box-parameter
    [ heap-size %box-struct ]
    [ box-parameter ]
    if-value-structs? ;

M: struct-type box-return
    f swap heap-size %box-struct ;

M: struct-type stack-size
    [ heap-size ] [ stack-size ] if-value-structs? ;

: c-struct? ( type -- ? ) (c-type) struct-type? ;

: (define-struct) ( name vocab size align fields -- )
    >r [ align ] keep r>
    struct-type boa
    -rot define-c-type ;

: make-field ( struct-name vocab type field-name -- spec )
    <slot-spec>
        0 >>offset
        swap >>name
        swap expand-constants >>class
        3dup name>> swap reader-word >>reader
        3dup name>> swap writer-word >>writer
    2nip ;

: define-struct-early ( name vocab fields -- fields )
    -rot [ rot first2 make-field ] 2curry map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] map supremum ;

: define-struct ( name vocab fields -- )
    pick >r
    [ struct-offsets ] keep
    [ [ class>> ] map compute-struct-align ] keep
    [ (define-struct) ] keep
    r> [ swap define-field ] curry each ;

: define-union ( name vocab members -- )
    [ expand-constants ] map
    [ [ heap-size ] map supremum ] keep
    compute-struct-align f (define-struct) ;
