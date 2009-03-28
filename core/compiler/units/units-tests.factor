USING: definitions compiler.units tools.test arrays sequences words kernel
accessors namespaces fry ;
IN: compiler.units.tests

[ [ [ ] define-temp ] with-compilation-unit ] must-infer
[ [ [ ] define-temp ] with-nested-compilation-unit ] must-infer

[ flushed-dependency ] [ f flushed-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ flushed-dependency f strongest-dependency ] unit-test
[ inlined-dependency ] [ flushed-dependency inlined-dependency strongest-dependency ] unit-test
[ inlined-dependency ] [ called-dependency inlined-dependency strongest-dependency ] unit-test
[ flushed-dependency ] [ called-dependency flushed-dependency strongest-dependency ] unit-test
[ called-dependency ] [ called-dependency f strongest-dependency ] unit-test

! Non-optimizing compiler bugs
[ 1 1 ] [
    "A" "B" <word> [ [ 1 ] dip ] >>def dup f 2array 1array modify-code-heap
    1 swap execute
] unit-test

[ "A" "B" ] [
    gensym "a" set
    gensym "b" set
    [
        "a" get [ "A" ] define
        "b" get "a" get '[ _ execute ] define
    ] with-compilation-unit
    "b" get execute
    [
        "a" get [ "B" ] define
    ] with-compilation-unit
    "b" get execute
] unit-test

! Notify observers even if compilation unit did nothing
SINGLETON: observer

observer add-definition-observer

SYMBOL: counter

0 counter set-global

M: observer definitions-changed 2drop global [ counter inc ] bind ;

[ ] with-compilation-unit

[ 1 ] [ counter get-global ] unit-test