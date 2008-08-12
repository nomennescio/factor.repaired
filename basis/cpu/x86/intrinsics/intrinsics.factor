! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors arrays cpu.x86.assembler
cpu.x86.allot cpu.x86.architecture cpu.architecture kernel
kernel.private math math.private namespaces quotations sequences
words generic byte-arrays hashtables hashtables.private
compiler.generator compiler.generator.registers
compiler.generator.fixup sequences.private sbufs sbufs.private
vectors vectors.private layouts system strings.private
slots.private compiler.constants ;
IN: cpu.x86.intrinsics

! Type checks
\ tag [
    "in" operand tag-mask get AND
    "in" operand %tag-fixnum
] H{
    { +input+ { { f "in" } } }
    { +output+ { "in" } }
} define-intrinsic

! Slots
: %slot-literal-known-tag ( -- op )
    "obj" operand
    "n" get cells
    "obj" get operand-tag - [+] ;

: %slot-literal-any-tag ( -- op )
    "obj" operand %untag
    "obj" operand "n" get cells [+] ;

: %slot-any ( -- op )
    "obj" operand %untag
    "n" operand fixnum>slot@
    "obj" operand "n" operand [+] ;

\ slot {
    ! Slot number is literal and the tag is known
    {
        [ "val" operand %slot-literal-known-tag MOV ] H{
            { +input+ { { f "obj" known-tag } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "val" } } }
            { +output+ { "val" } }
        }
    }
    ! Slot number is literal
    {
        [ "obj" operand %slot-literal-any-tag MOV ] H{
            { +input+ { { f "obj" } { [ small-slot? ] "n" } } }
            { +output+ { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ "obj" operand %slot-any MOV ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +output+ { "obj" } }
            { +clobber+ { "n" } }
        }
    }
} define-intrinsics

: generate-write-barrier ( -- )
    #! Mark the card pointed to by vreg.
    "val" get operand-immediate? "obj" get fresh-object? or [
        ! Mark the card
        "obj" operand card-bits SHR
        "cards_offset" f temp-reg v>operand %alien-global
        temp-reg v>operand "obj" operand [+] card-mark <byte> MOV

        ! Mark the card deck
        "obj" operand deck-bits card-bits - SHR
        "decks_offset" f temp-reg v>operand %alien-global
        temp-reg v>operand "obj" operand [+] card-mark <byte> MOV
    ] unless ;

\ set-slot {
    ! Slot number is literal and the tag is known
    {
        [ %slot-literal-known-tag "val" operand MOV generate-write-barrier ] H{
            { +input+ { { f "val" } { f "obj" known-tag } { [ small-slot? ] "n" } } }
            { +clobber+ { "obj" } }
        }
    }
    ! Slot number is literal
    {
        [ %slot-literal-any-tag "val" operand MOV generate-write-barrier ] H{
            { +input+ { { f "val" } { f "obj" } { [ small-slot? ] "n" } } }
            { +clobber+ { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ %slot-any "val" operand MOV generate-write-barrier ] H{
            { +input+ { { f "val" } { f "obj" } { f "n" } } }
            { +clobber+ { "obj" "n" } }
        }
    }
} define-intrinsics

! Sometimes, we need to do stuff with operands which are
! less than the word size. Instead of teaching the register
! allocator about the different sized registers, with all
! the complexity this entails, we just push/pop a register
! which is guaranteed to be unused (the tempreg)
: small-reg cell 8 = RBX EBX ? ; inline
: small-reg-8 BL ; inline
: small-reg-16 BX ; inline
: small-reg-32 EBX ; inline

! Fixnums
: fixnum-op ( op hash -- pair )
    >r [ "x" operand "y" operand ] swap suffix r> 2array ;

: fixnum-value-op ( op -- pair )
    H{
        { +input+ { { f "x" } { [ small-tagged? ] "y" } } }
        { +output+ { "x" } }
    } fixnum-op ;

: fixnum-register-op ( op -- pair )
    H{
        { +input+ { { f "x" } { f "y" } } }
        { +output+ { "x" } }
    } fixnum-op ;

: define-fixnum-op ( word op -- )
    [ fixnum-value-op ] keep fixnum-register-op
    2array define-intrinsics ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUB }
    { fixnum-bitand AND }
    { fixnum-bitor OR }
    { fixnum-bitxor XOR }
} [
    first2 define-fixnum-op
] each

