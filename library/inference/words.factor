! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: inference
USE: errors
USE: generic
USE: interpreter
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings
USE: vectors
USE: words
USE: hashtables
USE: parser
USE: prettyprint

: with-dataflow ( param op [[ in# out# ]] quot -- )
    #! Take input parameters, execute quotation, take output
    #! parameters, add node. The quotation is called with the
    #! stack effect.
    >r dup car ensure-d
    >r dataflow, r> r> rot
    [ pick car swap [ length 0 node-inputs ] bind ] keep
    pick >r >r nip call r> r> cdr car swap
    [ length 0 node-outputs ] bind ; inline

: consume-d ( typelist -- )
    [ pop-d 2drop ] each ;

: produce-d ( typelist -- )
    [ <computed> push-d ] each ;

: (consume/produce) ( param op effect )
    dup >r -rot r>
    [ unswons consume-d car produce-d ] with-dataflow ;

: consume/produce ( word [ in-types out-types ] -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    #call swap (consume/produce) ;

: apply-effect ( word [ in-types out-types ] -- )
    #! If a word does not have special inference behavior, we
    #! either execute the word in the meta interpreter (if it is
    #! side-effect-free and all parameters are literal), or
    #! simply apply its stack effect to the meta-interpreter.
    over "infer" word-property [
        swap car ensure-d call drop
    ] [
        consume/produce
    ] ifte* ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name cat2 throw ;

: with-block ( word label quot -- node )
    #! Execute a quotation with the word on the stack, and add
    #! its dataflow contribution to a new block node in the IR.
    over [
        >r
        dupd cons
        recursive-state cons@
        r> call
    ] (with-block) ;

: recursive? ( word -- ? )
    dup word-parameter tree-contains? ;

: inline-compound ( word -- effect node )
    #! Infer the stack effect of a compound word in the current
    #! inferencer instance. If the word in question is recursive
    #! we infer its stack effect inside a new block.
    gensym [ word-parameter infer-quot effect ] with-block ;

: infer-compound ( word -- effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        recursive-state get init-inference
        dup dup inline-compound drop present-effect
        [ "infer-effect" set-word-property ] keep
    ] with-scope consume/produce ;

GENERIC: (apply-word)

M: compound (apply-word) ( word -- )
    #! Infer a compound word's stack effect.
    dup "inline" word-property [
        inline-compound 2drop
    ] [
        infer-compound
    ] ifte ;

M: promise (apply-word) ( word -- )
    "promise" word-property unit ensure-d ;

M: symbol (apply-word) ( word -- )
    apply-literal ;

: current-word ( -- word )
    #! Push word we're currently inferring effect of.
    recursive-state get car car ;

: check-recursion ( word -- )
    #! If at the location of the recursive call, we're taking
    #! more items from the stack than producing, we have a
    #! diverging recursion. Note that this check is not done for
    #! mutually-recursive words. Generally they should be
    #! avoided.
    current-word = [
        d-in get vector-length
        meta-d get vector-length > [
            current-word word-name " diverges." cat2 throw
        ] when
    ] when ;

: with-recursion ( quot -- )
    [
        inferring-base-case inc
        call
    ] [
        inferring-base-case dec
        rethrow
    ] catch ;

: base-case ( word label -- )
    [
        over inline-compound [
            drop
            [ #call-label ] [ #call ] ?ifte
            node-op set
            node-param set
        ] bind
    ] with-recursion ;

: no-base-case ( word -- )
    word-name " does not have a base case." cat2 throw ;

: recursive-word ( word label -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    inferring-base-case get max-recursion > [
        drop no-base-case
    ] [
        inferring-base-case get max-recursion = [
            base-case
        ] [
            [ drop inline-compound 2drop ] with-recursion
        ] ifte
    ] ifte ;

: apply-word ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        dup check-recursion recursive-word
    ] [
        dup "infer-effect" word-property [
            apply-effect
        ] [
            (apply-word)
        ] ifte*
    ] ifte* ;

: infer-call ( -- )
    [ general-list ] ensure-d
    dataflow-drop,
    gensym dup [
        drop pop-d dup
        value-recursion recursive-state set
        literal-value infer-quot
    ] with-block drop ;

\ call [ infer-call ] "infer" set-word-property

! These hacks will go away soon
\ * [ [ number number ] [ number ] ] "infer-effect" set-word-property
\ - [ [ number number ] [ number ] ] "infer-effect" set-word-property

\ undefined-method t "terminator" set-word-property
\ undefined-method [ [ object word ] [ ] ] "infer-effect" set-word-property
\ not-a-number t "terminator" set-word-property
\ throw t "terminator" set-word-property
