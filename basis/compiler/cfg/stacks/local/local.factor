! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg.instructions
compiler.cfg.parallel-copy compiler.cfg.registers fry hash-sets kernel
make math math.order namespaces sequences sets ;
IN: compiler.cfg.stacks.local

TUPLE: height-state ds-begin rs-begin ds-inc rs-inc ;

: >loc< ( loc -- n ds? )
    [ n>> ] [ ds-loc? ] bi ;

: ds-height ( height-state -- n )
    [ ds-begin>> ] [ ds-inc>> ] bi + ;

: rs-height ( height-state -- n )
    [ rs-begin>> ] [ rs-inc>> ] bi + ;

: global-loc>local ( loc height-state -- loc' )
    [ clone dup >loc< ] dip swap [ ds-height ] [ rs-height ] if - >>n ;

: inc-stack ( loc -- )
    >loc< height-state get swap
    [ [ + ] change-ds-inc ] [ [ + ] change-rs-inc ] if drop ;

: height-state>insns ( height-state -- insns )
    [ ds-inc>> ds-loc ] [ rs-inc>> rs-loc ] bi [ new swap >>n ] 2bi@ 2array
    [ n>> 0 = ] reject [ ##inc new swap >>loc ] map ;

: reset-incs ( height-state -- )
    dup ds-inc>> '[ _ + ] change-ds-begin
    dup rs-inc>> '[ _ + ] change-rs-begin
    0 >>ds-inc 0 >>rs-inc drop ;

: kill-locations ( begin-height current-height -- seq )
    dupd [-] iota [ swap - ] with map ;

: local-kill-set ( ds-begin rs-begin ds-current rs-current  -- set )
    swapd [ kill-locations ] 2bi@
    [ [ <ds-loc> ] map ] [ [ <rs-loc> ] map ] bi*
    append >hash-set ;

SYMBOLS: locs>vregs local-peek-set replaces ;

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

: replaces>copy-insns ( replaces -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: changes>insns ( replaces height-state -- insns )
    [ replaces>copy-insns ] [ height-state>insns ] bi* append ;

: emit-insns ( replaces state -- )
    building get pop -rot changes>insns % , ;

: peek-loc ( loc -- vreg )
    height-state get global-loc>local
    dup replaces get at
    [ ] [ dup local-peek-set get adjoin loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    height-state get global-loc>local
    replaces get set-at ;

: record-stack-heights ( ds-height rs-height bb -- )
    [ rs-height<< ] keep ds-height<< ;

: compute-local-kill-set ( height-state -- set )
    { [ ds-begin>> ] [ rs-begin>> ] [ ds-height ] [ rs-height ] } cleave
    local-kill-set ;

: begin-local-analysis ( basic-block -- )
    height-state get reset-incs
    height-state get [ ds-height ] [ rs-height ] bi rot record-stack-heights
    HS{ } clone local-peek-set namespaces:set
    H{ } clone replaces namespaces:set ;

: remove-redundant-replaces ( replaces -- replaces' )
    [ [ loc>vreg ] dip = ] assoc-reject ;

: end-local-analysis ( basic-block -- )
    replaces get remove-redundant-replaces
    over kill-block?>> [
        [ height-state get emit-insns ] keep
    ] unless
    keys >hash-set >>replaces
    local-peek-set get >>peeks
    height-state get compute-local-kill-set >>kills drop ;
