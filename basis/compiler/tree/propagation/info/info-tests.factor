USING: accessors alien byte-arrays classes.struct math math.intervals sequences
classes.algebra kernel tools.test compiler.tree.propagation.info arrays ;
IN: compiler.tree.propagation.info.tests

{ f } [ 0.0 -0.0 eql? ] unit-test

{ t t } [
    0 10 [a,b] <interval-info>
    5 20 [a,b] <interval-info>
    value-info-intersect
    [ class>> real class= ]
    [ interval>> 5 10 [a,b] = ]
    bi
] unit-test

{ float 10.0 t } [
    10.0 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    [ class>> ] [ >literal< ] bi
] unit-test

{ null } [
    10 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    class>>
] unit-test

{ fixnum 10 t } [
    10 <literal-info>
    10 <literal-info>
    value-info-union
    [ class>> ] [ >literal< ] bi
] unit-test

{ 3.0 t } [
    3 3 [a,b] <interval-info> float <class-info>
    value-info-intersect >literal<
] unit-test

{ 3 t } [
    2 3 (a,b] <interval-info> fixnum <class-info>
    value-info-intersect >literal<
] unit-test

{ T{ value-info-state f null empty-interval f f } } [
    fixnum -10 0 [a,b] <class/interval-info>
    fixnum 19 29 [a,b] <class/interval-info>
    value-info-intersect
] unit-test

{ 3 t } [
    3 <literal-info>
    null-info value-info-union >literal<
] unit-test

{ } [ { } value-infos-union drop ] unit-test

TUPLE: test-tuple { x read-only } ;

{ t } [
    f f 3 <literal-info> 3array test-tuple <tuple-info> dup
    object-info value-info-intersect =
] unit-test

{ t t } [
    f <literal-info>
    fixnum 0 40 [a,b] <class/interval-info>
    value-info-union
    \ f class-not <class-info>
    value-info-intersect
    [ class>> fixnum class= ]
    [ interval>> 0 40 [a,b] = ] bi
] unit-test

! interval>literal
{ 10 t } [
    fixnum 10 10 [a,b]  interval>literal
] unit-test

STRUCT: self { s self* } ;

TUPLE: tup1 foo ;

TUPLE: tup2 < tup1 bar ;

: make-slotted-info ( slot-classes class -- info )
    [ [ dup [ <class-info> ] when ] map ] dip <tuple-info> ;

! slots<=
{ t t f } [
    null-info null-info slots<=
    { byte-array } self make-slotted-info self <class-info> slots<=
    self <class-info> { byte-array } self make-slotted-info slots<=
] unit-test

! value-info<=
! ------------

! Comparing classes
{ t t } [
    byte-array c-ptr [ <class-info> ] bi@ value-info<=
    alien c-ptr [ <class-info> ] bi@ value-info<=
] unit-test

! Literals vs. classes
{ t f } [
    20 <literal-info> fixnum <class-info> value-info<=
    fixnum <class-info> 20 <literal-info> value-info<=
] unit-test

! Nulls vs. literals
{ t f } [
    null-info 3 <literal-info> value-info<=
    3 <literal-info> null-info value-info<=
] unit-test

! Fulls vs. literal
{ t } [
    10 <literal-info> f value-info<=
] unit-test

! Same class, different slots
{ t t f } [
    { byte-array } self make-slotted-info
    { c-ptr } self make-slotted-info
    value-info<=

    { byte-array byte-array } self make-slotted-info
    { } self make-slotted-info
    value-info<=

    { } self make-slotted-info
    { byte-array byte-array } self make-slotted-info
    value-info<=
] unit-test

! Slots with literals
{ f } [
    10 <literal-info> 1array array <tuple-info>
    20 <literal-info> 1array array <tuple-info>
    value-info<=
] unit-test

! Slots, but different classes
{ t } [
    null-info { f c-ptr } self make-slotted-info value-info<=
] unit-test

! Null vs. null vs. full
{ t t f } [
    null-info null-info value-info<=
    null-info f value-info<=
    f null-info value-info<=
] unit-test

! Same class, intervals
{ t f } [
    fixnum 20 30 [a,b] <class/interval-info>
    fixnum 0 100 [a,b] <class/interval-info>
    value-info<=
    fixnum 0 100 [a,b] <class/interval-info>
    fixnum 20 30 [a,b] <class/interval-info>
    value-info<=
] unit-test

! Different classes, intervals
{ t f f } [
    fixnum 20 30 [a,b] <class/interval-info>
    real 0 100 [a,b] <class/interval-info>
    value-info<=

    real 5 10 [a,b] <class/interval-info>
    integer 0 20 [a,b] <class/interval-info>
    value-info<=

    integer 0 20 [a,b] <class/interval-info>
    real 5 10 [a,b] <class/interval-info>
    value-info<=
] unit-test

! Mutable literals
{ f f } [
    [ "foo" ] <literal-info> [ "foo" ] <literal-info> value-info<=
    "hey" <literal-info> "hey" <literal-info> value-info<=
] unit-test

! Tuples
{ t f } [
    tup2 <class-info> tup1 <class-info> value-info<=
    tup1 <class-info> tup2 <class-info> value-info<=
] unit-test
