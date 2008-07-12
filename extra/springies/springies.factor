
USING: kernel combinators sequences arrays math math.vectors
       generalizations vars accessors math.physics.vel ;

IN: springies

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scalar-projection ( a b -- n ) [ v. ] [ nip norm ] 2bi / ;

: vector-projection ( a b -- vec )
  [ nip normalize ] [ scalar-projection ] 2bi v*n ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: nodes
VAR: springs
VAR: time-slice
VAR: world-size

: world-width ( -- width ) world-size> first ;

: world-height ( -- height ) world-size> second ;

VAR: gravity

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! node
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! TUPLE: node mass elas pos vel force ;

TUPLE: node < vel mass elas force ;

C: <node> node

! : >>pos ( node pos -- node ) over set-node-pos ;

! : >>vel ( node vel -- node ) over set-node-vel ;

: node-vel ( node -- vel ) vel>> ;

: set-node-vel ( vel node -- ) swap >>vel drop ;

: pos-x ( node -- x ) pos>> first ;
: pos-y ( node -- y ) pos>> second ;
: vel-x ( node -- y ) vel>> first ;
: vel-y ( node -- y ) vel>> second ;

: >>pos-x ( node x -- node ) over pos>> set-first ;
: >>pos-y ( node y -- node ) over pos>> set-second ;
: >>vel-x ( node x -- node ) over vel>> set-first ;
: >>vel-y ( node y -- node ) over vel>> set-second ;

: apply-force ( node vec -- ) over node-force v+ swap set-node-force ;

: reset-force ( node -- ) 0 0 2array swap set-node-force ;

: node-id ( id -- node ) 1- nodes> nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! spring
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: spring rest-length k damp node-a node-b ;

C: <spring> spring

: end-points ( spring -- b-pos a-pos )
  [ spring-node-b pos>> ] [ spring-node-a pos>> ] bi ;

: spring-length ( spring -- length ) end-points v- norm ;

: stretch-length ( spring -- length )
  [ spring-length ] [ spring-rest-length ] bi - ;

: dir ( spring -- vec ) end-points v- normalize ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Hooke
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! F = -kx
! 
! k :: spring constant
! x :: distance stretched beyond rest length
! 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hooke-force-mag ( spring -- mag ) [ spring-k ] [ stretch-length ] bi * ;

: hooke-force ( spring -- force ) [ dir ] [ hooke-force-mag ] bi v*n ;

: hooke-forces ( spring -- a b ) hooke-force dup vneg ;

: act-on-nodes-hooke ( spring -- )
  [ spring-node-a ] [ spring-node-b ] [ ] tri hooke-forces swapd
  apply-force
  apply-force ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! damping
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! F = -bv
! 
! b :: Damping constant
! v :: Velocity
! 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : damping-force-a ( spring -- vec )
!   [ spring-node-a node-vel ] [ spring-damp ] bi v*n vneg ;

! : damping-force-b ( spring -- vec )
!   [ spring-node-b node-vel ] [ spring-damp ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-velocity-a ( spring -- vel )
  [ spring-node-a vel>> ] [ spring-node-b vel>> ] bi v- ;

: unit-vec-b->a ( spring -- vec )
  [ spring-node-a pos>> ] [ spring-node-b pos>> ] bi v- ;

: relative-velocity-along-spring-a ( spring -- vel )
  [ relative-velocity-a ] [ unit-vec-b->a ] bi vector-projection ;

: damping-force-a ( spring -- vec )
  [ relative-velocity-along-spring-a ] [ spring-damp ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-velocity-b ( spring -- vel )
  [ spring-node-b vel>> ] [ spring-node-a vel>> ] bi v- ;

: unit-vec-a->b ( spring -- vec )
  [ spring-node-b pos>> ] [ spring-node-a pos>> ] bi v- ;

: relative-velocity-along-spring-b ( spring -- vel )
  [ relative-velocity-b ] [ unit-vec-a->b ] bi vector-projection ;

: damping-force-b ( spring -- vec )
  [ relative-velocity-along-spring-b ] [ spring-damp ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: act-on-nodes-damping ( spring -- )
  dup
  [ spring-node-a ] [ damping-force-a ] bi apply-force
  [ spring-node-b ] [ damping-force-b ] bi apply-force ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: below? ( node -- ? ) pos-y 0 < ;

: above? ( node -- ? ) pos-y world-height >= ;

: beyond-left? ( node -- ? ) pos-x 0 < ; 

: beyond-right? ( node -- ? ) pos-x world-width >= ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bounce-top ( node -- )
  world-height 1- >>pos-y
  dup [ vel-y ] [ node-elas ] bi * neg >>vel-y
  drop ;

: bounce-bottom ( node -- )
  0 >>pos-y
  dup [ vel-y ] [ node-elas ] bi * neg >>vel-y
  drop ;

: bounce-left ( node -- )
  0 >>pos-x
  dup [ vel-x ] [ node-elas ] bi * neg >>vel-x
  drop ;

: bounce-right ( node -- )
  world-width 1- >>pos-x
  dup [ vel-x ] [ node-elas ] bi * neg >>vel-x
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: handle-bounce ( node -- )
  { { [ dup above? ]        [ bounce-top ] }
    { [ dup below? ]        [ bounce-bottom ] }
    { [ dup beyond-left? ]  [ bounce-left ] }
    { [ dup beyond-right? ] [ bounce-right ] }
    { [ t ]                 [ drop ] } }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: act-on-nodes ( spring -- )
  dup
  act-on-nodes-hooke
  act-on-nodes-damping ;

! : act-on-nodes ( spring -- ) act-on-nodes-hooke ;

: loop-over-springs ( -- ) springs> [ act-on-nodes ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply-gravity ( node -- ) { 0 -9.8 } apply-force ;

: do-gravity ( -- ) gravity> [ nodes> [ apply-gravity ] each ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! F = ma

: calc-acceleration ( node -- vec ) [ node-force ] [ node-mass ] bi v/n ;

: new-vel ( node -- vel )
  [ vel>> ] [ calc-acceleration time-slice> v*n ] bi v+ ;

: new-pos ( node -- pos ) [ pos>> ] [ vel>> time-slice> v*n ] bi v+ ;

: iterate-node ( node -- )
  dup new-pos >>pos
  dup new-vel >>vel
  dup reset-force
  handle-bounce ;

: iterate-nodes ( -- ) nodes> [ iterate-node ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-system ( -- ) do-gravity loop-over-springs iterate-nodes ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Reading xspringies data files
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mass ( id x y x-vel y-vel mass elas -- )
  node new
    swap >>elas
    swap >>mass
    -rot 2array >>vel
    -rot 2array >>pos
    0 0  2array >>force
  nodes> swap suffix >nodes
  drop ;

: spng ( id id-a id-b k damp rest-length -- )
   spring new
     swap >>rest-length
     swap >>damp
     swap >>k
     swap node-id >>node-b
     swap node-id >>node-a
   springs> swap suffix >springs
   drop ;