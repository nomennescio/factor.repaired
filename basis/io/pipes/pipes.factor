! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.backend io.ports io.streams.duplex
io splitting grouping sequences namespaces kernel
destructors math concurrency.combinators accessors fry
arrays continuations quotations system vocabs combinators ;
IN: io.pipes

TUPLE: pipe in out ;

M: pipe dispose ( pipe -- )
    [ in>> dispose ] [ out>> dispose ] bi ;

HOOK: (pipe) io-backend ( -- pipe )

: <pipe> ( encoding -- stream )
    [
        [
            (pipe) |dispose
            [ in>> <input-port> ] [ out>> <output-port> ] bi
        ] dip <encoder-duplex>
    ] with-destructors ;

<PRIVATE

: ?reader ( handle/f -- stream )
    [ <input-port> &dispose ] [ input-stream get ] if* ;

: ?writer ( handle/f -- stream )
    [ <output-port> &dispose ] [ output-stream get ] if* ;

GENERIC: run-pipeline-element ( input-fd output-fd obj -- result )

M: callable run-pipeline-element
    [
        [ [ ?reader ] [ ?writer ] bi* ] dip
        '[ _ call( -- result ) ] with-streams*
    ] with-destructors ;

GENERIC: <pipes> ( obj -- pipes )

M: integer <pipes> ( n -- pipes )
    [
        [ (pipe) |dispose ] replicate
        T{ pipe } [ prefix ] [ suffix ] bi
        2 <clumps>
    ] with-destructors ;

M: sequence <pipes>
    [ { } ] [ length 1 - <pipes> ] if-empty ;

PRIVATE>

: run-pipeline ( seq -- results )
    [ <pipes> ] keep
    [
        [ [ first in>> ] [ second out>> ] bi ] dip
        run-pipeline-element
    ] 2parallel-map ;

{
    { [ os unix? ] [ "io.pipes.unix" require ] }
    { [ os windows? ] [ "io.pipes.windows" require ] }
    [ ]
} cond
