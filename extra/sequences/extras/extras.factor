USING: accessors arrays assocs combinators generalizations
grouping growable heaps kernel math math.order ranges sequences
sequences.private shuffle sorting splitting vectors ;
IN: sequences.extras

: find-all ( ... seq quot: ( ... elt -- ... ? ) -- ... elts )
    [ <enumerated> ] dip '[ nip @ ] assoc-filter ; inline

:: subseq* ( from to seq -- subseq )
    seq length :> len
    from [ dup 0 < [ len + ] when ] [ 0 ] if*
    to [ dup 0 < [ len + ] when ] [ len ] if*
    [ 0 len clamp ] bi@ dupd max seq subseq ;

: safe-subseq ( from to seq -- subseq )
    [ length '[ 0 _ clamp ] bi@ ] keep subseq ;

: all-subseqs ( seq -- seqs )
    dup length [1..b] [ clump ] with map concat ;

: each-subseq ( ... seq quot: ( ... subseq -- ... ) -- ... )
    [ dup length [ [0..b] ] [ ] bi ] dip '[
        dup _ (a..b] [ rot [ subseq _ call ] keep ] with each
    ] each drop ; inline

: map-like ( seq exemplar -- seq' )
    '[ _ like ] map ; inline

: filter-all-subseqs-range ( ... seq range quot: ( ... subseq -- ... ? ) -- seq )
    [
        '[ <clumps> _ filter ] with map concat
    ] keepdd map-like ; inline

: filter-all-subseqs ( ... seq quot: ( ... subseq -- ... ? ) -- seq )
    [ dup length [1..b] ] dip filter-all-subseqs-range ; inline

:: longest-subseq ( seq1 seq2 -- subseq )
    seq1 length :> len1
    seq2 length :> len2
    0 :> n!
    0 :> end!
    len1 1 + [ len2 1 + 0 <array> ] replicate :> table
    len1 [1..b] [| x |
        len2 [1..b] [| y |
            x 1 - seq1 nth-unsafe
            y 1 - seq2 nth-unsafe = [
                y 1 - x 1 - table nth-unsafe nth-unsafe 1 + :> len
                len y x table nth-unsafe set-nth-unsafe
                len n > [ len n! x end! ] when
            ] [ 0 y x table nth-unsafe set-nth-unsafe ] if
        ] each
    ] each end n - end seq1 subseq ;

: pad-longest ( seq1 seq2 elt -- seq1 seq2 )
    [ 2dup max-length ] dip [ pad-tail ] 2curry bi@ ;

: pad-center ( seq n elt -- padded )
    swap pick length [-] [ drop ] [
        [ 2/ ] [ over - ] bi rot '[ _ <repetition> ] bi@
        pick surround-as
    ] if-zero ;

: change-nths ( ... indices seq quot: ( ... elt -- ... elt' ) -- ... )
    [ change-nth ] 2curry each ; inline

: push-if-index ( ..a elt i quot: ( ..a elt i -- ..b ? ) accum -- ..b )
    [ keepd ] dip rot [ push ] [ 2drop ] if ; inline

: push-if* ( ..a elt quot: ( ..a elt -- ..b obj/f ) accum -- ..b )
    [ call ] dip [ push ] [ drop ] if* ; inline

: push? ( elt/f accum -- )
    over [ push ] [ 2drop ] if ; inline

<PRIVATE

: (index-selector-as) ( quot length exampler -- selector accum )
    new-resizable [ [ push-if-index ] 2curry ] keep ; inline

: (selector-as*) ( quot length exemplar -- selector accum )
    new-resizable [ [ push-if* ] 2curry ] keep ; inline

PRIVATE>

: index-selector-as ( quot exemplar -- selector accum )
    [ length ] keep (index-selector-as) ; inline

: index-selector ( quot -- selector accum )
    V{ } index-selector-as ; inline

: selector-as* ( quot exemplar -- selector accum )
    [ length ] keep (selector-as*) ; inline

: selector* ( quot -- selector accum ) V{ } selector-as* ; inline

: filter-index-as ( ... seq quot: ( ... elt i -- ... ? ) exemplar -- ... seq' )
    pick length over [ (index-selector-as) [ each-index ] dip ] 2curry dip like ; inline

: filter-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... seq' )
    over filter-index-as ; inline

: even-indices ( seq -- seq' )
    [ length 1 + 2/ ] keep [
        [ [ 2 * ] dip nth-unsafe ] curry
    ] keep map-integers-as ;

: odd-indices ( seq -- seq' )
    [ length 2/ ] keep [
        [ [ 2 * 1 + ] dip nth-unsafe ] curry
    ] keep map-integers-as ;

: compact ( ... seq quot: ( ... elt -- ... ? ) elt -- ... seq' )
    [ split-when harvest ] dip join ; inline

: collapse ( ... seq quot: ( ... elt -- ... ? ) elt -- ... seq' )
    [ split-when ] dip
    [ [ harvest ] dip join ]
    [ [ first empty? ] dip [ prepend ] curry when ]
    [ [ last empty? ] dip [ append ] curry when ]
    2tri ; inline

:: slice-when ( seq quot: ( elt -- ? ) -- seq' )
    seq length :> len
    0 [ len dupd < ] [
        dup seq quot find-from drop
        [ 2dup = [ 1 + ] when ] [ len ] if*
        [ seq <slice> ] keep len or swap
    ] produce nip ; inline

: ?<slice> ( from/f to/f sequence -- slice )
    [ [ 0 ] unless* ] 2dip
    over [ nip [ length ] [ ] bi ] unless
    <slice> ; inline

: sequence>slice ( sequence -- slice )
    [ drop 0 ] [ length ] [ ] tri <slice> ; inline

: slice-order-by-from ( slice1 slice2 -- slice-lt slice-gt )
    2dup [ from>> ] bi@ > [ swap ] when ; inline

: ordered-slices-range ( slice-lt slice-gt -- to from )
    [ to>> ] [ from>> ] bi* ;

: unordered-slices-range ( slice1 slice2 -- to from )
    slice-order-by-from ordered-slices-range ;

: ordered-slices-overlap? ( slice-lt slice-gt -- ? )
    ordered-slices-range > ; inline

: unordered-slices-overlap? ( slice1 slice2 -- ? )
    unordered-slices-range > ; inline

: slices-overlap? ( slice1 slice2 -- ? )
    unordered-slices-overlap? ;

: ordered-slices-touch? ( slice-lt slice-gt -- ? )
    ordered-slices-range >= ; inline

: unordered-slices-touch? ( slice1 slice2 -- ? )
    unordered-slices-range >= ; inline

: slices-touch? ( slice1 slice2 -- ? )
    unordered-slices-touch? ;

ERROR: slices-don't-touch slice1 slice2 ;

: merge-slices ( slice1 slice2 -- slice/* )
    slice-order-by-from
    2dup ordered-slices-touch? [
        [ from>> ] [ [ to>> ] [ seq>> ] bi ] bi* <slice>
    ] [
        slices-don't-touch
    ] if ;

: rotate ( seq n -- seq' )
    over length mod dup 0 >= [ cut ] [ abs cut* ] if prepend ;

ERROR: underlying-mismatch slice1 slice2 ;

: ensure-same-underlying ( slice1 slice2 -- slice1 slice2 )
    2dup [ seq>> ] bi@ eq? [ underlying-mismatch ] unless ;

: span-slices ( slice1 slice2 -- slice )
    ensure-same-underlying
    [ [ from>> ] bi@ min ]
    [ [ to>> ] bi@ max ]
    [ drop seq>> ] 2tri <slice> ;

: ?span-slices ( slice1/f slice2/f -- slice )
    2dup and [ span-slices ] [ or ] if ;

:: rotate! ( seq n -- )
    seq length :> len
    n len mod dup 0 < [ len + ] when seq bounds-check drop 0 over
    [ 2dup = ] [
        [ seq exchange-unsafe ] [ [ 1 + ] bi@ ] 2bi
        dup len = [ drop over ] when
        2over = [ -rot nip over ] when
    ] until 3drop ;

: all-rotations ( seq -- seq' )
    dup length <iota> [ rotate ] with map ;

<PRIVATE

: (appender-for) ( quot length exemplar -- appender accum )
    new-resizable [ [ push-all ] curry compose ] keep ; inline

PRIVATE>

: appender-for ( quot exemplar -- appender accum )
    [ length ] keep (appender-for) ; inline

: appender ( quot -- appender accum )
    V{ } appender-for ; inline

: map-concat-as ( ... seq quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    [ appender-for [ each ] dip ] keep like ; inline

: >resizable ( seq -- accum ) ! fixes map-concat "cannot apply call to run-time..."
    [ length ] keep [ new-resizable ] [ append! ] bi ;

: map-concat ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    over empty? [ 2drop { } ] [
        [ [ first ] dip call ] 2keep rot [
            >resizable [ '[ @ _ push-all ] 1 each-from ] keep
        ] keep like
    ] if ; inline

: map-filter-as ( ... seq map-quot: ( ... elt -- ... newelt ) filter-quot: ( ... newelt -- ... ? ) exemplar -- ... subseq )
    reach length over
    [ (selector-as) [ compose each ] dip ] 2curry dip like ; inline

: map-filter ( ... seq map-quot: ( ... elt -- ... newelt ) filter-quot: ( ... newelt -- ... ? ) -- ... subseq )
    pick map-filter-as ; inline

: map-sift ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    [ ] map-filter ; inline

: map-harvest ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    [ empty? not ] map-filter ; inline

: (each-integer-with-previous) ( ... prev i n quot: ( ... i -- ... ) -- ... )
    2over < [
        [ nip call ] 4keep nipdd
        [ 1 + ] 2dip (each-integer-with-previous)
    ] [
        4drop
    ] if ; inline recursive

: each-integer-with-previous ( ... n quot: ( ... i -- ... ) -- ... )
    [ f 0 ] 2dip (each-integer-with-previous) ; inline

: (collect-with-previous) ( quot into -- quot' )
    [ [ keep ] dip [ set-nth-unsafe ] keepdd ] 2curry ; inline

: collect-with-previous ( n quot into --  )
    (collect-with-previous) each-integer-with-previous ; inline

: map-integers-with ( ... len quot: ( ... prev i -- ... elt ) exemplar -- ... newseq )
    overd [ [ collect-with-previous ] keep ] new-like ; inline

: map-with-previous-as ( ... seq quot: ( ... elt prev/f -- ... newelt ) exemplar -- ... newseq )
    [ length-operator ] dip map-integers-with ; inline

: map-with-previous ( ... seq quot: ( ... elt prev/f -- ... newelt ) -- ... newseq )
    over map-with-previous-as ; inline

: setup-each-from ( seq quot -- n quot )
    [ [ length ] keep [ nth-unsafe ] curry ] dip compose ; inline

: map-from-as ( ... seq quot: ( ... elt -- ... newelt ) from exemplar -- ... newseq )
    -rotd [ sequence-operator nipd ] dip map-integers-from-as ; inline

: map-from ( ... seq quot: ( ... elt -- ... newelt ) from -- ... newseq )
    pick map-from-as ; inline

: map-if ( ... seq if-quot: ( ... elt -- ... ? ) map-quot: ( ... elt -- ... newelt ) -- ... newseq )
    '[ dup @ _ when ] map ; inline

: reduce-from ( ... seq identity quot: ( ... prev elt -- ... next ) from -- ... result )
    [ swap ] 2dip each-from ; inline

: 2reduce-from ( ... seq1 seq2 identity quot: ( ... prev elt1 elt2 -- ... next ) i -- ... result )
    [ -rot ] 2dip 2each-from ; inline

: 0accumulate-as ( ... seq quot: ( ... prev elt -- ... next ) exemplar -- ... newseq )
    pick empty? [
        2nip clone
    ] [
        [ 0 ] 2dip
        [ swapd [ dup ] compose ] dip map-as nip
    ] if ; inline

: 0accumulate ( ... seq quot: ( ... prev elt -- ... next ) -- ... final newseq )
    over 0accumulate-as ; inline

: occurrence-count-by ( seq quot: ( elt -- elt' ) -- hash seq' )
    '[ nip @ over inc-at* ] [ H{ } clone ] 2dip 0accumulate ; inline

: occurrence-count ( seq -- hash seq' )
    [ ] occurrence-count-by ; inline

: nth-index ( n obj seq -- i )
    [ = dup [ drop 1 - dup 0 < ] when ] with find drop nip ;

: progressive-index-by-as ( seq1 seq2 quot exemplar -- hash seq' )
    [
        pick length '[
            tuck [ @ over inc-at* ] 2dip swap nth-index _ or
        ] [ H{ } clone ] 3dip with
    ] dip map-as ; inline

: progressive-index-by ( seq1 seq2 quot -- hash seq' )
    { } progressive-index-by-as ; inline

: progressive-index ( seq1 seq2 -- hash seq' )
    [ ] progressive-index-by ; inline

: 0reduce ( seq quot: ( prev elt -- next ) -- result )
    [ 0 ] dip reduce ; inline

<PRIVATE

: push-map-if ( ..a elt filter-quot: ( ..a elt -- ..b ? ) map-quot: ( ..a elt -- ..b newelt ) accum -- ..b )
    [ keep over ] 2dip [ when ] dip rot [ push ] [ 2drop ] if ; inline

: (filter-mapper-for) ( filter-quot map-quot length exempler -- filter-mapper accum )
    new-resizable [ [ push-map-if ] 3curry ] keep ; inline

: filter-mapper-for ( filter-quot map-quot exemplar -- filter-mapper accum )
    [ length ] keep (filter-mapper-for) ; inline

: filter-mapper ( filter-quot map-quot -- filter-mapper accum )
    V{ } filter-mapper-for ; inline

PRIVATE>

: filter-map-as ( ... seq filter-quot: ( ... elt -- ... ? ) map-quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    reach length over
    [ (filter-mapper-for) [ each ] dip ] 2curry dip like ; inline

: filter-map ( ... seq filter-quot: ( ... elt -- ... ? ) map-quot: ( ... elt -- ... newelt ) -- ... newseq )
    pick filter-map-as ; inline

: 2map-sum ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... n ) -- ... n )
    [ 0 ] 3dip [ dip + ] curry [ rot ] prepose 2each ; inline

: 2count ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... n )
    [ 1 0 ? ] compose 2map-sum ; inline

: 3each-from
    ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... ) i -- ... )
    [ 3length-operator ] dip -rot each-integer-from ; inline

: 3map-reduce
    ( ..a seq1 seq2 seq3 map-quot: ( ..a elt1 elt2 elt3 -- ..b intermediate ) reduce-quot: ( ..b prev intermediate -- ..a next ) -- ..a result )
    [ [ [ [ first ] tri@ ] 3keep ] dip [ 3dip ] keep ] dip compose 1 3each-from ; inline

: round-robin ( seq -- newseq )
    [ { } ] [
        [ longest length <iota> ] keep
        [ [ ?nth ] with map ] curry map concat sift
    ] if-empty ;

: sift-as ( seq exemplar -- newseq )
    [ ] swap filter-as ;

: sift! ( seq -- newseq )
    [ ] filter! ;

: harvest-as ( seq exemplar -- newseq )
    [ empty? not ] swap filter-as ;

: harvest! ( seq -- newseq )
    [ empty? ] reject! ;

: head-as ( seq n exemplar -- seq' )
    [ head-slice ] [ like ] bi* ; inline

: head*-as ( seq n exemplar -- seq' )
    [ head-slice* ] [ like ] bi* ; inline

: tail-as ( seq n exemplar -- seq' )
    [ tail-slice ] [ like ] bi* ; inline

: tail*-as ( seq n exemplar -- seq' )
    [ tail-slice* ] [ like ] bi* ; inline

: trim-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... newseq )
    [ trim-slice ] [ like ] bi* ; inline

: ?trim ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over [ first-unsafe ] [ last-unsafe ] bi pick either?
        [ trim ] [ drop ] if
    ] if ; inline

: ?trim-head ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over first-unsafe over call
        [ trim-head ] [ drop ] if
    ] if ; inline

: ?trim-tail ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over last-unsafe over call
        [ trim-tail ] [ drop ] if
    ] if ; inline

: unsurround ( newseq seq2 seq3 -- seq1 )
   [ ?head drop ] [ ?tail drop ] bi* ;

: >string-list ( seq -- seq' )
    [ "\"" 1surround ] map "," join ;

: with-string-lines ( str quot -- str' )
    [ string-lines ] dip map "\n" join ; inline

: prepend-lines-with-spaces ( str -- str' )
    [ "    " prepend ] with-string-lines ;

: one? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    [ find ] 2keep rot [
        [ 1 + ] 2dip find-from drop not
    ] [ 3drop f ] if ; inline

: map-index! ( ... seq quot: ( ... elt index -- ... newelt ) -- ... seq )
    over [ [ sequence-index-operator ] dip collect ] keep ; inline

<PRIVATE

: 2sequence-index-iterator ( seq1 seq2 quot -- n quot' )
    [ 2length-iterator [ keep ] curry ] dip compose ; inline

PRIVATE>

: 2each-index ( ... seq1 seq2 quot: ( ... elt1 elt2 index -- ... ) -- ... )
    2sequence-index-iterator each-integer ; inline

: 2map-into ( seq1 seq2 quot into -- )
    [ 2length-operator ] dip collect ; inline

: 2map! ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... seq1 )
    pick [ 2map-into ] keep ; inline

: 2map-index ( ... seq1 seq2 quot: ( ... elt1 elt2 index -- ... newelt ) -- ... newseq )
    pick [ 2sequence-index-iterator ] dip map-integers-as ; inline

TUPLE: evens { seq read-only } ;

C: <evens> evens

M: evens length seq>> length 1 + 2/ ; inline

M: evens virtual@ [ 2 * ] [ seq>> ] bi* ; inline

M: evens virtual-exemplar seq>> ; inline

INSTANCE: evens virtual-sequence

TUPLE: odds { seq read-only } ;

C: <odds> odds

M: odds length seq>> length 2/ ; inline

M: odds virtual@ [ 2 * 1 + ] [ seq>> ] bi* ; inline

M: odds virtual-exemplar seq>> ; inline

INSTANCE: odds virtual-sequence

: until-empty ( seq quot -- )
    [ dup empty? ] swap until drop ; inline

<PRIVATE

: push-index-if ( ..a elt i quot: ( ..a elt -- ..b ? ) accum -- ..b )
    [ dip ] dip rot [ push ] [ 2drop ] if ; inline

PRIVATE>

: arg-where ( ... seq quot: ( ... elt -- ... ? ) -- ... indices )
    over length <vector> [
        [ push-index-if ] 2curry each-index
    ] keep ; inline

: arg-sort ( seq -- indices )
    zip-index sort-keys values ;

: first= ( seq elt -- ? ) [ first ] dip = ; inline
: second= ( seq elt -- ? ) [ second ] dip = ; inline
: third= ( seq elt -- ? ) [ third ] dip = ; inline
: fourth= ( seq elt -- ? ) [ fourth ] dip = ; inline
: last= ( seq elt -- ? ) [ last ] dip = ; inline
: nth= ( n seq elt -- ? ) [ nth ] dip = ; inline

: first? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? ) [ first ] dip call ; inline
: second? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? ) [ second ] dip call ; inline
: third? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? ) [ third ] dip call ; inline
: fourth? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? ) [ fourth ] dip call ; inline
: last? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? ) [ last ] dip call ; inline
: nth? ( ... n seq quot: ( ... elt -- ... ? ) -- ... ? ) [ nth ] dip call ; inline

: loop>sequence** ( ... quot: ( ... -- ... obj ? ) exemplar -- ... seq )
    [ ] swap produce-as nip ; inline

: loop>array** ( ... quot: ( ... -- ... obj ? ) -- ... array )
    { } loop>sequence** ; inline

: loop>sequence* ( ... quot: ( ... -- ... obj ? ) exemplar -- ... seq )
    [ t ] [ '[ [ _ dip ] [ f f f ] if* ] [ swap ] ] [ produce-as 2nip ] tri* ; inline

: loop>array* ( ... quot: ( ... -- ... obj ? ) -- ... array )
    { } loop>sequence* ; inline

: loop>sequence ( ... quot: ( ... -- ... obj/f ) exemplar -- ... seq )
    [ [ dup ] compose [ ] ] dip produce-as nip ; inline

: loop>array ( ... quot: ( ... -- ... obj/f ) -- ... array )
   { } loop>sequence ; inline

: zero-loop>sequence ( ... quot: ( ... n -- ... obj/f ) exemplar -- ... seq )
    [ 0 ] [ '[ _ keep 1 + swap ] ] [ loop>sequence ] tri* nip ; inline

: zero-loop>array ( quot: ( ..a n -- ..a obj ) -- seq )
    { } zero-loop>sequence ; inline

: iterate-heap-while ( heap quot1: ( value key -- slurp? ) quot2: ( value key -- obj/f ) -- obj/f loop? )
    pick heap-empty?
    [ 3drop f f ]
    [
        [ [ heap-peek ] 2dip drop 2keep ]
        [
            nip ! ( pop? value key heap quot2 )
            5roll [
                swap heap-pop* call( value key -- obj/f ) t
            ] [
                4drop f f
            ] if
        ] 3bi
    ] if ; inline

: slurp-heap-while-map ( heap quot1: ( value key -- slurp? ) quot2: ( value key -- obj/f ) -- seq )
    '[ _ _ _ iterate-heap-while ] loop>array* ; inline

: heap>pairs ( heap -- pairs )
    [ 2drop t ] [ swap 2array ] slurp-heap-while-map ;

: map-zip-swap ( quot: ( x -- y ) -- alist )
    '[ _ keep ] map>alist ; inline

: ?heap-pop-value>array ( heap -- array )
    dup heap-empty? [ drop { } ] [ heap-pop drop 1array ] if ;

<PRIVATE

: (reverse) ( seq -- newseq )
    dup [ length ] keep new-sequence
    [ 0 swap copy-unsafe ] keep reverse! ;

PRIVATE>

: reverse-as ( seq exemplar -- newseq )
    [ (reverse) ] [ like ] bi* ;

: map-product ( ... seq quot: ( ... elt -- ... n ) -- ... n )
    [ 1 ] 2dip [ dip * ] with-assoc each ; inline

: insert-nth! ( elt n seq -- )
    [ length ] keep ensure swap pick (a..b]
    over '[ [ 1 + ] keep _ move-unsafe ] each
    set-nth-unsafe ;

: set-nths ( value indices seq -- )
    swapd '[ _ swap _ set-nth ] each ; inline

: set-nths-unsafe ( value indices seq -- )
    swapd '[ _ swap _ set-nth-unsafe ] each ; inline

<PRIVATE

: (map-find-index) ( seq quot find-quot -- result i elt )
    [ [ f ] 2dip [ [ nip ] 2dip call dup ] curry ] dip call
    [ [ [ drop f ] unless ] keep ] dip ; inline

PRIVATE>

: map-find-index ( ... seq quot: ( ... elt index -- ... result/f ) -- ... result i elt )
    [ find-index ] (map-find-index) ; inline

: filter-length ( seq n -- seq' ) '[ length _ = ] filter ;

: all-shortest ( seqs -- seqs' ) dup shortest length filter-length ;

: all-longest ( seqs -- seqs' ) dup longest length filter-length ;

: remove-first ( obj seq -- seq' )
    [ index ] keep over [ remove-nth ] [ nip ] if ;

: remove-first! ( obj seq -- seq )
    [ index ] keep over [ remove-nth! ] [ nip ] if ;

: remove-last ( obj seq -- seq' )
    [ last-index ] keep over [ remove-nth ] [ nip ] if ;

: remove-last! ( obj seq -- seq )
    [ last-index ] keep over [ remove-nth! ] [ nip ] if ;

: ?first2 ( seq -- first/f second/f )
    dup length {
        { 0 [ drop f f ] }
        { 1 [ first-unsafe f ] }
        [ drop first2-unsafe ]
    } case ;

: ?first3 ( seq -- first/f second/f third/f )
    dup length {
        { 0 [ drop f f f ] }
        { 1 [ first-unsafe f f ] }
        { 2 [ first2-unsafe f ] }
        [ drop first3-unsafe ]
    } case ;

: ?first4 ( seq -- first/f second/f third/f fourth/f )
    dup length {
        { 0 [ drop f f f f ] }
        { 1 [ first-unsafe f f f ] }
        { 2 [ first2-unsafe f f ] }
        { 3 [ first3-unsafe f ] }
        [ drop first4-unsafe ]
    } case ;

: cut-when ( ... seq quot: ( ... elt -- ... ? ) -- ... before after )
    [ find drop ] keepd swap
    [ cut ] [ f over like ] if* ; inline

: nth* ( n seq -- elt )
    [ length 1 - swap - ] [ nth ] bi ; inline

: each-index-from ( ... seq quot: ( ... elt index -- ... ) i -- ... )
    -rot sequence-index-operator each-integer-from ; inline

<PRIVATE

: select-by* ( ... seq quot: ( ... elt -- ... x ) compare: ( obj1 obj2 -- ? ) -- ... i elt )
    [
        [ keep swap ] curry [ dip ] curry
        [ [ first 0 ] dip call ] 2keep
        [ 2curry 3dip 5 npick pick ] curry
    ] [
        [ [ 3drop ] [ [ 3drop ] 3dip ] if ] compose
    ] bi* compose 1 each-index-from nip swap ; inline

PRIVATE>

: supremum-by* ( ... seq quot: ( ... elt -- ... x ) -- ... i elt )
    [ after? ] select-by* ; inline

: infimum-by* ( ... seq quot: ( ... elt -- ... x ) -- ... i elt )
    [ before? ] select-by* ; inline

: arg-max ( seq -- n )
    [ ] supremum-by* drop ;

: arg-min ( seq -- n )
    [ ] infimum-by* drop ;

: ?supremum ( seq/f -- elt/f )
    [ f ] [
        [ ] [ 2dup and [ max ] [ dupd ? ] if ] map-reduce
    ] if-empty ;

: ?infimum ( seq/f -- elt/f )
    [ f ] [
        [ ] [ 2dup and [ min ] [ dupd ? ] if ] map-reduce
    ] if-empty ;

: change-last ( seq quot -- )
    [ index-of-last ] [ change-nth ] bi* ; inline

: change-last-unsafe ( seq quot -- )
    [ index-of-last ] [ change-nth-unsafe ] bi* ; inline

: replicate-into ( ... seq quot: ( ... -- ... newelt ) -- ... )
    over [ length ] 2dip '[ _ dip _ set-nth-unsafe ] each-integer ; inline

: count* ( ... seq quot: ( ... elt -- ... ? ) -- ... % )
    over [ count ] [ length ] bi* / ; inline

: sequence-index-operator-last ( n seq quot -- n quot' )
    [ [ nth-unsafe ] curry [ keep ] curry ] dip compose ; inline

: find-last-index-from ( ... n seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    '[
        _ [ sequence-index-operator-last find-last-integer ] keepd
        index/element
    ] bounds-check-call ; inline

: find-last-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    [ index-of-last ] dip find-last-index-from ; inline

: map-find-last-index ( ... seq quot: ( ... elt index -- ... result/f ) -- ... result i elt )
    [ find-last-index ] (map-find-index) ; inline

:: (start-all) ( seq subseq increment -- indices )
    0
    [ seq subseq subseq-index-from dup ]
    [ [ increment + ] keep ] produce nip ;

: start-all ( seq subseq -- indices )
    dup length (start-all) ; inline

: start-all* ( seq subseq -- indices )
    1 (start-all) ; inline

: count-subseq ( seq subseq -- n )
    start-all length ; inline

: count-subseq* ( seq subseq -- n )
    start-all* length ; inline

: assoc-zip-with ( quot: ( key value -- calc ) -- alist )
    '[ _ 2keep 2array swap ] assoc-map ; inline

: take-while ( ... seq quot: ( ... elt -- ... ? ) -- head-slice )
    [ '[ @ not ] find drop ] keepd swap
    [ dup length ] unless* head-slice ; inline

: drop-while ( ... seq quot: ( ... elt -- ... ? ) -- tail-slice )
    [ '[ @ not ] find drop ] keepd swap
    [ dup length ] unless* tail-slice ; inline

: count-head ( seq quot -- n )
    [ not ] compose [ find drop ] keepd length or ; inline

: count-tail ( seq quot -- n )
    [ not ] compose [ find-last drop ] keepd
    length swap [ - 1 - ] when* ; inline

:: shorten* ( vector n -- seq )
    vector n tail
    n vector shorten ;

:: interleaved-as ( seq glue exemplar -- newseq )
    seq length dup 1 - + 0 max exemplar new-sequence :> newseq
    seq [ 2 * newseq set-nth-unsafe ] each-index
    seq length 1 - [ 2 * 1 + glue swap newseq set-nth-unsafe ] each-integer
    newseq ;

: interleaved ( seq glue -- newseq )
    over interleaved-as ;

: extract! ( ... seq quot: ( ... elt -- ... ? ) -- ... seq )
    [ dup ] compose over [ length ] keep new-resizable
    [ [ push-when ] 2curry reject! ] keep swap like ; inline

: find-pred-loop ( ... i n seq quot: ( ... elt -- ... calc ? ) -- ... calc/f i/f elt/f )
    2pick < [
        [ nipd call ] 4keep
        3 7 0 nrotated
        [ [ 3drop ] 2dip rot ]
        [ 2drop [ 1 + ] 3dip find-pred-loop ] if
    ] [
        4drop f f f
    ] if ; inline recursive

: find-pred ( ... seq quot: ( ... elt -- ... calc ) pred: ( ... calc -- ... ? ) -- ... calc/f i/f elt/f )
    [ 0 ] 3dip
    [ [ length check-length ] keep ] 2dip
    '[ nth-unsafe _ keep swap _ keep swap ] find-pred-loop swapd ; inline

! https://en.wikipedia.org/wiki/Maximum_subarray_problem
! Kadane's algorithm O(n) largest sum in subarray
: max-subarray-sum ( seq -- sum )
    [ -1/0. 0 ] dip
    [ [ + ] keep max [ max ] keep ] each drop ;

TUPLE: step-slice
    { from integer read-only initial: 0 }
    { to integer read-only initial: 0 }
    { seq read-only }
    { step integer read-only } ;

:: <step-slice> ( from to step seq -- step-slice )
    step zero? [ "can't be zero" throw ] when
    seq length :> len
    step 0 > [
        from [ 0 ] unless*
        to [ len ] unless*
    ] [
        from [ len ] unless*
        to [ 0 ] unless*
    ] if
    [ dup 0 < [ len + ] when 0 len clamp ] bi@
    ! FIXME: make this work with steps
    seq dup slice? [ collapse-slice ] when
    step step-slice boa ;

M: step-slice virtual-exemplar seq>> ; inline

M: step-slice virtual@
    [ step>> * ] [ from>> + ] [ seq>> ] tri ; inline

M: step-slice length
    [ to>> ] [ from>> - ] [ step>> ] tri
    dup 0 < [ [ neg 0 max ] dip neg ] when /mod
    zero? [ 1 + ] unless ; inline

INSTANCE: step-slice virtual-sequence

: 2nested-each* ( seq1 seq-quot: ( n -- seq ) quot: ( a b -- ) -- )
    '[
        _ keep swap _ with each
    ] each ; inline

: 2nested-filter-as* ( seq1 seq-quot quot exemplar -- seq )
    [ 2over [ length ] bi@ * ] dip
    [
        new-resizable
        [ [ push? ] curry compose 2nested-each* ] keep
    ] keep like ; inline

: 2nested-filter* ( seq1 seq-quot quot -- seq )
    pick 2nested-filter-as* ; inline

: 2nested-map-as* ( seq1 seq-quot quot exemplar -- seq )
    [ 2over [ length ] bi@ * ] dip
    [
        new-resizable
        [ [ push ] curry compose 2nested-each* ] keep
    ] keep like ; inline

: 2nested-map* ( seq1 seq-quot quot -- seq )
    pick 2nested-map-as* ; inline


: 2nested-each ( seq1 seq2 quot -- )
    swapd '[
        swap _ with each
    ] with each ; inline

: 2nested-filter-as ( seq1 seq2 quot exemplar -- seq )
    [ 2over [ length ] bi@ * ] dip
    [
        new-resizable
        [ [ push? ] curry compose 2nested-each ] keep
    ] keep like ; inline

: 2nested-filter ( seq1 seq2 quot -- seq )
    pick 2nested-filter-as ; inline

: 2nested-map-as ( seq1 seq2 quot exemplar -- seq )
    [ 2over [ length ] bi@ * ] dip
    [
        new-resizable
        [ [ push ] curry compose 2nested-each ] keep
    ] keep like ; inline

: 2nested-map ( seq1 seq2 quot -- seq )
    pick 2nested-map-as ; inline

: 3nested-each ( seq1 seq2 seq3 quot -- )
    [ spin ] dip '[
        -rot [
            swap _ with with each
        ] with with each
    ] with with each ; inline

: 3nested-filter-as ( seq1 seq2 seq3 quot exemplar -- seq )
    [ 3 nover [ length ] tri@ * * ] dip
    [
        new-resizable
        [ [ push? ] curry compose 3nested-each ] keep
    ] keep like ; inline

: 3nested-filter ( seq1 seq2 seq3 quot -- seq )
    reach 3nested-filter-as ; inline

: 3nested-map-as ( seq1 seq2 seq3 quot exemplar -- seq )
    [ 3 nover [ length ] tri@ * * ] dip
    [
        new-resizable
        [ [ push ] curry compose 3nested-each ] keep
    ] keep like ; inline

: 3nested-map ( seq1 seq2 seq3 quot -- seq )
    reach 3nested-map-as ; inline

: prev ( n seq -- obj ) [ 1 - ] dip nth ; inline
: ?prev ( n seq -- obj/f ) [ 1 - ] dip ?nth ; inline
: ??prev ( n seq -- obj/f ? ) [ 1 - ] dip ??nth ; inline
: prev-of ( seq n -- obj ) 1 - nth-of ; inline
: ?prev-of ( seq n -- obj/f ) 1 - ?nth-of ; inline
: ??prev-of ( seq n -- obj/f ? ) 1 - ??nth-of ; inline

: prev-identity ( i seq -- identity i seq )
    2dup ??prev [ drop 0 ] unless -rot ; inline

: each-prior-identity-from ( ... identity i seq quot: ( ... prior elt -- ... ) -- ... )
    '[ [ swap @ ] keep ]
    length-operator each-integer-from drop ; inline

: each-prior-from ( ... i seq quot: ( ... prior elt -- ... ) -- ... )
    [ prev-identity ] dip each-prior-identity-from ; inline

: each-prior ( ... seq quot: ( ... prior elt -- ... ) -- ... )
    0 -rot each-prior-from ; inline

: map-prior-identity-from-as ( ... identity i seq quot: ( ... prior elt -- elt' ) exemplar -- seq' )
    [
        '[ [ swap @ ] keep swap ] length-operator
    ] dip map-integers-from-as nip ; inline

: map-prior-identity-as ( ... identity seq quot: ( ... prior elt -- elt' ) exemplar -- seq' )
    [ 0 ] 3dip map-prior-identity-from-as ; inline

: map-prior-from-as ( ... i seq quot: ( ... prior elt -- elt' ) exemplar -- seq' )
    [ prev-identity ] 2dip map-prior-identity-from-as ; inline

: map-prior-as ( ... seq quot: ( ... prior elt -- elt' ) exemplar -- seq' )
    0 -roll map-prior-from-as ; inline

: map-prior-from ( ... i seq quot: ( ... prior elt -- elt' ) -- seq' )
    over map-prior-from-as ; inline

: map-prior ( ... seq quot: ( ... prior elt -- elt' ) -- seq' )
    over map-prior-as ; inline

TUPLE: virtual-zip-index seq ;

C: <zip-index> virtual-zip-index

M: virtual-zip-index length seq>> length ; inline

M: virtual-zip-index nth-unsafe
    over [ seq>> nth-unsafe ] [ 2array ] bi* ; inline

INSTANCE: virtual-zip-index immutable-sequence
