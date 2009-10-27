! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.c-types alien.syntax ;
IN: vm

TYPEDEF: intptr_t cell
C-TYPE: context

STRUCT: zone
    { start cell }
    { here cell }
    { size cell }
    { end cell } ;

STRUCT: vm
    { stack_chain context* }
    { nursery zone }
    { cards_offset cell }
    { decks_offset cell }
    { userenv cell[70] } ;

: vm-field-offset ( field -- offset ) vm offset-of ; inline

C-ENUM:
collect-nursery-op
collect-aging-op
collect-to-tenured-op
collect-full-op
collect-compact-op
collect-growing-heap-op ;

STRUCT: gc-event
{ op uint }
{ nursery-size-before cell }
{ aging-size-before cell }
{ tenured-size-before cell }
{ tenured-free-block-count-before cell }
{ code-size-before cell }
{ code-free-block-count-before cell }
{ nursery-size-after cell }
{ aging-size-after cell }
{ tenured-size-after cell }
{ tenured-free-block-count-after cell }
{ code-size-after cell }
{ code-free-block-count-after cell }
{ cards-scanned cell }
{ decks-scanned cell }
{ code-blocks-scanned cell }
{ start-time ulonglong }
{ total-time cell }
{ card-scan-time cell }
{ code-scan-time cell }
{ data-sweep-time cell }
{ code-sweep-time cell }
{ compaction-time cell } ;

STRUCT: copying-sizes
{ size cell }
{ occupied cell }
{ free cell } ;

STRUCT: mark-sweep-sizes
{ size cell }
{ occupied cell }
{ total-free cell }
{ contiguous-free cell }
{ free-block-count cell } ;

STRUCT: data-heap-room
{ nursery copying-sizes }
{ aging copying-sizes }
{ tenured mark-sweep-sizes }
{ cards cell }
{ decks cell }
{ mark-stack cell } ;
