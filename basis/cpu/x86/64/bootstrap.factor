! Copyright (C) 2007, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system layouts vocabs parser compiler.constants
compiler.codegen.relocation math math.private cpu.x86.assembler
cpu.x86.assembler.operands sequences generic.single.private
threads.private ;
IN: bootstrap.x86

8 \ cell set

: shift-arg ( -- reg ) RCX ;
: div-arg ( -- reg ) RAX ;
: mod-arg ( -- reg ) RDX ;
: temp0 ( -- reg ) RAX ;
: temp1 ( -- reg ) RCX ;
: temp2 ( -- reg ) RDX ;
: temp3 ( -- reg ) RBX ;
: pic-tail-reg ( -- reg ) RBX ;
: return-reg ( -- reg ) RAX ;
: nv-reg ( -- reg ) RBX ;
: stack-reg ( -- reg ) RSP ;
: frame-reg ( -- reg ) RBP ;
: link-reg ( -- reg ) R11 ;
: ctx-reg ( -- reg ) R12 ;
: vm-reg ( -- reg ) R13 ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) temp0 1 SAR ;
: rex-length ( -- n ) 1 ;

: jit-call ( name -- )
    RAX 0 MOV f rc-absolute-cell rel-dlsym
    RAX CALL ;

[
    ! load entry point
    RAX 0 MOV rc-absolute-cell rel-this
    ! alignment
    RSP stack-frame-size bootstrap-cell - SUB
    ! store entry point
    RSP stack-frame-size bootstrap-cell 3 * - [+] RAX MOV
    ! store stack frame size
    RSP stack-frame-size bootstrap-cell 2 * - [+] stack-frame-size MOV
] jit-prolog jit-define

[
    pic-tail-reg 5 [RIP+] LEA
    0 JMP f rc-relative rel-word-pic-tail
] jit-word-jump jit-define

: jit-load-context ( -- )
    ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- )
    jit-load-context
    R11 RSP -8 [+] LEA
    ctx-reg context-callstack-top-offset [+] R11 MOV
    ctx-reg context-datastack-offset [+] ds-reg MOV
    ctx-reg context-retainstack-offset [+] rs-reg MOV ;

: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset [+] MOV
    rs-reg ctx-reg context-retainstack-offset [+] MOV ;

[
    ! ctx-reg is preserved across the call because it is non-volatile
    ! in the C ABI
    jit-save-context
    ! call the primitive
    arg1 vm-reg MOV
    RAX 0 MOV f f rc-absolute-cell rel-dlsym
    RAX CALL
    jit-restore-context
] jit-primitive jit-define

: jit-jump-quot ( -- ) arg1 quot-entry-point-offset [+] JMP ;

: jit-call-quot ( -- ) arg1 quot-entry-point-offset [+] CALL ;

[
    arg2 arg1 MOV
    arg1 vm-reg MOV
    "begin_callback" jit-call

    ! call the quotation
    arg1 return-reg MOV
    jit-call-quot

    arg1 vm-reg MOV
    "end_callback" jit-call
] \ c-to-factor define-sub-primitive

USE: locals

:: jit-save-volatile-regs ( -- save-size )
    ! do we also need to save XMM?
    volatile-regs length bootstrap-cell * 16 align :> save-size
    RSP 2 bootstrap-cells [+] save-size ADD ! bump up stack frame size
    RSP save-size SUB
    volatile-regs
    [| r i | RSP i bootstrap-cell * [+] r MOV ] each-index
    save-size ;

:: jit-restore-volatile-regs ( save-size -- )
    volatile-regs
    [| r i | r RSP i bootstrap-cell * [+] MOV ] each-index
    RSP save-size ADD ;

[| |
    jit-save-volatile-regs :> save-size
    jit-save-context
    RAX vm-reg vm-signal-handler-addr-offset [+] MOV
    RAX CALL
    save-size jit-restore-volatile-regs
] \ signal-handler define-sub-primitive

[| |
    jit-save-volatile-regs :> save-size
    jit-save-context
    RAX vm-reg vm-signal-handler-addr-offset [+] MOV
    RAX CALL
    ! Stack at this point has a fake stack frame set up to represent the
    ! leaf procedure we interrupted. We must tear down that frame in
    ! addition to our own before resuming.
    ! Grab our resume address and place it just underneath the leaf proc's
    ! return address, since we can't touch any registers once they've been
    ! restored. If we got this far there should be no faults here and we
    ! can get away with corrupting the stack frame.
    RAX RSP save-size 3 bootstrap-cells + [+] MOV
    RSP save-size 6 bootstrap-cells + [+] RAX MOV

    ! Popping 3 extra cells here plus the 3 cells the epilogue pops leaves
    ! the resume address at the top of the stack for when the epilogue RETs.
    save-size 3 bootstrap-cells + jit-restore-volatile-regs
] \ leaf-signal-handler define-sub-primitive

