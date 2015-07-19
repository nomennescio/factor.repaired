USING: cpu.x86.assembler cpu.x86.assembler.operands
kernel tools.test namespaces make layouts ;
IN: cpu.x86.assembler.tests

! small registers
{ { 128 192 12 } } [ [ AL 12 <byte> ADD ] { } make ] unit-test
{ { 128 196 12 } } [ [ AH 12 <byte> ADD ] { } make ] unit-test
{ { 176 12 } } [ [ AL 12 <byte> MOV ] { } make ] unit-test
{ { 180 12 } } [ [ AH 12 <byte> MOV ] { } make ] unit-test
{ { 198 0 12 } } [ [ EAX [] 12 <byte> MOV ] { } make ] unit-test
{ { 0 235 } } [ [ BL CH ADD ] { } make ] unit-test
{ { 136 235 } } [ [ BL CH MOV ] { } make ] unit-test

! immediate operands
cell 4 = [
    [ { 0xb9 0x01 0x00 0x00 0x00 } ] [ [ ECX 1 MOV ] { } make ] unit-test
] [
    [ { 0xb9 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } ] [ [ ECX 1 MOV ] { } make ] unit-test
] if

{ { 0x83 0xc1 0x01 } } [ [ ECX 1 ADD ] { } make ] unit-test
{ { 0x81 0xc1 0x96 0x00 0x00 0x00 } } [ [ ECX 150 ADD ] { } make ] unit-test
{ { 0xf7 0xc1 0xd2 0x04 0x00 0x00 } } [ [ ECX 1234 TEST ] { } make ] unit-test

! 64-bit registers
{ { 0x40 0x8a 0x2a } } [ [ BPL RDX [] MOV ] { } make ] unit-test

{ { 0x49 0x89 0x04 0x24 } } [ [ R12 [] RAX MOV ] { } make ] unit-test
{ { 0x49 0x8b 0x06 } } [ [ RAX R14 [] MOV ] { } make ] unit-test

{ { 0x89 0xca } } [ [ EDX ECX MOV ] { } make ] unit-test
{ { 0x4c 0x89 0xe2 } } [ [ RDX R12 MOV ] { } make ] unit-test
{ { 0x49 0x89 0xd4 } } [ [ R12 RDX MOV ] { } make ] unit-test

! memory address modes
{ { 0x8a 0x18         } } [ [ BL RAX [] MOV ] { } make ] unit-test
{ { 0x66 0x8b 0x18 } } [ [ BX RAX [] MOV ] { } make ] unit-test
{ { 0x8b 0x18         } } [ [ EBX RAX [] MOV ] { } make ] unit-test
{ { 0x48 0x8b 0x18 } } [ [ RBX RAX [] MOV ] { } make ] unit-test
{ { 0x88 0x18         } } [ [ RAX [] BL MOV ] { } make ] unit-test
{ { 0x66 0x89 0x18 } } [ [ RAX [] BX MOV ] { } make ] unit-test
{ { 0x89 0x18         } } [ [ RAX [] EBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x18 } } [ [ RAX [] RBX MOV ] { } make ] unit-test

{ { 0x0f 0xbe 0xc3 } } [ [ EAX BL MOVSX ] { } make ] unit-test
{ { 0x0f 0xbf 0xc3 } } [ [ EAX BX MOVSX ] { } make ] unit-test

{ { 0x80 0x08 0x05 } } [ [ EAX [] 5 <byte> OR ] { } make ] unit-test
{ { 0xc6 0x00 0x05 } } [ [ EAX [] 5 <byte> MOV ] { } make ] unit-test

{ { 0x49 0x89 0x04 0x1a } } [ [ R10 RBX [+] RAX MOV ] { } make ] unit-test
{ { 0x49 0x89 0x04 0x1b } } [ [ R11 RBX [+] RAX MOV ] { } make ] unit-test

{ { 0x49 0x89 0x04 0x1c } } [ [ R12 RBX [+] RAX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x04 0x1c } } [ [ RSP RBX [+] RAX MOV ] { } make ] unit-test

{ { 0x49 0x89 0x44 0x1d 0x00 } } [ [ R13 RBX [+] RAX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x44 0x1d 0x00 } } [ [ RBP RBX [+] RAX MOV ] { } make ] unit-test

{ { 0x4a 0x89 0x04 0x23 } } [ [ RBX R12 [+] RAX MOV ] { } make ] unit-test
{ { 0x4a 0x89 0x04 0x2b } } [ [ RBX R13 [+] RAX MOV ] { } make ] unit-test

