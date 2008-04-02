IN: generic.standard.new.tests
USING: tools.test math math.functions math.constants
generic.standard.new strings sequences arrays kernel accessors
words float-arrays byte-arrays bit-arrays parser ;

<< : GENERIC: CREATE-GENERIC define-simple-generic ; parsing >>

GENERIC: lo-tag-test

M: integer lo-tag-test 3 + ;

M: float lo-tag-test 4 - ;

M: rational lo-tag-test 2 - ;

M: complex lo-tag-test sq ;

[ 8 ] [ 5 >bignum lo-tag-test ] unit-test
[ 0.0 ] [ 4.0 lo-tag-test ] unit-test
[ -1/2 ] [ 1+1/2 lo-tag-test ] unit-test
[ -16 ] [ C{ 0 4 } lo-tag-test ] unit-test

GENERIC: hi-tag-test

M: string hi-tag-test ", in bed" append ;

M: number hi-tag-test 3 + ;

M: array hi-tag-test [ hi-tag-test ] map ;

M: sequence hi-tag-test reverse ;

[ B{ 3 2 1 } ] [ B{ 1 2 3 } hi-tag-test ] unit-test

[ { 6 9 12 } ] [ { 3 6 9 } hi-tag-test ] unit-test

[ "i like monkeys, in bed" ] [ "i like monkeys" hi-tag-test ] unit-test

TUPLE: shape ;

TUPLE: abstract-rectangle < shape width height ;

TUPLE: rectangle < abstract-rectangle ;

C: <rectangle> rectangle

TUPLE: parallelogram < abstract-rectangle skew ;

C: <parallelogram> parallelogram

TUPLE: circle < shape radius ;

C: <circle> circle

GENERIC: area

M: abstract-rectangle area [ width>> ] [ height>> ] bi * ;

M: circle area radius>> sq pi * ;

[ 12 ] [ 4 3 <rectangle> area ] unit-test
[ 12 ] [ 4 3 2 <parallelogram> area ] unit-test
[ t ] [ 2 <circle> area 4 pi * = ] unit-test

GENERIC: perimiter

: rectangle-perimiter + 2 * ;

M: rectangle perimiter
    [ width>> ] [ height>> ] bi
    rectangle-perimiter ;

: hypotenuse [ sq ] bi@ + sqrt ;

M: parallelogram perimiter
    [ width>> ]
    [ [ height>> ] [ skew>> ] bi hypotenuse ] bi
    rectangle-perimiter ;

M: circle perimiter 2 * pi * ;

[ 14 ] [ 4 3 <rectangle> perimiter ] unit-test
[ 30 ] [ 10 4 3 <parallelogram> perimiter ] unit-test

GENERIC: big-mix-test

M: object big-mix-test drop "object" ;

M: tuple big-mix-test drop "tuple" ;

M: integer big-mix-test drop "integer" ;

M: float big-mix-test drop "float" ;

M: complex big-mix-test drop "complex" ;

M: string big-mix-test drop "string" ;

M: array big-mix-test drop "array" ;

M: sequence big-mix-test drop "sequence" ;

M: rectangle big-mix-test drop "rectangle" ;

M: parallelogram big-mix-test drop "parallelogram" ;

M: circle big-mix-test drop "circle" ;

[ "integer" ] [ 3 big-mix-test ] unit-test
[ "float" ] [ 5.0 big-mix-test ] unit-test
[ "complex" ] [ -1 sqrt big-mix-test ] unit-test
[ "sequence" ] [ F{ 1.0 2.0 3.0 } big-mix-test ] unit-test
[ "sequence" ] [ B{ 1 2 3 } big-mix-test ] unit-test
[ "sequence" ] [ ?{ t f t } big-mix-test ] unit-test
[ "sequence" ] [ SBUF" hello world" big-mix-test ] unit-test
[ "sequence" ] [ V{ "a" "b" } big-mix-test ] unit-test
[ "sequence" ] [ BV{ 1 2 } big-mix-test ] unit-test
[ "sequence" ] [ ?V{ t t f f } big-mix-test ] unit-test
[ "sequence" ] [ FV{ -0.3 4.6 } big-mix-test ] unit-test
[ "string" ] [ "hello" big-mix-test ] unit-test
[ "rectangle" ] [ 1 2 <rectangle> big-mix-test ] unit-test
[ "parallelogram" ] [ 10 4 3 <parallelogram> big-mix-test ] unit-test
[ "circle" ] [ 100 <circle> big-mix-test ] unit-test
[ "tuple" ] [ H{ } big-mix-test ] unit-test
[ "object" ] [ \ + big-mix-test ] unit-test

GENERIC: small-lo-tag

M: fixnum small-lo-tag drop "fixnum" ;

M: string small-lo-tag drop "string" ;

M: array small-lo-tag drop "array" ;

M: float-array small-lo-tag drop "float-array" ;

M: byte-array small-lo-tag drop "byte-array" ;

[ "fixnum" ] [ 3 small-lo-tag ] unit-test

[ "float-array" ] [ F{ 1.0 } small-lo-tag ] unit-test
