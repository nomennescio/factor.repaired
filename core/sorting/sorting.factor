! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences vectors math.order
sequences sequences.private math.order ;
IN: sorting

DEFER: sort

<PRIVATE

: <iterator> 0 tail-slice ; inline

: this ( slice -- obj )
    dup slice-from swap slice-seq nth-unsafe ; inline

: next ( iterator -- )
    dup slice-from 1+ swap set-slice-from ; inline

: smallest ( iter1 iter2 quot -- elt )
    >r over this over this r> call +lt+ eq?
    -rot ? [ this ] keep next ; inline

: (merge) ( iter1 iter2 quot accum -- )
    >r pick empty? [
        drop nip r> push-all
    ] [
        over empty? [
            2drop r> push-all
        ] [
            3dup smallest r> [ push ] keep (merge)
        ] if
    ] if ; inline

: merge ( sorted1 sorted2 quot -- result )
    >r [ [ <iterator> ] bi@ ] 2keep r>
    rot length rot length + <vector>
    [ (merge) ] [ underlying>> ] bi ; inline

: conquer ( first second quot -- result )
    [ tuck >r >r sort r> r> sort ] keep merge ; inline

PRIVATE>

: sort ( seq quot -- sortedseq )
    over length 1 <=
    [ drop ] [ over >r >r halves r> conquer r> like ] if ;
    inline

: natural-sort ( seq -- sortedseq ) [ <=> ] sort ;

: sort-keys ( seq -- sortedseq ) [ [ first ] compare ] sort ;

: sort-values ( seq -- sortedseq ) [ [ second ] compare ] sort ;

: sort-pair ( a b -- c d ) 2dup after? [ swap ] when ;
