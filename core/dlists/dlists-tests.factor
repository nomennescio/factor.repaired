USING: dlists dlists.private kernel tools.test random assocs
hashtables sequences namespaces sorting debugger io prettyprint
math ;
IN: temporary

[ t ] [ <dlist> dlist-empty? ] unit-test

[ T{ dlist f T{ dlist-node f 1 f f } T{ dlist-node f 1 f f } 1 } ]
[ <dlist> 1 over push-front ] unit-test

! Make sure empty lists are empty
[ t ] [ <dlist> dlist-empty? ] unit-test
[ f ] [ <dlist> 1 over push-front dlist-empty? ] unit-test
[ f ] [ <dlist> 1 over push-back dlist-empty? ] unit-test

[ 1 ] [ <dlist> 1 over push-front pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-front pop-back ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-back ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-front dup pop-front* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-front dup pop-back* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-back dup pop-front* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-back dup pop-back* ] unit-test

! Test the prev,next links for two nodes
[ f ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-prev
] unit-test

[ 2 ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-obj
] unit-test

[ 1 ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-prev dlist-node-obj
] unit-test

[ f ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-next
] unit-test

[ f f ] [ <dlist> [ 1 = ] swap dlist-find ] unit-test
[ 1 t ] [ <dlist> 1 over push-back [ 1 = ] swap dlist-find ] unit-test
[ f f ] [ <dlist> 1 over push-back [ 2 = ] swap dlist-find ] unit-test
[ f ] [ <dlist> 1 over push-back [ 2 = ] swap dlist-contains? ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] swap dlist-contains? ] unit-test

[ 1 ] [ <dlist> 1 over push-back [ 1 = ] swap delete-node ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] over delete-node drop dlist-empty? ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] over delete-node drop dlist-empty? ] unit-test
[ 0 ] [ <dlist> 1 over push-back [ 1 = ] over delete-node drop dlist-length ] unit-test
[ 1 ] [ <dlist> 1 over push-back 2 over push-back [ 1 = ] over delete-node drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back [ 1 = ] over delete-node drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back [ 2 = ] over delete-node drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back [ 3 = ] over delete-node drop dlist-length ] unit-test

[ 0 ] [ <dlist> dlist-length ] unit-test
[ 1 ] [ <dlist> 1 over push-front dlist-length ] unit-test
[ 0 ] [ <dlist> 1 over push-front dup pop-front* dlist-length ] unit-test

: assert-same-elements
    [ prune natural-sort ] 2apply assert= ;

: dlist-push-all [ push-front ] curry each ;

: dlist-delete-all [ dlist-delete drop ] curry each ;

: dlist>array [ [ , ] dlist-slurp ] { } make ;

[ ] [
    5 [ drop 30 random >fixnum ] map prune
    6 [ drop 30 random >fixnum ] map prune 2dup nl . . nl
    [
        <dlist>
        [ dlist-push-all ] keep
        [ dlist-delete-all ] keep
        dlist>array
    ] 2keep seq-diff assert-same-elements
] unit-test

[ ] [
    <dlist> "d" set
    1 "d" get push-front
    2 "d" get push-front
    3 "d" get push-front
    4 "d" get push-front
    2 "d" get dlist-delete drop
    3 "d" get dlist-delete drop
    4 "d" get dlist-delete drop
] unit-test

[ 1 ] [ "d" get dlist-length ] unit-test
[ 1 ] [ "d" get dlist>array length ] unit-test
