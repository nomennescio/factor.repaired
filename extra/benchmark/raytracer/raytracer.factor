! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/free/ray_tracer/languages.html

USING: arrays accessors float-arrays io io.files
io.encodings.binary kernel math math.functions math.vectors
math.parser make sequences sequences.private words hints ;
IN: benchmark.raytracer

! parameters
: light
    #! Normalized { -1 -3 2 }.
    F{
        -0.2672612419124244
        -0.8017837257372732
        0.5345224838248488
    } ; inline

: oversampling 4 ; inline

: levels 3 ; inline

: size 200 ; inline

: delta 1.4901161193847656E-8 ; inline

TUPLE: ray { orig float-array read-only } { dir float-array read-only } ;

C: <ray> ray

TUPLE: hit { normal float-array read-only } { lambda float read-only } ;

C: <hit> hit

GENERIC: intersect-scene ( hit ray scene -- hit )

TUPLE: sphere { center float-array read-only } { radius float read-only } ;

C: <sphere> sphere

: sphere-v ( sphere ray -- v )
    [ center>> ] [ orig>> ] bi* v- ; inline

: sphere-b ( v ray -- b )
    dir>> v. ; inline

: sphere-d ( sphere b v -- d )
    [ radius>> sq ] [ sq ] [ norm-sq ] tri* - + ; inline

: -+ ( x y -- x-y x+y )
    [ - ] [ + ] 2bi ; inline

: sphere-t ( b d -- t )
    -+ dup 0.0 <
    [ 2drop 1.0/0.0 ] [ [ [ 0.0 > ] keep ] dip ? ] if ; inline

: sphere-b&v ( sphere ray -- b v )
    [ sphere-v ] [ nip ] 2bi
    [ sphere-b ] [ drop ] 2bi ; inline

: ray-sphere ( sphere ray -- t )
    [ drop ] [ sphere-b&v ] 2bi
    [ drop ] [ sphere-d ] 3bi
    dup 0.0 < [ 3drop 1/0. ] [ sqrt sphere-t nip ] if ; inline

: if-ray-sphere ( hit ray sphere quot -- hit )
    #! quot: hit ray sphere l -- hit
    [
        [ ] [ swap ray-sphere nip ] [ 2drop lambda>> ] 3tri
        [ drop ] [ < ] 2bi
    ] dip [ 3drop ] if ; inline

: sphere-n ( ray sphere l -- n )
    [ [ orig>> ] [ dir>> ] bi ] [ center>> ] [ ] tri*
    swap [ v*n ] dip v- v+ ; inline

M: sphere intersect-scene ( hit ray sphere -- hit )
    [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ;

TUPLE: group < sphere { objs array read-only } ;

: <group> ( objs bound -- group )
    [ center>> ] [ radius>> ] bi rot group boa ; inline

: make-group ( bound quot -- )
    swap [ { } make ] dip <group> ; inline

M: group intersect-scene ( hit ray group -- hit )
    [ drop objs>> [ intersect-scene ] with each ] if-ray-sphere ;

: initial-hit T{ hit f F{ 0.0 0.0 0.0 } 1/0. } ; inline

: initial-intersect ( ray scene -- hit )
    [ initial-hit ] 2dip intersect-scene ; inline

: ray-o ( ray hit -- o )
    [ [ orig>> ] [ normal>> delta v*n ] bi* ]
    [ [ dir>> ] [ lambda>> ] bi* v*n ]
    2bi v+ v+ ; inline

: sray-intersect ( ray scene hit -- ray )
    swap [ ray-o light vneg <ray> ] dip initial-intersect ; inline

: ray-g ( hit -- g ) normal>> light v. ; inline

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup lambda>> 1/0. = [
        3drop 0.0
    ] [
        [ sray-intersect lambda>> 1/0. = ] keep swap
        [ ray-g neg ] [ drop 0.0 ] if
    ] if ; inline

: create-center ( c r d -- c2 )
    [ 3.0 12.0 sqrt / * ] dip n*v v+ ; inline

DEFER: create ( level c r -- scene )

: create-step ( level c r d -- scene )
    over [ create-center ] dip 2.0 / [ 1 - ] 2dip create ;

: create-offsets ( quot -- )
    {
        F{ -1.0 1.0 -1.0 }
        F{ 1.0 1.0 -1.0 }
        F{ -1.0 1.0 1.0 }
        F{ 1.0 1.0 1.0 }
    } swap each ; inline

: create-bound ( c r -- sphere ) 3.0 * <sphere> ;

: create-group ( level c r -- scene )
    2dup create-bound [
        2dup <sphere> ,
        [ [ 3dup ] dip create-step , ] create-offsets 3drop
    ] make-group ;

: create ( level c r -- scene )
    pick 1 = [ <sphere> nip ] [ create-group ] if ;

: ss-point ( dx dy -- point )
    [ oversampling /f ] bi@ 0.0 3float-array ;

: ss-grid ( -- ss-grid )
    oversampling [ oversampling [ ss-point ] with map ] map ;

: ray-grid ( point ss-grid -- ray-grid )
    [
        [ v+ normalize F{ 0.0 0.0 -4.0 } swap <ray> ] with map
    ] with map ;

: ray-pixel ( scene point -- n )
    ss-grid ray-grid 0.0 -rot
    [ [ swap cast-ray + ] with each ] with each ;

: pixel-grid ( -- grid )
    size reverse [
        size [
            [ size 0.5 * - ] bi@ swap size
            3float-array
        ] with map
    ] map ;

: pgm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pgm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: ray-trace ( scene -- pixels )
    pixel-grid [ [ ray-pixel ] with map ] with map ;

: run ( -- string )
    levels F{ 0.0 -1.0 0.0 } 1.0 create ray-trace [
        size size pgm-header
        [ [ oversampling sq / pgm-pixel ] each ] each
    ] B{ } make ;

: raytracer-main ( -- )
    run "raytracer.pnm" temp-file binary set-file-contents ;

MAIN: raytracer-main