{ { 0x4b 0x89 0x44 0x25 0x00 } } [ [ R13 R12 [+] RAX MOV ] { } make ] unit-test
{ { 0x4b 0x89 0x04 0x2c } } [ [ R12 R13 [+] RAX MOV ] { } make ] unit-test

{ { 0x49 0x89 0x04 0x2c } } [ [ R12 RBP [+] RAX MOV ] { } make ] unit-test
[ [ R12 RSP [+] RAX MOV ] { } make ] must-fail

{ { 0x89 0x1c 0x11 } } [ [ ECX EDX [+] EBX MOV ] { } make ] unit-test
{ { 0x89 0x1c 0x51 } } [ [ ECX EDX 1 0 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x1c 0x91 } } [ [ ECX EDX 2 0 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x1c 0xd1 } } [ [ ECX EDX 3 0 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x5c 0x11 0x64 } } [ [ ECX EDX 0 100 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x5c 0x51 0x64 } } [ [ ECX EDX 1 100 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x5c 0x91 0x64 } } [ [ ECX EDX 2 100 <indirect> EBX MOV ] { } make ] unit-test
{ { 0x89 0x5c 0xd1 0x64 } } [ [ ECX EDX 3 100 <indirect> EBX MOV ] { } make ] unit-test

{ { 0x48 0x89 0x1c 0x11 } } [ [ RCX RDX [+] RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x1c 0x51 } } [ [ RCX RDX 1 0 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x1c 0x91 } } [ [ RCX RDX 2 0 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x1c 0xd1 } } [ [ RCX RDX 3 0 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x5c 0x11 0x64 } } [ [ RCX RDX 0 100 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x5c 0x51 0x64 } } [ [ RCX RDX 1 100 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x5c 0x91 0x64 } } [ [ RCX RDX 2 100 <indirect> RBX MOV ] { } make ] unit-test
{ { 0x48 0x89 0x5c 0xd1 0x64 } } [ [ RCX RDX 3 100 <indirect> RBX MOV ] { } make ] unit-test

! r-rm / m-r sse instruction
{ { 0x0f 0x10 0xc1 } } [ [ XMM0 XMM1 MOVUPS ] { } make ] unit-test
{ { 0x0f 0x10 0x01 } } [ [ XMM0 ECX [] MOVUPS ] { } make ] unit-test
{ { 0x0f 0x11 0x08 } } [ [ EAX [] XMM1 MOVUPS ] { } make ] unit-test

{ { 0xf3 0x0f 0x10 0xc1 } } [ [ XMM0 XMM1 MOVSS ] { } make ] unit-test
{ { 0xf3 0x0f 0x10 0x01 } } [ [ XMM0 ECX [] MOVSS ] { } make ] unit-test
{ { 0xf3 0x0f 0x11 0x08 } } [ [ EAX [] XMM1 MOVSS ] { } make ] unit-test

{ { 0x66 0x0f 0x6f 0xc1 } } [ [ XMM0 XMM1 MOVDQA ] { } make ] unit-test
{ { 0x66 0x0f 0x6f 0x01 } } [ [ XMM0 ECX [] MOVDQA ] { } make ] unit-test
{ { 0x66 0x0f 0x7f 0x08 } } [ [ EAX [] XMM1 MOVDQA ] { } make ] unit-test

! r-rm only sse instruction
{ { 0x66 0x0f 0x2e 0xc1 } } [ [ XMM0 XMM1 UCOMISD ] { } make ] unit-test
{ { 0x66 0x0f 0x2e 0x01 } } [ [ XMM0 ECX [] UCOMISD ] { } make ] unit-test
[ [ EAX [] XMM1 UCOMISD ] { } make ] must-fail
{ { 0x66 0x0f 0x38 0x2a 0x01 } } [ [ XMM0 ECX [] MOVNTDQA ] { } make ] unit-test

{ { 0x66 0x48 0x0f 0x6e 0xc8 } } [ [ XMM1 RAX MOVD ] { } make ] unit-test
{ { 0x66 0x0f 0x6e 0xc8 } } [ [ XMM1 EAX MOVD ] { } make ] unit-test
{ { 0x66 0x48 0x0f 0x7e 0xc8 } } [ [ RAX XMM1 MOVD ] { } make ] unit-test
{ { 0x66 0x0f 0x7e 0xc8 } } [ [ EAX XMM1 MOVD ] { } make ] unit-test

