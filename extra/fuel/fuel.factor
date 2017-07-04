! Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.units continuations fuel.eval
fuel.help fuel.xref help.topics io.pathnames kernel namespaces parser
parser.notes sequences tools.scaffold vocabs vocabs.files
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.parser words ;
IN: fuel

! Evaluation

: fuel-eval-restartable ( -- )
    t eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f eval-res-flag set-global ; inline

: fuel-eval-in-context ( lines in usings -- )
    eval-in-context ;

: fuel-eval-set-result ( obj -- )
    clone eval-result set-global ; inline

: fuel-retort ( -- ) f f "" send-retort ; inline

! Loading files

<PRIVATE

SYMBOL: :uses
SYMBOL: :uses-suggestions

: is-use-restart ( restart -- ? )
    name>> [ "Use the " head? ] [ " vocabulary" tail? ] bi and ;

: get-restart-vocab ( restart -- vocab/f )
    obj>> dup word? [ vocabulary>> ] [ drop f ] if ;

: is-suggested-restart ( restart -- ? )
    dup is-use-restart [
        get-restart-vocab :uses-suggestions get member?
    ] [ drop f ] if ;

: try-suggested-restarts ( -- )
    restarts get [ is-suggested-restart ] filter
    dup length 1 = [ first continue-restart ] [ drop ] if ;

: set-use-hook ( -- )
    [ manifest get auto-used>> clone :uses prefix fuel-eval-set-result ]
    print-use-hook set ;

: get-uses ( lines -- )
    [
        parser-quiet? on
        parse-fresh drop
    ] curry with-compilation-unit ; inline

PRIVATE>

: fuel-use-suggested-vocabs ( ..a suggestions quot: ( ..a -- ..b ) -- ..b )
    [ :uses-suggestions set ] dip
    [ try-suggested-restarts rethrow ] recover ; inline

: fuel-run-file ( path -- )
    [ set-use-hook run-file ] curry with-scope ; inline

: fuel-with-autouse ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ set-use-hook call ] curry with-scope ; inline

: fuel-get-uses ( lines -- )
    [ get-uses ] curry fuel-with-autouse ;

! Edit locations

: fuel-get-word-location ( word -- )
    word-location fuel-eval-set-result ;

: fuel-get-vocab-location ( vocab -- )
    vocab-location fuel-eval-set-result ;

: fuel-get-doc-location ( word -- )
    doc-location fuel-eval-set-result ;

: fuel-get-article-location ( name -- )
    article-location fuel-eval-set-result ;

: fuel-get-vocabs ( -- )
    all-disk-vocab-names fuel-eval-set-result ;

: fuel-get-vocabs/prefix ( prefix -- )
    get-vocabs/prefix fuel-eval-set-result ;

: fuel-get-words ( prefix names -- )
    get-vocabs-words/prefix fuel-eval-set-result ;

! Cross-references

: fuel-callers-xref ( word -- ) callers-xref fuel-eval-set-result ;

: fuel-callees-xref ( word -- ) callees-xref fuel-eval-set-result ;

: fuel-apropos-xref ( str -- ) apropos-xref fuel-eval-set-result ;

: fuel-vocab-xref ( vocab -- ) vocab-xref fuel-eval-set-result ;

: fuel-vocab-uses-xref ( vocab -- ) vocab-uses-xref fuel-eval-set-result ;

: fuel-vocab-usage-xref ( vocab -- ) vocab-usage-xref fuel-eval-set-result ;

! Help support

: fuel-get-article ( name -- ) fuel.help:get-article fuel-eval-set-result ;

: fuel-get-article-title ( name -- )
    articles get at [ article-title ] [ f ] if* fuel-eval-set-result ;

: fuel-word-help ( name -- ) word-help fuel-eval-set-result ;

: fuel-word-def ( name -- ) word-def fuel-eval-set-result ;

: fuel-vocab-help ( name -- ) fuel.help:vocab-help fuel-eval-set-result ;

: fuel-word-synopsis ( word -- ) word-synopsis fuel-eval-set-result ;

: fuel-vocab-summary ( name -- )
    fuel.help:vocab-summary fuel-eval-set-result ;

: fuel-index ( quot -- ) call( -- seq ) format-index fuel-eval-set-result ;

: fuel-get-vocabs/tag ( tag -- )
    get-vocabs/tag fuel-eval-set-result ;

: fuel-get-vocabs/author ( author -- )
    get-vocabs/author fuel-eval-set-result ;

! Scaffold support

: scaffold-name ( devname -- )
    [ developer-name set ] when* ;

: fuel-scaffold-vocab ( root name devname -- )
    [ scaffold-name dup [ scaffold-vocab ] dip ] with-scope
    dup require vocab-source-path absolute-path fuel-eval-set-result ;

: fuel-scaffold-help ( name devname -- )
    [ scaffold-name dup require dup scaffold-docs ] with-scope
    vocab-docs-path absolute-path fuel-eval-set-result ;

: fuel-scaffold-tests ( name devname -- )
    [ scaffold-name dup require dup scaffold-tests ] with-scope
    vocab-tests-file absolute-path fuel-eval-set-result ;

: fuel-scaffold-authors ( name devname -- )
    [ scaffold-name dup require dup scaffold-authors ] with-scope
    [ vocab-authors-path ] keep swap vocab-append-path absolute-path fuel-eval-set-result ;

: fuel-scaffold-tags ( name tags -- )
    [ scaffold-tags ]
    [
        drop [ vocab-tags-path ] keep swap
        vocab-append-path absolute-path fuel-eval-set-result
    ] 2bi ;

: fuel-scaffold-summary ( name summary -- )
    [ scaffold-summary ]
    [
        drop [ vocab-summary-path ] keep swap
        vocab-append-path absolute-path fuel-eval-set-result
    ] 2bi ;

: fuel-scaffold-platforms ( name platforms -- )
    [ scaffold-platforms ]
    [
        drop [ vocab-platforms-path ] keep swap
        vocab-append-path absolute-path fuel-eval-set-result
    ] 2bi ;

: fuel-scaffold-get-root ( name -- ) find-vocab-root fuel-eval-set-result ;
