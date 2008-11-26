USING: locals math sequences tools.test hashtables words kernel
namespaces arrays strings prettyprint io.streams.string parser
accessors generic eval combinators combinators.short-circuit
combinators.short-circuit.smart math.order math.functions
definitions compiler.units fry lexer ;
IN: locals.tests

:: foo ( a b -- a a ) a a ;

[ 1 1 ] [ 1 2 foo ] unit-test

:: add-test ( a b -- c ) a b + ;

[ 3 ] [ 1 2 add-test ] unit-test

:: sub-test ( a b -- c ) a b - ;

[ -1 ] [ 1 2 sub-test ] unit-test

:: map-test ( a b -- seq ) a [ b + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test ] unit-test

:: map-test-2 ( seq inc -- seq ) seq [| elt | elt inc + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test-2 ] unit-test

:: let-test ( c -- d )
    [let | a [ 1 ] b [ 2 ] | a b + c + ] ;

[ 7 ] [ 4 let-test ] unit-test

:: let-test-2 ( a -- a )
    a [let | a [ ] | [let | b [ a ] | a ] ] ;

[ 3 ] [ 3 let-test-2 ] unit-test

:: let-test-3 ( a -- a )
    a [let | a [ ] | [let | b [ [ a ] ] | [let | a [ 3 ] | b ] ] ] ;

:: let-test-4 ( a -- b )
    a [let | a [ 1 ] b [ ] | a b 2array ] ;

[ { 1 2 } ] [ 2 let-test-4 ] unit-test

:: let-test-5 ( a -- b )
    a [let | a [ ] b [ ] | a b 2array ] ;

[ { 2 1 } ] [ 1 2 let-test-5 ] unit-test

:: let-test-6 ( a -- b )
    a [let | a [ ] b [ 1 ] | a b 2array ] ;

[ { 2 1 } ] [ 2 let-test-6 ] unit-test

[ -1 ] [ -1 let-test-3 call ] unit-test

[ 5 ] [
    [let | a [ 3 ] | [wlet | func [ a + ] | 2 func ] ]
] unit-test

:: wlet-test-2 ( a b -- seq )
    [wlet | add-b [ b + ] |
        a [ add-b ] map ] ;


[ { 4 5 6 } ] [ { 2 3 4 } 2 wlet-test-2 ] unit-test
    
:: wlet-test-3 ( a -- b )
    [wlet | add-a [ a + ] | [ add-a ] ]
    [let | a [ 3 ] | a swap call ] ;

[ 5 ] [ 2 wlet-test-3 ] unit-test

:: wlet-test-4 ( a -- b )
    [wlet | sub-a [| b | b a - ] |
        3 sub-a ] ;

[ -7 ] [ 10 wlet-test-4 ] unit-test

:: write-test-1 ( n! -- q )
    [| i | n i + dup n! ] ;

0 write-test-1 "q" set

{ 1 1 } "q" get must-infer-as

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

:: write-test-2 ( -- q )
    [let | n! [ 0 ] |
        [| i | n i + dup n! ] ] ;

write-test-2 "q" set

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

[ 10 20 ]
[
    20 10 [| a! | [| b! | a b ] ] call call
] unit-test

:: write-test-3 ( a! -- q ) [| b | b a! ] ;

[ ] [ 1 2 write-test-3 call ] unit-test

:: write-test-4 ( x! -- q ) [ [let | y! [ 0 ] | f x! ] ] ;

[ ] [ 5 write-test-4 drop ] unit-test

! Not really a write test; just enforcing consistency
:: write-test-5 ( x -- y )
    [wlet | fun! [ x + ] | 5 fun! ] ;

[ 9 ] [ 4 write-test-5 ] unit-test

SYMBOL: a

:: use-test ( a b c -- a b c )
    USE: kernel ;

[ t ] [ a symbol? ] unit-test

:: let-let-test ( n -- n ) [let | n [ n 3 + ] | n ] ;

[ 13 ] [ 10 let-let-test ] unit-test

GENERIC: lambda-generic ( a b -- c )

GENERIC# lambda-generic-1 1 ( a b -- c )

M:: integer lambda-generic-1 ( a b -- c ) a b * ;

M:: string lambda-generic-1 ( a b -- c )
    a b CHAR: x <string> lambda-generic ;

M:: integer lambda-generic ( a b -- c ) a b lambda-generic-1 ;

GENERIC# lambda-generic-2 1 ( a b -- c )

M:: integer lambda-generic-2 ( a b -- c )
    a CHAR: x <string> b lambda-generic ;

M:: string lambda-generic-2 ( a b -- c ) a b append ;

M:: string lambda-generic ( a b -- c ) a b lambda-generic-2 ;

[ 10 ] [ 5 2 lambda-generic ] unit-test

[ "abab" ] [ "aba" "b" lambda-generic ] unit-test

[ "abaxxx" ] [ "aba" 3 lambda-generic ] unit-test

[ "xaba" ] [ 1 "aba" lambda-generic ] unit-test

[ ] [ \ lambda-generic-1 see ] unit-test

