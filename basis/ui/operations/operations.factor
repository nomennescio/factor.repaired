! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions kernel ui.commands
ui.gestures sequences strings math words generic namespaces
hashtables help.markup quotations assocs ;
IN: ui.operations

SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate command translator hook listener? ;

: <operation> ( predicate command -- operation )
    operation new
        [ ] >>hook
        [ ] >>translator
        swap >>command
        swap >>predicate ;

PREDICATE: listener-operation < operation
    dup command>> listener-command?
    swap listener?>> or ;

M: operation command-name
    command>> command-name ;

M: operation command-description
    command>> command-description ;

M: operation command-word command>> command-word ;

: operation-gesture ( operation -- gesture )
    command>> +keyboard+ word-prop ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ predicate>> call ] with filter ;

: find-operation ( obj quot -- command )
    >r object-operations r> find-last nip ; inline

: primary-operation ( obj -- operation )
    [ command>> +primary+ word-prop ] find-operation ;

: secondary-operation ( obj -- operation )
    dup
    [ command>> +secondary+ word-prop ] find-operation
    [ ] [ primary-operation ] ?if ;

: default-flags ( -- assoc )
    H{ { +keyboard+ f } { +primary+ f } { +secondary+ f } } ;

: define-operation ( pred command flags -- )
    default-flags swap assoc-union
    dupd define-command <operation>
    operations get push ;

: modify-operation ( hook translator operation -- operation )
    clone
    tuck (>>translator)
    tuck (>>hook)
    t over (>>listener?) ;

: modify-operations ( operations hook translator -- operations )
    rot [ >r 2dup r> modify-operation ] map 2nip ;

: operations>commands ( object hook translator -- pairs )
    >r >r object-operations r> r> modify-operations
    [ [ operation-gesture ] keep ] { } map>assoc ;

: define-operation-map ( class group blurb object hook translator -- )
    operations>commands define-command-map ;

: operation-quot ( target command -- quot )
    [
        swap literalize ,
        dup translator>> %
        command>> ,
    ] [ ] make ;

M: operation invoke-command ( target command -- )
    [ hook>> call ] keep operation-quot call ;
