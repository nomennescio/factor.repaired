USING: sequences.deep kernel tools.test strings math arrays
namespaces sequences ;
IN: sequences.deep.tests

[ [ "hello" 3 4 swap ] ] [ [ { "hello" V{ 3 4 } } swap ] flatten ] unit-test

[ "foo" t ] [ { { "foo" } "bar" } [ string? ] deep-find* ] unit-test

[ f f ] [ { { "foo" } "bar" } [ number? ] deep-find* ] unit-test

[ { { "foo" } "bar" } t ] [ { { "foo" } "bar" } [ array? ] deep-find* ] unit-test

: change-something ( seq -- newseq )
    dup array? [ "hi" suffix ] [ "hello" append ] if ;

[ { { "heyhello" "hihello" } "hihello" } ]
[ "hey" 1array 1array [ change-something ] deep-map ] unit-test

[ { { "heyhello" "hihello" } } ]
[ "hey" 1array 1array [ [ change-something ] deep-change-each ] keep ] unit-test

[ t ] [ "foo" [ string? ] deep-contains?  ] unit-test

[ "foo" ] [ "foo" [ string? ] deep-find ] unit-test

[ { { 1 2 } 1 2 } ] [ [ { 1 2 } [ , ] deep-each ] { } make ] unit-test
