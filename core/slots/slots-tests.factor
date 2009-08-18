USING: math accessors slots strings generic.single kernel
tools.test generic words parser eval math.functions ;
IN: slots.tests

TUPLE: r/w-test foo ;

TUPLE: r/o-test { foo read-only } ;

[ r/o-test new 123 >>foo ] [ no-method? ] must-fail-with

TUPLE: decl-test { foo integer } ;

[ decl-test new 1.0 >>foo ] [ bad-slot-value? ] must-fail-with

TUPLE: hello length ;

[ 3 ] [ "xyz" length>> ] unit-test

[ "xyz" 4 >>length ] [ no-method? ] must-fail-with

! Test protocol slots
SLOT: my-protocol-slot-test

TUPLE: protocol-slot-test-tuple x ;

M: protocol-slot-test-tuple my-protocol-slot-test>> x>> sq ;
M: protocol-slot-test-tuple (>>my-protocol-slot-test) [ sqrt ] dip (>>x) ;

[ 9 ] [ T{ protocol-slot-test-tuple { x 3 } } my-protocol-slot-test>> ] unit-test

[ 4.0 ] [
    T{ protocol-slot-test-tuple { x 3 } } clone
    [ 7 + ] change-my-protocol-slot-test x>>
] unit-test
