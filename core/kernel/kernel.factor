! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel.private slots.private classes.tuple.private ;
IN: kernel

! Stack stuff
: spin ( x y z -- z y x ) swap rot ; inline

: roll ( x y z t -- y z t x ) >r rot r> swap ; inline

: -roll ( x y z t -- t x y z ) swap >r -rot r> ; inline

: 2over ( x y z -- x y z x y ) pick pick ; inline

: clear ( -- ) { } set-datastack ;

! Combinators
GENERIC: call ( callable -- )

DEFER: if

: ? ( ? true false -- true/false )
    #! 'if' and '?' can be defined in terms of each other
    #! because the JIT special-cases an 'if' preceeded by
    #! two literal quotations.
    rot [ drop ] [ nip ] if ; inline

: if ( ? true false -- ) ? call ;

! Single branch
: unless ( ? false -- )
    swap [ drop ] [ call ] if ; inline

: when ( ? true -- )
    swap [ call ] [ drop ] if ; inline

! Anaphoric
: if* ( ? true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: when* ( ? true -- )
    over [ call ] [ 2drop ] if ; inline

: unless* ( ? false -- )
    over [ drop ] [ nip call ] if ; inline

! Default
: ?if ( default cond true false -- )
    pick [ roll 2drop call ] [ 2nip call ] if ; inline

! Slippers
: slip ( quot x -- x ) >r call r> ; inline

: 2slip ( quot x y -- x y ) >r >r call r> r> ; inline

: 3slip ( quot x y z -- x y z ) >r >r >r call r> r> r> ; inline

: dip ( obj quot -- obj ) swap slip ; inline

: 2dip ( obj1 obj2 quot -- obj1 obj2 ) -rot 2slip ; inline

: 3dip ( obj1 obj2 obj3 quot -- obj1 obj2 obj3 ) -roll 3slip ; inline

! Keepers
: keep ( x quot -- x ) over slip ; inline

: 2keep ( x y quot -- x y ) 2over 2slip ; inline

: 3keep ( x y z quot -- x y z ) >r 3dup r> -roll 3slip ; inline

! Cleavers
: bi ( x p q -- )
    >r keep r> call ; inline

: tri ( x p q r -- )
    >r >r keep r> keep r> call ; inline

! Double cleavers
: 2bi ( x y p q -- )
    >r 2keep r> call ; inline

: 2tri ( x y p q r -- )
    >r >r 2keep r> 2keep r> call ; inline

! Triple cleavers
: 3bi ( x y z p q -- )
    >r 3keep r> call ; inline

: 3tri ( x y z p q r -- )
    >r >r 3keep r> 3keep r> call ; inline

! Spreaders
: bi* ( x y p q -- )
    >r dip r> call ; inline

: tri* ( x y z p q r -- )
    >r >r 2dip r> dip r> call ; inline

! Double spreaders
: 2bi* ( w x y z p q -- )
    >r 2dip r> call ; inline

! Appliers
: bi@ ( x y quot -- )
    dup bi* ; inline

: tri@ ( x y z quot -- )
    dup dup tri* ; inline

! Double appliers
: 2bi@ ( w x y z quot -- )
    dup 2bi* ; inline

: loop ( pred: ( -- ? ) -- )
    dup slip swap [ loop ] [ drop ] if ; inline recursive

: while ( pred: ( -- ? ) body: ( -- ) tail: ( -- ) -- )
    >r >r dup slip r> r> roll
    [ >r tuck 2slip r> while ]
    [ 2nip call ] if ; inline recursive

! Object protocol
GENERIC: hashcode* ( depth obj -- code )

M: object hashcode* 2drop 0 ;

M: f hashcode* 2drop 31337 ;

: hashcode ( obj -- code ) 3 swap hashcode* ; inline

GENERIC: equal? ( obj1 obj2 -- ? )

M: object equal? 2drop f ;

TUPLE: identity-tuple ;

M: identity-tuple equal? 2drop f ;

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [ equal? ] if ; inline

GENERIC: clone ( obj -- cloned )

M: object clone ;

M: callstack clone (clone) ;

! Tuple construction
GENERIC: new ( class -- tuple )

GENERIC: boa ( ... class -- tuple )

! Quotation building
: 2curry ( obj1 obj2 quot -- curry )
    curry curry ; inline

: 3curry ( obj1 obj2 obj3 quot -- curry )
    curry curry curry ; inline

: with ( param obj quot -- obj curry )
    swapd [ swapd call ] 2curry ; inline

: prepose ( quot1 quot2 -- compose )
    swap compose ; inline

: 3compose ( quot1 quot2 quot3 -- compose )
    compose compose ; inline

! Booleans
: not ( obj -- ? ) [ f ] [ t ] if ; inline

: and ( obj1 obj2 -- ? ) over ? ; inline

: >boolean ( obj -- ? ) [ t ] [ f ] if ; inline

: or ( obj1 obj2 -- ? ) dupd ? ; inline

: xor ( obj1 obj2 -- ? ) [ f swap ? ] when* ; inline

: both? ( x y quot -- ? ) bi@ and ; inline

: either? ( x y quot -- ? ) bi@ or ; inline

: most ( x y quot -- z )
    >r 2dup r> call [ drop ] [ nip ] if ; inline

! Error handling -- defined early so that other files can
! throw errors before continuations are loaded
: throw ( error -- * ) 5 getenv [ die ] or 1 (throw) ;

ERROR: assert got expect ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

<PRIVATE

: declare ( spec -- ) drop ;

: hi-tag ( obj -- n ) { hi-tag } declare 0 slot ; inline

: do-primitive ( number -- ) "Improper primitive call" throw ;

PRIVATE>
