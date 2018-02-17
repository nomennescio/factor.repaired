! Copyright (C) 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs classes classes.tuple
classes.tuple.private kernel sequences sequences.private
slots.private ;

IN: named-tuples

MIXIN: named-tuple

M: named-tuple assoc-size tuple-size ;

M: named-tuple at* get-slot-named t ;

M: named-tuple set-at set-slot-named ;

M: named-tuple >alist
    dup class-of all-slots
    [ [ offset>> slot ] [ name>> ] bi swap ] with { } map>assoc ;

INSTANCE: named-tuple assoc

M: named-tuple length tuple-size ;

M: named-tuple nth-unsafe array-nth ;

M: named-tuple set-nth-unsafe set-array-nth ;

M: named-tuple like class-of slots>tuple ;

INSTANCE: named-tuple sequence

