! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry namespaces sequences math accessors kernel arrays
combinators sequences.deep assocs
stack-checker.backend
stack-checker.branches
stack-checker.inlining
compiler.tree
compiler.tree.combinators ;
IN: compiler.tree.normalization

! A transform pass done before optimization can begin to
! fix up some oddities in the tree output by the stack checker:
!
! - We rewrite the code so that all #introduce nodes are
! replaced with a single one, at the beginning of a program.
! This simplifies subsequent analysis.
!
! - We collect #return-recursive and #call-recursive nodes and
! store them in the #recursive's label slot.
!
! - We normalize #call-recursive as follows. The stack checker
! says that the inputs of a #call-recursive are the entire stack
! at the time of the call. This is a conservative estimate; we
! don't know the exact number of stack values it touches until
! the #return-recursive node has been visited, because of row
! polymorphism. So in the normalize pass, we split a
! #call-recursive into a #copy of the unchanged values and a
! #call-recursive with trimmed inputs and outputs.

! Collect introductions
SYMBOL: introductions

GENERIC: count-introductions* ( node -- )

: count-introductions ( nodes -- n )
    #! Note: we use each, not each-node, since the #branch
    #! method recurses into children directly and we don't
    #! recurse into #recursive at all.
    [
        0 introductions set
        [ count-introductions* ] each
        introductions get
    ] with-scope ;

: introductions+ ( n -- ) introductions [ + ] change ;

M: #introduce count-introductions*
    out-d>> length introductions+ ;

M: #branch count-introductions*
    children>>
    [ count-introductions ] map supremum
    introductions+ ;

M: #recursive count-introductions*
    [ label>> ] [ child>> count-introductions ] bi
    >>introductions
    drop ;

M: node count-introductions* drop ;

! Collect label info
GENERIC: collect-label-info ( node -- )

M: #return-recursive collect-label-info
    dup label>> (>>return) ;

M: #call-recursive collect-label-info
    dup label>> calls>> push ;

M: #recursive collect-label-info
    label>> V{ } clone >>calls drop ;

M: node collect-label-info drop ;

! Normalize
GENERIC: normalize* ( node -- node' )

SYMBOL: introduction-stack

: pop-introduction ( -- value )
    introduction-stack [ unclip-last swap ] change ;

: pop-introductions ( n -- values )
    introduction-stack [ swap cut* swap ] change ;

M: #introduce normalize*
    out-d>> [ length pop-introductions ] keep #copy ;

SYMBOL: remaining-introductions

M: #branch normalize*
    [
        [
            [
                [ normalize* ] map flatten
                introduction-stack get
                2array
            ] with-scope
        ] map unzip swap
    ] change-children swap
    [ remaining-introductions set ]
    [ [ length ] map infimum introduction-stack [ swap head ] change ]
    bi ;

: eliminate-phi-introductions ( introductions seq terminated -- seq' )
    [
        [ nip ] [
            dup [ +bottom+ eq? ] left-trim
            [ [ length ] bi@ - tail* ] keep append
        ] if
    ] 3map ;

M: #phi normalize*
    remaining-introductions get swap dup terminated>>
    '[ , eliminate-phi-introductions ] change-phi-in-d ;

: (normalize) ( nodes introductions -- nodes )
    introduction-stack [
        [ normalize* ] map flatten
    ] with-variable ;

M: #recursive normalize*
    dup label>> introductions>>
    [ drop [ child>> first ] [ in-d>> ] bi >>in-d drop ]
    [ make-values '[ , (normalize) ] change-child ]
    2bi ;

M: #enter-recursive normalize*
    [ introduction-stack get prepend ] change-out-d
    dup [ label>> ] keep >>enter-recursive drop
    dup [ label>> ] [ out-d>> ] bi >>enter-out drop ;

: unchanged-underneath ( #call-recursive -- n )
    [ out-d>> length ] [ label>> return>> in-d>> length ] bi - ;

: call<return ( #call-recursive n -- nodes )
    neg dup make-values [
        [ pop-introductions '[ , prepend ] change-in-d ]
        [ '[ , prepend ] change-out-d ]
        bi*
    ] [ introduction-stack [ prepend ] change ] bi ;

: call>return ( #call-recursive n -- nodes )
    [ [ [ in-d>> ] [ out-d>> ] bi ] [ '[ , head ] ] bi* bi@ #copy ]
    [ '[ , tail ] [ change-in-d ] [ change-out-d ] bi ]
    2bi 2array ;

M: #call-recursive normalize*
    dup unchanged-underneath {
        { [ dup 0 < ] [ call<return ] }
        { [ dup 0 = ] [ drop ] }
        { [ dup 0 > ] [ call>return ] }
    } cond ;

M: node normalize* ;

: normalize ( nodes -- nodes' )
    dup [ collect-label-info ] each-node
    dup count-introductions make-values
    [ (normalize) ] [ nip #introduce ] 2bi
    prefix ;
