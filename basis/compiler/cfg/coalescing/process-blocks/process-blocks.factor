! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math math.order arrays
namespaces sequences sorting sets combinators combinators.short-circuit
dlists deques make
compiler.cfg.def-use
compiler.cfg.instructions
compiler.cfg.liveness
compiler.cfg.dominance
compiler.cfg.coalescing.state
compiler.cfg.coalescing.forest
compiler.cfg.coalescing.interference ;
IN: compiler.cfg.coalescing.process-blocks

! phi-union maps a vreg to the predecessor block
! that carries it to the phi node's block

! unioned-blocks is a set of bb's which defined
! the source vregs above
SYMBOLS: phi-union unioned-blocks ;

:: operand-live-into-phi-node's-block? ( bb src dst -- ? )
    src bb live-in key? ;

:: phi-node-is-live-out-of-operand's-block? ( bb src dst -- ? )
    dst src def-of live-out key? ;

:: operand-is-phi-node-and-live-into-operand's-block? ( bb src dst -- ? )
    { [ src insn-of ##phi? ] [ src src def-of live-in key? ] } 0&& ;

:: operand-being-renamed? ( bb src dst -- ? )
    src processed-names get key? ;

:: two-operands-in-same-block? ( bb src dst -- ? )
    src def-of unioned-blocks get key? ;

: trivial-interference? ( bb src dst -- ? )
    {
        [ operand-live-into-phi-node's-block? ]
        [ phi-node-is-live-out-of-operand's-block? ]
        [ operand-is-phi-node-and-live-into-operand's-block? ]
        [ operand-being-renamed? ]
        [ two-operands-in-same-block? ]
    } 3|| ;

: don't-coalesce ( bb src dst -- )
    2nip processed-name ;

:: trivial-interference ( bb src dst -- )
    dst src bb waiting-for push-at
    src used-by-another get push ;

:: add-to-renaming-set ( bb src dst -- )
    bb src phi-union get set-at
    src def-of unioned-blocks get conjoin ;

: process-phi-operand ( bb src dst -- )
    {
        { [ 2dup eq? ] [ don't-coalesce ] }
        { [ 3dup trivial-interference? ] [ trivial-interference ] }
        [ add-to-renaming-set ]
    } cond ;

SYMBOLS: visited work-list ;

: node-is-live-in-of-child? ( node child -- ? )
    [ vreg>> ] [ bb>> live-in ] bi* key? ;

: node-is-live-out-of-child? ( node child -- ? )
    [ vreg>> ] [ bb>> live-out ] bi* key? ;

:: insert-copy ( bb src dst -- )
    bb src dst trivial-interference
    src phi-union get delete-at ;

:: insert-copy-for-parent ( bb src node dst -- )
    src node vreg>> eq? [ bb src dst insert-copy ] when ;

: insert-copies-for-parent ( ##phi node child -- )
    drop
    [ [ inputs>> ] [ dst>> ] bi ] dip
    '[ _ _ insert-copy-for-parent ] assoc-each ;

: defined-in-same-block? ( node child -- ? ) [ bb>> ] bi@ eq? ;

: add-interference ( ##phi node child -- )
    [ vreg>> ] bi@ 2array , drop ;

: add-to-work-list ( child -- inserted? )
    dup visited get key? [ drop f ] [ work-list get push-back t ] if ;

: process-df-child ( ##phi node child -- inserted? )
    [
        {
            { [ 2dup node-is-live-out-of-child? ] [ insert-copies-for-parent ] }
            { [ 2dup node-is-live-in-of-child? ] [ add-interference ] }
            { [ 2dup defined-in-same-block? ] [ add-interference ] }
            [ 3drop ]
        } cond
    ]
    [ add-to-work-list ]
    bi ;

: process-df-node ( ##phi node -- )
    dup visited get conjoin
    dup children>> [ process-df-child ] with with map
    [ ] any? [ work-list get pop-back* ] unless ;

: process-df-nodes ( ##phi work-list -- )
    dup deque-empty? [ 2drop ] [
        [ peek-back process-df-node ]
        [ process-df-nodes ]
        2bi
    ] if ;

: process-phi-union ( ##phi dom-forest -- )
    H{ } clone visited set
    <dlist> [ push-all-front ] keep
    [ work-list set ] [ process-df-nodes ] bi ;

:: add-local-interferences ( bb ##phi -- )
    ! bb contains the phi node. If the input is defined in the same
    ! block as the phi node, we have to check for interference.
    ! This can only happen if the value is carried by a back edge.
    phi-union get [
        drop dup def-of bb eq?
        [ ##phi dst>> 2array , ] [ drop ] if
    ] assoc-each ;

: compute-local-interferences ( bb ##phi -- pairs )
    [
        [ phi-union get keys compute-dom-forest process-phi-union drop ]
        [ add-local-interferences ]
        2bi
    ] { } make ;

:: insert-copies-for-interference ( ##phi src -- )
    ##phi inputs>> [| bb src' |
        src src' eq? [ bb src ##phi dst>> insert-copy ] when
    ] assoc-each ;

: process-local-interferences ( ##phi pairs -- )
    [
        first2 2dup interferes?
        [ drop insert-copies-for-interference ] [ 3drop ] if
    ] with each ;

: add-renaming-set ( ##phi -- )
    dst>> phi-union get swap renaming-sets get set-at
    phi-union get [ drop processed-name ] assoc-each ;

:: process-phi ( bb ##phi -- )
    H{ } clone phi-union set
    H{ } clone unioned-blocks set
    ##phi inputs>> ##phi dst>> '[ _ process-phi-operand ] assoc-each
    ##phi bb ##phi compute-local-interferences process-local-interferences
    ##phi add-renaming-set ;

: process-block ( bb -- )
    dup instructions>>
    [ dup ##phi? [ process-phi t ] [ 2drop f ] if ] with all? drop ;
