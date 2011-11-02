! (c)2011 Joe Groff bsd license
USING: accessors assocs calendar combinators
combinators.short-circuit continuations fry io kernel
kernel.private locals math math.statistics math.vectors memory
namespaces prettyprint sequences sorting
tools.profiler.sampling.private ;
FROM: sequences => change-nth ;
IN: tools.profiler.sampling

SYMBOL: raw-profile-data
SYMBOL: samples-per-second

CONSTANT: default-samples-per-second 1000

CONSTANT: ignore-words
    { signal-handler leaf-signal-handler profiling minor-gc }

: get-raw-profile-data ( -- data )
    raw-profile-data get-global [ "No profile data" throw ] unless* ;

: profile* ( rate quot -- )
    [ [ samples-per-second set-global ] [ profiling ] bi ] dip
    [ 0 profiling ] [ ] cleanup
    (get-samples) raw-profile-data set-global ; inline

: profile ( quot -- ) default-samples-per-second swap profile* ; inline

: total-sample-count ( sample -- count ) first ;
: gc-sample-count ( sample -- count ) second ;
: foreign-sample-count ( sample -- count ) third ;
: foreign-thread-sample-count ( sample -- count ) fourth ;
: sample-context ( sample -- alien ) 4 swap nth ;
: sample-callstack ( sample -- array ) 5 swap nth ;

: samples>time ( samples -- time )
    samples-per-second get-global / seconds ;

: (total-time) ( samples -- n )
    [ total-sample-count ] map-sum samples>time ;

: (gc-time) ( samples -- n )
    [ gc-sample-count ] map-sum samples>time ;

: (foreign-time) ( samples -- n )
    [ foreign-sample-count ] map-sum samples>time ;

: (foreign-thread-time) ( samples -- n )
    [ foreign-thread-sample-count ] map-sum samples>time ;

: total-time ( -- n )
    get-raw-profile-data (total-time) ;
: gc-time ( -- n )
    get-raw-profile-data (gc-time) ;
: foreign-time ( -- n )
    get-raw-profile-data (foreign-time) ;
: foreign-thread-time ( -- n )
    get-raw-profile-data (foreign-thread-time) ;

: collect-contexts ( samples -- by-top )
    [ sample-context ] collect-by ;

: time-per-context ( -- n )
    get-raw-profile-data collect-contexts [ (total-time) ] assoc-map ;

: unclip-callstack ( sample -- sample' callstack-top )
    clone 5 over [ unclip swap ] change-nth ;

TUPLE: profile-node
    total-time gc-time foreign-time foreign-thread-time children ;

: <profile-node> ( times children -- node )
    [ first4 ] dip profile-node boa ;

: leaf-callstack? ( callstack -- ? )
    [ ignore-words member? ] all? ;

: sum-times ( samples -- times )
    { 0 0 0 0 } [ 4 head-slice v+ ] reduce [ samples>time ] map! ;

:: (collect-subtrees) ( samples child-quot -- children )
    samples [ sample-callstack leaf-callstack? not ] filter
    [ f ] [ child-quot call ] if-empty ; inline

: collect-tops ( samples -- node )
    [ unclip-callstack ] collect-pairs [
        [ sum-times ]
        [ [ collect-tops ] (collect-subtrees) ] bi <profile-node>
    ] assoc-map ;

: redundant-root-node? ( assoc -- ? )
    {
        [ children>> assoc-size 1 = ]
        [ children>> values first children>> ]
        [ [ total-time>> ] [ children>> values first total-time>> ] bi = ]
    } 1&& ;

: trim-root ( root -- root' )
    dup redundant-root-node? [ children>> values first trim-root ] when ;

: (top-down) ( samples -- tree )
    collect-contexts [
        [ sum-times ] [ collect-tops ] bi <profile-node> trim-root
    ] assoc-map ;

: top-down ( -- tree )
    get-raw-profile-data (top-down) ;

: depth. ( depth -- )
    [ "  " write ] times ;

: by-total-time ( nodes -- nodes' )
    >alist [ second total-time>> ] inv-sort-with ;

: duration. ( duration -- )
    duration>milliseconds >integer pprint "ms" write ;

DEFER: (profile.)

: times. ( node -- )
    {
        [ total-time>> duration. " (" write ]
        [ gc-time>> duration. " gc, " write ]
        [ foreign-time>> duration. " foreign, " write ]
        [ foreign-thread-time>> duration. " foreign threads)" write ]
    } cleave ;

:: (profile-node.) ( word node depth -- )
    depth depth. node times. ": " write word pprint nl
    node children>> depth 1 + (profile.) ;

: (profile.) ( nodes depth -- )
    [ by-total-time ] dip '[ _ (profile-node.) ] assoc-each ;

: profile. ( tree -- )
    [ 0 (profile-node.) ] assoc-each ;
