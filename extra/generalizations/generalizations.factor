! Copyright (C) 2007, 2008 Chris Double, Doug Coleman, Eduardo
! Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private namespaces math math.ranges
combinators macros quotations fry locals arrays ;
IN: generalizations

MACRO: narray ( n -- quot )
    [ <reversed> ] [ '[ , f <array> ] ] bi
    [ '[ @ [ , swap set-nth-unsafe ] keep ] ] reduce ;

MACRO: firstn ( n -- )
    dup zero? [ drop [ drop ] ] [
        [ [ '[ , _ nth-unsafe ] ] map ]
        [ 1- '[ , _ bounds-check 2drop ] ]
        bi prefix '[ , cleave ]
    ] if ;

MACRO: npick ( n -- )
    1- dup saver [ dup ] rot [ r> swap ] n*quot 3append ;

MACRO: ndup ( n -- )
    dup '[ , npick ] n*quot ;

MACRO: nrot ( n -- )
    1- dup saver swap [ r> swap ] n*quot append ;

MACRO: -nrot ( n -- )
    1- dup [ swap >r ] n*quot swap restorer append ;

MACRO: ndrop ( n -- )
    [ drop ] n*quot ;

: nnip ( n -- )
    swap >r ndrop r> ; inline

MACRO: ntuck ( n -- )
    2 + [ dupd -nrot ] curry ;

MACRO: nrev ( n -- quot )
    1 [a,b] [ '[ , -nrot ] ] map concat ;

MACRO: ndip ( quot n -- )
    dup saver -rot restorer 3append ;

MACRO: nslip ( n -- )
    dup saver [ call ] rot restorer 3append ;

MACRO: nkeep ( n -- )
    [ ] [ 1+ ] [ ] tri
    '[ [ , ndup ] dip , -nrot , nslip ] ;

MACRO: ncurry ( n -- ) [ curry ] n*quot ;

MACRO:: nwith ( quot n -- )
    [let | n' [ n 1+ ] |
        [ n' -nrot [ n' nrot quot call ] n ncurry ] ] ;

MACRO: napply ( n -- )
    2 [a,b]
    [ [ 1- ] keep '[ , ntuck , nslip ] ]
    map concat >quotation [ call ] append ;
