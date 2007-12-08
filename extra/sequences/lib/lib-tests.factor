USING: arrays kernel sequences sequences.lib math
math.functions tools.test strings ;

[ 4 ] [ { 1 2 } [ sq ] [ * ] map-reduce ] unit-test
[ 36 ] [ { 2 3 } [ sq ] [ * ] map-reduce ] unit-test

[ 10 ] [ { 1 2 3 4 } [ + ] reduce* ] unit-test
[ 24 ] [ { 1 2 3 4 } [ * ] reduce* ] unit-test

[ -4 ] [ 1 -4 [ abs ] higher ] unit-test
[ 1 ] [ 1 -4 [ abs ] lower ] unit-test

[ { 1 2 3 4 } ] [ { { 1 2 3 4 } { 1 2 3 } } longest ] unit-test
[ { 1 2 3 4 } ] [ { { 1 2 3 } { 1 2 3 4 } } longest ] unit-test

[ { 1 2 3 } ] [ { { 1 2 3 4 } { 1 2 3 } } shortest ] unit-test
[ { 1 2 3 } ] [ { { 1 2 3 } { 1 2 3 4 } } shortest ] unit-test

[ 3 ] [ 1 3 bigger ] unit-test
[ 1 ] [ 1 3 smaller ] unit-test

[ "abd" ] [ "abc" "abd" bigger ] unit-test
[ "abc" ] [ "abc" "abd" smaller ] unit-test

[ "abe" ] [ { "abc" "abd" "abe" } biggest ] unit-test
[ "abc" ] [ { "abc" "abd" "abe" } smallest ] unit-test

[ 1 3 ] [ { 1 2 3 } minmax ] unit-test
[ -11 -9 ] [ { -11 -10 -9 } minmax ] unit-test
[ -1/0. 1/0. ] [ { -1/0. 1/0. -11 -10 -9 } minmax ] unit-test

[ { { 1 } { -1 5 } { 2 4 } } ]
[ { 1 -1 5 2 4 } [ < ] monotonic-split [ >array ] map ] unit-test
[ { { 1 1 1 1 } { 2 2 } { 3 } { 4 } { 5 } { 6 6 6 } } ]
[ { 1 1 1 1 2 2 3 4 5 6 6 6 } [ = ] monotonic-split [ >array ] map ] unit-test
[ f ] [ { } singleton? ] unit-test
[ t ] [ { "asdf" } singleton? ] unit-test
[ f ] [ { "asdf" "bsdf" } singleton? ] unit-test

[ 2 ] [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] unit-test-fails

[ { 1 9 25 } ] [ { 1 3 5 6 } [ sq ] [ even? ] map-until ] unit-test
[ { 2 4 } ] [ { 2 4 1 3 } [ even? ] take-while ] unit-test

[ { { 0 0 } { 1 0 } { 0 1 } { 1 1 } } ] [ 2 2 exact-strings ] unit-test
[ t ] [ "ab" 4 strings [ >string ] map "abab" swap member? ] unit-test
[ { { } { 1 } { 2 } { 1 2 } } ] [ { 1 2 } power-set ] unit-test
