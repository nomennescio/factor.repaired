! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays combinators continuations destructors
kernel math namespaces sequences sequences.private ;
IN: io

SYMBOLS: +byte+ +character+ ;

GENERIC: stream-element-type ( stream -- type )

GENERIC: stream-read1 ( stream -- elt )
GENERIC: stream-read-unsafe ( n buf stream -- count )
GENERIC: stream-read-until ( seps stream -- seq sep/f )
GENERIC: stream-read-partial-unsafe ( n buf stream -- count )
GENERIC: stream-readln ( stream -- str/f )
GENERIC: stream-contents ( stream -- seq )

GENERIC: stream-write1 ( elt stream -- )
GENERIC: stream-write ( data stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

ERROR: bad-seek-type type ;

SINGLETONS: seek-absolute seek-relative seek-end ;

GENERIC: stream-tell ( stream -- n )
GENERIC: stream-seek ( n seek-type stream -- )
GENERIC: stream-seekable? ( stream -- ? )
GENERIC: stream-length ( stream -- n/f )

: stream-print ( str stream -- ) [ stream-write ] [ stream-nl ] bi ;

! Default streams
SYMBOL: input-stream
SYMBOL: output-stream
SYMBOL: error-stream

: readln ( -- str/f ) input-stream get stream-readln ; inline
: read1 ( -- elt ) input-stream get stream-read1 ; inline
: read-until ( seps -- seq sep/f ) input-stream get stream-read-until ; inline
: tell-input ( -- n ) input-stream get stream-tell ; inline
: tell-output ( -- n ) output-stream get stream-tell ; inline
: seek-input ( n seek-type -- ) input-stream get stream-seek ; inline
: seek-output ( n seek-type -- ) output-stream get stream-seek ; inline

: write1 ( elt -- ) output-stream get stream-write1 ; inline
: write ( seq -- ) output-stream get stream-write ; inline
: flush ( -- ) output-stream get stream-flush ; inline

: nl ( -- ) output-stream get stream-nl ; inline

: with-input-stream* ( stream quot -- )
    input-stream swap with-variable ; inline

: with-input-stream ( stream quot -- )
    [ with-input-stream* ] curry with-disposal ; inline

: with-output-stream* ( stream quot -- )
    output-stream swap with-variable ; inline

: with-output-stream ( stream quot -- )
    [ with-output-stream* ] curry with-disposal ; inline

: with-streams* ( input output quot -- )
    swapd [ with-output-stream* ] curry with-input-stream* ; inline

: with-streams ( input output quot -- )
    #! We have to dispose of the output stream first, so that
    #! if both streams point to the same FD, we get to flush the
    #! buffer before closing the FD.
    swapd [ with-output-stream ] curry with-input-stream ; inline

: print ( str -- ) output-stream get stream-print ; inline

: bl ( -- ) " " write ;

: each-morsel ( ..a handler: ( ..a data -- ..b ) reader: ( ..b -- ..a data ) -- ..a )
    [ dup ] compose swap while drop ; inline

<PRIVATE

: stream-exemplar ( stream -- exemplar )
    stream-element-type {
        { +byte+ [ B{ } ] }
        { +character+ [ "" ] }
    } case ; inline

: stream-exemplar-growable ( stream -- exemplar )
    stream-element-type {
        { +byte+ [ BV{ } ] }
        { +character+ [ SBUF" " ] }
    } case ; inline

: (new-sequence-for-stream) ( n stream -- seq )
    stream-exemplar new-sequence ; inline

: (read-into-new) ( n stream quot: ( n buf stream -- count ) -- seq/f )
    [ 2dup (new-sequence-for-stream) swap ] dip curry keep
    over 0 = [ 2drop f ] [ resize ] if ; inline

: (read-into) ( buf stream quot: ( n buf stream -- count ) -- buf-slice/f )
    [ dup length over ] 2dip call
    [ drop f ] [ head-slice ] if-zero ; inline

PRIVATE>

: stream-read ( n stream -- seq/f )
    [ stream-read-unsafe ] (read-into-new) ; inline

: stream-read-partial ( n stream -- seq/f )
    [ stream-read-partial-unsafe ] (read-into-new) ; inline

ERROR: invalid-read-buffer buf stream ;


: stream-read-into ( buf stream -- buf-slice/f )
    [ stream-read-unsafe ] (read-into) ; inline
: stream-read-partial-into ( buf stream -- buf-slice/f )
    [ stream-read-partial-unsafe ] (read-into) ; inline

: read ( n -- seq ) input-stream get stream-read ; inline
: read-partial ( n -- seq ) input-stream get stream-read-partial ; inline
: read-into ( buf -- buf-slice/f )
    input-stream get stream-read-into ; inline
: read-partial-into ( buf -- buf-slice/f )
    input-stream get stream-read-partial-into ; inline

: each-stream-line ( ... stream quot: ( ... line -- ... ) -- ... )
    swap [ stream-readln ] curry each-morsel ; inline

: each-line ( ... quot: ( ... line -- ... ) -- ... )
    input-stream get swap each-stream-line ; inline

: stream-lines ( stream -- seq )
    [ [ ] collector [ each-stream-line ] dip { } like ] with-disposal ;

: lines ( -- seq )
    input-stream get stream-lines ; inline

: each-stream-block ( ... stream quot: ( ... block -- ... ) -- ... )
    swap [ 65536 swap stream-read-partial ] curry each-morsel ; inline

: each-block ( ... quot: ( ... block -- ... ) -- ... )
    input-stream get swap each-stream-block ; inline

: (stream-contents-by-length) ( stream len -- seq )
    dup rot [
        [ (new-sequence-for-stream) ]
        [ [ stream-read-unsafe ] curry keep resize ] bi
    ] with-disposal ;
: (stream-contents-by-block) ( stream -- seq )
    [
        [ [ ] collector [ each-stream-block ] dip { } like ]
        [ stream-exemplar concat-as ] bi
    ] with-disposal ;
: (stream-contents-by-length-or-block) ( stream -- seq )
    dup stream-length
    [ (stream-contents-by-length) ] 
    [ (stream-contents-by-block)  ] if* ; inline
: (stream-contents-by-element) ( stream -- seq )
    [
        [ [ stream-read1 dup ] curry [ ] ]
        [ stream-exemplar produce-as nip ] bi
    ] with-disposal ;

: contents ( -- seq )
    input-stream get stream-contents ; inline

: stream-copy* ( in out -- )
    [ stream-write ] curry each-stream-block ; inline

: stream-copy ( in out -- )
    [ [ stream-copy* ] with-disposal ] curry with-disposal ;

! Default implementations of stream operations in terms of read1/write1

<PRIVATE
: read-loop ( buf stream n i -- count )
     2dup = [ nip nip nip ] [
        pick stream-read1 [
            over [ pick set-nth-unsafe ] 2curry 3dip
            1 + read-loop
        ] [ nip nip nip ] if*
     ] if ; inline recursive

: finalize-read-until ( seq sep/f -- seq/f sep/f )
    2dup [ empty? ] [ not ] bi* and [ 2drop f f ] when ; inline

: read-until-loop ( seps stream -- seq sep/f )
    [ [ stream-read1 dup [ rot member? not ] [ nip f ] if* ] 2curry [ ] ]
    [ stream-exemplar ] bi produce-as swap finalize-read-until ; inline
PRIVATE>

M: object stream-read-unsafe rot 0 read-loop ;
M: object stream-read-partial-unsafe stream-read-unsafe ; inline
M: object stream-read-until read-until-loop ;
M: object stream-readln
    "\n" swap stream-read-until drop ; inline
M: object stream-contents (stream-contents-by-length-or-block) ; inline
M: object stream-seekable? drop f ; inline
M: object stream-length drop f ; inline

M: object stream-write [ stream-write1 ] curry each ; inline
M: object stream-flush drop ; inline
M: object stream-nl CHAR: \n swap stream-write1 ; inline

