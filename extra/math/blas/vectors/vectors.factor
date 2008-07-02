USING: accessors alien alien.c-types arrays byte-arrays fry
kernel macros math math.blas.cblas math.complex math.functions
math.order multi-methods qualified sequences sequences.private
shuffle ;
QUALIFIED: syntax
IN: math.blas.vectors

TUPLE: blas-vector-base data length inc ;
TUPLE: float-blas-vector < blas-vector-base ;
TUPLE: double-blas-vector < blas-vector-base ;
TUPLE: float-complex-blas-vector < blas-vector-base ;
TUPLE: double-complex-blas-vector < blas-vector-base ;

INSTANCE: float-blas-vector sequence
INSTANCE: double-blas-vector sequence
INSTANCE: float-complex-blas-vector sequence
INSTANCE: double-complex-blas-vector sequence

C: <float-blas-vector> float-blas-vector
C: <double-blas-vector> double-blas-vector
C: <float-complex-blas-vector> float-complex-blas-vector
C: <double-complex-blas-vector> double-complex-blas-vector

GENERIC: zero-vector ( v -- zero )

GENERIC: n*V+V-in-place ( n v1 v2 -- v2=n*v1+v2 )
GENERIC: n*V-in-place   ( n v -- v=n*v )

GENERIC: V. ( v1 v2 -- v1.v2 )
GENERIC: V.conj ( v1 v2 -- v1^H.v2 )
GENERIC: Vnorm ( v -- norm )
GENERIC: Vasum ( v -- abs-sum )
GENERIC: Vswap ( v1 v2 -- v1=v2 v2=v1 )

GENERIC: Viamax ( v -- abs-max-index )

<PRIVATE

GENERIC: (vector-c-type) ( v -- type )

METHOD: (vector-c-type) { float-blas-vector }
    drop "float" ;
METHOD: (vector-c-type) { double-blas-vector }
    drop "double" ;
METHOD: (vector-c-type) { float-complex-blas-vector }
    drop "CBLAS_C" ;
METHOD: (vector-c-type) { double-complex-blas-vector }
    drop "CBLAS_Z" ;

: (prepare-copy) ( v element-size -- length v-data v-inc v-dest-data v-dest-inc )
    [ [ length>> ] [ data>> ] [ inc>> ] tri ] dip
    4 npick * <byte-array>
    1 ;

MACRO: (do-copy) ( copy make-vector -- )
    '[ over 6 npick , 2dip 1 @ ] ;

