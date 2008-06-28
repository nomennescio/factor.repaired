! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private math namespaces
sequences strings words effects generic generic.standard
classes slots.private combinators slots ;
IN: slots.deprecated

: reader-effect ( class spec -- effect )
    >r ?word-name 1array r> slot-spec-name 1array <effect> ;

PREDICATE: slot-reader < word "reading" word-prop >boolean ;

: set-reader-props ( class spec -- )
    2dup reader-effect
    over slot-spec-reader
    swap "declared-effect" set-word-prop
    slot-spec-reader swap "reading" set-word-prop ;

: define-reader ( class spec -- )
    dup slot-spec-reader [
        [ set-reader-props ] 2keep
        dup slot-spec-offset
        over slot-spec-reader
        rot slot-spec-class reader-quot
        define-slot-word
    ] [
        2drop
    ] if ;

: writer-effect ( class spec -- effect )
    slot-spec-name swap ?word-name 2array 0 <effect> ;

PREDICATE: slot-writer < word "writing" word-prop >boolean ;

: set-writer-props ( class spec -- )
    2dup writer-effect
    over slot-spec-writer
    swap "declared-effect" set-word-prop
    slot-spec-writer swap "writing" set-word-prop ;

: define-writer ( class spec -- )
    dup slot-spec-writer [
        [ set-writer-props ] 2keep
        dup slot-spec-offset
        swap slot-spec-writer
        [ set-slot ]
        define-slot-word
    ] [
        2drop
    ] if ;

: define-slot ( class spec -- )
    2dup define-reader define-writer ;

: define-slots ( class specs -- )
    [ define-slot ] with each ;

: reader-word ( class name vocab -- word )
    >r >r "-" r> 3append r> create ;

: writer-word ( class name vocab -- word )
    >r [ swap "set-" % % "-" % % ] "" make r> create ;

: (simple-slot-word) ( class name -- class name vocab )
    over vocabulary>> >r >r name>> r> r> ;

: simple-reader-word ( class name -- word )
    (simple-slot-word) reader-word ;

: simple-writer-word ( class name -- word )
    (simple-slot-word) writer-word ;

: deprecated-slots ( class slot-specs -- slot-specs' )
    [
        2dup name>> simple-reader-word >>reader
        2dup name>> simple-writer-word >>writer
    ] map nip ;
