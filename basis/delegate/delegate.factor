! Copyright (C) 2007, 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors parser generic kernel classes classes.tuple
words slots assocs sequences arrays vectors definitions
prettyprint math hashtables sets generalizations namespaces make ;
IN: delegate

: protocol-words ( protocol -- words )
    \ protocol-words word-prop ;

: protocol-consult ( protocol -- consulters )
    \ protocol-consult word-prop ;

GENERIC: group-words ( group -- words )

M: tuple-class group-words
    all-slots [
        name>>
        [ reader-word 0 2array ]
        [ writer-word 0 2array ] bi
        2array
    ] map concat ;

! Consultation

: consult-method ( word class quot -- )
    [ drop swap first create-method ]
    [ nip [ , dup second , \ ndip , first , ] [ ] make ] 3bi
    define ;

: change-word-prop ( word prop quot -- )
    rot props>> swap change-at ; inline

: register-protocol ( group class quot -- )
    rot \ protocol-consult [ swapd ?set-at ] change-word-prop ;

: define-consult ( group class quot -- )
    [ register-protocol ]
    [ [ group-words ] 2dip [ consult-method ] 2curry each ]
    3bi ;

: CONSULT:
    scan-word scan-word parse-definition define-consult ; parsing

! Protocols

: cross-2each ( seq1 seq2 quot -- )
    [ with each ] 2curry each ; inline

: forget-all-methods ( classes words -- )
    [ first method forget ] cross-2each ;

: protocol-users ( protocol -- users )
    protocol-consult keys ;

: lost-words ( protocol wordlist -- lost-words )
    [ protocol-words ] dip diff ;

: forget-old-definitions ( protocol new-wordlist -- )
    [ drop protocol-users ] [ lost-words ] 2bi
    forget-all-methods ;

: added-words ( protocol wordlist -- added-words )
    swap protocol-words diff ;

: add-new-definitions ( protocol wordlist -- )
    [ drop protocol-consult >alist ] [ added-words ] 2bi
    [ swap first2 consult-method ] cross-2each ;

: initialize-protocol-props ( protocol wordlist -- )
    [
        drop \ protocol-consult
        [ H{ } assoc-like ] change-word-prop
    ] [ { } like \ protocol-words set-word-prop ] 2bi ;

: fill-in-depth ( wordlist -- wordlist' )
    [ dup word? [ 0 2array ] when ] map ;

: define-protocol ( protocol wordlist -- )
    fill-in-depth
    [ forget-old-definitions ]
    [ add-new-definitions ]
    [ initialize-protocol-props ] 2tri ;

: PROTOCOL:
    CREATE-WORD
    [ define-symbol ]
    [ f "inline" set-word-prop ]
    [ parse-definition define-protocol ] tri ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ f forget-old-definitions ] [ call-next-method ] bi ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol synopsis* word-synopsis ; ! Necessary?

M: protocol group-words protocol-words ;
