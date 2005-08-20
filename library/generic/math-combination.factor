! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors generic hashtables kernel kernel-internals lists
math namespaces sequences words ;

! Math combination for generic dyadic upgrading arithmetic.

: math-priority ( class -- n )
    #! Non-number classes have the highest priority.
    "math-priority" word-prop [ 100 ] unless* ;

: math-class< ( class class -- ? )
    swap math-priority swap math-priority < ;

: math-class-max ( class class -- class )
    [ swap math-class< ] 2keep ? ;

: math-upgrade ( left right -- quot )
    2dup math-class< [
        nip [ \ >r , "coercer" word-prop % \ r> , ] make-list
    ] [
        2dup swap math-class< [
            drop "coercer" word-prop
        ] [
            2drop [ ]
        ] ifte
    ] ifte ;

TUPLE: no-math-method left right generic ;

: no-math-method ( left right generic -- )
    3dup <no-math-method> throw ;

: applicable-method ( generic class -- quot )
    over "methods" word-prop hash [ ] [
        literalize [ no-math-method ] cons
    ] ?ifte ;

: math-method ( word left right -- quot )
    swap type>class swap type>class 2dup and [
        2dup math-upgrade >r
        math-class-max over order min-class applicable-method
        r> swap append
    ] [
        2drop object applicable-method
    ] ifte ;

: math-vtable ( picker quot -- )
    [
        swap , \ tag ,
        [ num-tags swap map % ] make-vector ,
        \ dispatch ,
    ] make-list ; inline

: math-class? ( object -- ? )
    dup word? [ "math-priority" word-prop ] [ drop f ] ifte ;

: math-combination ( word -- vtable )
    \ over [
        dup type>class math-class? [
            \ dup [ >r 2dup r> math-method ] math-vtable
        ] [
            over object applicable-method
        ] ifte nip
    ] math-vtable nip ;

PREDICATE: generic 2generic ( word -- ? )
    "combination" word-prop [ math-combination ] = ;
