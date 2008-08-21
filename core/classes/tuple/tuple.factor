! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions hashtables kernel kernel.private math
namespaces sequences sequences.private strings vectors words
quotations memory combinators generic classes classes.algebra
classes.builtin classes.private slots.deprecated slots.private
slots compiler.units math.private accessors assocs effects ;
IN: classes.tuple

PREDICATE: tuple-class < class
    "metaclass" word-prop tuple-class eq? ;

M: tuple class 1 slot 2 slot { word } declare ;

ERROR: not-a-tuple object ;

: check-tuple ( object -- tuple )
    dup tuple? [ not-a-tuple ] unless ; inline

: all-slots ( class -- slots )
    superclasses [ "slots" word-prop ] map concat ;

PREDICATE: immutable-tuple-class < tuple-class ( class -- ? )
    #! Delegation
    all-slots rest-slice [ read-only>> ] all? ;

<PRIVATE

: tuple-layout ( class -- layout )
    "layout" word-prop ;

: layout-of ( tuple -- layout )
    1 slot { tuple-layout } declare ; inline

: tuple-size ( tuple -- size )
    layout-of size>> ; inline

: prepare-tuple>array ( tuple -- n tuple layout )
    check-tuple [ tuple-size ] [ ] [ layout-of ] tri ;

: copy-tuple-slots ( n tuple -- array )
    [ array-nth ] curry map ;

: check-slots ( seq class -- seq class )
    [ ] [
        2dup all-slots [
            class>> 2dup instance?
            [ 2drop ] [ bad-slot-value ] if
        ] 2each
    ] if-bootstrapping ; inline

: initial-values ( class -- slots )
    all-slots [ initial>> ] map ;

