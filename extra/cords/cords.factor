! Copysecond (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences sorting math math.order
arrays combinators kernel ;
IN: cords

<PRIVATE

TUPLE: simple-cord first second ;

M: simple-cord length
    [ first>> length ] [ second>> length ] bi + ;

M: simple-cord virtual-seq first>> ;

M: simple-cord virtual@
    2dup first>> length <
    [ first>> ] [ [ first>> length - ] [ second>> ] bi ] if ;

TUPLE: multi-cord count seqs ;

M: multi-cord length count>> ;

M: multi-cord virtual@
    dupd
    seqs>> [ first <=> ] binsearch*
    [ first - ] [ second ] bi ;

M: multi-cord virtual-seq
    seqs>> dup empty? [ drop f ] [ first second ] if ;

: <cord> ( seqs -- cord )
    dup length 2 = [
        first2 simple-cord boa
    ] [
        [ 0 [ length + ] accumulate ] keep zip multi-cord boa
    ] if ;

PRIVATE>

UNION: cord simple-cord multi-cord ;

INSTANCE: cord virtual-sequence

INSTANCE: multi-cord virtual-sequence

: cord-append ( seq1 seq2 -- cord )
    {
        { [ over empty? ] [ nip ] }
        { [ dup empty? ] [ drop ] }
        { [ 2dup [ cord? ] both? ] [ [ seqs>> values ] bi@ append <cord> ] }
        { [ over cord? ] [ [ seqs>> values ] dip suffix <cord> ] }
        { [ dup cord? ] [ seqs>> values swap prefix <cord> ] }
        [ 2array <cord> ]
    } cond ;

: cord-concat ( seqs -- cord )
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup length 1 = ] [ first ] }
        [
            [
                {
                    { [ dup cord? ] [ seqs>> values ] }
                    { [ dup empty? ] [ drop { } ] }
                    [ 1array ]
                } cond
            ] map concat <cord>
        ]
    } cond ;
