! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.files hashtables kernel namespaces sequences
vocabs.loader io combinators io.encodings.utf8 calendar accessors
math.parser io.streams.string ui.tools.operations quotations
strings arrays prettyprint words vocabs sorting combinators.lib
sets cords ;
IN: tools.scaffold

SYMBOL: developer-name
SYMBOL: using

ERROR: not-a-vocab-root string ;

: root? ( str -- ? )
    vocab-roots get member?  ;

ERROR: vocab-name-contains-separator path ;
ERROR: vocab-name-contains-dot path ;
: check-vocab-name ( str -- str )
    dup dup [ CHAR: . = ] trim [ length ] bi@ =
    [ vocab-name-contains-dot ] unless
    ".." over subseq? [ vocab-name-contains-dot ] when
    dup [ path-separator? ] contains?
    [ vocab-name-contains-separator ] when ;

: check-root ( str -- str )
    check-vocab-name
    dup "resource:" head? [ "resource:" prepend ] unless
    dup root? [ not-a-vocab-root ] unless ;

: directory-exists ( path -- )
    "Not creating a directory, it already exists: " write print ;

: scaffold-directory ( path -- )
    dup exists? [ directory-exists ] [ make-directories ] if ;

: not-scaffolding ( path -- )
    "Not creating scaffolding for " write <pathname> . ;

: scaffolding ( path -- )
    "Creating scaffolding for " write <pathname> . ;

: scaffold-path ( path suffix -- path ? )
    dupd [ file-name ] dip append append-path
    dup exists? [ dup not-scaffolding f ] [ dup scaffolding t ] if ;

: scaffold-copyright ( -- )
    "! Copyright (C) " write now year>> number>string write
    developer-name get [ "Your name" ] unless* bl write "." print
    "! See http://factorcode.org/license.txt for BSD license." print ;

: main-file-string ( vocab -- str )
    [
        scaffold-copyright
        "USING: ;" print
        "IN: " write print
    ] with-string-writer ;

: set-scaffold-main-file ( path vocab -- )
    main-file-string swap utf8 set-file-contents ;

: scaffold-main ( path vocab -- )
    [ ".factor" scaffold-path ] dip
    swap [ set-scaffold-main-file ] [ 2drop ] if ;

: tests-file-string ( vocab -- str )
    [
        scaffold-copyright
        "USING: tools.test " write dup write " ;" print
        "IN: " write write ".tests" print
    ] with-string-writer ;

: set-scaffold-tests-file ( path vocab -- )
    tests-file-string swap utf8 set-file-contents ;

: scaffold-tests ( path vocab -- )
    [ "-tests.factor" scaffold-path ] dip
    swap [ set-scaffold-tests-file ] [ 2drop ] if ;

: scaffold-authors ( path -- )
    "authors.txt" append-path dup exists? [
        not-scaffolding
    ] [
        dup scaffolding
        developer-name get swap utf8 set-file-contents
    ] if ;

: lookup-type ( string -- object/string ? )
    H{
        { "obj" object }
        { "obj1" object }
        { "obj2" object }
        { "obj3" object }
        { "obj4" object }
        { "quot" quotation }
        { "quot1" quotation }
        { "quot2" quotation }
        { "quot3" quotation }
        { "str" string }
        { "str1" string }
        { "str2" string }
        { "str3" string }
        { "hashtable" hashtable }
        { "?" "a boolean" }
        { "ch" "a character" }
    } at* ;

: add-using ( object -- )
    vocabulary>> using get conjoin ;

: ($values.) ( array -- )
    [
        " { " write
        dup array? [ first ] when
        dup lookup-type [
            [ unparse write bl ]
            [ dup string? [ unparse write ] [ [ pprint ] [ add-using ] bi ] if ] bi*
        ] [
            drop unparse write
        ] if
        " }" write
    ] each ;

: $values. ( word -- )
    "declared-effect" word-prop [
        "{ $values" print
        [ in>> ] [ out>> ] bi
        [ "    " write ($values.) nl ] bi@
        "}" write nl
    ] when* ;

: $description. ( word -- )
    drop
    "{ $description } ;" print ;

: help-header. ( word -- )
    "HELP: " write name>> print ;

: help. ( word -- )
    [ help-header. ] [ $values. ] [ $description. ] tri ;

: help-file-string ( str1 -- str2 )
    [
        [ "IN: " write print nl ]
        [ words natural-sort [ help. nl ] each ]
        [ "ARTICLE: " write unparse dup write bl print ";" print nl ]
        [ "ABOUT: " write unparse print ] quad
    ] with-string-writer ;

: write-using ( -- )
    "USING:" write
    using get keys
    { "help.markup" "help.syntax" } cord-append natural-sort 
    [ bl write ] each
    " ;" print ;

: set-scaffold-help-file ( path vocab -- )
    swap utf8 <file-writer> [
        scaffold-copyright help-file-string write-using write
    ] with-output-stream ;

: check-scaffold ( vocab-root str -- vocab-root str )
    [ check-root ] [ check-vocab-name ] bi* ;

: vocab>scaffold-path ( vocab-root str -- path )
    path-separator first CHAR: . associate substitute
    append-path ;

: prepare-scaffold ( vocab-root str -- str path )
    check-scaffold [ vocab>scaffold-path ] keep ;

: scaffold-help ( vocab-root str -- )
    H{ } clone using [
        prepare-scaffold
        [ "-docs.factor" scaffold-path ] dip
        swap [ set-scaffold-help-file ] [ 2drop ] if
    ] with-variable ;

: scaffold-vocab ( vocab-root str -- )
    prepare-scaffold
    {
        [ drop scaffold-directory ]
        [ scaffold-main ]
        [ scaffold-tests ]
        [ drop scaffold-authors ]
    } 2cleave ;
