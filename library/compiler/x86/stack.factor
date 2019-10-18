! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel lists math
memory sequences words ;

: rel-cs ( -- )
    #! Add an entry to the relocation table for the 32-bit
    #! immediate just compiled.
    "cs" f 0 0 rel-dlsym ;

: CS ( -- [ address ] ) "cs" f dlsym unit ;
: CS> ( register -- ) CS MOV rel-cs ;
: >CS ( register -- ) CS swap MOV rel-cs ;

: reg-stack ( reg n -- op ) cell * neg 2list ;
: ds-op ( n -- op ) ESI swap reg-stack ;
: cs-op ( n -- op ) ECX swap reg-stack ;

M: %peek-d generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 ds-op MOV ;

M: %replace-d generate-node ( vop -- )
    dup vop-in-2 v>operand swap vop-in-1 ds-op swap MOV ;

M: %inc-d generate-node ( vop -- )
    ESI swap vop-in-1 cell *
    dup 0 > [ ADD ] [ neg SUB ] ifte ;

M: %immediate generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 address MOV ;

: load-indirect ( dest literal -- )
    intern-literal unit MOV 0 0 rel-address ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    dup vop-out-1 v>operand swap vop-in-1 load-indirect ;

M: %peek-r generate-node ( vop -- )
    ECX CS>  dup vop-out-1 v>operand swap vop-in-1 cs-op MOV ;

M: %dec-r generate-node ( vop -- )
    #! Can only follow a %peek-r
    vop-in-1 ECX swap cell * SUB  ECX >CS ;

M: %replace-r generate-node ( vop -- )
    #! Can only follow a %inc-r
    dup vop-in-2 v>operand swap vop-in-1 cs-op swap MOV
    ECX >CS ;

M: %inc-r generate-node ( vop -- )
    #! Can only follow a %peek-r
    ECX CS>
    vop-in-1 ECX swap cell * ADD ;
