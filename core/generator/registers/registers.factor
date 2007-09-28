! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.private combinators
cpu.architecture generator.fixup generic hashtables
inference.dataflow inference.stack kernel kernel.private layouts
math memory namespaces quotations sequences system vectors words
effects ;
IN: generator.registers

SYMBOL: +input+
SYMBOL: +output+
SYMBOL: +scratch+
SYMBOL: +clobber+
SYMBOL: known-tag

! A scratch register for computations
TUPLE: vreg n ;

: <vreg> ( n reg-class -- vreg )
    { set-vreg-n set-delegate } vreg construct ;

! Register classes
TUPLE: int-regs ;
TUPLE: float-regs size ;

: <int-vreg> ( n -- vreg ) T{ int-regs } <vreg> ;
: <float-vreg> ( n -- vreg ) T{ float-regs f 8 } <vreg> ;

! Temporary register for stack shuffling
TUPLE: temp-reg ;

: temp-reg T{ temp-reg T{ int-regs } } ;

M: vreg v>operand dup vreg-n swap vregs nth ;

TUPLE: cached loc vreg ;

C: <cached> cached

! A data stack location.
TUPLE: ds-loc n ;

C: <ds-loc> ds-loc

! A retain stack location.
TUPLE: rs-loc n ;

C: <rs-loc> rs-loc

! Unboxed alien pointers
TUPLE: unboxed-alien vreg ;
C: <unboxed-alien> unboxed-alien
M: unboxed-alien v>operand unboxed-alien-vreg v>operand ;

TUPLE: unboxed-byte-array vreg ;
C: <unboxed-byte-array> unboxed-byte-array
M: unboxed-byte-array v>operand unboxed-byte-array-vreg v>operand ;

TUPLE: unboxed-f vreg ;
C: <unboxed-f> unboxed-f
M: unboxed-f v>operand unboxed-f-vreg v>operand ;

TUPLE: unboxed-c-ptr vreg ;
C: <unboxed-c-ptr> unboxed-c-ptr
M: unboxed-c-ptr v>operand unboxed-c-ptr-vreg v>operand ;

<PRIVATE

UNION: loc ds-loc rs-loc ;

! Moving values between locations and registers
GENERIC: move-spec ( obj -- spec )

M: unboxed-alien move-spec class ;
M: unboxed-byte-array move-spec class ;
M: unboxed-f move-spec class ;
M: unboxed-c-ptr move-spec class ;
M: int-regs move-spec drop f ;
M: float-regs move-spec drop float ;
M: value move-spec class ;
M: cached move-spec drop cached ;
M: loc move-spec drop loc ;
M: f move-spec drop loc ;

: %move ( dst src -- )
    2dup [ move-spec ] 2apply 2array {
        { { f f } [ "Bug in generator.registers %move" throw ] }
        { { f value } [ value-literal swap load-literal ] }

        { { f float } [ %box-float ] }
        ! { { f unboxed-alien } [ %box-alien ] }
        { { f unboxed-c-ptr } [ %box-alien ] }
        { { f loc } [ %peek ] }

        { { float f } [ %unbox-float ] }
        { { unboxed-alien f } [ %unbox-alien ] }
        { { unboxed-byte-array f } [ %unbox-byte-array ] }
        { { unboxed-f f } [ %unbox-f ] }
        { { unboxed-c-ptr f } [ %unbox-c-ptr ] }
        { { loc f } [ swap %replace ] }

        [ drop temp-reg swap %move temp-reg %move ]
    } case ;

! A compile-time stack
TUPLE: phantom-stack height ;

GENERIC: finalize-height ( stack -- )

SYMBOL: phantom-d
SYMBOL: phantom-r

: <phantom-stack> ( class -- stack )
    >r
    V{ } clone 0
    { set-delegate set-phantom-stack-height }
    phantom-stack construct
    r> construct-delegate ;

: (loc)
    #! Utility for methods on <loc>
    phantom-stack-height - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    swap [
        phantom-stack-height
        dup zero? [ 2drop ] [ swap execute ] if
        0
    ] keep set-phantom-stack-height ; inline

GENERIC: <loc> ( n stack -- loc )

TUPLE: phantom-datastack ;

: <phantom-datastack> phantom-datastack <phantom-stack> ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ %inc-d (finalize-height) ;

TUPLE: phantom-retainstack ;

: <phantom-retainstack> phantom-retainstack <phantom-stack> ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ %inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    >r <reversed> r> [ <loc> ] curry map ;

