USING: destructors kernel tools.test continuations ;
IN: destructors.tests

TUPLE: dummy-obj destroyed? ;

: <dummy-obj> dummy-obj new ;

TUPLE: dummy-destructor obj ;

C: <dummy-destructor> dummy-destructor

M: dummy-destructor dispose ( obj -- )
    dummy-destructor-obj t swap set-dummy-obj-destroyed? ;

: destroy-always
    <dummy-destructor> &dispose drop ;

: destroy-later
    <dummy-destructor> |dispose drop ;

[ t ] [
    [
        <dummy-obj> dup destroy-always
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ f ] [
    [
        <dummy-obj> dup destroy-later
    ] with-destructors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-always
            "foo" throw
        ] with-destructors
    ] ignore-errors dummy-obj-destroyed? 
] unit-test

[ t ] [
    <dummy-obj> [
        [
            dup destroy-later
            "foo" throw
        ] with-destructors
    ] ignore-errors dummy-obj-destroyed? 
] unit-test

