! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel sets namespaces accessors assocs
arrays combinators continuations columns math vectors
stack-checker.branches
compiler.tree
compiler.tree.def-use
compiler.tree.combinators ;
IN: compiler.tree.checker

! Check some invariants; this can help catch compiler bugs.

ERROR: check-use-error value message ;

: check-use ( value uses -- )
    [ empty? [ "No use" check-use-error ] [ drop ] if ]
    [ all-unique? [ drop ] [ "Uses not all unique" check-use-error ] if ] 2bi ;

: check-def-use ( -- )
    def-use get [ uses>> check-use ] assoc-each ;

GENERIC: check-node* ( node -- )

M: #shuffle check-node*
    [ [ mapping>> values ] [ in-d>> ] bi subset? [ "Bad mapping inputs" throw ] unless ]
    [ [ mapping>> keys ] [ out-d>> ] bi set= [ "Bad mapping outputs" throw ] unless ]
    bi ;

: check-lengths ( seq -- )
    [ length ] map all-equal? [ "Bad lengths" throw ] unless ;

M: #copy check-node* inputs/outputs 2array check-lengths ;

M: #>r check-node* inputs/outputs 2array check-lengths ;

M: #r> check-node* inputs/outputs 2array check-lengths ;

M: #return-recursive check-node* inputs/outputs 2array check-lengths ;

M: #phi check-node*
    [ [ phi-in-d>> <flipped> ] [ out-d>> ] bi 2array check-lengths ]
    [ phi-in-d>> check-lengths ]
    bi ;

M: #enter-recursive check-node*
    [ [ in-d>> ] [ out-d>> ] bi 2array check-lengths ]
    [ recursive-phi-in check-lengths ]
    bi ;

M: #push check-node*
    out-d>> length 1 = [ "Bad #push" throw ] unless ;

M: node check-node* drop ;

: check-values ( seq -- )
    [ integer? ] all? [ "Bad values" throw ] unless ;

ERROR: check-node-error node error ;

: check-node ( node -- )
    [
        [ node-uses-values check-values ]
        [ node-defs-values check-values ]
        [ check-node* ]
        tri
    ] [ check-node-error ] recover ;

SYMBOL: datastack
SYMBOL: retainstack

GENERIC: check-stack-flow* ( node -- )

: (check-stack-flow) ( nodes -- )
    [ check-stack-flow* ] each ;

: init-stack-flow ( -- )
    V{ } clone datastack set
    V{ } clone retainstack set ;

: check-stack-flow ( nodes -- )
    [
        init-stack-flow
        (check-stack-flow)
    ] with-scope ;

: check-inputs ( seq var -- )
    [ dup length ] dip [ swap cut* swap ] change
    sequence= [ "Bad stack flow" throw ] unless ;

: check-in-d ( node -- )
    in-d>> datastack check-inputs ;

: check-in-r ( node -- )
    in-r>> retainstack check-inputs ;

: check-outputs ( node var -- )
    get push-all ;

: check-out-d ( node -- )
    out-d>> datastack check-outputs ;

: check-out-r ( node -- )
    out-r>> retainstack check-outputs ;

M: #introduce check-stack-flow* check-out-d ;

M: #push check-stack-flow* check-out-d ;

M: #call check-stack-flow* [ check-in-d ] [ check-out-d ] bi ;

M: #shuffle check-stack-flow* [ check-in-d ] [ check-out-d ] bi ;

M: #>r check-stack-flow* [ check-in-d ] [ check-out-r ] bi ;

M: #r> check-stack-flow* [ check-in-r ] [ check-out-d ] bi ;

: assert-datastack-empty ( -- )
    datastack get empty? [ "Data stack not empty" throw ] unless ;

: assert-retainstack-empty ( -- )
    retainstack get empty? [ "Retain stack not empty" throw ] unless ;

: must-consume-all ( -- )
    assert-datastack-empty assert-retainstack-empty ;

M: #return check-stack-flow*
    check-in-d must-consume-all ;

M: #enter-recursive check-stack-flow*
    check-out-d ;

M: #return-recursive check-stack-flow*
    [ check-in-d ] [ check-out-d ] bi ;

M: #call-recursive check-stack-flow*
    [ check-in-d ] [ check-out-d ] bi ;

: check-terminate-in-d ( #terminate -- )
    in-d>> datastack get over length tail* sequence=
    [ "Bad terminate data stack" throw ] unless ;

: check-terminate-in-r ( #terminate -- )
    in-r>> retainstack get over length tail* sequence=
    [ "Bad terminate retain stack" throw ] unless ;

M: #terminate check-stack-flow*
    [ check-terminate-in-d ] [ check-terminate-in-r ] bi ;

SYMBOL: branch-out

: check-branch ( nodes -- stack )
    [
        datastack [ clone ] change
        V{ } clone retainstack set
        (check-stack-flow)
        assert-retainstack-empty
        datastack get
    ] with-scope ;

M: #branch check-stack-flow*
    [ check-in-d ]
    [ children>> [ check-branch ] map branch-out set ]
    bi ;

: check-phi-in ( #phi -- )
    phi-in-d>> branch-out get [
        over [ +bottom+ eq? ] all? [
            2drop
        ] [
            over length tail* sequence= [
                "Branch outputs don't match phi inputs"
                throw
            ] unless
        ] if
    ] 2each ;

: set-phi-datastack ( #phi -- )
    phi-in-d>> first length
    branch-out get [ [ +bottom+ eq? ] all? not ] find nip
    dup [ swap head* >vector ] [ 2drop V{ } clone ] if datastack set ;

M: #phi check-stack-flow*
    [ check-phi-in ] [ set-phi-datastack ] [ check-out-d ] tri ;

M: #recursive check-stack-flow*
    [
        init-stack-flow
        child>> (check-stack-flow)
        datastack get
    ] with-scope
    datastack set ;

M: #copy check-stack-flow* [ check-in-d ] [ check-out-d ] bi ;

M: #alien-invoke check-stack-flow* [ check-in-d ] [ check-out-d ] bi ;

M: #alien-indirect check-stack-flow* [ check-in-d ] [ check-out-d ] bi ;

M: #alien-callback check-stack-flow* drop ;

M: #declare check-stack-flow* drop ;

: check-nodes ( nodes -- )
    compute-def-use
    check-def-use
    [ [ check-node ] each-node ]
    [ check-stack-flow ]
    bi ;
