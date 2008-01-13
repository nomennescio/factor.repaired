! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays vectors kernel kernel.private sequences
namespaces math splitting sorting quotations assocs ;
IN: continuations

SYMBOL: error
SYMBOL: error-continuation
SYMBOL: restarts

<PRIVATE

: catchstack* ( -- catchstack )
    1 getenv { vector } declare ; inline

: >c ( continuation -- ) catchstack* push ;

: c> ( -- continuation ) catchstack* pop ;

: (catch) ( quot -- newquot )
    [ swap >c call c> drop ] curry ; inline

: dummy ( -- obj )
    #! Optimizing compiler assumes stack won't be messed with
    #! in-transit. To ensure that a value is actually reified
    #! on the stack, we put it in a non-inline word together
    #! with a declaration.
    f { object } declare ;

PRIVATE>

: catchstack ( -- catchstack ) catchstack* clone ; inline

: set-catchstack ( catchstack -- ) >vector 1 setenv ; inline

TUPLE: continuation data call retain name catch ;

C: <continuation> continuation

: continuation ( -- continuation )
    datastack callstack retainstack namestack catchstack
    <continuation> ;

: >continuation< ( continuation -- data call retain name catch )
    {
        continuation-data
        continuation-call
        continuation-retain
        continuation-name
        continuation-catch
    } get-slots ;

: ifcc ( capture restore -- )
    #! After continuation is being captured, the stacks looks
    #! like:
    #! ( f continuation r:capture r:restore )
    #! so the 'capture' branch is taken.
    #!
    #! Note that the continuation itself is not captured as part
    #! of the datastack.
    #!
    #! BUT...
    #!
    #! After the continuation is resumed, (continue-with) pushes
    #! the given value together with f,
    #! so now, the stacks looks like:
    #! ( value f r:capture r:restore )
    #! Execution begins right after the call to 'continuation'.
    #! The 'restore' branch is taken.
    >r >r dummy continuation r> r> ?if ; inline

: callcc0 ( quot -- ) [ drop ] ifcc ; inline

: callcc1 ( quot -- obj ) [ ] ifcc ; inline

<PRIVATE

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-retainstack
    >r set-datastack r>
    set-callstack ;

: (continue-with) ( obj continuation -- )
    swap 4 setenv
    >continuation<
    set-catchstack
    set-namestack
    set-retainstack
    >r set-datastack drop 4 getenv f 4 setenv f r>
    set-callstack ;

PRIVATE>

: set-walker-hook ( quot -- ) 3 setenv ; inline

: walker-hook ( -- quot ) 3 getenv f set-walker-hook ; inline

: continue-with ( obj continuation -- )
    [
        walker-hook [ >r 2array r> ] when* (continue-with)
    ] 2curry (throw) ;

: continue ( continuation -- )
    f swap continue-with ;

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    dup error set-global
    compute-restarts restarts set-global ;

PRIVATE>

: rethrow ( error -- * )
    catchstack* empty? [ die ] when
    dup save-error c> continue-with ;

: catch ( try -- error/f )
    (catch) [ f ] compose callcc1 ; inline

: recover ( try recovery -- )
    >r (catch) r> ifcc ; inline

: cleanup ( try cleanup-always cleanup-error -- )
    over >r compose [ dip rethrow ] curry
    recover r> call ; inline

: attempt-all ( seq quot -- obj )
    [
        [ [ , f ] compose [ , drop t ] recover ] curry all?
    ] { } make peek swap [ rethrow ] when ; inline

TUPLE: condition restarts continuation ;

: <condition> ( error restarts cc -- condition )
    {
        set-delegate
        set-condition-restarts
        set-condition-continuation
    } condition construct ;

: throw-restarts ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

: rethrow-restarts ( error restarts -- restart )
    [ <condition> rethrow ] callcc1 2nip ;

TUPLE: restart name obj continuation ;

C: <restart> restart

: restart ( restart -- )
    dup restart-obj swap restart-continuation continue-with ;

M: object compute-restarts drop { } ;

M: tuple compute-restarts delegate compute-restarts ;

M: condition compute-restarts
    [ delegate compute-restarts ] keep
    [ condition-restarts ] keep
    condition-continuation
    [ <restart> ] curry { } assoc>map
    append ;

<PRIVATE

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! VM calls on error
    [
        continuation error-continuation set-global rethrow
    ] 5 setenv
    ! VM adds this to kernel errors, so that user-space
    ! can identify them
    "kernel-error" 6 setenv ;

PRIVATE>

! Debugging support
: with-walker-hook ( continuation -- )
    [ swap set-walker-hook (continue) ] curry callcc1 ;

SYMBOL: break-hook

: break ( -- )
    continuation callstack
    over set-continuation-call
    walker-hook [ (continue-with) ] [ break-hook get call ] if* ;

GENERIC: (step-into) ( obj -- )

M: wrapper (step-into) wrapped break ;
M: object (step-into) break ;
M: callable (step-into) \ break add* break ;
