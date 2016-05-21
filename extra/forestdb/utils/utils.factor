! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs continuations forestdb.lib fry io.directories
io.files.temp kernel math.parser math.ranges sequences ;
IN: forestdb.utils

: with-forestdb-test-db-kvs ( name quot -- )
    '[
        "forestdb-test" ".db" [
            _ _ with-forestdb-kvs 
        ] cleanup-unique-file
    ] with-temp-directory ; inline

: with-forestdb-test-db ( quot -- )
    '[
        "forestdb-test" ".db" [
            "default" _ with-forestdb-kvs 
        ] cleanup-unique-file
    ] with-temp-directory ; inline

: make-kv-nth ( n -- key val )
    number>string [ "key" prepend ] [ "val" prepend ] bi ;

: make-kv-n ( n -- seq )
    [1,b] [ make-kv-nth ] { } map>assoc ;

: make-kv-range ( a b -- seq )
    [a,b] [ make-kv-nth ] { } map>assoc ;

: set-kv-n ( n -- )
    make-kv-n [ fdb-set-kv ] assoc-each ;

: del-kv-n ( n -- )
    make-kv-n keys [ fdb-del-kv ] each ;

: set-kv-nth ( n -- )
    make-kv-nth fdb-set-kv ;

: set-kv-range ( a b -- )
    make-kv-range [ fdb-set-kv ] assoc-each ;
