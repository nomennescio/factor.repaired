! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic hashtables kernel math namespaces
prettyprint sequences strings vectors words ;

: skip ( i seq quot -- n | quot: elt -- ? )
    over >r find* drop dup -1 =
    [ drop r> length ] [ r> drop ] if ; inline

: skip-blank ( -- )
    column [ line-text get [ blank? not ] skip ] change ;

: skip-word ( n line -- n )
    2dup nth CHAR: " = [ drop 1+ ] [ [ blank? ] skip ] if ;

: (scan) ( n line -- start end )
    dupd 2dup length < [ skip-word ] [ drop ] if ;

: scan ( -- token )
    skip-blank
    column [ line-text get (scan) dup ] change
    2dup = [ 2drop f ] [ line-text get subseq ] if ;

: CREATE ( -- word ) scan create-in ;

SYMBOL: string-mode

: do-what-i-mean ( string -- restarts )
    all-words [ word-name = ] subset-with natural-sort [
        [ "Use the word " swap synopsis append ] keep 2array
    ] map ;

: word-not-found ( str -- word )
    "No word named "
    over
    " found in current vocabulary search path" append3
    swap do-what-i-mean condition ;

: scan-word ( -- obj )
    scan dup [
        dup ";" = not string-mode get and [
            dup use get hash-stack [ ] [
                dup string>number [ ] [
                    word-not-found dup word-vocabulary use+
                ] ?if
            ] ?if
        ] unless
    ] when ;

: parsed ( parse-tree obj -- parse-tree ) swap ?push ;

: parse-loop ( -- )
    scan-word [
        dup parsing? [ execute ] [ parsed ] if  parse-loop
    ] when* ;

: (parse) ( str -- ) line-text set 0 column set parse-loop ;

! Parsing word utilities
: escape ( ch -- esc )
    H{
        { CHAR: e  CHAR: \e }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } hash [ "Bad escape" throw ] unless* ;

: next-escape ( n str -- n ch )
    2dup nth CHAR: u =
    [ >r 1+ dup 4 + tuck r> subseq hex> ]
    [ over 1+ -rot nth escape ] if ;

: next-char ( n str -- n ch )
    2dup nth CHAR: \\ =
    [ >r 1+ r> next-escape ] [ over 1+ -rot nth ] if ;

: (parse-string) ( n str -- n )
    2dup nth CHAR: " =
    [ drop 1+ ] [ [ next-char , ] keep (parse-string) ] if ;

: parse-string ( -- str )
    column
    [ [ line-text get (parse-string) ] "" make swap ] change ;

global [
    {
        "scratchpad" "syntax" "arrays" "compiler"
        "errors" "generic" "hashtables" "help" "inference"
        "inspector" "io" "jedit" "kernel" "listener" "math"
        "memory" "modules" "namespaces" "parser" "prettyprint"
        "sequences" "shells" "strings" "styles" "test"
        "threads" "vectors" "walker" "words"
    } set-use
    "scratchpad" set-in
] bind
