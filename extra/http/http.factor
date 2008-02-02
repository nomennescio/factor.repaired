! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables io kernel math namespaces math.parser assocs
sequences strings splitting ascii io.utf8 ;
IN: http

: header-line ( line -- )
    ": " split1 dup [ swap set ] [ 2drop ] if ;

: (read-header) ( -- )
    readln dup
    empty? [ drop ] [ header-line (read-header) ] if ;

: read-header ( -- hash )
    [ (read-header) ] H{ } make-assoc ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_-." member? or ; foldable

: push-utf8 ( string -- )
    1string encode-utf8 [ CHAR: % , >hex 2 CHAR: 0 pad-left % ] each ;

: url-encode ( str -- str )
    [ [
        dup url-quotable? [ , ] [ push-utf8 ] if
    ] each ] "" make ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        >r 1+ dup 2 + r> subseq  hex> [ , ] when*
    ] if ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex >r 3 + r> ;

: url-decode-+-or-other ( index str ch -- index str )
    dup CHAR: + = [ drop CHAR: \s ] when , >r 1+ r> ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop url-decode-%
        ] [
            url-decode-+-or-other
        ] if url-decode-iter
    ] if ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] "" make decode-utf8 ;

: hash>query ( hash -- str )
    [ [ url-encode ] 2apply "=" swap 3append ] { } assoc>map
    "&" join ;

: build-url ( str query-params -- newstr )
    [
        over %
        dup assoc-empty? [
            2drop
        ] [
            CHAR: ? rot member? "&" "?" ? %
            hash>query %
        ] if
    ] "" make ;

