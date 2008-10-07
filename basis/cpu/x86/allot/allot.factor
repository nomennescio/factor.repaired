! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cpu.architecture cpu.x86.assembler
cpu.x86.architecture kernel.private namespaces math sequences
generic arrays compiler.generator compiler.generator.fixup
compiler.generator.registers system layouts alien locals
compiler.constants ;
IN: cpu.x86.allot

: allot-reg ( -- reg )
    #! We temporarily use the datastack register, since it won't
    #! be accessed inside the quotation given to %allot in any
    #! case.
    ds-reg ;

: (object@) ( n -- operand ) allot-reg swap [+] ;

: object@ ( n -- operand ) cells (object@) ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    0 MOV "nursery" f rc-absolute-cell rel-dlsym ;

: load-allot-ptr ( -- )
    allot-reg load-zone-ptr
    allot-reg PUSH
    allot-reg dup cell [+] MOV ;

: inc-allot-ptr ( n -- )
    allot-reg POP
    allot-reg cell [+] swap 8 align ADD ;

M: x86 %gc ( -- )
    "end" define-label
    temp-reg-1 load-zone-ptr
    temp-reg-2 temp-reg-1 cell [+] MOV
    temp-reg-2 1024 ADD
    temp-reg-1 temp-reg-1 3 cells [+] MOV
    temp-reg-2 temp-reg-1 CMP
    "end" get JLE
    0 frame-required
    %prepare-alien-invoke
    "minor_gc" f %alien-invoke
    "end" resolve-label ;

: store-header ( header -- )
    0 object@ swap type-number tag-fixnum MOV ;

: %allot ( header size quot -- )
    allot-reg PUSH
    swap >r >r
    load-allot-ptr
    store-header
    r> call
    r> inc-allot-ptr
    allot-reg POP ; inline

: %store-tagged ( reg tag -- )
    >r dup fresh-object v>operand r>
    allot-reg swap tag-number OR
    allot-reg MOV ;

M: x86 %box-float ( dst src -- )
    #! Only called by pentium4 backend, uses SSE2 instruction
    #! dest is a loc or a vreg
    float 16 [
        8 (object@) swap v>operand MOVSD
        float %store-tagged
    ] %allot ;

: %allot-bignum-signed-1 ( outreg inreg -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        { "end" "nonzero" "positive" "store" }
        [ define-label ] each
        dup v>operand 0 CMP ! is it zero?
        "nonzero" get JNE
        0 >bignum pick load-literal ! this is our result
        "end" get JMP
        "nonzero" resolve-label
        bignum 4 cells [
            ! Write length
            1 object@ 2 v>operand MOV
            ! Test sign
            dup v>operand 0 CMP
            "positive" get JGE
            2 object@ 1 MOV ! negative sign
            dup v>operand NEG
            "store" get JMP
            "positive" resolve-label
            2 object@ 0 MOV ! positive sign
            "store" resolve-label
            3 object@ swap v>operand MOV
            ! Store tagged ptr in reg
            bignum %store-tagged
        ] %allot
        "end" resolve-label
    ] with-scope ;

M: x86 %box-alien ( dst src -- )
    [
        { "end" "f" } [ define-label ] each
        dup v>operand 0 CMP
        "f" get JE
        alien 4 cells [
            1 object@ f v>operand MOV
            2 object@ f v>operand MOV
            ! Store src in alien-offset slot
            3 object@ swap v>operand MOV
            ! Store tagged ptr in dst
            dup object %store-tagged
        ] %allot
        "end" get JMP
        "f" resolve-label
        f [ v>operand ] bi@ MOV
        "end" resolve-label
    ] with-scope ;

M:: x86 %write-barrier ( src temp -- )
    #! Mark the card pointed to by vreg.
    ! Mark the card
    src card-bits SHR
    "cards_offset" f temp %alien-global
    temp temp [+] card-mark <byte> MOV

    ! Mark the card deck
    temp deck-bits card-bits - SHR
    "decks_offset" f temp %alien-global
    temp temp [+] card-mark <byte> MOV ;

! : load-zone-ptr ( reg -- )
!     #! Load pointer to start of zone array
!     0 MOV "nursery" f rc-absolute-cell rel-dlsym ;
! 
! : load-allot-ptr ( temp -- )
!     [ load-zone-ptr ] [ PUSH ] [ dup cell [+] MOV ] tri ;
! 
! : inc-allot-ptr ( n temp -- )
!     [ POP ] [ cell [+] swap 8 align ADD ] bi ;
! 
! : store-header ( temp type -- )
!     [ 0 [+] ] [ type-number tag-fixnum ] bi* MOV ;
! 
! : store-tagged ( dst temp tag -- )
!     dupd tag-number OR MOV ;
! 
! M:: x86 %allot ( dst size type tag temp -- )
!     temp load-allot-ptr
!     temp type store-header
!     temp size inc-allot-ptr
!     dst temp store-tagged ;
