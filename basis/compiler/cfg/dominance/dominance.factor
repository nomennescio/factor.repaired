! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators sets math fry kernel math.order
dlists deques namespaces sequences sorting compiler.cfg.rpo ;
IN: compiler.cfg.dominance

! Reference:

! A Simple, Fast Dominance Algorithm
! Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy
! http://www.cs.rice.edu/~keith/EMBED/dom.pdf

! Also, a nice overview is given in these lecture notes:
! http://llvm.cs.uiuc.edu/~vadve/CS526/public_html/Notes/4ssa.4up.pdf

<PRIVATE

! Maps bb -> idom(bb)
SYMBOL: dom-parents

PRIVATE>

: dom-parent ( bb -- bb' ) dom-parents get at ;

<PRIVATE

: set-idom ( idom bb -- changed? )
    dom-parents get maybe-set-at ;

: intersect ( finger1 finger2 -- bb )
    2dup [ number>> ] compare {
        { +gt+ [ [ dom-parent ] dip intersect ] }
        { +lt+ [ dom-parent intersect ] }
        [ 2drop ]
    } case ;

: compute-idom ( bb -- idom )
    predecessors>> [ dom-parent ] filter
    [ ] [ intersect ] map-reduce ;

: iterate ( rpo -- changed? )
    [ [ compute-idom ] keep set-idom ] map [ ] any? ;

: compute-dom-parents ( cfg -- )
    H{ } clone dom-parents set
    reverse-post-order
    unclip dup set-idom drop '[ _ iterate ] loop ;

! Maps bb -> {bb' | idom(bb') = bb}
SYMBOL: dom-childrens

PRIVATE>

: dom-children ( bb -- seq ) dom-childrens get at ;

<PRIVATE

: compute-dom-children ( -- )
    dom-parents get H{ } clone
    [ '[ 2dup eq? [ 2drop ] [ _ push-at ] if ] assoc-each ] keep
    dom-childrens set ;

PRIVATE>

: compute-dominance ( cfg -- )
    compute-dom-parents compute-dom-children ;

<PRIVATE

! Maps bb -> DF(bb)
SYMBOL: dom-frontiers

: compute-dom-frontier ( bb pred -- )
    2dup [ dom-parent ] dip eq? [ 2drop ] [
        [ dom-frontiers get conjoin-at ]
        [ dom-parent compute-dom-frontier ] 2bi
    ] if ;

PRIVATE>

: dom-frontier ( bb -- set ) dom-frontiers get at keys ;

: compute-dom-frontiers ( cfg -- )
    H{ } clone dom-frontiers set
    [
        dup predecessors>> dup length 2 >= [
            [ compute-dom-frontier ] with each
        ] [ 2drop ] if
    ] each-basic-block ;

<PRIVATE

SYMBOLS: work-list visited ;

: add-to-work-list ( bb -- )
    dom-frontier work-list get push-all-front ;

: iterated-dom-frontier-step ( bb -- )
    dup visited get key? [ drop ] [
        [ visited get conjoin ]
        [ add-to-work-list ] bi
    ] if ;

PRIVATE>

: iterated-dom-frontier ( bbs -- bbs' )
    [
        <dlist> work-list set
        H{ } clone visited set
        [ add-to-work-list ] each
        work-list get [ iterated-dom-frontier-step ] slurp-deque
        visited get keys
    ] with-scope ;

<PRIVATE

SYMBOLS: preorder maxpreorder ;

PRIVATE>

: pre-of ( bb -- n ) [ preorder get at ] [ -1/0. ] if* ;

: maxpre-of ( bb -- n ) [ maxpreorder get at ] [ 1/0. ] if* ;

<PRIVATE

: (compute-dfs) ( n bb -- n )
    [ 1 + ] dip
    [ dupd preorder get set-at ]
    [ dom-children [ (compute-dfs) ] each ]
    [ dupd maxpreorder get set-at ]
    tri ;

PRIVATE>

: compute-dfs ( cfg -- )
    H{ } clone preorder set
    H{ } clone maxpreorder set
    [ 0 ] dip entry>> (compute-dfs) drop ;

: dominates? ( bb1 bb2 -- ? )
    ! Requires DFS to be computed
    swap [ pre-of ] [ [ pre-of ] [ maxpre-of ] bi ] bi* between? ;