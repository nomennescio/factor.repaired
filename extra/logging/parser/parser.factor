! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser-combinators memoize kernel sequences
logging arrays words strings vectors io io.files
namespaces combinators combinators.lib logging.server ;
IN: logging.parser

: string-of satisfy <!*> [ >string ] <@ ;

: 'date'
    [ CHAR: ] eq? not ] string-of
    "[" "]" surrounded-by ;

: 'log-level'
    log-levels [
        [ word-name token ] keep [ nip ] curry <@
    ] map <or-parser> ;

: 'word-name'
    [ " :" member? not ] string-of ;

SYMBOL: malformed

: 'malformed-line'
    [ drop t ] string-of [ malformed swap 2array ] <@ ;

: 'log-message'
    [ drop t ] string-of [ 1vector ] <@ ;

MEMO: 'log-line' ( -- parser )
    'date' " " token <&
    'log-level' " " token <& <&>
    'word-name' ": " token <& <:&>
    'log-message' <:&>
    'malformed-line' <|> ;

: parse-log-line ( string -- entry )
    'log-line' parse-1 ;

: malformed? ( line -- ? )
    first malformed eq? ;

: multiline? ( line -- ? )
    first first CHAR: - = ;

: malformed-line
    "Warning: malformed log line:" print
    second print ;

: add-multiline ( line -- )
    building get empty? [
        "Warning: log begins with multiline entry" print drop
    ] [
        fourth first building get peek fourth push
    ] if ;

: parse-log ( lines -- entries )
    [
        [
            parse-log-line {
                { [ dup malformed? ] [ malformed-line ] }
                { [ dup multiline? ] [ add-multiline ] }
                { [ t ] [ , ] }
            } cond
        ] each
    ] { } make ;