: phantom-locs* ( phantom -- locs )
    dup length swap phantom-locs ;

: (each-loc) ( phantom quot -- )
    >r dup phantom-locs* swap r> 2each ; inline

: each-loc ( quot -- )
    >r phantom-d get r> phantom-r get over
    >r >r (each-loc) r> r> (each-loc) ; inline

: adjust-phantom ( n phantom -- )
    [ phantom-stack-height + ] keep set-phantom-stack-height ;

GENERIC: cut-phantom ( n phantom -- seq )

M: phantom-stack cut-phantom
    [ delegate cut* swap ] keep set-delegate ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom push-all ;

: phantom-input ( n phantom -- seq )
    [
        2dup length <= [
            cut-phantom
        ] [
            [ phantom-locs ] keep
            [ length head-slice* ] keep
            [ append ] keep
            delete-all
        ] if
    ] 2keep >r neg r> adjust-phantom ;

PRIVATE>

: phantom-push ( obj -- )
    1 phantom-d get adjust-phantom
    phantom-d get push ;

: phantom-shuffle ( shuffle -- )
    [ effect-in length phantom-d get phantom-input ] keep
    shuffle* phantom-d get phantom-append ;

: phantom->r ( n -- )
    phantom-d get phantom-input
    phantom-r get phantom-append ;

: phantom-r> ( n -- )
    phantom-r get phantom-input
    phantom-d get phantom-append ;

<PRIVATE

: phantoms ( -- phantom phantom ) phantom-d get phantom-r get ;

: each-phantom ( quot -- ) phantoms rot 2apply ; inline

: finalize-heights ( -- ) [ finalize-height ] each-phantom ;

! Phantom stacks hold values, locs, and vregs
GENERIC: live-vregs* ( obj -- )

M: cached live-vregs* cached-vreg live-vregs* ;
M: unboxed-alien live-vregs* unboxed-alien-vreg , ;
M: unboxed-byte-array live-vregs* unboxed-byte-array-vreg , ;
M: unboxed-f live-vregs* unboxed-f-vreg , ;
M: unboxed-c-ptr live-vregs* unboxed-c-ptr-vreg , ;
M: vreg live-vregs* , ;
M: object live-vregs* drop ;

: live-vregs ( -- seq )
    [ [ [ live-vregs* ] each ] each-phantom ] { } make ;

GENERIC: live-loc? ( actual current -- ? )

M: cached live-loc? cached-loc live-loc? ;
M: loc live-loc? = not ;
M: object live-loc? 2drop f ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    dup phantom-locs* swap 2array flip
    [ live-loc? ] assoc-subset
    values ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

! Operands holding pointers to freshly-allocated objects which
! are guaranteed to be in the nursery
SYMBOL: fresh-objects

! Computing free registers and initializing allocator
: free-vregs ( reg-class -- seq )
    #! Free vregs in a given register class
    \ free-vregs get at ;

: (compute-free-vregs) ( used class -- vector )
    #! Find all vregs in 'class' which are not in 'used'.
    [ vregs length reverse ] keep
    [ <vreg> ] curry map seq-diff
    >vector ;

: compute-free-vregs ( -- )
    #! Create a new hashtable for thee free-vregs variable.
    live-vregs
    { T{ int-regs } T{ float-regs f 8 } }
    [ 2dup (compute-free-vregs) ] H{ } map>assoc
    \ free-vregs set
    drop ;

: reg-spec>class ( spec -- class )
    float eq?
    T{ float-regs f 8 } T{ int-regs } ? ;

! Copying vregs to stacks
: alloc-vreg ( spec -- reg )
    dup reg-spec>class free-vregs pop swap {
        { unboxed-alien [ <unboxed-alien> ] }
        { unboxed-byte-array [ <unboxed-byte-array> ] }
        { unboxed-f [ <unboxed-f> ] }
        { unboxed-c-ptr [ <unboxed-c-ptr> ] }
        [ drop ]
    } case ;

: allocation ( value spec -- reg-class )
    dup quotation? [
        2drop f
    ] [
        dup rot move-spec = [
            drop f
        ] [
            reg-spec>class
        ] if
    ] if ;

GENERIC# (lazy-load) 1 ( value spec -- value )

M: cached (lazy-load)
    >r cached-vreg r> (lazy-load) ;

M: object (lazy-load)
    2dup allocation [ alloc-vreg dup rot %move ] [ drop ] if ;

