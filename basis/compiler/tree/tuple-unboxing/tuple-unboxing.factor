! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs accessors kernel combinators
classes.algebra sequences sequences.deep slots.private
classes.tuple.private math math.private arrays
stack-checker.branches
compiler.tree
compiler.tree.intrinsics
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.escape-analysis.simple
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.tuple-unboxing

! This pass must run after escape analysis

GENERIC: unbox-tuples* ( node -- node/nodes )

: unbox-output? ( node -- values )
    out-d>> first unboxed-allocation ;

: (expand-#push) ( object value -- nodes )
    dup unboxed-allocation dup [
        [ object-slots ] [ drop ] [ ] tri*
        [ (expand-#push) ] 2map
    ] [
        drop #push
    ] if ;

: expand-#push ( #push -- nodes )
    [ literal>> ] [ out-d>> first ] bi (expand-#push) ;

M: #push unbox-tuples* ( #push -- nodes )
    dup unbox-output? [ expand-#push ] when ;

: unbox-<tuple-boa> ( #call -- nodes )
    dup unbox-output? [ in-d>> 1 tail* #drop ] when ;

: unbox-<complex> ( #call -- nodes )
    dup unbox-output? [ drop { } ] when ;

: (flatten-values) ( values -- values' )
    [ dup unboxed-allocation [ (flatten-values) ] [ ] ?if ] map ;

: flatten-values ( values -- values' )
    (flatten-values) flatten ;

: prepare-slot-access ( #call -- tuple-values outputs slot-values )
    [ in-d>> flatten-values ]
    [ out-d>> flatten-values ]
    [
        out-d>> first slot-accesses get at
        [ slot#>> ] [ value>> ] bi allocation nth
        1array flatten-values
    ] tri ;

: slot-access-shuffle ( tuple-values outputs slot-values -- #shuffle )
    [ drop ] [ zip ] 2bi #shuffle ;

: unbox-slot-access ( #call -- nodes )
    dup out-d>> first unboxed-slot-access? [
        prepare-slot-access slot-access-shuffle
    ] when ;

M: #call unbox-tuples*
    dup word>> {
        { \ <tuple-boa> [ unbox-<tuple-boa> ] }
        { \ <complex> [ unbox-<complex> ] }
        { \ slot [ unbox-slot-access ] }
        [ drop ]
    } case ;

M: #declare unbox-tuples*
    #! We don't look at declarations after propagation anyway.
    f >>declaration ;

M: #copy unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #>r unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-r ;

M: #r> unbox-tuples*
    [ flatten-values ] change-in-r
    [ flatten-values ] change-out-d ;

M: #shuffle unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d
    [ unzip [ flatten-values ] bi@ zip ] change-mapping ;

M: #terminate unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-in-r ;

M: #phi unbox-tuples*
    [ [ flatten-values ] map pad-with-bottom ] change-phi-in-d
    [ flatten-values ] change-out-d ;

M: #recursive unbox-tuples*
    [ label>> [ flatten-values ] change-enter-out drop ]
    [ [ flatten-values ] change-in-d ]
    bi ;

M: #enter-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #call-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #return-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

! These nodes never participate in unboxing
: assert-not-unboxed ( values -- )
    dup array?
    [ [ unboxed-allocation ] contains? ] [ unboxed-allocation ] if
    [ "Unboxing wrong value" throw ] when ;

M: #branch unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #return unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #introduce unbox-tuples* dup out-d>> assert-not-unboxed ;

M: #alien-invoke unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #alien-indirect unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #alien-callback unbox-tuples* ;

: unbox-tuples ( nodes -- nodes ) [ unbox-tuples* ] map-nodes ;