[
    arg1 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ (call) define-combinator-primitive

[
    ! Unwind stack frames
    RSP arg2 MOV

    ! Load VM pointer into vm-reg, since we're entering from
    ! C code
    vm-reg 0 MOV 0 rc-absolute-cell rel-vm

    ! Load ds and rs registers
    jit-load-context
    jit-restore-context

    ! Call quotation
    jit-jump-quot
] \ unwind-native-frames define-sub-primitive

[
    RSP 2 SUB
    RSP [] FNSTCW
    FNINIT
    AX RSP [] MOV
    RSP 2 ADD
] \ fpu-state define-sub-primitive

[
    RSP 2 SUB
    RSP [] arg1 16-bit-version-of MOV
    RSP [] FLDCW
    RSP 2 ADD
] \ set-fpu-state define-sub-primitive

[
    ! Load callstack object
    arg4 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ! Get ctx->callstack_bottom
    jit-load-context
    arg1 ctx-reg context-callstack-bottom-offset [+] MOV
    ! Get top of callstack object -- 'src' for memcpy
    arg2 arg4 callstack-top-offset [+] LEA
    ! Get callstack length, in bytes --- 'len' for memcpy
    arg3 arg4 callstack-length-offset [+] MOV
    arg3 tag-bits get SHR
    ! Compute new stack pointer -- 'dst' for memcpy
    arg1 arg3 SUB
    ! Install new stack pointer
    RSP arg1 MOV
    ! Call memcpy; arguments are now in the correct registers
    ! Create register shadow area for Win64
    RSP 32 SUB
    "factor_memcpy" jit-call
    ! Tear down register shadow area
    RSP 32 ADD
    ! Return with new callstack
    0 RET
] \ set-callstack define-sub-primitive

[
    jit-save-context
    arg2 vm-reg MOV
    "lazy_jit_compile" jit-call
    arg1 return-reg MOV
]
[ return-reg quot-entry-point-offset [+] CALL ]
[ jit-jump-quot ]
\ lazy-jit-compile define-combinator-primitive

[
    temp2 HEX: ffffffff MOV f rc-absolute-cell rel-literal
    temp1 temp2 CMP
] pic-check-tuple jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    RBX RSP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    arg1 RBX MOV
    arg2 vm-reg MOV
    RAX 0 MOV rc-absolute-cell rel-inline-cache-miss
    RAX CALL
    jit-load-context
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss-tail define-combinator-primitive

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ds-reg 8 SUB
    jit-save-context
    arg1 ds-reg [] MOV
    arg2 ds-reg 8 [+] MOV
    arg3 arg1 MOV
    [ [ arg3 arg2 ] dip call ] dip
    ds-reg [] arg3 MOV
    [ JNO ]
    [ arg3 vm-reg MOV jit-call ]
    jit-conditional ; inline

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg 8 SUB
    jit-save-context
    RCX ds-reg [] MOV
    RBX ds-reg 8 [+] MOV
    RBX tag-bits get SAR
    RAX RCX MOV
    RBX IMUL
    ds-reg [] RAX MOV
    [ JNO ]
    [
        arg1 RCX MOV
        arg1 tag-bits get SAR
        arg2 RBX MOV
        arg3 vm-reg MOV
        "overflow_fixnum_multiply" jit-call
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

! Contexts
: jit-switch-context ( reg -- )
    ! Reset return value since its bogus right now, to avoid
    ! confusing the GC
    RSP -8 [+] 0 MOV

    ! Make the new context the current one
    ctx-reg swap MOV
    vm-reg vm-context-offset [+] ctx-reg MOV

    ! Load new stack pointer
    RSP ctx-reg context-callstack-top-offset [+] MOV

    ! Load new ds, rs registers
    jit-restore-context

    ctx-reg jit-update-tib ;

: jit-pop-context-and-param ( -- )
    arg1 ds-reg [] MOV
    arg1 arg1 alien-offset [+] MOV
    arg2 ds-reg -8 [+] MOV
    ds-reg 16 SUB ;

: jit-push-param ( -- )
    ds-reg 8 ADD
    ds-reg [] arg2 MOV ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    jit-save-context
    arg1 jit-switch-context
    RSP 8 ADD
    jit-push-param ;

[ jit-set-context ] \ (set-context) define-sub-primitive

: jit-pop-quot-and-param ( -- )
    arg1 ds-reg [] MOV
    arg2 ds-reg -8 [+] MOV
    ds-reg 16 SUB ;

: jit-start-context ( -- )
    ! Create the new context in return-reg. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    jit-save-context
    arg1 vm-reg MOV
    "new_context" jit-call

    jit-pop-quot-and-param
    jit-save-context
    return-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

[ jit-start-context ] \ (start-context) define-sub-primitive

: jit-delete-current-context ( -- )
    jit-load-context
    arg1 vm-reg MOV
    arg2 ctx-reg MOV
    "delete_context" jit-call ;

[
    jit-delete-current-context
    jit-set-context
] \ (set-context-and-delete) define-sub-primitive

: jit-start-context-and-delete ( -- )
    jit-load-context
    arg1 vm-reg MOV
    arg2 ctx-reg MOV
    "reset_context" jit-call

    jit-pop-quot-and-param
    ctx-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

: jit-safepoint ( -- )
    0 [RIP+] EAX MOV rc-relative rel-safepoint ;

[
    jit-start-context-and-delete
] \ (start-context-and-delete) define-sub-primitive
