USING: assocs kernel math.geometry.rect combinators accessors
math.vectors vectors sequences math math.points math.geometry
combinators.short-circuit arrays fry locals ;
IN: quadtrees

TUPLE: quadtree { bounds rect } point value ll lr ul ur leaf? ;

: <quadtree> ( bounds -- quadtree ) f f f f f f t quadtree boa ;

: rect-ll ( rect -- point ) loc>> ;
: rect-lr ( rect -- point ) [ loc>> ] [ width  ] bi v+x ;
: rect-ul ( rect -- point ) [ loc>> ] [ height ] bi v+y ;
: rect-ur ( rect -- point ) [ loc>> ] [ dim>>  ] bi v+  ;

: rect-center ( rect -- point ) [ loc>> ] [ dim>> 0.5 v*n ] bi v+ ; inline

<PRIVATE

DEFER: (prune)
DEFER: insert
DEFER: erase
DEFER: at-point
DEFER: quadtree>alist
DEFER: node-insert
DEFER: in-rect*

: child-dim ( rect -- dim/2 ) dim>> 0.5 v*n ; inline
: ll-bounds ( rect -- rect' )
    [   loc>>                                  ] [ child-dim ] bi <rect> ;
: lr-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.5 0.0 } v* ] bi v+ ] [ child-dim ] bi <rect> ;
: ul-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.0 0.5 } v* ] bi v+ ] [ child-dim ] bi <rect> ;
: ur-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.5 0.5 } v* ] bi v+ ] [ child-dim ] bi <rect> ;

: (quadrant) ( pt node -- quadrant )
    swap [ first 0.0 < ] [ second 0.0 < ] bi
    [ [ ll>> ] [ lr>> ] if ]
    [ [ ul>> ] [ ur>> ] if ] if ;

: quadrant ( pt node -- quadrant )
    [ bounds>> rect-center v- ] keep (quadrant) ;

: descend ( pt node -- pt subnode )
    [ drop ] [ quadrant ] 2bi ; inline

: {quadrants} ( node -- quadrants )
    { [ ll>> ] [ lr>> ] [ ul>> ] [ ur>> ] } cleave 4array ;

:: each-quadrant ( node quot -- array )
    node ll>> quot call
    node lr>> quot call
    node ul>> quot call
    node ur>> quot call ; inline
: map-quadrant ( node quot: ( child-node -- x ) -- array )
    each-quadrant 4array ; inline

: add-subnodes ( node -- node )
    dup bounds>> {
        [ ll-bounds <quadtree> >>ll ]
        [ lr-bounds <quadtree> >>lr ]
        [ ul-bounds <quadtree> >>ul ]
        [ ur-bounds <quadtree> >>ur ]
    } cleave
    f >>leaf? ;

: split-leaf ( value point leaf -- )
    add-subnodes
    [ value>> ] [ point>> ] [ ] tri
    [ node-insert ] [ node-insert ] bi ;

: leaf-replaceable? ( pt leaf -- ? ) point>> { [ nip not ] [ = ] } 2|| ;
: leaf-insert ( value point leaf -- )
    2dup leaf-replaceable?
    [ [ (>>point) ] [ (>>value) ] bi ]
    [ split-leaf ] if ;

: node-insert ( value point node -- )
    descend insert ;

: insert ( value point tree -- )
    dup leaf?>> [ leaf-insert ] [ node-insert ] if ;

: leaf-at-point ( point leaf -- value/f ? )
    tuck point>> = [ value>> t ] [ drop f f ] if ;

: node-at-point ( point node -- value/f ? )
    descend at-point ;

: at-point ( point tree -- value/f ? )
    dup leaf?>> [ leaf-at-point ] [ node-at-point ] if ;

: (node-in-rect*) ( values rect node -- values )
    2dup bounds>> intersects? [ in-rect* ] [ 2drop ] if ;
: node-in-rect* ( values rect node -- values )
    [ (node-in-rect*) ] with each-quadrant ;

: leaf-in-rect* ( values rect leaf -- values ) 
    tuck { [ nip point>> ] [ point>> swap intersects? ] } 2&&
    [ value>> over push ] [ drop ] if ;

: in-rect* ( values rect tree -- values )
    dup leaf?>> [ leaf-in-rect* ] [ node-in-rect* ] if ;

: leaf-erase ( point leaf -- )
    tuck point>> = [ f >>point f >>value ] when drop ;

: node-erase ( point node -- )
    descend erase ;

: erase ( point tree -- )
    dup leaf?>> [ leaf-erase ] [ node-erase ] if ;

: (?leaf) ( quadrant -- {point,value}/f )
    dup point>> [ swap value>> 2array ] [ drop f ] if* ;
: ?leaf ( quadrants -- {point,value}/f )
    [ (?leaf) ] map sift dup length {
        { 1 [ first ] }
        { 0 [ drop { f f } ] }
        [ 2drop f ]
    } case ;

: collapseable? ( node -- {point,value}/f )
    {quadrants} { [ [ leaf?>> ] all? ] [ ?leaf ] } 1&& ;

: remove-subnodes ( node -- leaf ) f >>ll f >>lr f >>ul f >>ur t >>leaf? ;

: collapse ( node {point,value} -- )
    first2 [ >>point ] [ >>value ] bi* remove-subnodes drop ;

: node-prune ( node -- )
    [ [ (prune) ] each-quadrant ] [ ] [ collapseable? ] tri
    [ collapse ] [ drop ] if* ;

: (prune) ( tree -- )
    dup leaf?>> [ drop ] [ node-prune ] if ;

: leaf>alist ( leaf -- alist )
    dup point>> [ [ point>> ] [ value>> ] bi 2array 1array ] [ drop { } ] if ;

: node>alist ( node -- alist ) [ quadtree>alist ] map-quadrant concat ;

: quadtree>alist ( tree -- assoc )
    dup leaf?>> [ leaf>alist ] [ node>alist ] if ;

: leaf= ( a b -- ? ) [ [ point>> ] [ value>> ] bi 2array ] bi@ = ;

: node= ( a b -- ? ) [ {quadrants} ] bi@ = ;

: (tree=) ( a b -- ? ) dup leaf?>> [ leaf= ] [ node= ] if ;

: tree= ( a b -- ? )
    2dup [ leaf?>> ] bi@ = [ (tree=) ] [ 2drop f ] if ;

PRIVATE>

: prune ( tree -- tree ) [ (prune) ] keep ;

: in-rect ( tree rect -- values )
    [ 16 <vector> ] 2dip in-rect* ;

M: quadtree equal? ( a b -- ? )
    over quadtree? [ tree= ] [ 2drop f ] if ;

INSTANCE: quadtree assoc

M: quadtree at* ( key assoc -- value/f ? ) at-point ;
M: quadtree assoc-size ( assoc -- n ) quadtree>alist length ; ! XXX implement proper
M: quadtree >alist ( assoc -- alist ) quadtree>alist ;
M: quadtree set-at ( value key assoc -- ) insert ;
M: quadtree delete-at ( key assoc -- ) erase ;
M: quadtree clear-assoc ( assoc -- )
    t >>leaf?
    f >>point
    f >>value
    drop ;

