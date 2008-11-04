! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences
system layouts alien alien.c-types alien.accessors alien.structs
slots splitting assocs combinators cpu.x86.assembler
cpu.x86.architecture cpu.architecture compiler.constants
compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics ;
IN: cpu.x86.64

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { double-float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;
M: x86.64 temp-reg-1 RAX ;
M: x86.64 temp-reg-2 RCX ;

M: int-regs return-reg drop RAX ;
M: int-regs param-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs return-reg drop XMM0 ;

M: float-regs param-regs
    drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

M: x86.64 rel-literal-x86 rc-relative rel-literal ;

M: x86.64 %prologue ( n -- )
    temp-reg-1 0 MOV rc-absolute-cell rel-this
    dup PUSH
    temp-reg-1 PUSH
    stack-reg swap 3 cells - SUB ;

M: stack-params %load-param-reg
    drop
    >r R11 swap stack@ MOV
    r> stack@ R11 MOV ;

M: stack-params %save-param-reg
    drop
    R11 swap next-stack@ MOV
    stack@ R11 MOV ;

: with-return-regs ( quot -- )
    [
        V{ RDX RAX } clone int-regs set
        V{ XMM1 XMM0 } clone float-regs set
        call
    ] with-scope ; inline

! The ABI for passing structs by value is pretty messed up
<< "void*" c-type clone "__stack_value" define-primitive-type
stack-params "__stack_value" c-type (>>reg-class) >>

: struct-types&offset ( struct-type -- pairs )
    fields>> [
        [ type>> ] [ offset>> ] bi 2array
    ] map ;

: split-struct ( pairs -- seq )
    [
        [ 8 mod zero? [ t , ] when , ] assoc-each
    ] { } make { t } split harvest ;

: flatten-small-struct ( c-type -- seq )
    struct-types&offset split-struct [
        [ c-type c-type-reg-class ] map
        int-regs swap member? "void*" "double" ? c-type
    ] map ;

: flatten-large-struct ( c-type -- seq )
    heap-size cell align
    cell /i "__stack_value" c-type <repetition> ;

M: struct-type flatten-value-type ( type -- seq )
    dup heap-size 16 > [
        flatten-large-struct
    ] [
        flatten-small-struct
    ] if ;

M: x86.64 %prepare-unbox ( -- )
    ! First parameter is top of stack
    RDI R14 [] MOV
    R14 cell SUB ;

M: x86.64 %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: x86.64 %unbox-long-long ( n func -- )
    int-regs swap %unbox ;

: %unbox-struct-field ( c-type i -- )
    ! Alien must be in RDI.
    RDI swap cells [+] swap reg-class>> {
        { int-regs [ int-regs get pop swap MOV ] }
        { double-float-regs [ float-regs get pop swap MOVSD ] }
    } case ;

M: x86.64 %unbox-small-struct ( c-type -- )
    ! Alien must be in RDI.
    "alien_offset" f %alien-invoke
    ! Move alien_offset() return value to RDI so that we don't
    ! clobber it.
    RDI RAX MOV
    [
        flatten-small-struct [ %unbox-struct-field ] each-index
    ] with-return-regs ;

M: x86.64 %unbox-large-struct ( n c-type -- )
    ! Source is in RDI
    heap-size
    ! Load destination address
    RSI rot stack@ LEA
    ! Load structure size
    RDX swap MOV
    ! Copy the struct to the C stack
    "to_value_struct" f %alien-invoke ;

: load-return-value ( reg-class -- )
    0 over param-reg swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

M: x86.64 %box ( n reg-class func -- )
    rot [
        rot [ 0 swap param-reg ] keep %load-param-reg
    ] [
        swap load-return-value
    ] if*
    f %alien-invoke ;

M: x86.64 %box-long-long ( n func -- )
    int-regs swap %box ;

M: x86.64 struct-small-enough? ( size -- ? )
    heap-size 2 cells <= ;

: box-struct-field@ ( i -- operand ) 1+ cells stack@ ;

: %box-struct-field ( c-type i -- )
    box-struct-field@ swap reg-class>> {
        { int-regs [ int-regs get pop MOV ] }
        { double-float-regs [ float-regs get pop MOVSD ] }
    } case ;

M: x86.64 %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct.
    [
        [ flatten-small-struct [ %box-struct-field ] each-index ]
        [ RDX swap heap-size MOV ] bi
        RDI 0 box-struct-field@ MOV
        RSI 1 box-struct-field@ MOV
        "box_small_struct" f %alien-invoke
    ] with-return-regs ;

: struct-return@ ( n -- operand )
    [ stack-frame get params>> ] unless* stack@ ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    RSI swap heap-size MOV
    ! Compute destination address
    RDI swap struct-return@ LEA
    ! Copy the struct from the C stack
    "box_value_struct" f %alien-invoke ;

M: x86.64 %prepare-box-struct ( -- )
    ! Compute target address for value struct return
    RAX f struct-return@ LEA
    ! Store it as the first parameter
    0 stack@ RAX MOV ;

M: x86.64 %prepare-var-args RAX RAX XOR ;

M: x86.64 %alien-global
    [ 0 MOV rc-absolute-cell rel-dlsym ] [ dup [] MOV ] bi ;

M: x86.64 %alien-invoke
    R11 0 MOV
    rc-absolute-cell rel-dlsym
    R11 CALL ;

M: x86.64 %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    RBP RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    RBP CALL ;

M: x86.64 %alien-callback ( quot -- )
    RDI swap %load-indirect
    "c_to_factor" f %alien-invoke ;

M: x86.64 %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    ! Save top of data stack
    RSP 8 SUB
    RDI PUSH
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Put former top of data stack in RDI
    RDI POP
    RSP 8 ADD
    ! Unbox former top of data stack to return registers
    unbox-return ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

! SSE2 is always available on x86-64.
enable-float-intrinsics
