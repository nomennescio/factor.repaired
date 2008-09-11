! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.backend.alien

! #alien-invoke
: set-stack-frame ( n -- )
    dup [ frame-required ] when* \ stack-frame set ;

: with-stack-frame ( n quot -- )
    swap set-stack-frame
    call
    f set-stack-frame ; inline

GENERIC: reg-size ( register-class -- n )

M: int-regs reg-size drop cell ;

M: single-float-regs reg-size drop 4 ;

M: double-float-regs reg-size drop 8 ;

GENERIC: reg-class-variable ( register-class -- symbol )

M: reg-class reg-class-variable ;

M: float-regs reg-class-variable drop float-regs ;

GENERIC: inc-reg-class ( register-class -- )

M: reg-class inc-reg-class
    dup reg-class-variable inc
    fp-shadows-int? [ reg-size stack-params +@ ] [ drop ] if ;

M: float-regs inc-reg-class
    dup call-next-method
    fp-shadows-int? [ reg-size cell /i int-regs +@ ] [ drop ] if ;

GENERIC: reg-class-full? ( class -- ? )

M: stack-params reg-class-full? drop t ;

M: object reg-class-full?
    [ reg-class-variable get ] [ param-regs length ] bi >= ;

: spill-param ( reg-class -- n reg-class )
    stack-params get
    >r reg-size stack-params +@ r>
    stack-params ;

: fastcall-param ( reg-class -- n reg-class )
    [ reg-class-variable get ] [ inc-reg-class ] [ ] tri ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ param-reg ] keep ;

: (flatten-int-type) ( size -- )
    cell /i "void*" c-type <repetition> % ;

GENERIC: flatten-value-type ( type -- )

M: object flatten-value-type , ;

M: struct-type flatten-value-type ( type -- )
    stack-size cell align (flatten-int-type) ;

M: long-long-type flatten-value-type ( type -- )
    stack-size cell align (flatten-int-type) ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        0 [
            c-type
            [ parameter-align (flatten-int-type) ] keep
            [ stack-size cell align + ] keep
            flatten-value-type
        ] reduce drop
    ] { } make ;

: each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2reverse-each ; inline

: reset-freg-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-freg-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    >r
    alien-parameters
    flatten-value-types
    r> [ >r alloc-parameter r> execute ] curry each-parameter ;
    inline

: unbox-parameters ( offset node -- )
    parameters>> [
        %prepare-unbox >r over + r> unbox-parameter
    ] reverse-each-parameter drop ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> dup large-struct?
    [ heap-size %prepare-box-struct cell ] [ drop 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to register on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return ] if-void ;

TUPLE: no-such-library name ;

M: no-such-library summary
    drop "Library not found" ;

M: no-such-library compiler-error-type
    drop +linkage+ ;

: no-such-library ( name -- )
    \ no-such-library boa
    compiling-word get compiler-error ;

TUPLE: no-such-symbol name ;

M: no-such-symbol summary
    drop "Symbol not found" ;

M: no-such-symbol compiler-error-type
    drop +linkage+ ;

: no-such-symbol ( name -- )
    \ no-such-symbol boa
    compiling-word get compiler-error ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd [ dlsym ] curry contains?
        [ drop ] [ no-such-symbol ] if
    ] [
        dll-path no-such-library drop
    ] if ;

: stdcall-mangle ( symbol node -- symbol )
    "@"
    swap parameters>> parameter-sizes drop
    number>string 3append ;

: alien-invoke-dlsym ( params -- symbols dll )
    dup function>> dup pick stdcall-mangle 2array
    swap library>> library dup [ dll>> ] when
    2dup check-dlsym ;

M: #alien-invoke generate-node
    params>>
    dup alien-invoke-frame [
        end-basic-block
        %prepare-alien-invoke
        dup objects>registers
        %prepare-var-args
        dup alien-invoke-dlsym %alien-invoke
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

! #alien-indirect
M: #alien-indirect generate-node
    params>>
    dup alien-invoke-frame [
        ! Flush registers
        end-basic-block
        ! Save registers for GC
        %prepare-alien-invoke
        ! Save alien at top of stack to temporary storage
        %prepare-alien-indirect
        dup objects>registers
        %prepare-var-args
        ! Call alien in temporary storage
        %alien-indirect
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

! #alien-callback
: box-parameters ( params -- )
    alien-parameters [ box-parameter ] each-parameter ;

: registers>objects ( node -- )
    [
        dup \ %save-param-reg move-parameters
        "nest_stacks" f %alien-invoke
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback 2 getenv ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-catchstack
    dup 2 setenv
    slip
    wait-to-return ; inline

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup "void" = ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size [ memcpy ] curry ] }
        [ c-type c-type-unboxer-quot ]
    } cond ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [
        [ callback-prep-quot ]
        [ quot>> ]
        [ callback-return-quot ] tri 3append ,
        [ callback-context new do-callback ] %
    ] [ ] make ;

: %unnest-stacks ( -- ) "unnest_stacks" f %alien-invoke ;

: callback-unwind ( params -- n )
    {
        { [ dup abi>> "stdcall" = ] [ alien-stack-frame ] }
        { [ dup return>> large-struct? ] [ drop 4 ] }
        [ drop 0 ]
    } cond ;

: %callback-return ( params -- )
    #! All the extra book-keeping for %unwind is only for x86.
    #! On other platforms its an alias for %return.
    dup alien-return
    [ %unnest-stacks ] [ %callback-value ] if-void
    callback-unwind %unwind ;

: generate-callback ( params -- )
    dup xt>> dup [
        init-templates
        %prologue
        dup alien-stack-frame [
            [ registers>objects ]
            [ wrap-callback-quot %alien-callback ]
            [ %callback-return ]
            tri
        ] with-stack-frame
    ] with-cfg-builder ;

M: #alien-callback generate-node
    end-basic-block
    params>> generate-callback iterate-next ;