{ { 0xf3 0x0f 0x7e 0x08 } } [ [ XMM1 EAX [] MOVQ ] { } make ] unit-test
{ { 0xf3 0x0f 0x7e 0x08 } } [ [ XMM1 EAX [] MOVQ ] { } make ] unit-test
{ { 0xf3 0x0f 0x7e 0xca } } [ [ XMM1 XMM2 MOVQ ] { } make ] unit-test

! rm-r only sse instructions
{ { 0x0f 0x2b 0x08 } } [ [ EAX [] XMM1 MOVNTPS ] { } make ] unit-test
{ { 0x66 0x0f 0xe7 0x08 } } [ [ EAX [] XMM1 MOVNTDQ ] { } make ] unit-test

! three-byte-opcode ssse3 instruction
{ { 0x66 0x0f 0x38 0x02 0xc1 } } [ [ XMM0 XMM1 PHADDD ] { } make ] unit-test

! int/sse conversion instruction
{ { 0xf2 0x0f 0x2c 0xc0 } } [ [ EAX XMM0 CVTTSD2SI ] { } make ] unit-test
{ { 0xf2 0x48 0x0f 0x2c 0xc0 } } [ [ RAX XMM0 CVTTSD2SI ] { } make ] unit-test
{ { 0xf2 0x4c 0x0f 0x2c 0xe0 } } [ [ R12 XMM0 CVTTSD2SI ] { } make ] unit-test
{ { 0xf2 0x0f 0x2a 0xc0 } } [ [ XMM0 EAX CVTSI2SD ] { } make ] unit-test
{ { 0xf2 0x48 0x0f 0x2a 0xc0 } } [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
{ { 0xf2 0x48 0x0f 0x2a 0xc1 } } [ [ XMM0 RCX CVTSI2SD ] { } make ] unit-test
{ { 0xf2 0x48 0x0f 0x2a 0xd9 } } [ [ XMM3 RCX CVTSI2SD ] { } make ] unit-test
{ { 0xf2 0x48 0x0f 0x2a 0xc0 } } [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
{ { 0xf2 0x49 0x0f 0x2a 0xc4 } } [ [ XMM0 R12 CVTSI2SD ] { } make ] unit-test

! 3-operand r-rm-imm sse instructions
{ { 0x66 0x0f 0x70 0xc1 0x02 } }
[ [ XMM0 XMM1 2 PSHUFD ] { } make ] unit-test

{ { 0x0f 0xc6 0xc1 0x02 } }
[ [ XMM0 XMM1 2 SHUFPS ] { } make ] unit-test

! shufflers with arrays of indexes
{ { 0x66 0x0f 0x70 0xc1 0x02 } }
[ [ XMM0 XMM1 { 2 0 0 0 } PSHUFD ] { } make ] unit-test

{ { 0x0f 0xc6 0xc1 0x63 } }
[ [ XMM0 XMM1 { 3 0 2 1 } SHUFPS ] { } make ] unit-test

{ { 0x66 0x0f 0xc6 0xc1 0x2 } }
[ [ XMM0 XMM1 { 0 1 } SHUFPD ] { } make ] unit-test

{ { 0x66 0x0f 0xc6 0xc1 0x1 } }
[ [ XMM0 XMM1 { 1 0 } SHUFPD ] { } make ] unit-test

! scalar register insert/extract sse instructions
{ { 0x66 0x0f 0xc4 0xc1 0x02 } } [ [ XMM0 ECX 2 PINSRW ] { } make ] unit-test
{ { 0x66 0x0f 0xc4 0x04 0x11 0x03 } } [ [ XMM0 ECX EDX [+] 3 PINSRW ] { } make ] unit-test

{ { 0x66 0x0f 0xc5 0xc1 0x02 } } [ [ EAX XMM1 2 PEXTRW ] { } make ] unit-test
{ { 0x66 0x0f 0x3a 0x15 0x08 0x02 } } [ [ EAX [] XMM1 2 PEXTRW ] { } make ] unit-test
{ { 0x66 0x0f 0x3a 0x15 0x14 0x08 0x03 } } [ [ EAX ECX [+] XMM2 3 PEXTRW ] { } make ] unit-test
{ { 0x66 0x0f 0x3a 0x14 0xc8 0x02 } } [ [ EAX XMM1 2 PEXTRB ] { } make ] unit-test
{ { 0x66 0x0f 0x3a 0x14 0x08 0x02 } } [ [ EAX [] XMM1 2 PEXTRB ] { } make ] unit-test

! sse shift instructions
{ { 0x66 0x0f 0x71 0xd0 0x05 } } [ [ XMM0 5 PSRLW ] { } make ] unit-test
{ { 0x66 0x0f 0xd1 0xc1 } } [ [ XMM0 XMM1 PSRLW ] { } make ] unit-test

! sse comparison instructions
{ { 0x66 0x0f 0xc2 0xc1 0x02 } } [ [ XMM0 XMM1 CMPLEPD ] { } make ] unit-test

! unique sse instructions
{ { 0x0f 0x18 0x00 } } [ [ EAX [] PREFETCHNTA ] { } make ] unit-test
{ { 0x0f 0x18 0x08 } } [ [ EAX [] PREFETCHT0 ] { } make ] unit-test
{ { 0x0f 0x18 0x10 } } [ [ EAX [] PREFETCHT1 ] { } make ] unit-test
{ { 0x0f 0x18 0x18 } } [ [ EAX [] PREFETCHT2 ] { } make ] unit-test
{ { 0x0f 0xae 0x10 } } [ [ EAX [] LDMXCSR ] { } make ] unit-test
{ { 0x0f 0xae 0x18 } } [ [ EAX [] STMXCSR ] { } make ] unit-test

{ { 0x0f 0xc3 0x08 } } [ [ EAX [] ECX MOVNTI ] { } make ] unit-test

{ { 0x0f 0x50 0xc1 } } [ [ EAX XMM1 MOVMSKPS ] { } make ] unit-test
{ { 0x66 0x0f 0x50 0xc1 } } [ [ EAX XMM1 MOVMSKPD ] { } make ] unit-test

{ { 0xf3 0x0f 0xb8 0xc1 } } [ [ EAX ECX POPCNT ] { } make ] unit-test
{ { 0xf3 0x48 0x0f 0xb8 0xc1 } } [ [ RAX RCX POPCNT ] { } make ] unit-test
{ { 0xf3 0x0f 0xb8 0x01 } } [ [ EAX ECX [] POPCNT ] { } make ] unit-test
{ { 0xf3 0x0f 0xb8 0x04 0x11 } } [ [ EAX ECX EDX [+] POPCNT ] { } make ] unit-test

{ { 0xf2 0x0f 0x38 0xf0 0xc1 } } [ [ EAX CL CRC32B ] { } make ] unit-test
{ { 0xf2 0x0f 0x38 0xf0 0x01 } } [ [ EAX ECX [] CRC32B ] { } make ] unit-test
{ { 0xf2 0x0f 0x38 0xf1 0xc1 } } [ [ EAX ECX CRC32 ] { } make ] unit-test
{ { 0xf2 0x0f 0x38 0xf1 0x01 } } [ [ EAX ECX [] CRC32 ] { } make ] unit-test

! shifts
{ { 0x48 0xd3 0xe0 } } [ [ RAX CL SHL ] { } make ] unit-test
{ { 0x48 0xd3 0xe1 } } [ [ RCX CL SHL ] { } make ] unit-test
{ { 0x48 0xd3 0xe8 } } [ [ RAX CL SHR ] { } make ] unit-test
{ { 0x48 0xd3 0xe9 } } [ [ RCX CL SHR ] { } make ] unit-test

{ { 0xc1 0xe0 0x05 } } [ [ EAX 5 SHL ] { } make ] unit-test
{ { 0xc1 0xe1 0x05 } } [ [ ECX 5 SHL ] { } make ] unit-test
{ { 0xc1 0xe8 0x05 } } [ [ EAX 5 SHR ] { } make ] unit-test
{ { 0xc1 0xe9 0x05 } } [ [ ECX 5 SHR ] { } make ] unit-test

! multiplication
{ { 0x4d 0x6b 0xc0 0x03 } } [ [ R8 R8 3 IMUL3 ] { } make ] unit-test
{ { 0x49 0x6b 0xc0 0x03 } } [ [ RAX R8 3 IMUL3 ] { } make ] unit-test
{ { 0x4c 0x6b 0xc0 0x03 } } [ [ R8 RAX 3 IMUL3 ] { } make ] unit-test
{ { 0x48 0x6b 0xc1 0x03 } } [ [ RAX RCX 3 IMUL3 ] { } make ] unit-test
{ { 0x48 0x69 0xc1 0x44 0x03 0x00 0x00 } } [ [ RAX RCX 0x344 IMUL3 ] { } make ] unit-test

! BT family instructions
{ { 0x0f 0xba 0xe0 0x01 } } [ [ EAX 1 BT ] { } make ] unit-test
{ { 0x0f 0xba 0xf8 0x01 } } [ [ EAX 1 BTC ] { } make ] unit-test
{ { 0x0f 0xba 0xe8 0x01 } } [ [ EAX 1 BTS ] { } make ] unit-test
{ { 0x0f 0xba 0xf0 0x01 } } [ [ EAX 1 BTR ] { } make ] unit-test
{ { 0x48 0x0f 0xba 0xe0 0x01 } } [ [ RAX 1 BT ] { } make ] unit-test
{ { 0x0f 0xba 0x20 0x01 } } [ [ EAX [] 1 BT ] { } make ] unit-test

{ { 0x0f 0xa3 0xd8 } } [ [ EAX EBX BT ] { } make ] unit-test
{ { 0x0f 0xbb 0xd8 } } [ [ EAX EBX BTC ] { } make ] unit-test
{ { 0x0f 0xab 0xd8 } } [ [ EAX EBX BTS ] { } make ] unit-test
{ { 0x0f 0xb3 0xd8 } } [ [ EAX EBX BTR ] { } make ] unit-test
{ { 0x0f 0xa3 0x18 } } [ [ EAX [] EBX BT ] { } make ] unit-test

! x87 instructions
{ { 0xD8 0xC5 } } [ [ ST0 ST5 FADD ] { } make ] unit-test
{ { 0xDC 0xC5 } } [ [ ST5 ST0 FADD ] { } make ] unit-test
{ { 0xD8 0x00 } } [ [ ST0 EAX [] FADD ] { } make ] unit-test

{ { 0xD9 0xC2 } } [ [ ST2 FLD  ] { } make ] unit-test
{ { 0xDD 0xD2 } } [ [ ST2 FST  ] { } make ] unit-test
{ { 0xDD 0xDA } } [ [ ST2 FSTP ] { } make ] unit-test

{ { 15 183 195 } } [ [ EAX BX MOVZX ] { } make ] unit-test

bootstrap-cell 4 = [
    [ { 100 199 5 0 0 0 0 123 0 0 0 } ] [ [ 0 [] FS 123 MOV ] { } make ] unit-test

    [ { 0xa0 0x67 0x45 0x23 0x01 } ]
    [ [ AL 0x0123,4567 MOVABS ] { } make ] unit-test

    [ { 0x66 0xa1 0x67 0x45 0x23 0x01 } ]
    [ [ AX 0x0123,4567 MOVABS ] { } make ] unit-test

    [ { 0xa1 0x67 0x45 0x23 0x01 } ]
    [ [ EAX 0x0123,4567 MOVABS ] { } make ] unit-test

    [ { 0x48 0xa1 0x67 0x45 0x23 0x01 } ]
    [ [ RAX 0x0123,4567 MOVABS ] { } make ] unit-test

    [ { 0xa2 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567 AL MOVABS ] { } make ] unit-test

    [ { 0x66 0xa3 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567 AX MOVABS ] { } make ] unit-test

    [ { 0xa3 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567 EAX MOVABS ] { } make ] unit-test

    [ { 0x48 0xa3 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567 RAX MOVABS ] { } make ] unit-test
] when

bootstrap-cell 8 = [
    [ { 72 137 13 123 0 0 0 } ] [ [ 123 [RIP+] RCX MOV ] { } make ] unit-test
    [ { 101 72 137 12 37 123 0 0 0 } ] [ [ 123 [] GS RCX MOV ] { } make ] unit-test

    [ { 0xa0 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ AL 0x0123,4567,89ab,cdef MOVABS ] { } make ] unit-test

    [ { 0x66 0xa1 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ AX 0x0123,4567,89ab,cdef MOVABS ] { } make ] unit-test

    [ { 0xa1 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ EAX 0x0123,4567,89ab,cdef MOVABS ] { } make ] unit-test

    [ { 0x48 0xa1 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ RAX 0x0123,4567,89ab,cdef MOVABS ] { } make ] unit-test

    [ { 0xa2 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567,89ab,cdef AL MOVABS ] { } make ] unit-test

    [ { 0x66 0xa3 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567,89ab,cdef AX MOVABS ] { } make ] unit-test

    [ { 0xa3 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567,89ab,cdef EAX MOVABS ] { } make ] unit-test

    [ { 0x48 0xa3 0xef 0xcd 0xab 0x89 0x67 0x45 0x23 0x01 } ]
    [ [ 0x0123,4567,89ab,cdef RAX MOVABS ] { } make ] unit-test
] when
