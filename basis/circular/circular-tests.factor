! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license
USING: arrays kernel tools.test sequences sequences.private
circular strings ;
IN: circular.tests

[ 0 ] [ { 0 1 2 3 4 } <circular> 0 swap virtual@ drop ] unit-test
[ 2 ] [ { 0 1 2 3 4 } <circular> 2 swap virtual@ drop ] unit-test

[ CHAR: t ] [ "test" <circular> 0 swap nth ] unit-test
[ "test"  ] [ "test" <circular> >string ] unit-test

[ CHAR: e ] [ "test" <circular> 5 swap nth-unsafe ] unit-test
 
[ [ 1 2 3 ] ] [ { 1 2 3 } <circular> [ ] like ] unit-test
[ [ 2 3 1 ] ] [ { 1 2 3 } <circular> [ rotate-circular ] keep [ ] like ] unit-test
[ [ 3 1 2 ] ] [ { 1 2 3 } <circular> [ rotate-circular ] keep [ rotate-circular ] keep [ ] like ] unit-test
[ [ 2 3 1 ] ] [ { 1 2 3 } <circular> 1 over change-circular-start [ ] like ] unit-test
[ [ 3 1 2 ] ] [ { 1 2 3 } <circular> 1 over change-circular-start 1 over change-circular-start [ ] like ] unit-test
[ [ 3 1 2 ] ] [ { 1 2 3 } <circular> -100 over change-circular-start [ ] like ] unit-test

[ "fob" ] [ "foo" <circular> CHAR: b 2 pick set-nth >string ] unit-test
[ "boo" ] [ "foo" <circular> CHAR: b 3 pick set-nth-unsafe >string ] unit-test
[ "ornact" ] [ "factor" <circular> 4 over change-circular-start CHAR: n 2 pick set-nth >string ] unit-test

[ "bcd" ] [ 3 <circular-string> "abcd" [ over circular-push ] each >string ] unit-test

[ { 0 0 } ] [ { 0 0 } <circular> -1 over change-circular-start >array ] unit-test

! This no longer fails
! [ "test" <circular> 5 swap nth ] must-fail
! [ "foo" <circular> CHAR: b 3 rot set-nth ] must-fail

[ { } ] [ 3 <growing-circular> >array ] unit-test
[ { 1 2 } ] [
    3 <growing-circular>
    [ 1 swap growing-circular-push ] keep
    [ 2 swap growing-circular-push ] keep >array
] unit-test
[ { 3 4 5 } ] [
    3 <growing-circular> dup { 1 2 3 4 5 } [
        swap growing-circular-push
    ] with each >array
] unit-test

[ V{ 1 2 3 1 2 } ] [
    { 1 2 3 } <circular> V{ } [
        [ [ push ] [ length 4 < ] bi ] curry circular-while
    ] keep
] unit-test