\ fixnum-bitnot [
    "x" operand NOT
    "x" operand tag-mask get XOR
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

\ fixnum*fast {
    {
        [
            "x" operand "y" get IMUL2
        ] H{
            { +input+ { { f "x" } { [ small-tagged? ] "y" } } }
            { +output+ { "x" } }
        }
    } {
        [
            "out" operand "x" operand MOV
            "out" operand %untag-fixnum
            "y" operand "out" operand IMUL2
        ] H{
            { +input+ { { f "x" } { f "y" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    }
} define-intrinsics

: %untag-fixnums ( seq -- )
    [ %untag-fixnum ] unique-operands ;

\ fixnum-shift-fast [
    "x" operand "y" get
    dup 0 < [ neg SAR ] [ SHL ] if
    ! Mask off low bits
    "x" operand %untag
] H{
    { +input+ { { f "x" } { [ ] "y" } } }
    { +output+ { "x" } }
} define-intrinsic

: overflow-check ( word -- )
    "end" define-label
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } %untag-fixnums
    "x" operand "y" operand rot execute
    "z" get "x" get %allot-bignum-signed-1
    "end" resolve-label ; inline

: overflow-template ( word insn -- )
    [ overflow-check ] curry H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "z" } } }
        { +output+ { "z" } }
        { +clobber+ { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD overflow-template
\ fixnum- \ SUB overflow-template

: fixnum-jump ( op inputs -- pair )
    >r [ "x" operand "y" operand CMP ] swap suffix r> 2array ;

: fixnum-value-jump ( op -- pair )
    { { f "x" } { [ small-tagged? ] "y" } } fixnum-jump ;

: fixnum-register-jump ( op -- pair )
    { { f "x" } { f "y" } } fixnum-jump ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] keep fixnum-register-jump
    2array define-if-intrinsics ;

{
    { fixnum< JGE }
    { fixnum<= JG }
    { fixnum> JLE }
    { fixnum>= JL }
    { eq? JNE }
} [
    first2 define-fixnum-jump
] each

\ fixnum>bignum [
    "x" operand %untag-fixnum
    "x" get dup %allot-bignum-signed-1
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

\ bignum>fixnum [
    "nonzero" define-label
    "positive" define-label
    "end" define-label
    "x" operand %untag
    "y" operand "x" operand cell [+] MOV
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    "y" operand 1 v>operand CMP
    "nonzero" get JNE
    "y" operand 0 MOV
    "end" get JMP
    "nonzero" resolve-label
    ! load the value
    "y" operand "x" operand 3 cells [+] MOV
    ! load the sign
    "x" operand "x" operand 2 cells [+] MOV
    ! is the sign negative?
    "x" operand 0 CMP
    "positive" get JE
    "y" operand -1 IMUL2
    "positive" resolve-label
    "y" operand 3 SHL
    "end" resolve-label
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "y" } } }
    { +clobber+ { "x" } }
    { +output+ { "y" } }
} define-intrinsic

! User environment
: %userenv ( -- )
    "x" operand 0 MOV
    "userenv" f rc-absolute-cell rel-dlsym
    "n" operand fixnum>slot@
    "n" operand "x" operand ADD ;

