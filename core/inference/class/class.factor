! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs hashtables inference kernel
math namespaces sequences words parser math.intervals
effects classes classes.algebra inference.dataflow
inference.backend combinators ;
IN: inference.class

! Class inference

! A constraint is a statement about a value.

! We need a notion of equality which doesn't recurse so cannot
! infinite loop on circular data
GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? number= ;

! Maps constraints to constraints
SYMBOL: constraints

TUPLE: literal-constraint literal value ;

C: <literal-constraint> literal-constraint

M: literal-constraint equal?
    over literal-constraint? [
        2dup
        [ literal-constraint-literal ] bi@ eql? >r
        [ literal-constraint-value ] bi@ = r> and
    ] [
        2drop f
    ] if ;

TUPLE: class-constraint class value ;

C: <class-constraint> class-constraint

TUPLE: interval-constraint interval value ;

C: <interval-constraint> interval-constraint

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input node get node-in-d nth ;
: `output node get node-out-d nth ;
: class, <class-constraint> , ;
: literal, <literal-constraint> , ;
: interval, <interval-constraint> , ;

M: f apply-constraint drop ;

: make-constraints ( node quot -- constraint )
    [ swap node set call ] { } make ; inline

: set-constraints ( node quot -- )
    make-constraints
    unclip [ 2array ] reduce
    apply-constraint ; inline

: assume ( constraint -- )
    constraints get at [ apply-constraint ] when* ;

! Variables used by the class inferencer

! Current value --> literal mapping
SYMBOL: value-literals

! Current value --> interval mapping
SYMBOL: value-intervals

! Current value --> class mapping
SYMBOL: value-classes

: value-interval* ( value -- interval/f )
    value-intervals get at ;

: set-value-interval* ( interval value -- )
    value-intervals get set-at ;

: intersect-value-interval ( interval value -- )
    [ value-interval* interval-intersect ] keep
    set-value-interval* ;

M: interval-constraint apply-constraint
    dup interval-constraint-interval
    swap interval-constraint-value intersect-value-interval ;

: set-class-interval ( class value -- )
    over class? [
        over "interval" word-prop [
            >r "interval" word-prop r> set-value-interval*
        ] [ 2drop ] if
    ] [ 2drop ] if ;

: value-class* ( value -- class )
    value-classes get at object or ;

: set-value-class* ( class value -- )
    over [
        dup value-intervals get at [
            2dup set-class-interval
        ] unless
        2dup <class-constraint> assume
    ] when
    value-classes get set-at ;

: intersect-value-class ( class value -- )
    [ value-class* class-and ] keep set-value-class* ;

M: class-constraint apply-constraint
    dup class-constraint-class
    swap class-constraint-value intersect-value-class ;

: set-value-literal* ( literal value -- )
    over class over set-value-class*
    over real? [ over [a,a] over set-value-interval* ] when
    2dup <literal-constraint> assume
    value-literals get set-at ;

M: literal-constraint apply-constraint
    dup literal-constraint-literal
    swap literal-constraint-value set-value-literal* ;

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

GENERIC: infer-classes-before ( node -- )

GENERIC: infer-classes-around ( node -- )

M: node infer-classes-before drop ;

M: node child-constraints
    node-children length
    dup zero? [ drop f ] [ f <repetition> ] if ;

: value-literal* ( value -- obj ? )
    value-literals get at* ;

M: literal-constraint constraint-satisfied?
    dup literal-constraint-value value-literal*
    [ swap literal-constraint-literal eql? ] [ 2drop f ] if ;

M: class-constraint constraint-satisfied?
    dup class-constraint-value value-class*
    swap class-constraint-class class< ;

M: pair apply-constraint
    first2 2dup constraints get set-at
    constraint-satisfied? [ apply-constraint ] [ drop ] if ;

M: pair constraint-satisfied?
    first constraint-satisfied? ;

: extract-keys ( assoc seq -- newassoc )
    dup length <hashtable> swap [
        dup >r pick at* [ r> pick set-at ] [ r> 2drop ] if
    ] each nip f assoc-like ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values
    value-intervals get over extract-keys pick set-node-intervals
    value-classes get over extract-keys pick set-node-classes
    value-literals get over extract-keys pick set-node-literals
    2drop ;

: intersect-classes ( classes values -- )
    [ intersect-value-class ] 2each ;

: intersect-intervals ( intervals values -- )
    [ intersect-value-interval ] 2each ;

: predicate-constraints ( class #call -- )
    [
        ! If word outputs true, input is an instance of class
        [
            0 `input class,
            \ f class-not 0 `output class,
        ] set-constraints
    ] [
        ! If word outputs false, input is not an instance of class
        [
            class-not 0 `input class,
            \ f 0 `output class,
        ] set-constraints
    ] 2bi ;

: compute-constraints ( #call -- )
    dup node-param "constraints" word-prop [
        call
    ] [
        dup node-param "predicating" word-prop dup
        [ swap predicate-constraints ] [ 2drop ] if
    ] if* ;

: compute-output-classes ( node word -- classes intervals )
    dup node-param "output-classes" word-prop
    dup [ call ] [ 2drop f f ] if ;

: output-classes ( node -- classes intervals )
    dup compute-output-classes >r
    [ ] [ node-param "default-output-classes" word-prop ] ?if
    r> ;

M: #call infer-classes-before
    dup compute-constraints
    dup node-out-d swap output-classes
    >r over intersect-classes
    r> swap intersect-intervals ;

M: #push infer-classes-before
    node-out-d
    [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-constraints
    [
        \ f class-not 0 `input class,
        f 0 `input literal,
    ] make-constraints ;

M: #dispatch child-constraints
    dup [
        node-children length [
            0 `input literal,
        ] each
    ] make-constraints ;

