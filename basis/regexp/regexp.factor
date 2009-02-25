! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry locals regexp.minimize
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables splitting sorting regexp.ast
regexp.negation ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa ;

: make-regexp ( string ast -- regexp )
    f f <options> f regexp boa ; foldable
    ! Foldable because, when the dfa slot is set,
    ! it'll be set to the same thing regardless of who sets it

: <optioned-regexp> ( string options -- regexp )
    [ dup parse-regexp ] [ string>options ] bi*
    f regexp boa ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

<PRIVATE

: compile-regexp ( regexp -- regexp )
    dup dfa>> [
        dup 
        [ parse-tree>> ]
        [ options>> ] bi
        <with-options> ast>dfa
        >>dfa
    ] unless ;

: (match) ( string regexp -- dfa-traverser )
    compile-regexp dfa>> <dfa-traverser> do-match ; inline

PRIVATE>

: match ( string regexp -- slice/f )
    (match) return-match ;

: matches? ( string regexp -- ? )
    dupd match
    [ [ length ] bi@ = ] [ drop f ] if* ;

: match-head ( string regexp -- end/f ) match [ length ] [ f ] if* ;

: match-at ( string m regexp -- n/f finished? )
    [
        2dup swap length > [ 2drop f f ] [ tail-slice t ] if
    ] dip swap [ match-head f ] [ 2drop f t ] if ;

: match-range ( string m regexp -- a/f b/f )
    3dup match-at over [
        drop nip rot drop dupd +
    ] [
        [ 3drop drop f f ] [ drop [ 1+ ] dip match-range ] if
    ] if ;

: first-match ( string regexp -- slice/f )
    dupd 0 swap match-range rot over [ <slice> ] [ 3drop f ] if ;

: re-cut ( string regexp -- end/f start )
    dupd first-match
    [ split1-slice swap ] [ "" like f swap ] if* ;

<PRIVATE

: (re-split) ( string regexp -- )
    over [ [ re-cut , ] keep (re-split) ] [ 2drop ] if ;

PRIVATE>

: re-split ( string regexp -- seq )
    [ (re-split) ] { } make ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

: next-match ( string regexp -- end/f match/f )
    dupd first-match dup
    [ [ split1-slice nip ] keep ] [ 2drop f f ] if ;

: all-matches ( string regexp -- seq )
    [ dup ] swap '[ _ next-match ] [ ] produce nip harvest ;

: count-matches ( string regexp -- n )
    all-matches length ;

<PRIVATE

: find-regexp-syntax ( string -- prefix suffix )
    {
        { "R/ "  "/"  }
        { "R! "  "!"  }
        { "R\" " "\"" }
        { "R# "  "#"  }
        { "R' "  "'"  }
        { "R( "  ")"  }
        { "R@ "  "@"  }
        { "R[ "  "]"  }
        { "R` "  "`"  }
        { "R{ "  "}"  }
        { "R| "  "|"  }
    } swap [ subseq? not nip ] curry assoc-find drop ;

: parsing-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    lexer get dup still-parsing-line?
    [ (parse-token) ] [ drop f ] if
    <optioned-regexp> compile-regexp parsed ;

PRIVATE>

: R! CHAR: ! parsing-regexp ; parsing
: R" CHAR: " parsing-regexp ; parsing
: R# CHAR: # parsing-regexp ; parsing
: R' CHAR: ' parsing-regexp ; parsing
: R( CHAR: ) parsing-regexp ; parsing
: R/ CHAR: / parsing-regexp ; parsing
: R@ CHAR: @ parsing-regexp ; parsing
: R[ CHAR: ] parsing-regexp ; parsing
: R` CHAR: ` parsing-regexp ; parsing
: R{ CHAR: } parsing-regexp ; parsing
: R| CHAR: | parsing-regexp ; parsing

M: regexp pprint*
    [
        [
            [ raw>> dup find-regexp-syntax swap % swap % % ]
            [ options>> options>string % ] bi
        ] "" make
    ] keep present-text ;