GENERIC: lazy-store ( dst src -- )

M: loc lazy-store
    2dup = [ 2drop ] [ \ live-locs get at %move ] if ;

M: cached lazy-store
    2dup cached-loc = [ 2drop ] [ cached-vreg %move ] if ;

M: object lazy-store
    2drop ;

: do-shuffle ( hash -- )
    dup assoc-empty? [
        drop
    ] [
        \ live-locs set
        [ lazy-store ] each-loc
    ] if ;

: fast-shuffle ( locs -- )
    #! We have enough free registers to load all shuffle inputs
    #! at once
    [ dup f (lazy-load) ] H{ } map>assoc do-shuffle ;

GENERIC: minimal-ds-loc* ( min obj -- min )

M: cached minimal-ds-loc* cached-loc minimal-ds-loc* ;
M: ds-loc minimal-ds-loc* ds-loc-n min ;
M: object minimal-ds-loc* drop ;

: minimal-ds-loc ( phantom -- n )
    #! When shuffling more values than can fit in registers, we
    #! need to find an area on the data stack which isn't in
    #! use.
    dup phantom-stack-height neg [ minimal-ds-loc* ] reduce ;

: find-tmp-loc ( -- n )
    #! Find an area of the data stack which is not referenced
    #! from the phantom stacks. We can clobber there all we want
    [ minimal-ds-loc ] each-phantom min 1- ;

: slow-shuffle-mapping ( locs tmp -- pairs )
    >r dup length r>
    [ swap - <ds-loc> ] curry map swap 2array flip ;

: slow-shuffle ( locs -- )
    #! We don't have enough free registers to load all shuffle
    #! inputs, so we use a single temporary register, together
    #! with the area of the data stack above the stack pointer
    find-tmp-loc slow-shuffle-mapping
    [ [ %move ] assoc-each ] keep
    >hashtable do-shuffle ;

: fast-shuffle? ( live-locs -- ? )
    #! Test if we have enough free registers to load all
    #! shuffle inputs at once.
    T{ int-regs } free-vregs [ length ] 2apply <= ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    [
        \ free-vregs [ [ clone ] assoc-map ] change
        live-locs dup fast-shuffle?
        [ fast-shuffle ] [ slow-shuffle ] if
    ] with-scope ;

: finalize-vregs ( -- )
    #! Store any vregs to their final stack locations.
    [
        dup loc? over cached? or [ 2drop ] [ %move ] if
    ] each-loc ;

: finalize-contents ( -- )
    finalize-locs finalize-vregs [ delete-all ] each-phantom ;

: %gc ( -- )
    0 frame-required
    %prepare-alien-invoke
    "simple_gc" f %alien-invoke ;

! Loading stacks to vregs
: free-vregs# ( -- int# float# )
    T{ int-regs } T{ float-regs f 8 } 
    [ free-vregs length ] 2apply ;

