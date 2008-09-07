! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences kernel compiler.tree ;
IN: compiler.generator.iterator

SYMBOL: node-stack

: >node ( cursor -- ) node-stack get push ;
: node> ( -- cursor ) node-stack get pop ;
: node@ ( -- cursor ) node-stack get peek ;
: current-node ( -- node ) node@ first ;
: iterate-next ( -- cursor ) node@ rest-slice ;
: skip-next ( -- next ) node> rest-slice [ first ] [ >node ] bi ;

: iterate-nodes ( cursor quot: ( -- ) -- )
    over empty? [
        2drop
    ] [
        [ swap >node call node> drop ] keep iterate-nodes
    ] if ; inline recursive

: with-node-iterator ( quot -- )
    >r V{ } clone node-stack r> with-variable ; inline

DEFER: (tail-call?)

: tail-phi? ( cursor -- ? )
    [ first #phi? ] [ rest-slice (tail-call?) ] bi and ;

: (tail-call?) ( cursor -- ? )
    [ t ] [
        [ first [ #return? ] [ #terminate? ] bi or ]
        [ tail-phi? ]
        bi or
    ] if-empty ;

: tail-call? ( -- ? )
    node-stack get [
        rest-slice
        [ t ] [
            [ (tail-call?) ]
            [ first #terminate? not ]
            bi and
        ] if-empty
    ] all? ;