\ getenv [
    %userenv  "n" operand dup [] MOV
] H{
    { +input+ { { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +output+ { "n" } }
} define-intrinsic

\ setenv [
    %userenv  "n" operand [] "val" operand MOV
] H{
    { +input+ { { f "val" } { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +clobber+ { "n" } }
} define-intrinsic

! \ (tuple) [
!     tuple "layout" get size>> 2 + cells [
!         ! Store layout
!         "layout" get "scratch" get load-literal
!         1 object@ "scratch" operand MOV
!         ! Store tagged ptr in reg
!         "tuple" get tuple %store-tagged
!     ] %allot
! ] H{
!     { +input+ { { [ ] "layout" } } }
!     { +scratch+ { { f "tuple" } { f "scratch" } } }
!     { +output+ { "tuple" } }
! } define-intrinsic
! 
! \ (array) [
!     array "n" get 2 + cells [
!         ! Store length
!         1 object@ "n" operand MOV
!         ! Store tagged ptr in reg
!         "array" get object %store-tagged
!     ] %allot
! ] H{
!     { +input+ { { [ ] "n" } } }
!     { +scratch+ { { f "array" } } }
!     { +output+ { "array" } }
! } define-intrinsic
! 
! \ (byte-array) [
!     byte-array "n" get 2 cells + [
!         ! Store length
!         1 object@ "n" operand MOV
!         ! Store tagged ptr in reg
!         "array" get object %store-tagged
!     ] %allot
! ] H{
!     { +input+ { { [ ] "n" } } }
!     { +scratch+ { { f "array" } } }
!     { +output+ { "array" } }
! } define-intrinsic

\ <ratio> [
    ratio 3 cells [
        1 object@ "numerator" operand MOV
        2 object@ "denominator" operand MOV
        ! Store tagged ptr in reg
        "ratio" get ratio %store-tagged
    ] %allot
] H{
    { +input+ { { f "numerator" } { f "denominator" } } }
    { +scratch+ { { f "ratio" } } }
    { +output+ { "ratio" } }
} define-intrinsic

\ <complex> [
    complex 3 cells [
        1 object@ "real" operand MOV
        2 object@ "imaginary" operand MOV
        ! Store tagged ptr in reg
        "complex" get complex %store-tagged
    ] %allot
] H{
    { +input+ { { f "real" } { f "imaginary" } } }
    { +scratch+ { { f "complex" } } }
    { +output+ { "complex" } }
} define-intrinsic

\ <wrapper> [
    wrapper 2 cells [
        1 object@ "obj" operand MOV
        ! Store tagged ptr in reg
        "wrapper" get object %store-tagged
    ] %allot
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "wrapper" } } }
    { +output+ { "wrapper" } }
} define-intrinsic

! Alien intrinsics
: %alien-accessor ( quot -- )
    "offset" operand %untag-fixnum
    "offset" operand "alien" operand ADD
    "offset" operand [] swap call ; inline

: %alien-integer-get ( quot reg -- )
    small-reg PUSH
    swap %alien-accessor
    "value" operand small-reg MOV
    "value" operand %tag-fixnum
    small-reg POP ; inline

: alien-integer-get-template
    H{
        { +input+ {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +scratch+ { { f "value" } } }
        { +output+ { "value" } }
        { +clobber+ { "offset" } }
    } ;

: define-getter ( word quot reg -- )
    [ %alien-integer-get ] 2curry
    alien-integer-get-template
    define-intrinsic ;

: define-unsigned-getter ( word reg -- )
    [ small-reg dup XOR MOV ] swap define-getter ;

: define-signed-getter ( word reg -- )
    [ [ >r MOV small-reg r> MOVSX ] curry ] keep define-getter ;

: %alien-integer-set ( quot reg -- )
    small-reg PUSH
    "offset" get "value" get = [
        "value" operand %untag-fixnum
    ] unless
    small-reg "value" operand MOV
    swap %alien-accessor
    small-reg POP ; inline

: alien-integer-set-template
    H{
        { +input+ {
            { f "value" fixnum }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +clobber+ { "value" "offset" } }
    } ;

: define-setter ( word reg -- )
    [ swap MOV ] swap
    [ %alien-integer-set ] 2curry
    alien-integer-set-template
    define-intrinsic ;

\ alien-unsigned-1 small-reg-8 define-unsigned-getter
\ set-alien-unsigned-1 small-reg-8 define-setter

\ alien-signed-1 small-reg-8 define-signed-getter
\ set-alien-signed-1 small-reg-8 define-setter

\ alien-unsigned-2 small-reg-16 define-unsigned-getter
\ set-alien-unsigned-2 small-reg-16 define-setter

\ alien-signed-2 small-reg-16 define-signed-getter
\ set-alien-signed-2 small-reg-16 define-setter

\ alien-cell [
    "value" operand [ MOV ] %alien-accessor
] H{
    { +input+ {
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { +scratch+ { { unboxed-alien "value" } } }
    { +output+ { "value" } }
    { +clobber+ { "offset" } }
} define-intrinsic

\ set-alien-cell [
    "value" operand [ swap MOV ] %alien-accessor
] H{
    { +input+ {
        { unboxed-c-ptr "value" pinned-c-ptr }
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { +clobber+ { "offset" } }
} define-intrinsic
