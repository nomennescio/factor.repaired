! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry namespaces sequences math accessors kernel arrays
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
    >>introductions drop ;

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

! Eliminate introductions
SYMBOL: introduction-stack

: fixup-enter-recursive ( introductions recursive -- )
    [ child>> first ] [ in-d>> ] bi >>in-d
    [ append ] change-out-d
    drop ;

GENERIC: eliminate-introductions* ( node -- node' )

: pop-introduction ( -- value )
    introduction-stack [ unclip-last swap ] change ;

: pop-introductions ( n -- values )
    introduction-stack [ swap cut* swap ] change ;

M: #introduce eliminate-introductions*
    out-d>> [ length pop-introductions ] keep #copy ;

SYMBOL: remaining-introductions

M: #branch eliminate-introductions*
    dup children>> [
        [
            [ eliminate-introductions* ] change-each
            introduction-stack get
        ] with-scope
    ] map
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

M: #phi eliminate-introductions*
    remaining-introductions get swap dup terminated>>
    '[ , eliminate-phi-introductions ] change-phi-in-d ;

M: node eliminate-introductions* ;

: eliminate-introductions ( nodes introductions -- nodes )
    introduction-stack [
        [ eliminate-introductions* ] map
    ] with-variable ;

: eliminate-toplevel-introductions ( nodes -- nodes' )
    dup count-introductions make-values
    [ eliminate-introductions ] [ nip #introduce ] 2bi
    prefix ;

: eliminate-recursive-introductions ( recursive n -- )
    make-values
    [ swap fixup-enter-recursive ]
    [ '[ , eliminate-introductions ] change-child drop ]
    2bi ;

! Normalize
GENERIC: normalize* ( node -- node' )

M: #recursive normalize*
    dup dup label>> introductions>>
    eliminate-recursive-introductions ;

M: #enter-recursive normalize*
    dup [ label>> ] keep >>enter-recursive drop
    dup [ label>> ] [ out-d>> ] bi >>enter-out drop ;

: unchanged-underneath ( #call-recursive -- n )
    [ out-d>> length ] [ label>> return>> in-d>> length ] bi - ;

M: #call-recursive normalize*
    dup unchanged-underneath
    [ [ [ in-d>> ] [ out-d>> ] bi ] [ '[ , head ] ] bi* bi@ #copy ]
    [ '[ , tail ] [ change-in-d ] [ change-out-d ] bi ]
    2bi 2array ;

M: node normalize* ;

: normalize ( nodes -- nodes' )
    dup [ collect-label-info ] each-node
    eliminate-toplevel-introductions
    [ normalize* ] map-nodes ;