[ ] [ \ lambda-generic-2 see ] unit-test

[ ] [ \ lambda-generic see ] unit-test

:: unparse-test-1 ( a -- ) [let | a! [ ] | ] ;

[ "[let | a! [ ] | ]" ] [
    \ unparse-test-1 "lambda" word-prop body>> first unparse
] unit-test

:: unparse-test-2 ( -- ) [wlet | a! [ ] | ] ;

[ "[wlet | a! [ ] | ]" ] [
    \ unparse-test-2 "lambda" word-prop body>> first unparse
] unit-test

:: unparse-test-3 ( -- b ) [| a! | ] ;

[ "[| a! | ]" ] [
    \ unparse-test-3 "lambda" word-prop body>> first unparse
] unit-test

DEFER: xyzzy

[ ] [
    "IN: locals.tests USE: math GENERIC: xyzzy M: integer xyzzy ;"
    <string-reader> "lambda-generic-test" parse-stream drop
] unit-test

[ 10 ] [ 10 xyzzy ] unit-test

[ ] [
    "IN: locals.tests USE: math USE: locals GENERIC: xyzzy M:: integer xyzzy ( n -- ) 5 ;"
    <string-reader> "lambda-generic-test" parse-stream drop
] unit-test

[ 5 ] [ 10 xyzzy ] unit-test

:: let*-test-1 ( a -- b )
    [let* | b [ a 1+ ]
            c [ b 1+ ] |
        a b c 3array ] ;

[ { 1 2 3 } ] [ 1 let*-test-1 ] unit-test

:: let*-test-2 ( a -- b )
    [let* | b [ a 1+ ]
            c! [ b 1+ ] |
        a b c 3array ] ;

[ { 1 2 3 } ] [ 1 let*-test-2 ] unit-test

:: let*-test-3 ( a -- b )
    [let* | b [ a 1+ ]
            c! [ b 1+ ] |
        c 1+ c!  a b c 3array ] ;

[ { 1 2 4 } ] [ 1 let*-test-3 ] unit-test

