USING: accessors arrays assocs combinators.short-circuit
compiler.cfg.dependence compiler.cfg.instructions compiler.cfg.registers fry
grouping kernel math namespaces random sequences tools.test vectors ;
IN: compiler.cfg.dependence.tests
FROM: sets => members set= ;

{ t } [
    V{ T{ ##inc-r } T{ ##inc-d } } [ <node> ] map dup
    build-dependence-graph
    first2 [ insn>> ##inc-r? ] [ insn>> ##inc-d? ] bi* and
] unit-test

{ 0 } [
    T{ ##load-tagged } <node> calculate-registers
] unit-test

: 2node-tree ( -- tree )
    2 [ node new ] replicate first2 over attach-parent ;

! 0 -> 1 -> 2
: 3node-tree ( -- tree )
    3 [ node new ] replicate first3
    over attach-parent over attach-parent ;

! Verification tests
ERROR: node-missing-parent trees nodes ;
ERROR: node-missing-children trees nodes ;

: flatten-tree ( node -- nodes )
    [ children>> [ flatten-tree ] map concat ] keep suffix ;

: verify-children ( nodes trees -- )
    2dup [ flatten-tree ] map concat
    { [ [ length ] same? ] [ set= ] } 2&&
    [ 2drop ] [ node-missing-children ] if ;

{ } [
    2node-tree [ flatten-tree ] keep 1array verify-children
] unit-test

[
    2node-tree 1array { } verify-children
] [ node-missing-children? ] must-fail-with

{ 1 } [ 3node-tree children>> length ] unit-test

{ 3 } [ 3node-tree flatten-tree length ] unit-test

[
    { } 3node-tree 1array verify-children
] [ node-missing-children? ] must-fail-with

[
    { } 3node-tree 1array verify-children
] [ node-missing-children? ] must-fail-with

! select-parent tests
{ f } [
    { } select-parent
] unit-test

: dummy-node ( number -- node )
    ##allot new swap >>insn# node new swap >>insn ;

! No parent because it has +control+
{ f } [
    10 20 [ dummy-node ] bi@ 2array { +data+ +control+ } zip select-parent
] unit-test

! Yes parent
{ 10 } [
    10 dummy-node +data+ 2array 1array select-parent insn>> insn#>>
] unit-test

{ 0 } [
    20 iota [ dummy-node +data+ 2array ] map randomize
    select-parent insn>> insn#>>
] unit-test

! Shared with compiler.cfg.scheduling
: test-not-in-order ( -- nodes )
    V{
        ##load-tagged
        ##allot
        ##set-slot-imm
        ##load-reference
        ##allot
        ##set-slot-imm
        ##set-slot-imm
        ##set-slot-imm
        ##replace
    } [ [ new ] [ 2 * ] bi* >>insn# ] map-index ;

! Another
{ t } [
    100 [
        test-not-in-order [ <node> ] map [ build-dependence-graph ] keep
        [ precedes>> select-parent ] map [ dup [ insn>> ] when ] map
    ] replicate all-equal?
] unit-test

{ t } [
    100 [
        test-not-in-order [ <node> ] map dup dup
        build-dependence-graph [ maybe-set-parent ] each
        [ children>> length ] map
    ] replicate all-equal?
] unit-test

: test-some-kind-of-dep ( -- insns )
    ! 0 node-number set-global
    V{
        T{ ##peek { dst 275 } { loc D 2 } }
        T{ ##load-tagged { dst 277 } { val 0 } }
        T{ ##allot
           { dst 280 }
           { size 16 }
           { class-of array }
           { temp 6 }
        }
        T{ ##set-slot-imm
           { src 277 }
           { obj 280 }
           { slot 1 }
           { tag 2 }
        }
        T{ ##load-reference
           { dst 283 }
           { obj
             {
                 vector
                 2
                 1
                 tuple
                 258304024774
                 vector
                 8390923745423
             }
           }
        }
        T{ ##allot
           { dst 285 }
           { size 32 }
           { class-of tuple }
           { temp 12 }
        }
        T{ ##set-slot-imm
           { src 283 }
           { obj 285 }
           { slot 1 }
           { tag 7 }
        }
        T{ ##set-slot-imm
           { src 280 }
           { obj 285 }
           { slot 2 }
           { tag 7 }
        }
    } [ 2 * >>insn# ] map-index [ <node> ] map ;

{ 7 } [
    test-not-in-order [ <node> ] map
    dup build-dependence-graph
    dup build-fan-in-trees
    [ parent-index>> -1/0. = ] count
] unit-test

{ V{ 0 6 12 14 } } [
    test-some-kind-of-dep
    dup build-dependence-graph
    dup build-fan-in-trees
    [ parent-index>> -1/0. = ] filter [ insn>> insn#>> ] map
] unit-test
