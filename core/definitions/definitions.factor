! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces assocs graphs math math.order ;

ERROR: no-compilation-unit definition ;

SYMBOL: changed-definitions

SYMBOL: +inlined+
SYMBOL: +flushed+
SYMBOL: +called+

: dependency<=> ( how1 how2 -- <=> )
    [ { f +called+ +flushed+ +inlined+ } index ] bi@ <=> ;

: dependency>= ( how1 how2 -- ? ) dependency<=> +lt+ eq? not ;

: strongest-dependency ( how1 how2 -- how )
    [ dependency>= ] most ;

: dependency<= ( how1 how2 -- ? ) dependency<=> +gt+ eq? not ;

: weakest-dependency ( how1 how2 -- how )
    [ dependency<= ] most ;

: changed-definition ( defspec how -- )
    swap changed-definitions get
    [ set-at ] [ no-compilation-unit ] if* ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

M: object forget* drop ;

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get
    [ no-compilation-unit ] unless*
    set-at ;

: forget ( defspec -- ) dup forgotten-definition forget* ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

M: object uses drop f ;

: xref ( defspec -- ) dup uses crossref get add-vertex ;

: usage ( defspec -- seq ) crossref get at keys ;

GENERIC: irrelevant? ( defspec -- ? )

M: object irrelevant? drop f ;

GENERIC: smart-usage ( defspec -- seq )

M: f smart-usage drop \ f smart-usage ;

M: object smart-usage usage [ irrelevant? not ] filter ;

: unxref ( defspec -- )
    dup uses crossref get remove-vertex ;

: delete-xref ( defspec -- )
    dup unxref crossref get delete-at ;
