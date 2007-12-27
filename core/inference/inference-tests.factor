USING: arrays generic inference inference.backend
inference.dataflow kernel classes kernel.private math
math.parser math.private namespaces namespaces.private parser
sequences strings vectors words quotations effects tools.test
continuations generic.standard sorting assocs definitions
prettyprint io inspector tuples
classes.union classes.predicate debugger bootstrap.image
bootstrap.image.private threads.private
io.streams.string combinators.private tools.test.inference ;
IN: temporary

{ 0 2 } [ 2 "Hello" ] unit-test-effect
{ 1 2 } [ dup ] unit-test-effect

{ 1 2 } [ [ dup ] call ] unit-test-effect
[ [ call ] infer ] unit-test-fails

{ 2 4 } [ 2dup ] unit-test-effect

{ 1 0 } [ [ ] [ ] if ] unit-test-effect
[ [ if ] infer ] unit-test-fails
[ [ [ ] if ] infer ] unit-test-fails
[ [ [ 2 ] [ ] if ] infer ] unit-test-fails
{ 4 3 } [ [ rot ] [ -rot ] if ] unit-test-effect

{ 4 3 } [
    [
        [ swap 3 ] [ nip 5 5 ] if
    ] [
        -rot
    ] if
] unit-test-effect

{ 1 1 } [ dup [ ] when ] unit-test-effect
{ 1 1 } [ dup [ dup fixnum* ] when ] unit-test-effect
{ 2 1 } [ [ dup fixnum* ] when ] unit-test-effect

{ 1 0 } [ [ drop ] when* ] unit-test-effect
{ 1 1 } [ [ { { [ ] } } ] unless* ] unit-test-effect

{ 0 1 }
[ [ 2 2 fixnum+ ] dup [ ] when call ] unit-test-effect

[
    [ [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call ] infer
] unit-test-fails

! Test inference of termination of control flow
: termination-test-1
    "foo" throw ;

: termination-test-2 [ termination-test-1 ] [ 3 ] if ;

{ 1 1 } [ termination-test-2 ] unit-test-effect

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer ] unit-test-fails

: no-base-case-1 dup [ no-base-case-1 ] [ no-base-case-1 ] if ;
[ [ no-base-case-1 ] infer ] unit-test-fails

: simple-recursion-1 ( obj -- obj )
    dup [ simple-recursion-1 ] [ ] if ;

{ 1 1 } [ simple-recursion-1 ] unit-test-effect

: simple-recursion-2 ( obj -- obj )
    dup [ ] [ simple-recursion-2 ] if ;

{ 1 1 } [ simple-recursion-2 ] unit-test-effect

: bad-recursion-2 ( obj -- obj )
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ [ bad-recursion-2 ] infer ] unit-test-fails

: funny-recursion ( obj -- obj )
    dup [ funny-recursion 1 ] [ 2 ] if drop ;

{ 1 1 } [ funny-recursion ] unit-test-effect

! Simple combinators
{ 1 2 } [ [ first ] keep second ] unit-test-effect

! Mutual recursion
DEFER: foe

: fie ( element obj -- ? )
    dup array? [ foe ] [ eq? ] if ;

: foe ( element tree -- ? )
    dup [
        2dup first fie [
            nip
        ] [
            second dup array? [
                foe
            ] [
                fie
            ] if
        ] if
    ] [
        2drop f
    ] if ;

{ 2 1 } [ fie ] unit-test-effect
{ 2 1 } [ foe ] unit-test-effect

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

{ 0 0 } [ nested-when ] unit-test-effect

: nested-when* ( obj -- )
    [
        [
            drop
        ] when*
    ] when* ;

{ 1 0 } [ nested-when* ] unit-test-effect

SYMBOL: sym-test

{ 0 1 } [ sym-test ] unit-test-effect

: terminator-branch
    dup [
        length
    ] [
        "foo" throw
    ] if ;

{ 1 1 } [ terminator-branch ] unit-test-effect

: recursive-terminator ( obj -- )
    dup [
        recursive-terminator
    ] [
        "Hi" throw
    ] if ;

{ 1 0 } [ recursive-terminator ] unit-test-effect

GENERIC: potential-hang ( obj -- obj )
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate ( obj -- )
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

{ 1 0 } [ iterate ] unit-test-effect

! Regression
: cat ( obj -- * ) dup [ throw ] [ throw ] if ;
: dog ( a b c -- ) dup [ cat ] [ 3drop ] if ;
{ 3 0 } [ dog ] unit-test-effect

! Regression
DEFER: monkey
: friend ( a b c -- ) dup [ friend ] [ monkey ] if ;
: monkey ( a b c -- ) dup [ 3drop ] [ friend ] if ;
{ 3 0 } [ friend ] unit-test-effect

! Regression -- same as above but we infer the second word first
DEFER: blah2
: blah ( a b c -- ) dup [ blah ] [ blah2 ] if ;
: blah2 ( a b c -- ) dup [ blah ] [ 3drop ] if ;
{ 3 0 } [ blah2 ] unit-test-effect

! Regression
DEFER: blah4
: blah3 ( a b c -- )
    dup [ blah3 ] [ dup [ blah4 ] [ blah3 ] if ] if ;
