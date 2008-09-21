! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces make kernel sequences accessors
combinators strings splitting io io.streams.string present
xml.writer xml.data xml.entities html.forms
html.templates html.templates.chloe.syntax ;
IN: html.templates.chloe.compiler

: chloe-attrs-only ( assoc -- assoc' )
    [ drop url>> chloe-ns = ] assoc-filter ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ drop url>> chloe-ns = not ] assoc-filter ;

: chloe-tag? ( tag -- ? )
    dup xml? [ body>> ] when
    {
        { [ dup tag? not ] [ f ] }
        { [ dup url>> chloe-ns = not ] [ f ] }
        [ t ]
    } cond nip ;

SYMBOL: string-buffer

SYMBOL: tag-stack

DEFER: compile-element

: compile-children ( tag -- )
    [ compile-element ] each ;

: [write] ( string -- ) string-buffer get push-all ;

: reset-buffer ( -- )
    string-buffer get [
        [ >string , \ write , ] [ delete-all ] bi
    ] unless-empty ;

: [code] ( quot -- )
    reset-buffer % ;

: [code-with] ( obj quot -- )
    reset-buffer [ , ] [ % ] bi* ;

: expand-attr ( value -- )
    [ value present write ] [code-with] ;

: compile-attr ( value -- )
    reset-buffer "@" ?head [ , [ value present ] % ] [ , ] if ;

: compile-attrs ( assoc -- )
    [
        " " [write]
        swap name>string [write]
        "=\"" [write]
        "@" ?head [ expand-attr ] [ escape-quoted-string [write] ] if
        "\"" [write]
    ] assoc-each ;

: compile-start-tag ( tag -- )
    "<" [write]
    [ name>string [write] ] [ compile-attrs ] bi
    ">" [write] ;

: compile-end-tag ( tag -- )
    "</" [write]
    name>string [write]
    ">" [write] ;

: compile-tag ( tag -- )
    {
        [ main>> tag-stack get push ]
        [ compile-start-tag ]
        [ compile-children ]
        [ compile-end-tag ]
        [ drop tag-stack get pop* ]
    } cleave ;

: compile-chloe-tag ( tag -- )
    ! "Unknown chloe tag: " prepend throw
    dup main>> dup tags get at
    [ curry assert-depth ] [ 2drop ] ?if ;

: compile-element ( element -- )
    {
        { [ dup chloe-tag? ] [ compile-chloe-tag ] }
        { [ dup [ tag? ] [ xml? ] bi or ] [ compile-tag ] }
        { [ dup string? ] [ escape-string [write] ] }
        { [ dup comment? ] [ drop ] }
        [ [ write-item ] [code-with] ]
    } cond ;

: with-compiler ( quot -- quot' )
    [
        SBUF" " string-buffer set
        V{ } clone tag-stack set
        call
        reset-buffer
    ] [ ] make ; inline

: compile-chunk ( seq -- )
    [ compile-element ] each ;

: compile-quot ( quot -- )
    reset-buffer
    [
        SBUF" " string-buffer set
        call
        reset-buffer
    ] [ ] make , ; inline

: process-children ( tag quot -- )
    [ [ compile-children ] compile-quot ] [ % ] bi* ; inline

: compile-children>string ( tag -- )
     [ with-string-writer ] process-children ;

: compile-with-scope ( quot -- )
    compile-quot [ with-scope ] [code] ; inline

: if-not-nested ( quot -- )
    nested-template? get swap unless ; inline

: compile-prologue ( xml -- )
    [
        [ before>> compile-chunk ]
        [ prolog>> [ write-prolog ] [code-with] ]
        bi
    ] compile-quot
    [ if-not-nested ] [code] ;

: compile-epilogue ( xml -- )
    [ after>> compile-chunk ] compile-quot
    [ if-not-nested ] [code] ;

: compile-template ( xml -- quot )
    [
        [ compile-prologue ]
        [ compile-element ]
        [ compile-epilogue ]
        tri
    ] with-compiler ;
