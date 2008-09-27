! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations sequences.deep prettyprint
words namespaces slots slots.private classes mirrors
classes.tuple combinators calendar.format symbols
classes.singleton accessors quotations random ;
IN: db.types

HOOK: persistent-table db ( -- hash )
HOOK: compound db ( string obj -- hash )

TUPLE: sql-spec class slot-name column-name type primary-key modifiers ;

TUPLE: literal-bind key type value ;
C: <literal-bind> literal-bind

TUPLE: generator-bind slot-name key generator-singleton type ;
C: <generator-bind> generator-bind
SINGLETON: random-id-generator

TUPLE: low-level-binding value ;
C: <low-level-binding> low-level-binding

SINGLETONS: +db-assigned-id+ +user-assigned-id+ +random-id+ ;
UNION: +primary-key+ +db-assigned-id+ +user-assigned-id+ +random-id+ ;

SYMBOLS: +autoincrement+ +serial+ +unique+ +default+ +null+ +not-null+
+foreign-id+ +has-many+ +on-delete+ +restrict+ +cascade+ +set-null+
+set-default+ ;

: offset-of-slot ( string tuple -- n )
    class superclasses [ "slots" word-prop ] map concat
    slot-named offset>> ;

: get-slot-named ( name tuple -- value )
    tuck offset-of-slot slot ;

: set-slot-named ( value name obj -- )
    tuck offset-of-slot set-slot ;

ERROR: not-persistent class ;

: db-table ( class -- object )
    dup "db-table" word-prop [ ] [ not-persistent ] ?if ;

: db-columns ( class -- object )
    superclasses [ "db-columns" word-prop ] map concat ;

: db-relations ( class -- object )
    "db-relations" word-prop ;

: find-primary-key ( specs -- seq )
    [ primary-key>> ] filter ;

: set-primary-key ( value tuple -- )
    [
        class db-columns
        find-primary-key first slot-name>>
    ] keep set-slot-named ;

: primary-key? ( spec -- ? )
    primary-key>> +primary-key+? ;

: db-assigned-id-spec? ( specs -- ? )
    [ primary-key>> +db-assigned-id+? ] contains? ;

: assigned-id-spec? ( specs -- ? )
    [ primary-key>> +user-assigned-id+? ] contains? ;

: normalize-spec ( spec -- )
    dup type>> dup +primary-key+? [
        >>primary-key drop
    ] [
        drop dup modifiers>> [
            +primary-key+?
        ] deep-find
        [ >>primary-key drop ] [ drop ] if*
    ] if ;

: db-assigned? ( class -- ? )
    db-columns find-primary-key db-assigned-id-spec? ;

: relation? ( spec -- ? ) [ +has-many+ = ] deep-find ;

SYMBOLS: INTEGER BIG-INTEGER SIGNED-BIG-INTEGER UNSIGNED-BIG-INTEGER
DOUBLE REAL BOOLEAN TEXT VARCHAR DATE TIME DATETIME TIMESTAMP BLOB
FACTOR-BLOB NULL URL ;

: spec>tuple ( class spec -- tuple )
    3 f pad-right
    [ first3 ] keep 3 tail
    sql-spec new
        swap >>modifiers
        swap >>type
        swap >>column-name
        swap >>slot-name
        swap >>class
    dup normalize-spec ;

: number>string* ( n/string -- string )
    dup number? [ number>string ] when ;

: remove-db-assigned-id ( specs -- obj )
    [ +db-assigned-id+? not ] filter ;

: remove-relations ( specs -- newcolumns )
    [ relation? not ] filter ;

: remove-id ( specs -- obj )
    [ primary-key>> not ] filter ;

! SQLite Types: http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB
! PostgreSQL Types:
! http://developer.postgresql.org/pgdocs/postgres/datatype.html


: ?at ( obj assoc -- value/obj ? )
    dupd at* [ [ nip ] [ drop ] if ] keep ;

ERROR: unknown-modifier modifier ;

: lookup-modifier ( obj -- string )
    {
        { [ dup array? ] [ unclip lookup-modifier swap compound ] }
        [ persistent-table ?at [ unknown-modifier ] unless third ]
    } cond ;

ERROR: no-sql-type type ;

: (lookup-type) ( obj -- string )
    persistent-table ?at [ no-sql-type ] unless ;

: lookup-type ( obj -- string )
    dup array? [
        unclip (lookup-type) first nip
    ] [
        (lookup-type) first
    ] if ;

: lookup-create-type ( obj -- string )
    dup array? [
        unclip (lookup-type) second swap compound
    ] [
        (lookup-type) second
    ] if ;

: modifiers ( spec -- string )
    modifiers>> [ lookup-modifier ] map " " join
    [ "" ] [ " " prepend ] if-empty ;

: join-space ( string1 string2 -- new-string )
    " " swap 3append ;

: paren ( string -- new-string )
    "(" swap ")" 3append ;

HOOK: bind% db ( spec -- )
HOOK: bind# db ( spec obj -- )

: >reference-string ( string pair -- string )
    first2
    [ [ unparse join-space ] [ db-columns ] bi ] dip
    swap [ slot-name>> = ] with find nip
    column-name>> paren append ;
