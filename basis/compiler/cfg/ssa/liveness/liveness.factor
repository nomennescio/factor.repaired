! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences assocs accessors
namespaces fry math sets combinators locals
compiler.cfg.rpo
compiler.cfg.dominance
compiler.cfg.def-use
compiler.cfg.instructions ;
IN: compiler.cfg.ssa.liveness

! Liveness checking on SSA IR, as described in
! "Fast Liveness Checking for SSA-Form Programs", Sebastian Hack et al.
! http://hal.archives-ouvertes.fr/docs/00/19/22/19/PDF/fast_liveness.pdf

<PRIVATE

! The sets T_q and R_q are described there
SYMBOL: T_q-sets
SYMBOL: R_q-sets

! Targets of back edges
SYMBOL: back-edge-targets

! hashtable of nodes => sets of vregs, where the vregs are inputs
! to phi nodes in a successor node
SYMBOL: phi-outs

: T_q ( q -- T_q )
    T_q-sets get at ;

: R_q ( q -- R_q )
    R_q-sets get at ;

: back-edge-target? ( block -- ? )
    back-edge-targets get key? ;

: phi-out? ( vreg node -- ? )
    phi-outs get at key? ;

: next-R_q ( q -- R_q )
    [ ] [ successors>> ] [ number>> ] tri
    '[ number>> _ >= ] filter
    [ R_q ] map assoc-combine
    [ conjoin ] keep ;

: set-R_q ( q -- )
    [ next-R_q ] keep R_q-sets get set-at ;

: set-back-edges ( q -- )
    [ successors>> ] [ number>> ] bi '[
        dup number>> _ < 
        [ back-edge-targets get conjoin ] [ drop ] if
    ] each ;

: set-phi-out ( block vreg -- )
    swap phi-outs get [ drop H{ } clone ] cache conjoin ;

: set-phi-outs ( q -- )
    instructions>> [
        dup ##phi? [
            inputs>> [ set-phi-out ] assoc-each
        ] [ drop ] if
    ] each ;

: init-R_q ( -- )
    H{ } clone R_q-sets set
    H{ } clone back-edge-targets set
    H{ } clone phi-outs set ;

: compute-R_q ( cfg -- )
    init-R_q
    post-order [
        [ set-R_q ]
        [ set-back-edges ]
        [ set-phi-outs ] tri
    ] each ;

! This algorithm for computing T_q uses equation (1)
! but not the faster algorithm described in the paper

: back-edges-from ( q -- edges )
    R_q keys [
        [ successors>> ] [ number>> ] bi
        '[ number>> _ < ] filter
    ] gather ;

: T^_q ( q -- T^_q )
    [ back-edges-from ] [ R_q ] bi
    '[ _ key? not ] filter ;

: next-T_q ( q -- T_q )
    dup dup T^_q [ next-T_q keys ] map 
    concat unique [ conjoin ] keep
    [ swap T_q-sets get set-at ] keep ;

: compute-T_q ( cfg -- )
    H{ } T_q-sets set
    [ next-T_q drop ] each-basic-block ;

:: compute-phi-uses ( cfg -- )
    ! Here, a phi node uses its argument in the block that it comes from.
    H{ } clone :> use
    cfg [| block |
        block instructions>> [
            dup ##phi?
            [ inputs>> [ use conjoin-at ] assoc-each ]
            [ uses-vregs [ block swap use conjoin-at ] each ]
            if
        ] each
    ] each-basic-block
    use [ keys ] assoc-map uses set ;

PRIVATE>

: precompute-liveness ( cfg -- )
    ! The first three of these depend only on the graph
    ! structure of the CFG, and don't need to be recomputed
    ! if that doesn't change
    {
        [ compute-R_q ]
        [ compute-T_q ]
        [ compute-dominance ]
        [ compute-defs ]
        [ compute-phi-uses ]
    } cleave ;

<PRIVATE

! This doesn't take advantage of ordering T_q,a so you 
! only have to check one if the CFG is reducible.
! It should be changed to be more efficient.

: only? ( seq obj -- ? )
    '[ _ eq? ] all? ;

: strictly-dominates? ( bb1 bb2 -- ? )
    [ dominates? ] [ eq? not ] 2bi and ;

: T_q,a ( a q -- T_q,a )
    ! This could take advantage of the structure of dominance,
    ! but probably I'll replace it with the algorithm that works
    ! on reducible CFGs anyway
    T_q keys swap def-of 
    [ '[ _ swap strictly-dominates? ] filter ] when* ;

: live? ( vreg node quot -- ? )
    [ [ T_q,a ] [ drop uses-of ] 2bi ] dip
    '[ [ R_q keys _ ] keep @ intersects? ] any? ; inline

PRIVATE>

: live-in? ( vreg node -- ? )
    [ drop ] live? ;

<PRIVATE

: (live-out?) ( vreg node -- ? )
    dup dup dup '[
        _ = _ back-edge-target? not and
        [ _ swap remove ] when
    ] live? ;

PRIVATE>

:: live-out? ( vreg node -- ? )
    [let | def [ vreg def-of ] |
        {
            { [ node def eq? ] [ vreg uses-of def only? not ] }
            { [ vreg node phi-out? ] [ t ] }
            { [ def node strictly-dominates? ] [ vreg node (live-out?) ] }
            [ f ]
        } cond
    ] ;
