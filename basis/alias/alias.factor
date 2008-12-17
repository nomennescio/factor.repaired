! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words quotations kernel effects sequences
parser definitions ;
IN: alias

PREDICATE: alias < word "alias" word-prop ;

: define-alias ( new old -- )
    [ [ 1quotation ] [ stack-effect ] bi define-inline ]
    [ drop t "alias" set-word-prop ] 2bi ;

: ALIAS: CREATE-WORD scan-word define-alias ; parsing

M: alias reset-word
    [ call-next-method ] [ f "alias" set-word-prop ] bi ;

M: alias stack-effect
    def>> first stack-effect ;
