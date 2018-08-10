! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays effects kernel math namespaces sequences
stack-checker.errors stack-checker.values stack-checker.visitor ;
IN: stack-checker.state

SYMBOL: terminated?

SYMBOL: input-count
SYMBOL: inner-d-index

DEFER: commit-literals

SYMBOL: (meta-d)
SYMBOL: (meta-r)

: meta-d ( -- stack ) commit-literals (meta-d) get ;

: meta-r ( -- stack ) (meta-r) get ;

SYMBOL: literals

: (push-literal) ( obj -- )
    dup <literal> make-known
    [ nip (meta-d) get push ] [ push#, ] 2bi ;

: commit-literals ( -- )
    literals get [ [ (push-literal) ] each ] [ delete-all ] bi ;

: current-stack-height ( -- n )
    meta-d length input-count get - ;

: current-effect ( -- effect )
    input-count get "x" <array>
    meta-d length "x" <array>
    terminated? get <terminated-effect> ;

: check-effect ( required-effect -- )
    [ current-effect ] dip 2dup effect<= [ 2drop ] [ effect-error ] if ;

: init-inference ( -- )
    terminated? off
    V{ } clone (meta-d) set
    V{ } clone literals set
    0 input-count set
    0 inner-d-index set ;
