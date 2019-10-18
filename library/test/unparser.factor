IN: temporary
USE: lists
USE: math
USE: parser
USE: test
USE: unparser
USE: kernel
USE: kernel-internals
USE: io-internals

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" unparse ]
unit-test

[ "\"\\u1234\"" ]
[ "\u1234" unparse ]
unit-test

[ "\"\\e\"" ]
[ "\e" unparse ]
unit-test

[ "1.0" ] [ 1.0 unparse ] unit-test
[ "f" ] [ f unparse ] unit-test
[ "t" ] [ t unparse ] unit-test
[ "car" ] [ \ car unparse ] unit-test
[ "#{ 1/2 2/3 }#" ] [ #{ 1/2 2/3 }# unparse ] unit-test
[ "1267650600228229401496703205376" ] [ 1 100 shift unparse ] unit-test

[ ] [ { 1 2 3 } unparse drop ] unit-test

[ "SBUF\" hello world\"" ] [ SBUF" hello world" unparse ] unit-test
