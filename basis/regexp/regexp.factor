! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences
sets assocs prettyprint.backend make lexer namespaces parser
arrays fry regexp.backend regexp.utils regexp.parser regexp.nfa
regexp.dfa regexp.traversal regexp.transition-tables splitting ;
IN: regexp

: default-regexp ( string -- regexp )
    regexp new
        swap >>raw
        <transition-table> >>nfa-table
        <transition-table> >>dfa-table
        <transition-table> >>minimized-table
        H{ } clone >>nfa-traversal-flags
        H{ } clone >>dfa-traversal-flags
        H{ } clone >>options
        reset-regexp ;

: construct-regexp ( regexp -- regexp' )
    {
        [ parse-regexp ]
        [ construct-nfa ]
        [ construct-dfa ]
        [ ]
    } cleave ;

: (match) ( string regexp -- dfa-traverser )
    <dfa-traverser> do-match ; inline

: match ( string regexp -- slice/f )
    (match) return-match ;

: match* ( string regexp -- slice/f captured-groups )
    (match) [ return-match ] [ captured-groups>> ] bi ;

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

: re-split ( string regexp -- seq )
    [ dup length 0 > ] swap '[ _ re-cut ] [ ] produce nip ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

: next-match ( string regexp -- end/f match/f )
    dupd first-match dup
    [ [ split1-slice nip ] keep ] [ 2drop f f ] if ;

: all-matches ( string regexp -- seq )
    [ dup ] swap '[ _ next-match ] [ ] produce nip harvest ;

: count-matches ( string regexp -- n )
    all-matches length ;

: initial-option ( regexp option -- regexp' )
    over options>> conjoin ;

: <regexp> ( string -- regexp )
    default-regexp construct-regexp ;

: <iregexp> ( string -- regexp )
    default-regexp
    case-insensitive initial-option
    construct-regexp ;

: <rregexp> ( string -- regexp )
    default-regexp
    reversed-regexp initial-option
    construct-regexp ;

: parsing-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    lexer get dup still-parsing-line?
    [ (parse-token) ] [ drop f ] if
    "i" = [ <iregexp> ] [ <regexp> ] if parsed ;

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

: option? ( option regexp -- ? )
    options>> key? ;

M: regexp pprint*
    [
        [
            dup raw>>
            dup find-regexp-syntax swap % swap % %
            case-insensitive swap option? [ "i" % ] when
        ] "" make
    ] keep present-text ;
