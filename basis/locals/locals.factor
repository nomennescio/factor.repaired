! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make sequences sequences.private assocs
math vectors strings classes.tuple generalizations parser words
quotations debugger macros arrays macros splitting combinators
prettyprint.backend definitions prettyprint hashtables
prettyprint.sections sets sequences.private effects
effects.parser generic generic.parser compiler.units accessors
locals.backend memoize macros.expander lexer classes
stack-checker.known-words ;
IN: locals

! Inspired by
! http://cat-language.googlecode.com/svn/trunk/CatPointFreeForm.cs

<PRIVATE

TUPLE: lambda vars body ;

C: <lambda> lambda

TUPLE: binding-form bindings body ;

TUPLE: let < binding-form ;

C: <let> let

TUPLE: let* < binding-form ;

C: <let*> let*

TUPLE: wlet < binding-form ;

C: <wlet> wlet

M: lambda expand-macros clone [ expand-macros ] change-body ;

M: lambda expand-macros* expand-macros literal ;

M: binding-form expand-macros
    clone
        [ [ expand-macros ] assoc-map ] change-bindings
        [ expand-macros ] change-body ;

M: binding-form expand-macros* expand-macros literal ;

PREDICATE: local < word "local?" word-prop ;

: <local> ( name -- word )
    #! Create a local variable identifier
    f <word>
    dup t "local?" set-word-prop
    dup { } { object } define-primitive ;

PREDICATE: local-word < word "local-word?" word-prop ;

: <local-word> ( name -- word )
    f <word> dup t "local-word?" set-word-prop ;

PREDICATE: local-reader < word "local-reader?" word-prop ;

: <local-reader> ( name -- word )
    f <word>
    dup t "local-reader?" set-word-prop
    dup { } { object } define-primitive ;

PREDICATE: local-writer < word "local-writer?" word-prop ;

: <local-writer> ( reader -- word )
    dup name>> "!" append f <word> {
        [ nip { object } { } define-primitive ]
        [ nip t "local-writer?" set-word-prop ]
        [ swap "local-reader" set-word-prop ]
        [ "local-writer" set-word-prop ]
        [ nip ]
    } 2cleave ;

TUPLE: quote local ;

C: <quote> quote

: local-index ( obj args -- n )
    [ dup quote? [ local>> ] when eq? ] with find drop ;

: read-local-quot ( obj args -- quot )
    local-index 1+ [ get-local ] curry ;

: localize-writer ( obj args -- quot )
    >r "local-reader" word-prop r>
    read-local-quot [ set-local-value ] append ;

: localize ( obj args -- quot )
    {
        { [ over local? ]        [ read-local-quot ] }
        { [ over quote? ]        [ >r local>> r> read-local-quot ] }
        { [ over local-word? ]   [ read-local-quot [ call ] append ] }
        { [ over local-reader? ] [ read-local-quot [ local-value ] append ] }
        { [ over local-writer? ] [ localize-writer ] }
        { [ over \ lambda eq? ]  [ 2drop [ ] ] }
        { [ t ]                  [ drop 1quotation ] }
    } cond ;

UNION: special local quote local-word local-reader local-writer ;

: load-locals-quot ( args -- quot )
    [
        [ ]
    ] [
        dup [ local-reader? ] contains? [
            <reversed> [
                local-reader? [ 1array >r ] [ >r ] ?
            ] map concat
        ] [
            length [ load-locals ] curry >quotation
        ] if
    ] if-empty ;

: drop-locals-quot ( args -- quot )
    [ [ ] ] [ length [ drop-locals ] curry ] if-empty ;

: point-free-body ( quot args -- newquot )
    >r but-last-slice r> [ localize ] curry map concat ;

: point-free-end ( quot args -- newquot )
    over peek special?
    [ dup drop-locals-quot >r >r peek r> localize r> append ]
    [ dup drop-locals-quot nip swap peek suffix ]
    if ;

: (point-free) ( quot args -- newquot )
    [ nip load-locals-quot ]
    [ point-free-body ]
    [ point-free-end ]
    2tri 3append >quotation ;

: point-free ( quot args -- newquot )
    over empty?
    [ nip length \ drop <repetition> >quotation ]
    [ (point-free) ] if ;

UNION: lexical local local-reader local-writer local-word ;

GENERIC: free-vars* ( form -- )

: free-vars ( form -- vars )
    [ free-vars* ] { } make prune ;

: add-if-free ( object -- )
    {
        { [ dup local-writer? ] [ "local-reader" word-prop , ] }
        { [ dup lexical? ] [ , ] }
        { [ dup quote? ] [ local>> , ] }
        { [ t ] [ free-vars* ] }
    } cond ;

