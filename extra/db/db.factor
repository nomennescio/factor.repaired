! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib tuples words ;
IN: db

TUPLE: db handle ;
C: <db> db ( handle -- obj )

! HOOK: db-create db ( str -- )
! HOOK: db-drop db ( str -- )
GENERIC: db-open ( db -- )
GENERIC: db-close ( db -- )

TUPLE: statement sql params handle bound? ;

TUPLE: simple-statement ;
TUPLE: prepared-statement ;

HOOK: <simple-statement> db ( str -- statement )
HOOK: <prepared-statement> db ( str -- statement )

GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( obj statement -- )
GENERIC: rebind-statement ( obj statement -- )

GENERIC: execute-statement ( statement -- )

: bind-statement ( obj statement -- )
    2dup dup statement-bound? [
        rebind-statement
    ] [
        bind-statement*
    ] if
    tuck set-statement-params
    t swap set-statement-bound? ;

TUPLE: result-set sql params handle n max ;

GENERIC: query-results ( query -- result-set )

GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set n -- obj )
GENERIC: advance-row ( result-set -- ? )

: init-result-set ( result-set -- )
    dup #rows over set-result-set-max
    -1 swap set-result-set-n ;

: <result-set> ( query handle tuple -- result-set )
    >r >r { statement-sql statement-params } get-slots r>
    {
        set-result-set-sql
        set-result-set-params
        set-result-set-handle
    } result-set construct r> construct-delegate ;

: sql-row ( result-set -- seq )
    dup #columns [ row-column ] with map ;

: query-each ( statement quot -- )
    over advance-row [
        2drop
    ] [
        [ call ] 2keep query-each
    ] if ; inline

: query-map ( statement quot -- seq )
    accumulator >r query-each r> { } like ; inline

: with-db ( db quot -- )
    [
        over db-open
        [ db swap with-variable ] curry with-disposal
    ] with-scope ;

: do-query ( query -- result-set )
    query-results [ [ sql-row ] query-map ] with-disposal ;

: do-bound-query ( obj query -- rows )
    [ bind-statement ] keep do-query ;

: do-bound-command ( obj query -- )
    [ bind-statement ] keep execute-statement ;

: sql-query ( sql -- rows )
    <simple-statement> [ do-query ] with-disposal ;

: sql-command ( sql -- )
    <simple-statement> [ execute-statement ] with-disposal ;

SYMBOL: in-transaction
HOOK: begin-transaction db ( -- )
HOOK: commit-transaction db ( -- )
HOOK: rollback-transaction db ( -- )

: in-transaction? ( -- ? ) in-transaction get ;

: with-transaction ( quot -- )
    t in-transaction [
        begin-transaction
        [ ] [ rollback-transaction ] cleanup commit-transaction
    ] with-variable ;