M: #declare infer-classes-before
    dup node-param swap node-in-d
    [ intersect-value-class ] 2each ;

DEFER: (infer-classes)

: infer-children ( node -- )
    dup node-children swap child-constraints [
        [
            value-classes [ clone ] change
            value-literals [ clone ] change
            value-intervals [ clone ] change
            constraints [ clone ] change
            apply-constraint
            (infer-classes)
        ] with-scope
    ] 2each ;

: pad-all ( seqs elt -- seq )
    >r dup [ length ] map supremum r> [ pad-left ] 2curry map ;

: (merge-classes) ( nodes -- seq )
    [ node-input-classes ] map
    null pad-all flip [ null [ class-or ] reduce ] map ;

: set-classes ( seq node -- )
    node-out-d [ set-value-class* ] 2reverse-each ;

: merge-classes ( nodes node -- )
    >r (merge-classes) r> set-classes ;

: set-intervals ( seq node -- )
    node-out-d [ set-value-interval* ] 2reverse-each ;

: merge-intervals ( nodes node -- )
    >r
    [ node-input-intervals ] map f pad-all flip
    [ dup first [ interval-union ] reduce ] map
    r> set-intervals ;

: annotate-merge ( nodes #merge/#entry -- )
    [ merge-classes ] [ merge-intervals ] 2bi ;

: merge-children ( node -- )
    dup node-successor dup #merge? [
        swap active-children dup empty?
        [ 2drop ] [ swap annotate-merge ] if
    ] [
        2drop
    ] if ;

: annotate-entry ( nodes #label -- )
    node-child merge-classes ;

M: #label infer-classes-before ( #label -- )
    #! First, infer types under the hypothesis which hold on
    #! entry to the recursive label.
    [ 1array ] keep annotate-entry ;

M: #label infer-classes-around ( #label -- )
    #! Now merge the types at every recursion point with the
    #! entry types.
    {
        [ annotate-node ]
        [ infer-classes-before ]
        [ infer-children ]
        [ [ collect-recursion ] [ suffix ] [ annotate-entry ] tri ]
        [ node-child (infer-classes) ]
    } cleave ;

M: object infer-classes-around
    {
        [ infer-classes-before ]
        [ annotate-node ]
        [ infer-children ]
        [ merge-children ]
    } cleave ;

: (infer-classes) ( node -- )
    [
        [ infer-classes-around ]
        [ node-successor (infer-classes) ] bi
    ] when* ;

: infer-classes-with ( node classes literals intervals -- )
    [
        H{ } assoc-like value-intervals set
        H{ } assoc-like value-literals set
        H{ } assoc-like value-classes set
        H{ } clone constraints set
        (infer-classes)
    ] with-scope ;

: infer-classes ( node -- )
    f f f infer-classes-with ;

: infer-classes/node ( node existing -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    dup node-classes
    over node-literals
    rot node-intervals
    infer-classes-with ;
