! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math namespaces sequences system
kernel.private byte-arrays arrays ;
IN: alien

! Some predicate classes used by the compiler for optimization
! purposes
PREDICATE: simple-alien < alien underlying>> not ;

UNION: simple-c-ptr
simple-alien POSTPONE: f byte-array ;

DEFER: pinned-c-ptr?

PREDICATE: pinned-alien < alien underlying>> pinned-c-ptr? ;

UNION: pinned-c-ptr
    pinned-alien POSTPONE: f ;

GENERIC: expired? ( c-ptr -- ? ) flushable

M: alien expired? expired>> ;

M: f expired? drop t ;

: <alien> ( address -- alien )
    f <displaced-alien> { simple-c-ptr } declare ; inline

: <bad-alien> ( -- alien )
    -1 <alien> t >>expired ; inline

M: alien equal?
    over alien? [
        2dup [ expired? ] either? [
            [ expired? ] both?
        ] [
            [ alien-address ] bi@ =
        ] if
    ] [
        2drop f
    ] if ;

SYMBOL: libraries

libraries global [ H{ } assoc-like ] change-at

TUPLE: library path abi dll ;

: library ( name -- library ) libraries get at ;

: <library> ( path abi -- library )
    over dup [ dlopen ] when \ library boa ;

: load-library ( name -- dll )
    library dup [ library-dll ] when ;

: add-library ( name path abi -- )
    <library> swap libraries get set-at ;

ERROR: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    alien-callback-error ;

ERROR: alien-indirect-error ;

: alien-indirect ( ... funcptr return parameters abi -- )
    alien-indirect-error ;

ERROR: alien-invoke-error library symbol ;

: alien-invoke ( ... return library function parameters -- ... )
    2over alien-invoke-error ;
