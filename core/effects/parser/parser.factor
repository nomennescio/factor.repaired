! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators continuations effects kernel lexer
make parser sequences sets splitting vocabs.parser words ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;
ERROR: invalid-row-variable ;
ERROR: row-variable-can't-have-type ;
ERROR: stack-effect-omits-dashes ;

SYMBOL: effect-var

<PRIVATE
: end-token? ( end token -- token ? ) [ nip ] [ = ] 2bi ; inline
: effect-opener? ( token -- token ? ) dup { f "(" "--" } member? ; inline
: effect-closer? ( token -- token ? ) dup ")" sequence= ; inline
: row-variable? ( token -- token' ? ) ".." ?head ; inline

: parse-effect-var ( first? var name -- var )
    nip
    [ ":" ?tail [ row-variable-can't-have-type ] when ] curry
    [ invalid-row-variable ] if ;

: parse-effect-value ( token -- value )
    ":" ?tail [ scan-object 2array ] when ;
PRIVATE>

: parse-effect-token ( first? var end -- var more? )
    scan-token {
        { [ end-token? ] [ drop nip f ] }
        { [ effect-opener? ] [ bad-effect ] }
        { [ effect-closer? ] [ stack-effect-omits-dashes ] }
        { [ row-variable? ] [ parse-effect-var t ] }
        [ [ drop ] 2dip parse-effect-value , t ]
    } cond ;

: parse-effect-tokens ( end -- var tokens )
    [
        [ t f ] dip [ parse-effect-token [ f ] 2dip ] curry [ ] while nip
    ] { } make ;

: parse-effect ( end -- effect )
    [ "--" parse-effect-tokens ] dip parse-effect-tokens
    <variable-effect> ;

: scan-effect ( -- effect )
    "(" expect ")" parse-effect ;

: parse-call-paren ( accum word -- accum )
    [ ")" parse-effect ] dip 2array append! ;

CONSTANT: in-definition HS{ }

ERROR: can't-nest-definitions word ;

: set-in-definition ( -- )
    current-vocab in-definition ?adjoin
    [ last-word can't-nest-definitions ] unless ;

: unset-in-definition ( -- )
    current-vocab in-definition delete ;

: with-definition ( quot -- )
    [ set-in-definition ] prepose [ unset-in-definition ] [ ] cleanup ; inline

: (:) ( -- word def effect )
    [
        scan-new-word
        scan-effect
        parse-definition swap
    ] with-definition ;
