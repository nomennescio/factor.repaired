! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.backend io.ports io.streams.duplex
io splitting sequences sequences.lib namespaces kernel
destructors math concurrency.combinators accessors
arrays continuations quotations ;
IN: io.pipes

TUPLE: pipe in out ;

M: pipe dispose ( pipe -- )
    [ in>> close-handle ] [ out>> close-handle ] bi ;

HOOK: (pipe) io-backend ( -- pipe )

: <pipe> ( encoding -- stream )
    [
        >r (pipe) |dispose
        [ in>> <input-port> ] [ out>> <output-port> ] bi
        r> <encoder-duplex>
    ] with-destructors ;

<PRIVATE

: ?reader [ <input-port> &dispose ] [ input-stream get ] if* ;
: ?writer [ <output-port> &dispose ] [ output-stream get ] if* ;

GENERIC: run-pipeline-element ( input-fd output-fd obj -- quot )

M: callable run-pipeline-element
    [
        >r [ ?reader ] [ ?writer ] bi*
        r> with-streams*
    ] with-destructors ;

: <pipes> ( n -- pipes )
    [
        [ (pipe) |dispose ] replicate
        T{ pipe } [ prefix ] [ suffix ] bi
        2 <clumps>
    ] with-destructors ;

PRIVATE>

: run-pipeline ( seq -- results )
    [ length dup zero? [ drop { } ] [ 1- <pipes> ] if ] keep
    [
        >r [ first in>> ] [ second out>> ] bi
        r> run-pipeline-element
    ] 2parallel-map ;