: (prepare-swap) ( v1 v2 -- length v1-data v1-inc v2-data v2-inc v1 v2 )
    [
        [ [ length>> ] bi@ min ]
        [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi
    ] 2keep ;

: (prepare-axpy) ( n v1 v2 -- length n v1-data v1-inc v2-data v2-inc v2 )
    [
        [ [ length>> ] bi@ min swap ]
        [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi
    ] keep ;

: (prepare-scal) ( n v -- length n v-data v-inc v )
    [ [ length>> swap ] [ data>> ] [ inc>> ] tri ] keep ;

: (prepare-dot) ( v1 v2 -- length v1-data v1-inc v2-data v2-inc )
    [ [ length>> ] bi@ min ]
    [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi ;

: (prepare-nrm2) ( v -- length v1-data v1-inc )
    [ length>> ] [ data>> ] [ inc>> ] tri ;

: (flatten-complex-sequence) ( seq -- seq' )
    [ [ real-part ] [ imaginary-part ] bi 2array ] map concat ;

: (>c-complex) ( complex -- alien )
    [ real-part ] [ imaginary-part ] bi 2array >c-float-array ;
: (>z-complex) ( complex -- alien )
    [ real-part ] [ imaginary-part ] bi 2array >c-double-array ;

: (c-complex>) ( alien -- complex )
    2 c-float-array> first2 rect> ;
: (z-complex>) ( alien -- complex )
    2 c-double-array> first2 rect> ;

: (prepare-nth) ( n v -- n*inc v-data )
    [ inc>> ] [ data>> ] bi [ * ] dip ;

MACRO: (complex-nth) ( nth-quot -- )
    '[ 
        [ 2 * dup 1+ ] dip
        , curry bi@ rect>
    ] ;

: (c-complex-nth) ( n alien -- complex )
    [ float-nth ] (complex-nth) ;
: (z-complex-nth) ( n alien -- complex )
    [ double-nth ] (complex-nth) ;

MACRO: (set-complex-nth) ( set-nth-quot -- )
    '[
        [
            [ [ real-part ] [ imaginary-part ] bi ]
            [ 2 * dup 1+ ] bi*
            swapd
        ] dip
        , curry 2bi@ 
    ] ;

: (set-c-complex-nth) ( complex n alien -- )
    [ set-float-nth ] (set-complex-nth) ;
: (set-z-complex-nth) ( complex n alien -- )
    [ set-double-nth ] (set-complex-nth) ;

PRIVATE>

METHOD: zero-vector { float-blas-vector }
    length>> 0.0 <float> swap 0 <float-blas-vector> ;
METHOD: zero-vector { double-blas-vector }
    length>> 0.0 <double> swap 0 <double-blas-vector> ;
METHOD: zero-vector { float-complex-blas-vector }
    length>> "CBLAS_C" <c-object> swap 0 <float-complex-blas-vector> ;
METHOD: zero-vector { double-complex-blas-vector }
    length>> "CBLAS_Z" <c-object> swap 0 <double-complex-blas-vector> ;

syntax:M: blas-vector-base length
    length>> ;

syntax:M: float-blas-vector nth-unsafe
    (prepare-nth) float-nth ;
syntax:M: float-blas-vector set-nth-unsafe
    (prepare-nth) set-float-nth ;

syntax:M: double-blas-vector nth-unsafe
    (prepare-nth) double-nth ;
syntax:M: double-blas-vector set-nth-unsafe
    (prepare-nth) set-double-nth ;

syntax:M: float-complex-blas-vector nth-unsafe
    (prepare-nth) (c-complex-nth) ;
syntax:M: float-complex-blas-vector set-nth-unsafe
    (prepare-nth) (set-c-complex-nth) ;

syntax:M: double-complex-blas-vector nth-unsafe
    (prepare-nth) (z-complex-nth) ;
syntax:M: double-complex-blas-vector set-nth-unsafe
    (prepare-nth) (set-z-complex-nth) ;

: >float-blas-vector ( seq -- v )
    [ >c-float-array ] [ length ] bi 1 <float-blas-vector> ;
: >double-blas-vector ( seq -- v )
    [ >c-double-array ] [ length ] bi 1 <double-blas-vector> ;
: >float-complex-blas-vector ( seq -- v )
    [ (flatten-complex-sequence) >c-float-array ] [ length ] bi 1 <float-complex-blas-vector> ;
: >double-complex-blas-vector ( seq -- v )
    [ (flatten-complex-sequence) >c-double-array ] [ length ] bi 1 <double-complex-blas-vector> ;

syntax:M: float-blas-vector clone
    "float" heap-size (prepare-copy)
    [ cblas_scopy ] [ <float-blas-vector> ] (do-copy) ;
syntax:M: double-blas-vector clone
    "double" heap-size (prepare-copy)
    [ cblas_dcopy ] [ <double-blas-vector> ] (do-copy) ;
syntax:M: float-complex-blas-vector clone
    "CBLAS_C" heap-size (prepare-copy)
    [ cblas_ccopy ] [ <float-complex-blas-vector> ] (do-copy) ;
syntax:M: double-complex-blas-vector clone
    "CBLAS_Z" heap-size (prepare-copy)
    [ cblas_zcopy ] [ <double-complex-blas-vector> ] (do-copy) ;

METHOD: Vswap { float-blas-vector float-blas-vector }
    (prepare-swap) [ cblas_sswap ] 2dip ;
METHOD: Vswap { double-blas-vector double-blas-vector }
    (prepare-swap) [ cblas_dswap ] 2dip ;
METHOD: Vswap { float-complex-blas-vector float-complex-blas-vector }
    (prepare-swap) [ cblas_cswap ] 2dip ;
METHOD: Vswap { double-complex-blas-vector double-complex-blas-vector }
    (prepare-swap) [ cblas_zswap ] 2dip ;

METHOD: n*V+V-in-place { real float-blas-vector float-blas-vector }
    (prepare-axpy) [ cblas_saxpy ] dip ;
METHOD: n*V+V-in-place { real double-blas-vector double-blas-vector }
    (prepare-axpy) [ cblas_daxpy ] dip ;
METHOD: n*V+V-in-place { number float-complex-blas-vector float-complex-blas-vector }
    [ (>c-complex) ] 2dip
    (prepare-axpy) [ cblas_caxpy ] dip ;
METHOD: n*V+V-in-place { number double-complex-blas-vector double-complex-blas-vector }
    [ (>z-complex) ] 2dip
    (prepare-axpy) [ cblas_zaxpy ] dip ;

METHOD: n*V-in-place { real float-blas-vector }
    (prepare-scal) [ cblas_sscal ] dip ;
METHOD: n*V-in-place { real double-blas-vector }
    (prepare-scal) [ cblas_dscal ] dip ;
METHOD: n*V-in-place { number float-complex-blas-vector }
    [ (>c-complex) ] dip
    (prepare-scal) [ cblas_cscal ] dip ;
METHOD: n*V-in-place { number double-complex-blas-vector }
    [ (>z-complex) ] dip
    (prepare-scal) [ cblas_zscal ] dip ;



: n*V+V ( n v1 v2 -- n*v1+v2 ) clone n*V+V-in-place ;
: n*V ( n v1 -- n*v1 ) clone n*V-in-place ;

: V+ ( v1 v2 -- v1+v2 )
    1.0 -rot n*V+V ;
: V- ( v1 v2 -- v1+v2 )
    -1.0 spin n*V+V ;

: Vneg ( v1 -- -v1 )
    [ zero-vector ] keep V- ;

: V*n ( v n -- v*n )
    swap n*V ;
: V/n ( v n -- v*n )
    recip swap n*V ;

METHOD: V. { float-blas-vector float-blas-vector }
    (prepare-dot) cblas_sdot ;
METHOD: V. { double-blas-vector double-blas-vector }
    (prepare-dot) cblas_ddot ;
METHOD: V. { float-complex-blas-vector float-complex-blas-vector }
    (prepare-dot)
    "CBLAS_C" <c-object> [ cblas_cdotu_sub ] keep (c-complex>) ;
METHOD: V. { double-complex-blas-vector double-complex-blas-vector }
    (prepare-dot)
    "CBLAS_Z" <c-object> [ cblas_zdotu_sub ] keep (z-complex>) ;

METHOD: V.conj { float-complex-blas-vector float-complex-blas-vector }
    (prepare-dot)
    "CBLAS_C" <c-object> [ cblas_cdotc_sub ] keep (c-complex>) ;
METHOD: V.conj { double-complex-blas-vector double-complex-blas-vector }
    (prepare-dot)
    "CBLAS_Z" <c-object> [ cblas_zdotc_sub ] keep (z-complex>) ;

METHOD: Vnorm { float-blas-vector }
    (prepare-nrm2) cblas_snrm2 ;
METHOD: Vnorm { double-blas-vector }
    (prepare-nrm2) cblas_dnrm2 ;
METHOD: Vnorm { float-complex-blas-vector }
    (prepare-nrm2) cblas_scnrm2 ;
METHOD: Vnorm { double-complex-blas-vector }
    (prepare-nrm2) cblas_dznrm2 ;

METHOD: Vasum { float-blas-vector }
    (prepare-nrm2) cblas_sasum ;
METHOD: Vasum { double-blas-vector }
    (prepare-nrm2) cblas_dasum ;
METHOD: Vasum { float-complex-blas-vector }
    (prepare-nrm2) cblas_scasum ;
METHOD: Vasum { double-complex-blas-vector }
    (prepare-nrm2) cblas_dzasum ;

METHOD: Viamax { float-blas-vector }
    (prepare-nrm2) cblas_isamax ;
METHOD: Viamax { double-blas-vector }
    (prepare-nrm2) cblas_idamax ;
METHOD: Viamax { float-complex-blas-vector }
    (prepare-nrm2) cblas_icamax ;
METHOD: Viamax { double-complex-blas-vector }
    (prepare-nrm2) cblas_izamax ;

: Vamax ( v -- max )
    [ Viamax ] keep nth ;