M: object free-vars* drop ;

M: quotation free-vars* [ add-if-free ] each ;

M: lambda free-vars*
    [ vars>> ] [ body>> ] bi free-vars swap diff % ;

GENERIC: lambda-rewrite* ( obj -- )

GENERIC: local-rewrite* ( obj -- )

: lambda-rewrite ( form -- form' )
    expand-macros
    [ local-rewrite* ] [ ] make
    [ [ lambda-rewrite* ] each ] [ ] make ;

UNION: block callable lambda ;

GENERIC: block-vars ( block -- seq )

GENERIC: block-body ( block -- quot )

M: callable block-vars drop { } ;

M: callable block-body ;

M: callable local-rewrite*
    [ [ local-rewrite* ] each ] [ ] make , ;

M: lambda block-vars vars>> ;

M: lambda block-body body>> ;

M: lambda local-rewrite*
    [ vars>> ] [ body>> ] bi
    [ [ local-rewrite* ] each ] [ ] make <lambda> , ;

M: block lambda-rewrite*
    #! Turn free variables into bound variables, curry them
    #! onto the body
    dup free-vars [ <quote> ] map dup % [
        over block-vars prepend
        swap block-body [ [ lambda-rewrite* ] each ] [ ] make
        swap point-free ,
    ] keep length \ curry <repetition> % ;

GENERIC: rewrite-literal? ( obj -- ? )

M: special rewrite-literal? drop t ;

M: array rewrite-literal? [ rewrite-literal? ] contains? ;

M: hashtable rewrite-literal? drop t ;

M: vector rewrite-literal? drop t ;

M: tuple rewrite-literal? drop t ;

M: object rewrite-literal? drop f ;

GENERIC: rewrite-element ( obj -- )

: rewrite-elements ( seq -- )
    [ rewrite-element ] each ;

: rewrite-sequence ( seq -- )
    [ rewrite-elements ] [ length , ] [ , ] tri \ nsequence , ;

M: array rewrite-element
    dup rewrite-literal? [ rewrite-sequence ] [ , ] if ;

M: vector rewrite-element rewrite-sequence ;

M: hashtable rewrite-element >alist rewrite-sequence \ >hashtable , ;

M: tuple rewrite-element
    [ tuple-slots rewrite-elements ] [ class , ] bi \ boa , ;

M: local rewrite-element , ;

M: word rewrite-element literalize , ;

M: object rewrite-element , ;

M: array local-rewrite* rewrite-element ;

M: vector local-rewrite* rewrite-element ;

M: tuple local-rewrite* rewrite-element ;

M: hashtable local-rewrite* rewrite-element ;

M: object lambda-rewrite* , ;

M: object local-rewrite* , ;

: make-local ( name -- word )
    "!" ?tail [
        <local-reader>
        dup <local-writer> dup name>> set
    ] [ <local> ] if
    dup dup name>> set ;

: make-locals ( seq -- words assoc )
    [ [ make-local ] map ] H{ } make-assoc ;

: make-local-word ( name -- word )
    <local-word> dup dup name>> set ;

: push-locals ( assoc -- )
    use get push ;

: pop-locals ( assoc -- )
    use get delete ;

SYMBOL: in-lambda?

: (parse-lambda) ( assoc end -- quot )
    t in-lambda? [ parse-until ] with-variable
    >quotation swap pop-locals ;

: parse-lambda ( -- lambda )
    "|" parse-tokens make-locals dup push-locals
    \ ] (parse-lambda) <lambda> ;

: parse-binding ( -- pair/f )
    scan dup "|" = [
        drop f
    ] [
        scan {
            { "[" [ \ ] parse-until >quotation ] }
            { "[|" [ parse-lambda ] }
        } case 2array
    ] if ;

: (parse-bindings) ( -- )
    parse-binding [
        first2 >r make-local r> 2array ,
        (parse-bindings)
    ] when* ;

: parse-bindings ( -- bindings vars )
    [
        [ (parse-bindings) ] H{ } make-assoc
        dup push-locals
    ] { } make swap ;

: parse-bindings* ( -- words assoc )
    [
        [
            namespace push-locals

            (parse-bindings)
        ] { } make-assoc
    ] { } make swap ;

: (parse-wbindings) ( -- )
    parse-binding [
        first2 >r make-local-word r> 2array ,
        (parse-wbindings)
    ] when* ;

