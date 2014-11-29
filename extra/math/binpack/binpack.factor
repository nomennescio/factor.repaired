! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs kernel locals math math.functions sequences
sorting sorting.extras vectors fry ;
USE: accessors

IN: math.binpack

<PRIVATE

TUPLE: bin items total ;

: <bin> ( -- bin )
    V{ } clone 0 bin boa ; inline

: smallest-bin ( bins -- bin )
    [ total>> ] infimum-by ; inline

: add-to-bin ( item bin -- )
    [ items>> push ]
    [ [ second ] dip [ + ] change-total drop ] 2bi ;

:: (binpack) ( alist #bins -- bins )
    alist sort-values <reversed> :> items
    #bins [ <bin> ] replicate :> bins
    items [ bins smallest-bin add-to-bin ] each
    bins [ items>> keys ] map ;

PRIVATE>

: binpack ( items #bins -- bins )
    [ dup zip ] dip (binpack) ;

: map-binpack ( items quot: ( item -- weight ) #bins -- bins )
    [ dupd map zip ] dip (binpack) ; inline
