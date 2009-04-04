! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry html.parser html.parser.analyzer
http.client kernel tools.time sets assocs sequences
concurrency.combinators io threads namespaces math multiline
math.parser inspector urls logging combinators.short-circuit
continuations calendar prettyprint dlists deques locals
spider.unique-deque ;
IN: spider

TUPLE: spider base count max-count sleep max-depth initial-links
filters spidered todo nonmatching quiet currently-spidering
#threads follow-robots? robots ;

TUPLE: spider-result url depth headers
fetched-in parsed-html links processed-in fetched-at ;

TUPLE: todo-url url depth ;

: <todo-url> ( url depth -- todo-url )
    todo-url new
        swap >>depth
        swap >>url ;

: <spider> ( base -- spider )
    >url
    spider new
        over >>base
        over >>currently-spidering
        swap 0 <unique-deque> [ push-url ] keep >>todo
        <unique-deque> >>nonmatching
        0 >>max-depth
        0 >>count
        1/0. >>max-count
        H{ } clone >>spidered
        1 >>#threads ;

<PRIVATE

: apply-filters ( links spider -- links' )
    filters>> [ '[ [ _ 1&& ] filter ] call( seq -- seq' ) ] when* ;

: push-links ( links level unique-deque -- )
    '[ _ _ push-url ] each ;

: add-todo ( links level spider -- )
    todo>> push-links ;

: add-nonmatching ( links level spider -- )
    nonmatching>> push-links ;

: filter-base-links ( spider spider-result -- base-links nonmatching-links )
    [ base>> host>> ] [ links>> prune ] bi*
    [ host>> = ] with partition ;

: add-spidered ( spider spider-result -- )
    [ [ 1+ ] change-count ] dip
    2dup [ spidered>> ] [ dup url>> ] bi* rot set-at
    [ filter-base-links ] 2keep
    depth>> 1+ swap
    [ add-nonmatching ]
    [ tuck [ apply-filters ] 2dip add-todo ] 2bi ;

: normalize-hrefs ( base links -- links' )
    [ derive-url ] with map ;

: print-spidering ( url depth -- )
    "depth: " write number>string write
    ", spidering: " write . yield ;

:: new-spidered-result ( spider url depth -- spider-result )
    f url spider spidered>> set-at
    [ url http-get ] benchmark :> fetched-at :> html :> headers
    [
        html parse-html
        spider currently-spidering>>
        over find-all-links normalize-hrefs
    ] benchmark :> processing-time :> links :> parsed-html
    url depth headers fetched-at parsed-html links processing-time
    now spider-result boa ;

:: spider-page ( spider url depth -- )
    spider quiet>> [ url depth print-spidering ] unless
    spider url depth new-spidered-result :> spidered-result
    spider quiet>> [ spidered-result describe ] unless
    spider spidered-result add-spidered ;

\ spider-page ERROR add-error-logging

: spider-sleep ( spider -- ) sleep>> [ sleep ] when* ;

: queue-initial-links ( spider -- )
    [
        [ currently-spidering>> ] [ initial-links>> ] bi normalize-hrefs 0
    ] keep add-todo ;

: spider-page? ( spider -- ? )
    {
        [ todo>> deque>> deque-empty? not ]
        [ [ todo>> peek-url depth>> ] [ max-depth>> ] bi < ]
        [ [ count>> ] [ max-count>> ] bi < ]
    } 1&& ;

: setup-next-url ( spider -- spider url depth )
    dup todo>> peek-url url>> >>currently-spidering
    dup todo>> pop-url [ url>> ] [ depth>> ] bi ;

: spider-next-page ( spider -- )
    setup-next-url spider-page ;

PRIVATE>

: run-spider-loop ( spider -- )
    dup spider-page? [
        [ spider-next-page ] [ spider-sleep ] [ run-spider-loop ] tri
    ] [
        drop
    ] if ;

: run-spider ( spider -- spider )
    "spider" [
        dup queue-initial-links [ run-spider-loop ] keep
    ] with-logging ;
