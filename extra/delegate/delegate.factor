! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: parser generic kernel classes words slots assocs sequences arrays ;
IN: delegate

: define-protocol ( wordlist protocol -- )
    swap { } like "protocol-words" set-word-prop ;

: PROTOCOL:
    CREATE dup reset-generic dup define-symbol
    parse-definition swap define-protocol ; parsing

PREDICATE: word protocol "protocol-words" word-prop ;

GENERIC: group-words ( group -- words )

M: protocol group-words
    "protocol-words" word-prop ;

M: generic group-words
    1array ;

M: tuple-class group-words
    "slots" word-prop 1 tail ! The first slot is the delegate
    ! 1 tail should be removed when the delegate slot is removed
    dup [ slot-spec-reader ] map
    swap [ slot-spec-writer ] map append ;

: define-consult-method ( word class quot -- )
    pick add spin define-method ;

: define-consult ( class group quot -- )
    >r group-words r>
    swapd [ define-consult-method ] 2curry each ;

: CONSULT:
    scan-word scan-word parse-definition swapd define-consult ; parsing

: define-mimic ( group mimicker mimicked -- )
    >r >r group-words r> r> [
        pick "methods" word-prop at dup
        [ method-def <method> spin define-method ] [ 3drop ] if
    ] 2curry each ; 

: MIMIC:
    scan-word scan-word scan-word define-mimic ; parsing