: blah4 ( a b c -- )
    dup [ blah4 ] [ dup [ 3drop ] [ blah3 ] if ] if ;
{ 3 0 } [ blah4 ] unit-test-effect

! Regression
: bad-combinator ( obj quot -- )
    over [
        2drop
    ] [
        [ swap slip ] keep swap bad-combinator
    ] if ; inline

[ [ [ 1 ] [ ] bad-combinator ] infer ] unit-test-fails

! Regression
: bad-input#
    dup string? [ 2array throw ] unless
    over string? [ 2array throw ] unless ;

{ 2 2 } [ bad-input# ] unit-test-effect

! Regression

! This order of branches works
DEFER: do-crap
: more-crap ( obj -- ) dup [ drop ] [ dup do-crap call ] if ;
: do-crap ( obj -- ) dup [ more-crap ] [ do-crap ] if ;
[ [ do-crap ] infer ] unit-test-fails

! This one does not
DEFER: do-crap*
: more-crap* ( obj -- ) dup [ drop ] [ dup do-crap* call ] if ;
: do-crap* ( obj -- ) dup [ do-crap* ] [ more-crap* ] if ;
[ [ do-crap* ] infer ] unit-test-fails

! Regression
: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline
{ 2 1 } [ too-deep ] unit-test-effect

! Error reporting is wrong
MATH: xyz
M: fixnum xyz 2array ;
M: float xyz
    [ 3 ] 2apply swapd >r 2array swap r> 2array swap ;

[ t ] [ [ [ xyz ] infer ] catch inference-error? ] unit-test

! Doug Coleman discovered this one while working on the
! calendar library
DEFER: A
DEFER: B
DEFER: C

: A ( a -- )
    dup {
        [ drop ]
        [ A ]
        [ \ A no-method ]
        [ dup C A ]
    } dispatch ;

: B ( b -- )
    dup {
        [ C ]
        [ B ]
        [ \ B no-method ]
        [ dup B B ]
    } dispatch ;

: C ( c -- )
    dup {
        [ A ]
        [ C ]
        [ \ C no-method ]
        [ dup B C ]
    } dispatch ;

{ 1 0 } [ A ] unit-test-effect
{ 1 0 } [ B ] unit-test-effect
{ 1 0 } [ C ] unit-test-effect

! I found this bug by thinking hard about the previous one
DEFER: Y
: X ( a b -- c d ) dup [ swap Y ] [ ] if ;
: Y ( a b -- c d ) X ;

{ 2 2 } [ X ] unit-test-effect
{ 2 2 } [ Y ] unit-test-effect

! This one comes from UI code
DEFER: #1
: #2 ( a b -- ) dup [ call ] [ 2drop ] if ; inline
: #3 ( a -- ) [ #1 ] #2 ;
: #4 ( a -- ) dup [ drop ] [ dup #4 dup #3 call ] if ;
: #1 ( a -- ) dup [ dup #4 dup #3 ] [ ] if drop ;

[ \ #4 word-def infer ] unit-test-fails
[ [ #1 ] infer ] unit-test-fails

! Similar
DEFER: bar
: foo ( a b -- c d ) dup [ 2drop f f bar ] [ ] if ;
: bar ( a b -- ) [ 2 2 + ] t foo drop call drop ;

[ [ foo ] infer ] unit-test-fails

[ 1234 infer ] unit-test-fails

! This used to hang
[ t ] [
    [ [ [ dup call ] dup call ] infer ] catch
    inference-error?
] unit-test

: m dup call ; inline

[ t ] [
    [ [ [ m ] m ] infer ] catch inference-error?
] unit-test

: m' dup curry call ; inline

[ t ] [
    [ [ [ m' ] m' ] infer ] catch inference-error?
] unit-test

: m'' [ dup curry ] ; inline

: m''' m'' call call ; inline

[ t ] [
    [ [ [ m''' ] m''' ] infer ] catch inference-error?
] unit-test

: m-if t over if ; inline

[ t ] [
    [ [ [ m-if ] m-if ] infer ] catch inference-error?
] unit-test

! This doesn't hang but it's also an example of the
! undedicable case
[ t ] [
    [ [ [ [ drop 3 ] swap call ] dup call ] infer ] catch
    inference-error?
] unit-test

! This form should not have a stack effect

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ [ bad-recursion-1 ] infer ] unit-test-fails

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
[ [ bad-bin ] infer ] unit-test-fails

[ t ] [ [ [ r> ] infer ] catch inference-error? ] unit-test

! Regression
[ t ] [ [ [ get-slots ] infer ] catch inference-error? ] unit-test

! Test some curry stuff
{ 1 1 } [ 3 [ ] curry 4 [ ] curry if ] unit-test-effect

{ 2 1 } [ [ ] curry 4 [ ] curry if ] unit-test-effect

[ [ 3 [ ] curry 1 2 [ ] 2curry if ] infer ] unit-test-fails

! Test number protocol
\ bitor must-infer
\ bitand must-infer
\ bitxor must-infer
\ mod must-infer
\ /i must-infer
\ /f must-infer
\ /mod must-infer
\ + must-infer
\ - must-infer
\ * must-infer
\ / must-infer
\ < must-infer
\ <= must-infer
\ > must-infer
\ >= must-infer
\ number= must-infer

! Test object protocol
\ = must-infer
\ clone must-infer
\ hashcode* must-infer

! Test sequence protocol
\ length must-infer
\ nth must-infer
\ set-length must-infer
\ set-nth must-infer
\ new must-infer
\ new-resizable must-infer
\ like must-infer
\ lengthen must-infer

! Test assoc protocol
\ at* must-infer
\ set-at must-infer
\ new-assoc must-infer
\ delete-at must-infer
\ clear-assoc must-infer
\ assoc-size must-infer
\ assoc-like must-infer
\ assoc-clone-like must-infer
\ >alist must-infer
{ 1 3 } [ [ 2drop f ] assoc-find ] unit-test-effect

! Test some random library words
\ 1quotation must-infer
\ string>number must-infer
\ get must-infer

\ push must-infer
\ append must-infer
\ peek must-infer

\ reverse must-infer
\ member? must-infer
\ remove must-infer
\ natural-sort must-infer

\ forget must-infer
\ define-class must-infer
\ define-tuple-class must-infer
\ define-union-class must-infer
\ define-predicate-class must-infer

! Test words with continuations
{ 0 0 } [ [ drop ] callcc0 ] unit-test-effect
{ 0 1 } [ [ 4 swap continue-with ] callcc1 ] unit-test-effect
{ 2 1 } [ [ + ] [ ] [ ] cleanup ] unit-test-effect
{ 2 1 } [ [ + ] [ 3drop 0 ] recover ] unit-test-effect

! Test stream protocol
\ set-timeout must-infer
\ stream-read must-infer
\ stream-read1 must-infer
\ stream-readln must-infer
\ stream-read-until must-infer
\ stream-write must-infer
\ stream-write1 must-infer
\ stream-nl must-infer
\ stream-close must-infer
\ stream-format must-infer
\ stream-write-table must-infer
\ stream-flush must-infer
\ make-span-stream must-infer
\ make-block-stream must-infer
\ make-cell-stream must-infer

! Test stream utilities
\ lines must-infer
\ contents must-infer

! Test prettyprinting
\ . must-infer
\ short. must-infer
\ unparse must-infer

\ describe must-infer
\ error. must-infer

! Test odds and ends
\ idle-thread must-infer

! Incorrect stack declarations on inline recursive words should
! be caught
: fooxxx ( a b -- c ) over [ foo ] when ; inline
: barxxx fooxxx ;

[ [ barxxx ] infer ] unit-test-fails

! A typo
{ 1 0 } [ { [ ] } dispatch ] unit-test-effect

DEFER: inline-recursive-2
: inline-recursive-1 ( -- ) inline-recursive-2 ;
: inline-recursive-2 ( -- ) inline-recursive-1 ;

{ 0 0 } [ inline-recursive-1 ] unit-test-effect

! Hooks
SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

{ 0 1 } [ my-hook ] unit-test-effect

DEFER: deferred-word

: calls-deferred-word [ deferred-word ] [ 3 ] if ;

{ 1 1 } [ calls-deferred-word ] unit-test-effect

USE: inference.dataflow

{ 1 0 } [ [ iterate-next ] iterate-nodes ] unit-test-effect

{ 1 0 }
[
    [ [ iterate-next ] iterate-nodes ] with-node-iterator
] unit-test-effect

: nilpotent ( quot -- )
    t [ [ call ] keep nilpotent ] [ drop ] if ; inline

: semisimple ( quot -- )
    [ call ] keep [ [ semisimple ] keep ] nilpotent drop ; inline

{ 0 1 }
[ [ ] [ call ] keep [ [ call ] keep ] nilpotent ]
unit-test-effect

{ 0 0 } [ [ ] semisimple ] unit-test-effect

{ 1 0 } [ [ drop ] each-node ] unit-test-effect

DEFER: an-inline-word

: normal-word-3 ( -- )
    3 [ [ 2 + ] curry ] an-inline-word call drop ;

: normal-word-2 ( -- )
    normal-word-3 ;

: normal-word ( x -- x )
    dup [ normal-word-2 ] when ;

: an-inline-word ( obj quot -- )
    >r normal-word r> call ; inline

{ 1 1 } [ [ 3 * ] an-inline-word ] unit-test-effect

{ 0 1 } [ [ 2 ] [ 2 ] [ + ] compose compose call ] unit-test-effect

TUPLE: custom-error ;

[ T{ effect f 0 0 t } ] [
    [ custom-error construct-boa throw ] infer
] unit-test

: funny-throw throw ; inline

[ T{ effect f 0 0 t } ] [
    [ 3 funny-throw ] infer
] unit-test

[ T{ effect f 0 0 t } ] [
    [ custom-error inference-error ] infer
] unit-test

[ T{ effect f 1 1 t } ] [
    [ dup >r 3 throw r> ] infer
] unit-test

! This was a false trigger of the undecidable quotation
! recursion bug
{ 2 1 } [ find-last-sep ] unit-test-effect
