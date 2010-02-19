! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words assocs definitions io io.pathnames io.styles kernel
prettyprint sorting see sets sequences arrays hashtables help
help.crossref help.topics help.markup quotations accessors
source-files namespaces graphs vocabs generic generic.single
threads compiler.units init combinators.smart ;
IN: tools.crossref

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

<PRIVATE

SYMBOL: visited

GENERIC# quot-uses 1 ( obj assoc -- )

M: object quot-uses 2drop ;

M: word quot-uses over crossref? [ conjoin ] [ 2drop ] if ;

: (seq-uses) ( seq assoc -- )
    [ quot-uses ] curry each ;

: seq-uses ( seq assoc -- )
    over visited get member-eq? [ 2drop ] [
        over visited get push
        (seq-uses)
    ] if ;

: assoc-uses ( assoc' assoc -- )
    over visited get member-eq? [ 2drop ] [
        over visited get push
        [ >alist ] dip (seq-uses)
    ] if ;

M: array quot-uses seq-uses ;

M: hashtable quot-uses assoc-uses ;

M: callable quot-uses seq-uses ;

M: wrapper quot-uses [ wrapped>> ] dip quot-uses ;

M: callable uses ( quot -- assoc )
    V{ } clone visited [
        H{ } clone [ quot-uses ] keep keys
    ] with-variable ;

M: word uses def>> uses ;

M: link uses
    [ { $subsection $subsections $link $see-also } article-links [ >link ] map ]
    [ { $vocab-link } article-links [ >vocab-link ] map ]
    bi append ;

M: pathname uses string>> source-file top-level-form>> [ uses ] [ { } ] if* ;

! To make UI browser happy
M: vocab uses drop f ;

GENERIC: crossref-def ( defspec -- )

M: object crossref-def
    dup uses crossref get add-vertex ;

M: word crossref-def
    [ call-next-method ] [ subwords [ crossref-def ] each ] bi ;

: defs-to-crossref ( -- seq )
    [
        all-words [ generic? not ] filter
        all-articles [ >link ] map
        source-files get keys [ <pathname> ] map
    ] append-outputs ;

: build-crossref ( -- crossref )
    "Computing usage index... " write flush yield
    H{ } clone [
        crossref set-global
        defs-to-crossref [ crossref-def ] each
    ] keep
    "done" print flush ;

: get-crossref ( -- crossref )
    crossref get-global [ build-crossref ] unless* ;

GENERIC: irrelevant? ( defspec -- ? )

M: object irrelevant? drop f ;

M: default-method irrelevant? drop t ;

M: predicate-engine irrelevant? drop t ;

PRIVATE>

: usage ( defspec -- seq ) get-crossref at keys ;

GENERIC: smart-usage ( defspec -- seq )

M: object smart-usage usage [ irrelevant? not ] filter ;

M: method smart-usage "method-generic" word-prop smart-usage ;

M: f smart-usage drop \ f smart-usage ;

: synopsis-alist ( definitions -- alist )
    [ [ synopsis ] keep ] { } map>assoc ;

: definitions. ( alist -- )
    [ write-object nl ] assoc-each ;

: sorted-definitions. ( definitions -- )
    synopsis-alist sort-keys definitions. ;

: usage. ( word -- )
    smart-usage
    [ "No usages." print ] [ sorted-definitions. ] if-empty ;

: vocab-xref ( vocab quot -- vocabs )
    [ [ vocab-name ] [ words [ generic? not ] filter ] bi ] dip map
    [
        [ [ word? ] [ generic? not ] bi and ] filter [
            dup method?
            [ "method-generic" word-prop ] when
            vocabulary>>
        ] map
    ] gather natural-sort remove sift ; inline

: vocabs. ( seq -- )
    [ dup >vocab-link write-object nl ] each ;

: vocab-uses ( vocab -- vocabs ) [ uses ] vocab-xref ;

: vocab-uses. ( vocab -- ) vocab-uses vocabs. ;

: vocab-usage ( vocab -- vocabs ) [ usage ] vocab-xref ;

: vocab-usage. ( vocab -- ) vocab-usage vocabs. ;

<PRIVATE

SINGLETON: invalidate-crossref

M: invalidate-crossref definitions-changed 2drop crossref global delete-at ;

[ invalidate-crossref add-definition-observer ] "tools.crossref" add-startup-hook

PRIVATE>
