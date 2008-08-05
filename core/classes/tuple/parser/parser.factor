! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sets namespaces sequences parser
lexer combinators words classes.parser classes.tuple arrays ;
IN: classes.tuple.parser

: slot-names ( slots -- seq )
    [ dup array? [ first ] when ] map ;

: shadowed-slots ( superclass slots -- shadowed )
    [ all-slots [ name>> ] map ] [ slot-names ] bi* intersect ;

: check-slot-shadowing ( class superclass slots -- )
    shadowed-slots [
        [
            "Definition of slot ``" %
            %
            "'' in class ``" %
            name>> %
            "'' shadows a superclass slot" %
        ] "" make note.
    ] with each ;

ERROR: duplicate-slot-names names ;

: check-duplicate-slots ( slots -- )
    slot-names duplicates
    dup empty? [ drop ] [ duplicate-slot-names ] if ;

ERROR: invalid-slot-name name ;

: parse-long-slot-name ( -- )
    [ scan , \ } parse-until % ] { } make ;

: parse-slot-name ( string/f -- ? )
    #! This isn't meant to enforce any kind of policy, just
    #! to check for mistakes of this form:
    #!
    #! TUPLE: blahblah foo bing
    #!
    #! : ...
    {
        { [ dup not ] [ unexpected-eof ] }
        { [ dup { ":" "(" "<" "\"" "!" } member? ] [ invalid-slot-name ] }
        { [ dup ";" = ] [ drop f ] }
        [ dup "{" = [ drop parse-long-slot-name ] when , t ]
    } cond ;

: parse-tuple-slots ( -- )
    scan parse-slot-name [ parse-tuple-slots ] when ;

: parse-tuple-definition ( -- class superclass slots )
    CREATE-CLASS
    scan {
        { ";" [ tuple f ] }
        { "<" [ scan-word [ parse-tuple-slots ] { } make ] }
        [ tuple swap [ parse-slot-name [ parse-tuple-slots ] when ] { } make ]
    } case
    dup check-duplicate-slots
    3dup check-slot-shadowing ;
