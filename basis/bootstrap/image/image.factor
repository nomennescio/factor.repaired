! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic assocs hashtables assocs
hashtables.private io kernel kernel.private math namespaces make
parser prettyprint sequences sequences.private strings sbufs
vectors words quotations assocs system layouts splitting
grouping growable classes classes.builtin classes.tuple
classes.tuple.private words.private io.binary io.files vocabs
vocabs.loader source-files definitions debugger
quotations.private sequences.private combinators
io.encodings.binary math.order math.private accessors slots.private ;
IN: bootstrap.image

: my-arch ( -- arch )
    cpu name>> 
    dup "ppc" = [ >r os name>> "-" r> 3append ] when ;

: boot-image-name ( arch -- string )
    "boot." swap ".image" 3append ;

: my-boot-image-name ( -- string )
    my-arch boot-image-name ;

: images ( -- seq )
    {
        "x86.32"
        "x86.64"
        "linux-ppc" "macosx-ppc"
    } ;

<PRIVATE

! Object cache; we only consider numbers equal if they have the
! same type
TUPLE: id obj ;

C: <id> id

M: id hashcode* obj>> hashcode* ;

GENERIC: (eql?) ( obj1 obj2 -- ? )

: eql? ( obj1 obj2 -- ? )
    [ (eql?) ] [ [ class ] bi@ = ] 2bi and ;

M: integer (eql?) = ;

M: sequence (eql?)
    over sequence? [
        2dup [ length ] bi@ =
        [ [ eql? ] 2all? ] [ 2drop f ] if
    ] [ 2drop f ] if ;

M: object (eql?) = ;

M: id equal?
    over id? [ [ obj>> ] bi@ eql? ] [ 2drop f ] if ;

SYMBOL: objects

: (objects) <id> objects get ; inline

: lookup-object ( obj -- n/f ) (objects) at ;

: put-object ( n obj -- ) (objects) set-at ;

: cache-object ( obj quot -- value )
    >r (objects) r> [ obj>> ] prepose cache ; inline

! Constants

: image-magic HEX: 0f0e0d0c ; inline
: image-version 4 ; inline

: data-base 1024 ; inline

: userenv-size 70 ; inline

: header-size 10 ; inline

: data-heap-size-offset 3 ; inline
: t-offset              6 ; inline
: 0-offset              7 ; inline
: 1-offset              8 ; inline
: -1-offset             9 ; inline

SYMBOL: sub-primitives

: make-jit ( quot rc rt offset -- quad )
    { [ { } make ] [ ] [ ] [ ] } spread 4array ; inline

: jit-define ( quot rc rt offset name -- )
    >r make-jit r> set ; inline

: define-sub-primitive ( quot rc rt offset word -- )
    >r make-jit r> sub-primitives get set-at ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

! Bootstrap global namesapce
SYMBOL: bootstrap-global

! Boot quotation, set in stage1.factor
SYMBOL: bootstrap-boot-quot

! JIT parameters
SYMBOL: jit-code-format
SYMBOL: jit-prolog
SYMBOL: jit-primitive-word
SYMBOL: jit-primitive
SYMBOL: jit-word-jump
SYMBOL: jit-word-call
SYMBOL: jit-push-literal
SYMBOL: jit-push-immediate
SYMBOL: jit-if-word
SYMBOL: jit-if-jump
SYMBOL: jit-dispatch-word
SYMBOL: jit-dispatch
SYMBOL: jit-epilog
SYMBOL: jit-return
SYMBOL: jit-profiling
SYMBOL: jit-declare-word

! Default definition for undefined words
SYMBOL: undefined-quot

: userenv-offset ( symbol -- n )
    {
        { bootstrap-boot-quot 20 }
        { bootstrap-global 21 }
        { jit-code-format 22 }
        { jit-prolog 23 }
        { jit-primitive-word 24 }
        { jit-primitive 25 }
        { jit-word-jump 26 }
        { jit-word-call 27 }
        { jit-push-literal 28 }
        { jit-if-word 29 }
        { jit-if-jump 30 }
        { jit-dispatch-word 31 }
        { jit-dispatch 32 }
        { jit-epilog 33 }
        { jit-return 34 }
        { jit-profiling 35 }
        { jit-push-immediate 36 }
        { jit-declare-word 42 }
        { undefined-quot 60 }
    } at header-size + ;

