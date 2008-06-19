! Copyright (C) 2005, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private slots.private math math.private
math.order ;
IN: sequences

MIXIN: sequence

GENERIC: length ( seq -- n ) flushable
GENERIC: set-length ( n seq -- )
GENERIC: nth ( n seq -- elt ) flushable
GENERIC: set-nth ( elt n seq -- )
GENERIC: new-sequence ( len seq -- newseq ) flushable
GENERIC: new-resizable ( len seq -- newseq ) flushable
GENERIC: like ( seq exemplar -- newseq ) flushable
GENERIC: clone-like ( seq exemplar -- newseq ) flushable

: new-like ( len exemplar quot -- seq )
    over >r >r new-sequence r> call r> like ; inline

M: sequence like drop ;

GENERIC: lengthen ( n seq -- )

M: sequence lengthen 2dup length > [ set-length ] [ 2drop ] if ;

: empty? ( seq -- ? ) length zero? ; inline
: delete-all ( seq -- ) 0 swap set-length ;

: first ( seq -- first ) 0 swap nth ; inline
: second ( seq -- second ) 1 swap nth ; inline
: third ( seq -- third ) 2 swap nth ; inline
: fourth  ( seq -- fourth ) 3 swap nth ; inline

: set-first ( first seq -- ) 0 swap set-nth ; inline
: set-second ( second seq -- ) 1 swap set-nth ; inline
: set-third ( third seq -- ) 2 swap set-nth ; inline
: set-fourth  ( fourth seq -- ) 3 swap set-nth ; inline

: push ( elt seq -- ) [ length ] [ set-nth ] bi ;

: bounds-check? ( n seq -- ? )
    length 1- 0 swap between? ; inline

ERROR: bounds-error index seq ;

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

MIXIN: immutable-sequence

ERROR: immutable seq ;

M: immutable-sequence set-nth immutable ;

INSTANCE: immutable-sequence sequence

<PRIVATE

: max-array-capacity ( -- n )
    #! A bit of a pain; can't call cell-bits here
    7 getenv 8 * 5 - 2^ 1- ; foldable

PREDICATE: array-capacity < fixnum
    0 max-array-capacity between? ;

: array-capacity ( array -- n )
    1 slot { array-capacity } declare ; inline

: array-nth ( n array -- elt )
    swap 2 fixnum+fast slot ; inline

: set-array-nth ( elt n array -- )
    swap 2 fixnum+fast set-slot ; inline

: dispatch ( n array -- ) array-nth (call) ;

GENERIC: resize ( n seq -- newseq ) flushable

! Unsafe sequence protocol for inner loops
GENERIC: nth-unsafe ( n seq -- elt ) flushable
GENERIC: set-nth-unsafe ( elt n seq -- )

M: sequence nth bounds-check nth-unsafe ;
M: sequence set-nth bounds-check set-nth-unsafe ;

M: sequence nth-unsafe nth ;
M: sequence set-nth-unsafe set-nth ;

! The f object supports the sequence protocol trivially
M: f length drop 0 ;
M: f nth-unsafe nip ;
M: f like drop dup empty? [ drop f ] when ;

INSTANCE: f immutable-sequence

! Integers support the sequence protocol
M: integer length ;
M: integer nth-unsafe drop ;

INSTANCE: integer immutable-sequence

: first2-unsafe
    [ 0 swap nth-unsafe 1 ] [ nth-unsafe ] bi ; inline

: first3-unsafe
    [ first2-unsafe 2 ] [ nth-unsafe ] bi ; inline

: first4-unsafe
    [ first3-unsafe 3 ] [ nth-unsafe ] bi ; inline

