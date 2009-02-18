! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry locals
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables splitting sorting regexp.ast ;
IN: regexp

TUPLE: regexp raw options parse-tree dfa ;

: (match) ( string regexp -- dfa-traverser )
    dfa>> <dfa-traverser> do-match ; inline

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

: (re-split) ( string regexp -- )
    over [ [ re-cut , ] keep (re-split) ] [ 2drop ] if ;

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

PRIVATE>

:: <optioned-regexp> ( string options -- regexp )
    string parse-regexp :> tree
    options parse-options :> opt
    tree opt <with-options> :> ast
    regexp new
        string >>raw
        opt >>options
        tree >>parse-tree
        tree opt <with-options> construct-nfa construct-dfa >>dfa ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

<PRIVATE

: parsing-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    lexer get dup still-parsing-line?
    [ (parse-token) ] [ drop f ] if
    <optioned-regexp> parsed ;

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