: pad-slots ( slots class -- slots' class )
    [ initial-values over length tail append ] keep ; inline

PRIVATE>

: tuple>array ( tuple -- array )
    prepare-tuple>array
    >r copy-tuple-slots r>
    class>> prefix ;

: tuple-slots ( tuple -- seq )
    prepare-tuple>array drop copy-tuple-slots ;

GENERIC: slots>tuple ( seq class -- tuple )

M: tuple-class slots>tuple
    check-slots pad-slots
    tuple-layout <tuple> [
        [ tuple-size ]
        [ [ set-array-nth ] curry ]
        bi 2each
    ] keep ;

: >tuple ( seq -- tuple )
    unclip slots>tuple ;

ERROR: bad-superclass class ;

<PRIVATE

: tuple= ( tuple1 tuple2 -- ? )
    2dup [ layout-of ] bi@ eq? [
        [ drop tuple-size ]
        [ [ [ drop array-nth ] [ nip array-nth ] 3bi = ] 2curry ]
        2bi all-integers?
    ] [
        2drop f
    ] if ; inline

: tuple-instance? ( object class echelon -- ? )
    #! 4 slot == superclasses>>
    rot dup tuple? [
        layout-of 4 slot
        2dup 1 slot fixnum<
        [ array-nth eq? ] [ 3drop f ] if
    ] [ 3drop f ] if ; inline

: define-tuple-predicate ( class -- )
    dup dup tuple-layout echelon>>
    [ tuple-instance? ] 2curry define-predicate ;

: superclass-size ( class -- n )
    superclasses but-last [ "slots" word-prop length ] sigma ;

: (instance-check-quot) ( class -- quot )
    [
        \ dup ,
        [ "predicate" word-prop % ]
        [ [ bad-slot-value ] curry , ] bi
        \ unless ,
    ] [ ] make ;

: (fixnum-check-quot) ( class -- quot )
    (instance-check-quot) fixnum "coercer" word-prop prepend ;

: instance-check-quot ( class -- quot )
    {
        { [ dup object bootstrap-word eq? ] [ drop [ ] ] }
        { [ dup "coercer" word-prop ] [ "coercer" word-prop ] }
        { [ dup \ fixnum class<= ] [ (fixnum-check-quot) ] }
        [ (instance-check-quot) ]
    } cond ;

: boa-check-quot ( class -- quot )
    all-slots 1 tail [ class>> instance-check-quot ] map spread>quot ;

: define-boa-check ( class -- )
    dup boa-check-quot "boa-check" set-word-prop ;

: tuple-prototype ( class -- prototype )
    [ initial-values ] keep
    over [ ] all? [ 2drop f ] [ slots>tuple ] if ;

: define-tuple-prototype ( class -- )
    dup tuple-prototype "prototype" set-word-prop ;

: finalize-tuple-slots ( class slots -- slots )
    over superclass-size 2 + finalize-slots deprecated-slots ;

: define-tuple-slots ( class -- )
    dup dup "slots" word-prop finalize-tuple-slots
    [ define-accessors ] ! new
    [ define-slots ] ! old
    2bi ;

: make-tuple-layout ( class -- layout )
    [ ]
    [ [ superclass-size ] [ "slots" word-prop length ] bi + ]
    [ superclasses dup length 1- ] tri
    <tuple-layout> ;

: define-tuple-layout ( class -- )
    dup make-tuple-layout "layout" set-word-prop ;

: compute-slot-permutation ( new-slots old-slots -- triples )
    [ [ [ name>> ] map ] bi@ [ index ] curry map ]
    [ drop [ class>> ] map ]
    [ drop [ initial>> ] map ]
    2tri 3array flip ;

: update-slot ( old-values n class initial -- value )
    pick [
        >r >r swap nth dup r> instance?
        [ r> drop ] [ drop r> ] if
    ] [ >r 3drop r> ] if ;

: apply-slot-permutation ( old-values triples -- new-values )
    [ first3 update-slot ] with map ;

: permute-slots ( old-values layout -- new-values )
    [ class>> all-slots ] [ outdated-tuples get at ] bi
    compute-slot-permutation
    apply-slot-permutation ;

: update-tuple ( tuple -- newtuple )
    [ tuple-slots ] [ layout-of ] bi
    [ permute-slots ] [ class>> ] bi
    slots>tuple ;

: outdated-tuple? ( tuple assoc -- ? )
    over tuple? [
        [ [ layout-of ] dip key? ]
        [ drop class "forgotten" word-prop not ]
        2bi and
    ] [ 2drop f ] if ;

: update-tuples ( -- )
    outdated-tuples get
    dup assoc-empty? [ drop ] [
        [ outdated-tuple? ] curry instances
        dup [ update-tuple ] map become
    ] if ;

[ update-tuples ] update-tuples-hook set-global

: update-tuples-after ( class -- )
    [ all-slots ] [ tuple-layout ] bi outdated-tuples get set-at ;

M: tuple-class update-class
    {
        [ define-boa-check ]
        [ define-tuple-layout ]
        [ define-tuple-slots ]
        [ define-tuple-predicate ]
        [ define-tuple-prototype ]
    } cleave ;

: define-new-tuple-class ( class superclass slots -- )
    make-slots
    [ drop f f tuple-class define-class ]
    [ nip "slots" set-word-prop ]
    [ 2drop update-classes ]
    3tri ;

: subclasses ( class -- classes )
    class-usages [ tuple-class? ] filter ;

: each-subclass ( class quot -- )
    >r subclasses r> each ; inline

: redefine-tuple-class ( class superclass slots -- )
    [
        2drop
        [
            [ update-tuples-after ]
            [ +inlined+ changed-definition ]
            [ redefined ]
            tri
        ] each-subclass
    ]
    [ define-new-tuple-class ]
    3bi ;

: tuple-class-unchanged? ( class superclass slots -- ? )
    rot tuck [ superclass = ] [ "slots" word-prop = ] 2bi* and ;

: valid-superclass? ( class -- ? )
    [ tuple-class? ] [ tuple eq? ] bi or ;

: check-superclass ( superclass -- )
    dup valid-superclass? [ bad-superclass ] unless drop ;

PRIVATE>

GENERIC# define-tuple-class 2 ( class superclass slots -- )

M: word define-tuple-class
    over check-superclass
    define-new-tuple-class ;

M: tuple-class define-tuple-class
    over check-superclass
    3dup tuple-class-unchanged?
    [ 3drop ] [ redefine-tuple-class ] if ;

: thrower-effect ( slots -- effect )
    [ dup array? [ first ] when ] map f <effect> t >>terminated? ;

: define-error-class ( class superclass slots -- )
    [ define-tuple-class ]
    [ 2drop reset-generic ]
    [
        [ dup [ boa throw ] curry ]
        [ drop ]
        [ thrower-effect ]
        tri* define-declared
    ] 3tri ;

M: tuple-class reset-class
    [
        dup "slots" word-prop [
            name>>
            [ reader-word method forget ]
            [ writer-word method forget ] 2bi
        ] with each
    ] [
        [ call-next-method ]
        [ { "layout" "slots" "boa-check" "prototype" } reset-props ]
        bi
    ] bi ;

M: tuple-class rank-class drop 0 ;

M: tuple-class instance?
    dup tuple-layout echelon>> tuple-instance? ;

M: tuple-class (flatten-class) dup set ;

M: tuple-class (classes-intersect?)
    {
        { [ over tuple eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        { [ over tuple-class? ] [ [ class<= ] [ swap class<= ] 2bi or ] }
        [ swap classes-intersect? ]
    } cond ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

M: tuple hashcode*
    [
        [ class hashcode ] [ tuple-size ] [ ] tri
        >r rot r> [
            swapd array-nth hashcode* sequence-hashcode-step
        ] 2curry each
    ] recursive-hashcode ;

M: tuple-class new
    dup "prototype" word-prop
    [ (clone) ] [ tuple-layout <tuple> ] ?if ;

M: tuple-class boa
    [ "boa-check" word-prop call ]
    [ tuple-layout ]
    bi <tuple-boa> ;

M: tuple-class initial-value* new ;

! Deprecated
M: object get-slots ( obj slots -- ... )
    [ execute ] with each ;

M: object set-slots ( ... obj slots -- )
    <reversed> get-slots ;

: delegates ( obj -- seq ) [ delegate ] follow ;

: is? ( obj quot -- ? ) >r delegates r> contains? ; inline