: exchange-unsafe ( m n seq -- )
    [ tuck nth-unsafe >r nth-unsafe r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ; inline

: (head) ( seq n -- from to seq ) 0 spin ; inline

: (tail) ( seq n -- from to seq ) over length rot ; inline

: from-end >r dup length r> - ; inline

: (2sequence)
    tuck 1 swap set-nth-unsafe
    tuck 0 swap set-nth-unsafe ; inline

: (3sequence)
    tuck 2 swap set-nth-unsafe
    (2sequence) ; inline

: (4sequence)
    tuck 3 swap set-nth-unsafe
    (3sequence) ; inline

PRIVATE>

: 2sequence ( obj1 obj2 exemplar -- seq )
    2 swap [ (2sequence) ] new-like ; inline

: 3sequence ( obj1 obj2 obj3 exemplar -- seq )
    3 swap [ (3sequence) ] new-like ; inline

: 4sequence ( obj1 obj2 obj3 obj4 exemplar -- seq )
    4 swap [ (4sequence) ] new-like ; inline

: first2 ( seq -- first second )
    1 swap bounds-check nip first2-unsafe ; flushable

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ; flushable

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ; flushable

: ?nth ( n seq -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ; flushable

MIXIN: virtual-sequence
GENERIC: virtual-seq ( seq -- seq' )
GENERIC: virtual@ ( n seq -- n' seq' )

M: virtual-sequence nth virtual@ nth ;
M: virtual-sequence set-nth virtual@ set-nth ;
M: virtual-sequence nth-unsafe virtual@ nth-unsafe ;
M: virtual-sequence set-nth-unsafe virtual@ set-nth-unsafe ;
M: virtual-sequence like virtual-seq like ;
M: virtual-sequence new-sequence virtual-seq new-sequence ;

INSTANCE: virtual-sequence sequence

! A reversal of an underlying sequence.
TUPLE: reversed seq ;

C: <reversed> reversed

M: reversed virtual-seq reversed-seq ;

M: reversed virtual@ reversed-seq [ length swap - 1- ] keep ;

M: reversed length reversed-seq length ;

INSTANCE: reversed virtual-sequence

: reverse ( seq -- newseq ) [ <reversed> ] [ like ] bi ;

! A slice of another sequence.
TUPLE: slice from to seq ;

: collapse-slice ( m n slice -- m' n' seq )
    dup slice-from swap slice-seq >r tuck + >r + r> r> ; inline

ERROR: slice-error reason ;

: check-slice ( from to seq -- from to seq )
    pick 0 < [ "start < 0" slice-error ] when
    dup length pick < [ "end > sequence" slice-error ] when
    2over > [ "start > end" slice-error ] when ; inline

: <slice> ( from to seq -- slice )
    dup slice? [ collapse-slice ] when
    check-slice
    slice boa ; inline

M: slice virtual-seq slice-seq ;

M: slice virtual@ [ slice-from + ] [ slice-seq ] bi ;

M: slice length dup slice-to swap slice-from - ;

: head-slice ( seq n -- slice ) (head) <slice> ;

: tail-slice ( seq n -- slice ) (tail) <slice> ;

: rest-slice ( seq -- slice ) 1 tail-slice ;

: head-slice* ( seq n -- slice ) from-end head-slice ;

: tail-slice* ( seq n -- slice ) from-end tail-slice ;

: but-last-slice ( seq -- slice ) 1 head-slice* ;

INSTANCE: slice virtual-sequence

! One element repeated many times
TUPLE: repetition len elt ;

C: <repetition> repetition

M: repetition length repetition-len ;
M: repetition nth-unsafe nip repetition-elt ;

INSTANCE: repetition immutable-sequence

<PRIVATE

: ((copy)) ( dst i src j n -- dst i src j n )
    dup -roll [
        + swap nth-unsafe -roll [
            + swap set-nth-unsafe
        ] 3keep drop
    ] 3keep ; inline

: (copy) ( dst i src j n -- dst )
    dup 0 <= [ 2drop 2drop ] [ 1- ((copy)) (copy) ] if ; inline

: prepare-subseq ( from to seq -- dst i src j n )
    [ >r swap - r> new-sequence dup 0 ] 3keep
    -rot drop roll length ; inline

: check-copy ( src n dst -- )
    over 0 < [ bounds-error ] when
    >r swap length + r> lengthen ; inline

PRIVATE>

: subseq ( from to seq -- subseq )
    [ check-slice prepare-subseq (copy) ] [ like ] bi ;

: head ( seq n -- headseq ) (head) subseq ;

: tail ( seq n -- tailseq ) (tail) subseq ;

: rest ( seq -- tailseq ) 1 tail ;

: head* ( seq n -- headseq ) from-end head ;

: tail* ( seq n -- tailseq ) from-end tail ;

: but-last ( seq -- headseq ) 1 head* ;

: copy ( src i dst -- )
    pick length >r 3dup check-copy spin 0 r>
    (copy) drop ; inline

M: sequence clone-like
    >r dup length r> new-sequence [ 0 swap copy ] keep ;

M: immutable-sequence clone-like like ;

: push-all ( src dest -- ) [ length ] [ copy ] bi ;

: ((append)) ( seq1 seq2 accum -- accum )
    [ >r over length r> copy ]
    [ 0 swap copy ] 
    [ ] tri ; inline

: (append) ( seq1 seq2 exemplar -- newseq )
    >r over length over length + r>
    [ ((append)) ] new-like ; inline

: (3append) ( seq1 seq2 seq3 exemplar -- newseq )
    >r pick length pick length pick length + + r> [
        [ >r pick length pick length + r> copy ]
        [ ((append)) ] bi
    ] new-like ; inline

: append ( seq1 seq2 -- newseq ) over (append) ;

: prepend ( seq1 seq2 -- newseq ) swap append ; inline

: 3append ( seq1 seq2 seq3 -- newseq ) pick (3append) ;

: change-nth ( i seq quot -- )
    [ >r nth r> call ] 3keep drop set-nth ; inline

: min-length ( seq1 seq2 -- n ) [ length ] bi@ min ; inline

: max-length ( seq1 seq2 -- n ) [ length ] bi@ max ; inline

<PRIVATE

: (each) ( seq quot -- n quot' )
    >r dup length swap [ nth-unsafe ] curry r> compose ; inline

: (collect) ( quot into -- quot' )
    [ >r keep r> set-nth-unsafe ] 2curry ; inline

: collect ( n quot into -- )
    (collect) each-integer ; inline

: map-into ( seq quot into -- )
    >r (each) r> collect ; inline

: 2nth-unsafe ( n seq1 seq2 -- elt1 elt2 )
    >r over r> nth-unsafe >r nth-unsafe r> ; inline

: (2each) ( seq1 seq2 quot -- n quot' )
    >r [ min-length ] 2keep r>
    [ >r 2nth-unsafe r> call ] 3curry ; inline

: finish-find ( i seq -- i elt )
    over [ dupd nth-unsafe ] [ drop f ] if ; inline

: (find) ( seq quot quot' -- i elt )
    pick >r >r (each) r> call r> finish-find ; inline

: (find-from) ( n seq quot quot' -- i elt )
    >r >r 2dup bounds-check? [
        r> r> (find)
    ] [
        r> r> 2drop 2drop f f
    ] if ; inline

: (monotonic) ( seq quot -- ? )
    [ 2dup nth-unsafe rot 1+ rot nth-unsafe ]
    prepose curry ; inline

: (interleave) ( n elt between quot -- )
    roll zero? [ nip ] [ swapd 2slip ] if call ; inline

PRIVATE>

: each ( seq quot -- )
    (each) each-integer ; inline

: reduce ( seq identity quot -- result )
    swapd each ; inline

: map-as ( seq quot exemplar -- newseq )
    >r over length r> [ [ map-into ] keep ] new-like ; inline

: map ( seq quot -- newseq )
    over map-as ; inline

: replicate ( seq quot -- newseq )
    [ drop ] prepose map ; inline

: replicate-as ( seq quot exemplar -- newseq )
    >r [ drop ] prepose r> map-as ; inline

: change-each ( seq quot -- )
    over map-into ; inline

: accumulate ( seq identity quot -- final newseq )
    swapd [ pick slip ] curry map ; inline

: 2each ( seq1 seq2 quot -- )
    (2each) each-integer ; inline

: 2reverse-each ( seq1 seq2 quot -- )
    >r [ <reversed> ] bi@ r> 2each ; inline

: 2reduce ( seq1 seq2 identity quot -- result )
    >r -rot r> 2each ; inline

: 2map ( seq1 seq2 quot -- newseq )
    pick >r (2each) over r>
    [ [ collect ] keep ] new-like ; inline

: 2all? ( seq1 seq2 quot -- ? )
    (2each) all-integers? ; inline

: find-from ( n seq quot -- i elt )
    [ (find-integer) ] (find-from) ; inline

: find ( seq quot -- i elt )
    [ find-integer ] (find) ; inline

: find-last-from ( n seq quot -- i elt )
    [ nip find-last-integer ] (find-from) ; inline

: find-last ( seq quot -- i elt )
    [ >r 1- r> find-last-integer ] (find) ; inline

: all? ( seq quot -- ? )
    (each) all-integers? ; inline

: push-if ( elt quot accum -- )
    >r keep r> rot [ push ] [ 2drop ] if  ; inline

: pusher ( quot -- quot accum )
    V{ } clone [ [ push-if ] 2curry ] keep ; inline

: filter ( seq quot -- subseq )
    over >r pusher >r each r> r> like ; inline

: monotonic? ( seq quot -- ? )
    >r dup length 1- swap r> (monotonic) all? ; inline

: interleave ( seq between quot -- )
    [ (interleave) ] 2curry >r dup length swap r> 2each ; inline

: accumulator ( quot -- quot' vec )
    V{ } clone [ [ push ] curry compose ] keep ; inline

: unfold ( pred quot tail -- seq )
    swap accumulator >r swap while r> { } like ; inline

: follow ( obj quot -- seq )
    >r [ dup ] r> [ keep ] curry [ ] unfold nip ; inline

: index ( obj seq -- n )
    [ = ] with find drop ;

: index-from ( obj i seq -- n )
    rot [ = ] curry find-from drop ;

: last-index ( obj seq -- n )
    [ = ] with find-last drop ;

: last-index-from ( obj i seq -- n )
    rot [ = ] curry find-last-from drop ;

: contains? ( seq quot -- ? )
    find drop >boolean ; inline

: member? ( obj seq -- ? )
    [ = ] with contains? ;

: memq? ( obj seq -- ? )
    [ eq? ] with contains? ;

: remove ( obj seq -- newseq )
    [ = not ] with filter ;

: sift ( seq -- newseq )
    [ ] filter ;

: harvest ( seq -- newseq )
    [ empty? not ] filter ;

: cache-nth ( i seq quot -- elt )
    2over ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline

: mismatch ( seq1 seq2 -- i )
    [ min-length ] 2keep
    [ 2nth-unsafe = not ] 2curry
    find drop ; inline

M: sequence <=>
    2dup mismatch
    [ -rot 2nth-unsafe <=> ] [ [ length ] compare ] if* ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] bi@ number=
    [ mismatch not ] [ 2drop f ] if ; inline

: sequence-hashcode-step ( oldhash newpart -- newhash )
    swap [
        dup -2 fixnum-shift-fast swap 5 fixnum-shift-fast
        fixnum+fast fixnum+fast
    ] keep fixnum-bitxor ; inline

: sequence-hashcode ( n seq -- x )
    0 -rot [
        hashcode* >fixnum sequence-hashcode-step
    ] with each ; inline

M: reversed equal? over reversed? [ sequence= ] [ 2drop f ] if ;

M: slice equal? over slice? [ sequence= ] [ 2drop f ] if ;

: move ( to from seq -- )
    2over number=
    [ 3drop ] [ [ nth swap ] [ set-nth ] bi ] if ; inline

: (delete) ( elt store scan seq -- elt store scan seq )
    2dup length < [
        3dup move
        [ nth pick = ] 2keep rot
        [ >r >r 1+ r> r> ] unless >r 1+ r> (delete)
    ] when ;

: delete ( elt seq -- ) 0 0 rot (delete) nip set-length drop ;

: prefix ( seq elt -- newseq )
    over >r over length 1+ r> [
        [ 0 swap set-nth-unsafe ] keep
        [ 1 swap copy ] keep
    ] new-like ;

: suffix ( seq elt -- newseq )
    over >r over length 1+ r> [
        [ >r over length r> set-nth-unsafe ] keep
        [ 0 swap copy ] keep
    ] new-like ;

: peek ( seq -- elt ) [ length 1- ] [ nth ] bi ;

: pop* ( seq -- ) [ length 1- ] [ set-length ] bi ;

: move-backward ( shift from to seq -- )
    2over number= [
        2drop 2drop
    ] [
        [ >r 2over + pick r> move >r 1+ r> ] keep
        move-backward
    ] if ;

: move-forward ( shift from to seq -- )
    2over number= [
        2drop 2drop
    ] [
        [ >r pick >r dup dup r> + swap r> move 1- ] keep
        move-forward
    ] if ;

: (open-slice) ( shift from to seq ? -- )
    [
        >r [ 1- ] bi@ r> move-forward
    ] [
        >r >r over - r> r> move-backward
    ] if ;

: open-slice ( shift from seq -- )
    pick zero? [
        3drop
    ] [
        pick over length + over >r >r
        pick 0 > >r [ length ] keep r> (open-slice)
        r> r> set-length
    ] if ;

: delete-slice ( from to seq -- )
    check-slice >r over >r - r> r> open-slice ;

: delete-nth ( n seq -- )
    >r dup 1+ r> delete-slice ;

: replace-slice ( new from to seq -- )
    [ >r >r dup pick length + r> - over r> open-slice ] keep
    copy ;

: pop ( seq -- elt )
    [ length 1- ] [ [ nth ] [ set-length ] 2bi ] bi ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: exchange ( m n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: reverse-here ( seq -- )
    dup length dup 2/ [
        >r 2dup r>
        tuck - 1- rot exchange-unsafe
    ] each 2drop ;

: sum-lengths ( seq -- n )
    0 [ length + ] reduce ;

: concat ( seq -- newseq )
    dup empty? [
        drop { }
    ] [
        [ sum-lengths ] keep
        [ first new-resizable ] keep
        [ [ over push-all ] each ] keep
        first like
    ] if ;

: joined-length ( seq glue -- n )
    >r dup sum-lengths swap length 1 [-] r> length * + ;

: join ( seq glue -- newseq )
    [
        2dup joined-length over new-resizable spin
        [ dup pick push-all ] [ pick push-all ] interleave drop
    ] keep like ;

: padding ( seq n elt quot -- newseq )
    >r >r over length [-] dup zero?
    [ r> r> 3drop ] [ r> <repetition> r> call ] if ; inline

: pad-left ( seq n elt -- padded )
    [ swap dup (append) ] padding ;

: pad-right ( seq n elt -- padded )
    [ append ] padding ;

: shorter? ( seq1 seq2 -- ? ) >r length r> length < ;

: head? ( seq begin -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length head-slice sequence=
    ] if ;

: tail? ( seq end -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length tail-slice* sequence=
    ] if ;

: cut-slice ( seq n -- before after )
    [ head-slice ] [ tail-slice ] 2bi ;

: midpoint@ ( seq -- n ) length 2/ ; inline

: halves ( seq -- first second )
    dup midpoint@ cut-slice ;

: binary-reduce ( seq start quot -- value )
    #! We can't use case here since combinators depends on
    #! sequences
    pick length dup 0 3 between? [
        >fixnum {
            [ drop nip ]
            [ 2drop first ]
            [ >r drop first2 r> call ]
            [ >r drop first3 r> bi@ ]
        } dispatch
    ] [
        drop
        >r >r halves r> r>
        [ [ binary-reduce ] 2curry bi@ ] keep
        call
    ] if ; inline

: cut ( seq n -- before after )
    [ head ] [ tail ] 2bi ;

: cut* ( seq n -- before after )
    [ head* ] [ tail* ] 2bi ;

<PRIVATE

: (start) ( subseq seq n -- subseq seq ? )
    pick length [
        >r 3dup r> [ + swap nth-unsafe ] keep rot nth-unsafe =
    ] all? nip ; inline

PRIVATE>

: start* ( subseq seq n -- i )
    pick length pick length swap - 1+
    [ (start) ] find-from
    swap >r 3drop r> ;

: start ( subseq seq -- i ) 0 start* ; inline

: subseq? ( subseq seq -- ? ) start >boolean ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    tuck tail-slice >r tail-slice r> ;

: unclip ( seq -- rest first )
    [ rest ] [ first ] bi ;

: unclip-last ( seq -- butlast last )
    [ but-last ] [ peek ] bi ;

: unclip-slice ( seq -- rest first )
    [ rest-slice ] [ first ] bi ;

: unclip-last-slice ( seq -- butfirst last )
    [ but-last-slice ] [ peek ] bi ;

: <flat-slice> ( seq -- slice )
    dup slice? [ { } like ] when 0 over length rot <slice> ;
    inline

: left-trim ( seq quot -- newseq )
    over >r [ not ] compose find drop r> swap
    [ tail ] [ dup length tail ] if* ; inline

: right-trim ( seq quot -- newseq )
    over >r [ not ] compose find-last drop r> swap
    [ 1+ head ] [ 0 head ] if* ; inline

: trim ( seq quot -- newseq )
    [ left-trim ] [ right-trim ] bi ; inline

: sum ( seq -- n ) 0 [ + ] binary-reduce ;
: product ( seq -- n ) 1 [ * ] binary-reduce ;

: infimum ( seq -- n ) dup first [ min ] reduce ;
: supremum ( seq -- n ) dup first [ max ] reduce ;

: flip ( matrix -- newmatrix )
    dup empty? [
        dup [ length ] map infimum
        swap [ [ nth-unsafe ] with { } map-as ] curry { } map-as
    ] unless ;