: free-vregs? ( int# float# -- ? )
    free-vregs# swapd <= >r <= r> and ;

: ensure-vregs ( int# float# -- )
    compute-free-vregs free-vregs?
    [ finalize-contents compute-free-vregs ] unless ;

: phantom&spec ( phantom spec -- phantom' spec' )
    0 <column>
    [ length f pad-left ] keep
    [ <reversed> ] 2apply ; inline

: phantom&spec-agree? ( phantom spec quot -- ? )
    >r phantom&spec r> 2all? ; inline

: split-template ( input -- slow fast )
    phantom-d get
    2dup [ length ] 2apply <=
    [ drop { } swap ] [ length swap cut* ] if ;

: vreg-substitution ( value vreg -- pair )
    dupd <cached> 2array ;

: substitute-vreg? ( old new -- ? )
    #! We don't substitute locs for float or alien vregs,
    #! since in those cases the boxing overhead might kill us.
    cached-vreg {
        { [ dup vreg? not ] [ f ] }
        { [ dup delegate int-regs? not ] [ f ] }
        { [ over loc? not ] [ f ] }
        { [ t ] [ t ] }
    } cond 2nip ;

: substitute-vregs ( values vregs -- )
    [ vreg-substitution ] 2map
    [ substitute-vreg? ] assoc-subset >hashtable
    [ swap substitute ] curry each-phantom ;

: lazy-load ( values template -- )
    #! Set operand vars here.
    2dup [ first (lazy-load) ] 2map dup rot
    [ >r dup value? [ value-literal ] when r> second set ] 2each
    substitute-vregs ;

: fast-input ( template -- )
    dup empty? [
        drop
    ] [
        dup length phantom-d get phantom-input swap lazy-load
    ] if ;

: output-vregs ( -- seq seq )
    +output+ +clobber+ [ get [ get ] map ] 2apply ;

: clash? ( seq -- ? )
    phantoms append [
        dup cached? [ cached-vreg ] when swap member?
    ] curry* contains? ;

: outputs-clash? ( -- ? )
    output-vregs append clash? ;

: slow-input ( template -- )
    outputs-clash? [ finalize-contents ] when fast-input ;

: count-vregs ( reg-classes -- ) [ [ inc ] when* ] each ;

: count-input-vregs ( phantom spec -- )
    phantom&spec [
        >r dup cached? [ cached-vreg ] when r> allocation
    ] 2map count-vregs ;

: count-scratch-regs ( spec -- )
    [ first reg-spec>class ] map count-vregs ;

: guess-vregs ( dinput rinput scratch -- int# float# )
    H{
        { T{ int-regs } 0 }
        { T{ float-regs 8 } 0 }
    } clone [
        count-scratch-regs
        phantom-r get swap count-input-vregs
        phantom-d get swap count-input-vregs
        T{ int-regs } get T{ float-regs 8 } get
    ] bind ;

: alloc-scratch ( -- )
    +scratch+ get [ >r alloc-vreg r> set ] assoc-each ;

: guess-template-vregs ( -- int# float# )
    +input+ get { } +scratch+ get guess-vregs ;

: template-inputs ( -- )
    ! Ensure we have enough to hold any new stack elements we
    ! will read (if any), and scratch.
    guess-template-vregs ensure-vregs
    ! Split the template into available (fast) parts and those
    ! that require allocating registers and reading the stack
    +input+ get split-template fast-input slow-input
    ! Finally allocate scratch registers
    alloc-scratch ;

: template-outputs ( -- )
    +output+ get [ get ] map phantom-d get phantom-append ;

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    dup quotation? [
        over value?
        [ >r value-literal r> call ] [ 2drop f ] if
    ] [
        2drop t
    ] if ;

: template-specs-match? ( -- ? )
    phantom-d get +input+ get
    [ value-matches? ] phantom&spec-agree? ;

: class-tag ( class -- tag/f )
    dup hi-tag class< [
        drop object tag-number
    ] [
        flatten-builtin-class keys
        dup length 1 = [ first tag-number ] [ drop f ] if
    ] if ;

: class-match? ( actual expected -- ? )
    {
        { f [ drop t ] }
        { known-tag [ class-tag >boolean ] }
        [ class< ]
    } case ;

: template-classes-match? ( -- ? )
    #! Depends on node@
    node@ node-input-classes +input+ get
    [ 2 swap ?nth class-match? ] 2all? ;

: template-matches? ( spec -- ? )
    #! Depends on node@
    clone [
        template-specs-match?
        template-classes-match? and
        [ guess-template-vregs free-vregs? ] [ f ] if
    ] bind ;

: (find-template) ( templates -- pair/f )
    #! Depends on node@
    [ second template-matches? ] find nip ;

PRIVATE>

: end-basic-block ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents finalize-heights
    fresh-objects get dup empty? swap delete-all [ %gc ] unless ;

: with-template ( quot hash -- )
    clone [ template-inputs call template-outputs ] bind
    compute-free-vregs ;
    inline

: fresh-object ( obj -- ) fresh-objects get push ;

: fresh-object? ( obj -- ? ) fresh-objects get memq? ;

: init-templates ( -- )
    #! Initialize register allocator.
    V{ } clone fresh-objects set
    <phantom-datastack> phantom-d set
    <phantom-retainstack> phantom-r set
    compute-free-vregs ;

: copy-templates ( -- )
    #! Copies register allocator state, used when compiling
    #! branches.
    fresh-objects [ clone ] change
    phantom-d [ clone ] change
    phantom-r [ clone ] change
    compute-free-vregs ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot hash }
    #! Depends on node@
    compute-free-vregs
    dup (find-template) [ ] [
        finalize-contents (find-template)
    ] ?if ;

: operand-class ( operand -- class )
    #! Depends on node@
    +input+ get [ second = ] curry* find drop
    node@ tuck node-in-d nth node-class ;

: operand-tag ( operand -- tag/f )
    #! Depends on node@
    operand-class class-tag ;
