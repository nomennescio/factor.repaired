! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser compiler.constants ;
IN: bootstrap.x86

4 \ cell set

: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: shift-arg ( -- reg ) ECX ;
: div-arg ( -- reg ) EAX ;
: mod-arg ( -- reg ) EDX ;
: arg0 ( -- reg ) EAX ;
: arg1 ( -- reg ) EDX ;
: arg2 ( -- reg ) ECX ;
: temp-reg ( -- reg ) EBX ;
: stack-reg ( -- reg ) ESP ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: fixnum>slot@ ( -- ) arg0 1 SAR ;
: rex-length ( -- n ) 0 ;

[
    arg0 0 [] MOV                              ! load stack_chain
    arg0 [] stack-reg MOV                      ! save stack pointer
] rc-absolute-cell rt-stack-chain 2 jit-save-stack jit-define

[
    (JMP) drop
] rc-relative rt-primitive 1 jit-primitive jit-define

<< "resource:basis/cpu/x86/bootstrap.factor" parse-file parsed >>
call
