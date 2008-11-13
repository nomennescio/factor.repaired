! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry arrays generic io io.streams.string kernel math
namespaces parser prettyprint sequences strings vectors words
quotations effects classes continuations debugger assocs
combinators compiler.errors accessors math.order definitions
sets generic.standard.engines.tuple stack-checker.state
stack-checker.visitor stack-checker.errors
stack-checker.values stack-checker.recursive-state ;
IN: stack-checker.backend

: push-d ( obj -- ) meta-d get push ;

: pop-d  ( -- obj )
    meta-d get [
        <value> dup 1array #introduce, d-in inc
    ] [ pop ] if-empty ;

: peek-d ( -- obj ) pop-d dup push-d ;

: make-values ( n -- values )
    [ <value> ] replicate ;

: ensure-d ( n -- values )
    meta-d get 2dup length > [
        2dup
        [ nip >array ] [ length - make-values ] [ nip delete-all ] 2tri
        [ length d-in +@ ] [ #introduce, ] [ meta-d get push-all ] tri
        meta-d get push-all
    ] when swap tail* ;

: shorten-by ( n seq -- )
    [ length swap - ] keep shorten ; inline

: consume-d ( n -- seq )
    [ ensure-d ] [ meta-d get shorten-by ] bi ;

: output-d ( values -- ) meta-d get push-all ;

: produce-d ( n -- values )
    make-values dup meta-d get push-all ;

: push-r ( obj -- ) meta-r get push ;

: pop-r  ( -- obj )
    meta-r get dup empty?
    [ too-many-r> inference-error ] [ pop ] if ;

: consume-r ( n -- seq )
    meta-r get 2dup length >
    [ too-many-r> inference-error ] when
    [ swap tail* ] [ shorten-by ] 2bi ;

: output-r ( seq -- ) meta-r get push-all ;

: pop-literal ( -- rstate obj )
    pop-d
    [ 1array #drop, ]
    [ literal [ recursion>> ] [ value>> ] bi ] bi ;

GENERIC: apply-object ( obj -- )

: push-literal ( obj -- )
    dup <literal> make-known [ nip push-d ] [ #push, ] 2bi ;

M: wrapper apply-object
    wrapped>>
    [ dup word? [ called-dependency depends-on ] [ drop ] if ]
    [ push-literal ]
    bi ;

M: object apply-object push-literal ;

: terminate ( -- )
    terminated? on meta-d get clone meta-r get clone #terminate, ;

: infer-quot-here ( quot -- )
    [ apply-object terminated? get not ] all? drop ;

: infer-quot ( quot rstate -- )
    recursive-state get [
        recursive-state set
        infer-quot-here
    ] dip recursive-state set ;

: time-bomb ( error -- )
    '[ _ throw ] infer-quot-here ;

: bad-call ( -- )
    "call must be given a callable" time-bomb ;

: infer-literal-quot ( literal -- )
    dup recursive-quotation? [
        value>> recursive-quotation-error inference-error
    ] [
        dup value>> callable? [
            [ value>> ]
            [ [ recursion>> ] keep add-local-quotation ]
            bi infer-quot
        ] [
            drop bad-call
        ] if
    ] if ;

: infer->r ( n -- )
    consume-d dup copy-values [ #>r, ] [ nip output-r ] 2bi ;

: infer-r> ( n -- )
    consume-r dup copy-values [ #r>, ] [ nip output-d ] 2bi ;

: undo-infer ( -- )
    recorded get [ f "inferred-effect" set-word-prop ] each ;

: consume/produce ( effect quot -- )
    #! quot is ( inputs outputs -- )
    [
        [
            [ in>> length consume-d ]
            [ out>> length produce-d ]
            bi
        ] dip call
    ] [
        drop
        terminated?>> [ terminate ] when
    ] 2bi ; inline

: infer-word-def ( word -- )
    [ def>> ] [ add-recursive-state ] bi infer-quot ;

: check->r ( -- )
    meta-r get empty? terminated? get or
    [ \ too-many->r inference-error ] unless ;

: end-infer ( -- )
    check->r
    meta-d get clone #return, ;

: effect-required? ( word -- ? )
    {
        { [ dup inline? ] [ drop f ] }
        { [ dup deferred? ] [ drop f ] }
        { [ dup crossref? not ] [ drop f ] }
        [ def>> [ [ word? ] [ primitive? not ] bi and ] contains? ]
    } cond ;

: ?missing-effect ( word -- )
    dup effect-required?
    [ missing-effect inference-error ] [ drop ] if ;

: check-effect ( word effect -- )
    over stack-effect {
        { [ dup not ] [ 2drop ?missing-effect ] }
        { [ 2dup effect<= ] [ 3drop ] }
        [ effect-error ]
    } cond ;

: finish-word ( word -- )
    current-effect
    [ check-effect ]
    [ drop recorded get push ]
    [ "inferred-effect" set-word-prop ]
    2tri ;

: cannot-infer-effect ( word -- * )
    "cannot-infer" word-prop throw ;

: maybe-cannot-infer ( word quot -- )
    [ [ "cannot-infer" set-word-prop ] keep throw ] recover ; inline

: infer-word ( word -- effect )
    [
        [
            init-inference
            init-known-values
            stack-visitor off
            dependencies off
            generic-dependencies off
            [ infer-word-def end-infer ]
            [ finish-word current-effect ]
            bi
        ] with-scope
    ] maybe-cannot-infer ;

: apply-word/effect ( word effect -- )
    swap '[ _ #call, ] consume/produce ;

: required-stack-effect ( word -- effect )
    dup stack-effect [ ] [ \ missing-effect inference-error ] ?if ;

: call-recursive-word ( word -- )
    dup required-stack-effect apply-word/effect ;

: cached-infer ( word -- )
    dup "inferred-effect" word-prop apply-word/effect ;

: with-infer ( quot -- effect visitor )
    [
        [
            V{ } clone recorded set
            init-inference
            init-known-values
            stack-visitor off
            call
            end-infer
            current-effect
            stack-visitor get
        ] [ ] [ undo-infer ] cleanup
    ] with-scope ; inline