:: let*-test-4 ( a b -- c d )
    [let | a [ b ]
           b [ a ] |
        [let* | a'  [ a  ]
                a'' [ a' ]
                b'  [ b  ]
                b'' [ b' ] |
            a'' b'' ] ] ;

[ "xxx" "yyy" ] [ "yyy" "xxx" let*-test-4 ] unit-test

GENERIC: next-method-test ( a -- b )

M: integer next-method-test 3 + ;

M:: fixnum next-method-test ( a -- b ) a call-next-method 1 + ;

[ 5 ] [ 1 next-method-test ] unit-test

: no-with-locals-test { 1 2 3 } [| x | x 3 + ] map ;

[ { 4 5 6 } ] [ no-with-locals-test ] unit-test

{ 3 0 } [| a b c | ] must-infer-as

[ ] [ 1 [let | a [ ] | ] ] unit-test

[ 3 ] [ 1 [let | a [ ] | 3 ] ] unit-test

[ ] [ 1 2 [let | a [ ] b [ ] | ] ] unit-test

:: a-word-with-locals ( a b -- ) ;

: new-definition "USING: math ;\nIN: locals.tests\n: a-word-with-locals ( -- x ) 2 3 + ;\n" ;

[ ] [ new-definition eval ] unit-test

[ t ] [
    [ \ a-word-with-locals see ] with-string-writer
    new-definition =
] unit-test

: method-definition "USING: locals locals.tests sequences ;\nM:: sequence method-with-locals ( a -- y ) a reverse ;\n" ;

GENERIC: method-with-locals ( x -- y )

M:: sequence method-with-locals ( a -- y ) a reverse ;

[ t ] [
    [ \ sequence \ method-with-locals method see ] with-string-writer
    method-definition =
] unit-test

:: cond-test ( a b -- c )
    {
        { [ a b < ] [ 3 ] }
        { [ a b = ] [ 4 ] }
        { [ a b > ] [ 5 ] }
    } cond ;

\ cond-test must-infer

[ 3 ] [ 1 2 cond-test ] unit-test
[ 4 ] [ 2 2 cond-test ] unit-test
[ 5 ] [ 3 2 cond-test ] unit-test

:: 0&&-test ( a -- ? )
    { [ a integer? ] [ a even? ] [ a 10 > ] } 0&& ;

\ 0&&-test must-infer

[ f ] [ 1.5 0&&-test ] unit-test
[ f ] [ 3 0&&-test ] unit-test
[ f ] [ 8 0&&-test ] unit-test
[ t ] [ 12 0&&-test ] unit-test

:: &&-test ( a -- ? )
    { [ a integer? ] [ a even? ] [ a 10 > ] } && ;

\ &&-test must-infer

[ f ] [ 1.5 &&-test ] unit-test
[ f ] [ 3 &&-test ] unit-test
[ f ] [ 8 &&-test ] unit-test
[ t ] [ 12 &&-test ] unit-test

:: let-and-cond-test-1 ( -- a )
    [let | a [ 10 ] |
        [let | a [ 20 ] |
            {
                { [ t ] [ [let | c [ 30 ] | a ] ] }
            } cond
        ]
    ] ;

\ let-and-cond-test-1 must-infer

[ 20 ] [ let-and-cond-test-1 ] unit-test

:: let-and-cond-test-2 ( -- pair )
    [let | A [ 10 ] |
        [let | B [ 20 ] |
            { { [ t ] [ { A B } ] } } cond
        ]
    ] ;

\ let-and-cond-test-2 must-infer

[ { 10 20 } ] [ let-and-cond-test-2 ] unit-test

[ { 10       } ] [ 10       [| a     | { a     } ] call ] unit-test
[ { 10 20    } ] [ 10 20    [| a b   | { a b   } ] call ] unit-test
[ { 10 20 30 } ] [ 10 20 30 [| a b c | { a b c } ] call ] unit-test

[ { 10 20 30 } ] [ [let | a [ 10 ] b [ 20 ] c [ 30 ] | { a b c } ] ] unit-test

[ V{ 10 20 30 } ] [ 10 20 30 [| a b c | V{ a b c } ] call ] unit-test

[ H{ { 10 "a" } { 20 "b" } { 30 "c" } } ]
[ 10 20 30 [| a b c | H{ { a "a" } { b "b" } { c "c" } } ] call ] unit-test

[ T{ slice f 0 3 "abc" } ]
[ 0 3 "abc" [| from to seq | T{ slice f from to seq } ] call ] unit-test

{ 3 1 } [| from to seq | T{ slice f from to seq } ] must-infer-as

ERROR: punned-class x ;

[ T{ punned-class f 3 } ] [ 3 [| a | T{ punned-class f a } ] call ] unit-test

:: literal-identity-test ( -- a b )
    { } V{ } ;

[ t f ] [
    literal-identity-test
    literal-identity-test
    swapd [ eq? ] [ eq? ] 2bi*
] unit-test

:: mutable-local-in-literal-test ( a! -- b ) a 1 + a! { a } ;

[ { 4 } ] [ 3 mutable-local-in-literal-test ] unit-test

:: compare-case ( obj1 obj2 lt-quot eq-quot gt-quot -- )
    obj1 obj2 <=> {
        { +lt+ [ lt-quot call ] }
        { +eq+ [ eq-quot call ] }
        { +gt+ [ gt-quot call ] }
    } case ; inline

[ [ ] [ ] [ ] compare-case ] must-infer

:: big-case-test ( a -- b )
    a {
        { 0 [ a 1 + ] }
        { 1 [ a 1 - ] }
        { 2 [ a 1 swap / ] }
        { 3 [ a dup * ] }
        { 4 [ a sqrt ] }
        { 5 [ a a ^ ] }
    } case ;

\ big-case-test must-infer

[ 9 ] [ 3 big-case-test ] unit-test

GENERIC: lambda-method-forget-test ( a -- b )

M:: integer lambda-method-forget-test ( a -- b ) ;

[ ] [ [ { integer lambda-method-forget-test } forget ] with-compilation-unit ] unit-test

[ { [ 10 ] } ] [ 10 [| A | { [ A ] } ] call ] unit-test

[
    "USING: locals fry math ; [ 0 '[ [let | A [ 10 ] | A _ + ] ] ]" eval
] [ error>> >r/r>-in-fry-error? ] must-fail-with

:: (funny-macro-test) ( obj quot -- ? ) obj { quot } 1&& ; inline
: funny-macro-test ( n -- ? ) [ odd? ] (funny-macro-test) ;

\ funny-macro-test must-infer

[ t ] [ 3 funny-macro-test ] unit-test
[ f ] [ 2 funny-macro-test ] unit-test

! Some odd parser corner cases
[ "USE: locals [let" eval ] [ error>> unexpected-eof? ] must-fail-with
[ "USE: locals [let |" eval ] [ error>> unexpected-eof? ] must-fail-with
[ "USE: locals [let | a" eval ] [ error>> unexpected-eof? ] must-fail-with
[ "USE: locals [|" eval ] [ error>> unexpected-eof? ] must-fail-with

[ 25 ] [ 5 [| a | { [ a sq ] } cond ] call ] unit-test
[ 25 ] [ 5 [| | { [| a | a sq ] } ] call first call ] unit-test

:: FAILdog-1 ( -- b ) { [| c | c ] } ;

\ FAILdog-1 must-infer

:: FAILdog-2 ( a -- b ) a { [| c | c ] } cond ;

\ FAILdog-2 must-infer

! :: wlet-&&-test ( a -- ? )
!     [wlet | is-integer? [ a integer? ]
!             is-even? [ a even? ]
!             >10? [ a 10 > ] |
!         { [ is-integer? ] [ is-even? ] [ >10? ] } &&
!     ] ;

! [ f ] [ 1.5 wlet-&&-test ] unit-test
! [ f ] [ 3 wlet-&&-test ] unit-test
! [ f ] [ 8 wlet-&&-test ] unit-test
! [ t ] [ 12 wlet-&&-test ] unit-test