: emit ( cell -- ) image get push ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) image get push-all ;

: fixup ( value offset -- ) image get set-nth ;

: heap-size ( -- size )
    image get length header-size - userenv-size -
    bootstrap-cells ;

: here ( -- size ) heap-size data-base + ;

: here-as ( tag -- pointer ) here bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

: emit-fixnum ( n -- ) tag-fixnum emit ;

: emit-object ( header tag quot -- addr )
    swap here-as >r swap tag-fixnum emit call align-here r> ;
    inline

! Write an object to the image.
GENERIC: ' ( obj -- ptr )

! Image header

: emit-header ( -- )
    image-magic emit
    image-version emit
    data-base emit ! relocation base at end of header
    0 emit ! size of data heap set later
    0 emit ! reloc base of code heap is 0
    0 emit ! size of code heap is 0
    0 emit ! pointer to t object
    0 emit ! pointer to bignum 0
    0 emit ! pointer to bignum 1
    0 emit ! pointer to bignum -1
    userenv-size [ f ' emit ] times ;

: emit-userenv ( symbol -- )
    [ get ' ] [ userenv-offset ] bi fixup ;

! Bignums

: bignum-bits ( -- n ) bootstrap-cell-bits 2 - ;

: bignum-radix ( -- n ) bignum-bits 2^ 1- ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ dup 0 > ]
    [ [ bignum-bits neg shift ] [ bignum-radix bitand ] bi ]
    [ ] produce nip ;

: emit-bignum ( n -- )
    dup dup 0 < [ neg ] when bignum>seq
    [ nip length 1+ emit-fixnum ]
    [ drop 0 < 1 0 ? emit ]
    [ nip emit-seq ]
    2tri ;

M: bignum '
    [
        bignum tag-number dup [ emit-bignum ] emit-object
    ] cache-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup
    bootstrap-most-negative-fixnum
    bootstrap-most-positive-fixnum between?
    [ tag-fixnum ] [ >bignum ' ] if ;

TUPLE: fake-bignum n ;

C: <fake-bignum> fake-bignum

M: fake-bignum ' n>> tag-fixnum ;

! Floats

M: float '
    [
        float tag-number dup [
            align-here double>bits emit-64
        ] emit-object
    ] cache-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, ( -- ) t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,F_TYPE)
    drop \ f tag-number ;

:  0, ( -- )  0 >bignum '  0-offset fixup ;
:  1, ( -- )  1 >bignum '  1-offset fixup ;
: -1, ( -- ) -1 >bignum ' -1-offset fixup ;

! Words

: word-sub-primitive ( word -- obj )
    global [ target-word ] bind sub-primitives get at ;

: emit-word ( word -- )
    [
        [ subwords [ emit-word ] each ]
        [
            [
                {
                    [ hashcode <fake-bignum> , ]
                    [ name>> , ]
                    [ vocabulary>> , ]
                    [ def>> , ]
                    [ props>> , ]
                    [ drop f , ]
                    [ drop 0 , ] ! count
                    [ word-sub-primitive , ]
                    [ drop 0 , ] ! xt
                    [ drop 0 , ] ! code
                    [ drop 0 , ] ! profiling
                } cleave
            ] { } make [ ' ] map
        ] bi
        \ word type-number object tag-number
        [ emit-seq ] emit-object
    ] keep put-object ;

: word-error ( word msg -- * )
    [ % dup vocabulary>> % " " % name>> % ] "" make throw ;

: transfer-word ( word -- word )
    [ target-word ] keep or ;

: fixup-word ( word -- offset )
    transfer-word dup lookup-object
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] change-each ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped>> ' wrapper type-number object tag-number
    [ emit ] emit-object ;

! Strings
: emit-bytes ( seq -- )
    bootstrap-cell <groups>
    big-endian get [ [ be> ] map ] [ [ le> ] map ] if
    emit-seq ;

: pad-bytes ( seq -- newseq )
    dup length bootstrap-cell align 0 pad-right ;

: emit-string ( string -- ptr )
    string type-number object tag-number [
        dup length emit-fixnum
        f ' emit
        f ' emit
        pad-bytes emit-bytes
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    [ emit-string ] cache-object ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    [ assert-empty ] [
        type-number object tag-number
        [ 0 emit-fixnum ] emit-object
    ] bi* ;

M: byte-array '
    byte-array type-number object tag-number [
        dup length emit-fixnum
        pad-bytes emit-bytes
    ] emit-object ;

! Tuples
: (emit-tuple) ( tuple -- pointer )
    [ tuple-slots ]
    [ class transfer-word tuple-layout ] bi prefix [ ' ] map
    tuple type-number dup [ emit-seq ] emit-object ;

: emit-tuple ( tuple -- pointer )
    dup class name>> "tombstone" =
    [ [ (emit-tuple) ] cache-object ] [ (emit-tuple) ] if ;

M: tuple ' emit-tuple ;

M: tuple-layout '
    [
        [
            {
                [ hashcode>> , ]
                [ class>> , ]
                [ size>> , ]
                [ superclasses>> , ]
                [ echelon>> , ]
            } cleave
        ] { } make [ ' ] map
        \ tuple-layout type-number
        object tag-number [ emit-seq ] emit-object
    ] cache-object ;

M: tombstone '
    state>> "((tombstone))" "((empty))" ?
    "hashtables.private" lookup def>> first
    [ emit-tuple ] cache-object ;

! Arrays
M: array '
    [ ' ] map array type-number object tag-number
    [ [ length emit-fixnum ] [ emit-seq ] bi ] emit-object ;

! Quotations

M: quotation '
    [
        array>> '
        quotation type-number object tag-number [
            emit ! array
            f ' emit ! compiled>>
            0 emit ! xt
            0 emit ! code
        ] emit-object
    ] cache-object ;

! End of the image

: emit-words ( -- )
    all-words [ emit-word ] each ;

: emit-global ( -- )
    {
        dictionary source-files builtins
        update-map implementors-map
    } [ [ bootstrap-word ] [ get ] bi ] H{ } map>assoc
    {
        class<=-cache class-not-cache classes-intersect-cache
        class-and-cache class-or-cache
    } [ H{ } clone ] H{ } map>assoc assoc-union
    bootstrap-global set
    bootstrap-global emit-userenv ;

: emit-boot-quot ( -- )
    bootstrap-boot-quot emit-userenv ;

: emit-jit-data ( -- )
    \ if jit-if-word set
    \ dispatch jit-dispatch-word set
    \ do-primitive jit-primitive-word set
    \ declare jit-declare-word set
    [ undefined ] undefined-quot set
    {
        jit-code-format
        jit-prolog
        jit-primitive-word
        jit-primitive
        jit-word-jump
        jit-word-call
        jit-push-literal
        jit-push-immediate
        jit-if-word
        jit-if-jump
        jit-dispatch-word
        jit-dispatch
        jit-epilog
        jit-return
        jit-profiling
        jit-declare-word
        undefined-quot
    } [ emit-userenv ] each ;

: fixup-header ( -- )
    heap-size data-heap-size-offset fixup ;

: build-image ( -- image )
    800000 <vector> image set
    20000 <hashtable> objects set
    emit-header t, 0, 1, -1,
    "Serializing words..." print flush
    emit-words
    "Serializing JIT data..." print flush
    emit-jit-data
    "Serializing global namespace..." print flush
    emit-global
    "Serializing boot quotation..." print flush
    emit-boot-quot
    "Performing word fixups..." print flush
    fixup-words
    "Performing header fixups..." print flush
    fixup-header
    "Image length: " write image get length .
    "Object cache size: " write objects get assoc-size .
    \ word global delete-at
    image get ;

! Image output

: (write-image) ( image -- )
    bootstrap-cell big-endian get [
        [ >be write ] curry each
    ] [
        [ >le write ] curry each
    ] if ;

: write-image ( image -- )
    "Writing image to " write
    architecture get boot-image-name resource-path
    [ write "..." print flush ]
    [ binary [ (write-image) ] with-file-writer ] bi ;

PRIVATE>

: make-image ( arch -- )
    [
        architecture set
        "resource:/core/bootstrap/stage1.factor" run-file
        build-image
        write-image
    ] with-scope ;

: make-images ( -- )
    images [ make-image ] each ;
