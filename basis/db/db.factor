! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations destructors kernel math
namespaces sequences classes.tuple words strings
tools.walker accessors combinators ;
IN: db

TUPLE: db
    handle
    insert-statements
    update-statements
    delete-statements ;

: new-db ( class -- obj )
    new
        H{ } clone >>insert-statements
        H{ } clone >>update-statements
        H{ } clone >>delete-statements ; inline

GENERIC: make-db* ( object db -- db )

: make-db ( object class -- db ) new-db make-db* ;

GENERIC: db-open ( db -- db )
HOOK: db-close db ( handle -- )

: dispose-statements ( assoc -- ) values dispose-each ;

: db-dispose ( db -- ) 
    dup db [
        {
            [ insert-statements>> dispose-statements ]
            [ update-statements>> dispose-statements ]
            [ delete-statements>> dispose-statements ]
            [ handle>> db-close ]
        } cleave
    ] with-variable ;

TUPLE: result-set sql in-params out-params handle n max ;

GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set column -- obj )
GENERIC# row-column-typed 1 ( result-set column -- sql )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

: init-result-set ( result-set -- )
    dup #rows >>max
    0 >>n drop ;

: new-result-set ( query handle class -- result-set )
    new
        swap >>handle
        >r [ sql>> ] [ in-params>> ] [ out-params>> ] tri r>
        swap >>out-params
        swap >>in-params
        swap >>sql ;

TUPLE: statement handle sql in-params out-params bind-params bound? type retries ;
TUPLE: simple-statement < statement ;
TUPLE: prepared-statement < statement ;

: new-statement ( sql in out class -- statement )
    new
        swap >>out-params
        swap >>in-params
        swap >>sql ;

HOOK: <simple-statement> db ( string in out -- statement )
HOOK: <prepared-statement> db ( string in out -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( statement -- )
GENERIC: low-level-bind ( statement -- )
GENERIC: bind-tuple ( tuple statement -- )

GENERIC: execute-statement* ( statement type -- )

M: object execute-statement* ( statement type -- )
    drop query-results dispose ;

: execute-statement ( statement -- )
    dup sequence? [
        [ execute-statement ] each
    ] [
        dup type>> execute-statement*
    ] if ;

: bind-statement ( obj statement -- )
    swap >>bind-params
    [ bind-statement* ] keep
    t >>bound? drop ;

: sql-row ( result-set -- seq )
    dup #columns [ row-column ] with map ;

: sql-row-typed ( result-set -- seq )
    dup #columns [ row-column-typed ] with map ;

: query-each ( statement quot: ( statement -- ) -- )
    over more-rows? [
        [ call ] 2keep over advance-row query-each
    ] [
        2drop
    ] if ; inline recursive

: query-map ( statement quot -- seq )
    accumulator [ query-each ] dip { } like ; inline

: with-db ( seq class quot -- )
    [ make-db db-open db ] dip
    [ db get swap [ drop ] prepose with-disposal ] curry with-variable ;
    inline

: default-query ( query -- result-set )
    query-results [ [ sql-row ] query-map ] with-disposal ;

: sql-query ( sql -- rows )
    f f <simple-statement> [ default-query ] with-disposal ;

: sql-command ( sql -- )
    dup string? [
        f f <simple-statement> [ execute-statement ] with-disposal
    ] [
        ! [
            [ sql-command ] each
        ! ] with-transaction
    ] if ;

SYMBOL: in-transaction
HOOK: begin-transaction db ( -- )
HOOK: commit-transaction db ( -- )
HOOK: rollback-transaction db ( -- )

M: db begin-transaction ( -- ) "BEGIN" sql-command ;
M: db commit-transaction ( -- ) "COMMIT" sql-command ;
M: db rollback-transaction ( -- ) "ROLLBACK" sql-command ;

: in-transaction? ( -- ? ) in-transaction get ;

: with-transaction ( quot -- )
    t in-transaction [
        begin-transaction
        [ ] [ rollback-transaction ] cleanup commit-transaction
    ] with-variable ;