: parse-wbindings ( -- bindings vars )
    [
        [ (parse-wbindings) ] H{ } make-assoc
        dup push-locals
    ] { } make swap ;

: let-rewrite ( body bindings -- )
    <reversed> [
        >r 1array r> spin <lambda> [ call ] curry compose
    ] assoc-each local-rewrite* \ call , ;

M: let local-rewrite*
    [ body>> ] [ bindings>> ] bi let-rewrite ;

M: let* local-rewrite*
    [ body>> ] [ bindings>> ] bi let-rewrite ;

M: wlet local-rewrite*
    [ body>> ] [ bindings>> ] bi
    [ [ ] curry ] assoc-map
    let-rewrite ;

: parse-locals ( -- vars assoc )
    ")" parse-effect
    word [ over "declared-effect" set-word-prop ] when*
    in>> [ dup pair? [ first ] when ] map make-locals dup push-locals ;

: parse-locals-definition ( word -- word quot )
    scan "(" assert= parse-locals \ ; (parse-lambda) <lambda>
    2dup "lambda" set-word-prop
    lambda-rewrite first ;

: (::) ( -- word def ) CREATE-WORD parse-locals-definition ;

: (M::) ( -- word def )
    CREATE-METHOD
    [ parse-locals-definition ] with-method-definition ;

: parsed-lambda ( accum form -- accum )
    in-lambda? get [ parsed ] [ lambda-rewrite over push-all ] if ;

PRIVATE>

: [| parse-lambda parsed-lambda ; parsing

: [let
    scan "|" assert= parse-bindings
    \ ] (parse-lambda) <let> parsed-lambda ; parsing

: [let*
    scan "|" assert= parse-bindings*
    \ ] (parse-lambda) <let*> parsed-lambda ; parsing

: [wlet
    scan "|" assert= parse-wbindings
    \ ] (parse-lambda) <wlet> parsed-lambda ; parsing

: :: (::) define ; parsing

: M:: (M::) define ; parsing

: MACRO:: (::) define-macro ; parsing

: MEMO:: (::) define-memoized ; parsing

<PRIVATE

! Pretty-printing locals
SYMBOL: |

: pprint-var ( var -- )
    #! Prettyprint a read/write local as its writer, just like
    #! in the input syntax: [| x! | ... x 3 + x! ]
    dup local-reader? [
        "local-writer" word-prop
    ] when pprint-word ;

: pprint-vars ( vars -- ) [ pprint-var ] each ;

M: lambda pprint*
    <flow
    \ [| pprint-word
    dup vars>> pprint-vars
    \ | pprint-word
    f <inset body>> pprint-elements block>
    \ ] pprint-word
    block> ;

: pprint-let ( let word -- )
    pprint-word
    [ body>> ] [ bindings>> ] bi
    \ | pprint-word
    t <inset
    <block
    [ <block >r pprint-var r> pprint* block> ] assoc-each
    block>
    \ | pprint-word
    <block pprint-elements block>
    block>
    \ ] pprint-word ;

M: let pprint* \ [let pprint-let ;

M: wlet pprint* \ [wlet pprint-let ;

M: let* pprint* \ [let* pprint-let ;

PREDICATE: lambda-word < word "lambda" word-prop >boolean ;

M: lambda-word definer drop \ :: \ ; ;

M: lambda-word definition
    "lambda" word-prop body>> ;

M: lambda-word reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

INTERSECTION: lambda-macro macro lambda-word ;

M: lambda-macro definer drop \ MACRO:: \ ; ;

M: lambda-macro definition
    "lambda" word-prop body>> ;

M: lambda-macro reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

INTERSECTION: lambda-method method-body lambda-word ;

M: lambda-method definer drop \ M:: \ ; ;

M: lambda-method definition
    "lambda" word-prop body>> ;

M: lambda-method reset-word
    [ f "lambda" set-word-prop ] [ call-next-method ] bi ;

INTERSECTION: lambda-memoized memoized lambda-word ;

M: lambda-memoized definer drop \ MEMO:: \ ; ;

M: lambda-memoized definition
    "lambda" word-prop body>> ;

M: lambda-memoized reset-word
    [ f "lambda" set-word-prop ] [ call-next-method ] bi ;

: method-stack-effect ( method -- effect )
    dup "lambda" word-prop vars>>
    swap "method-generic" word-prop stack-effect
    dup [ out>> ] when
    <effect> ;

M: lambda-method synopsis*
    dup dup dup definer.
    "method-class" word-prop pprint-word
    "method-generic" word-prop pprint-word
    method-stack-effect effect>string comment. ;

PRIVATE>
