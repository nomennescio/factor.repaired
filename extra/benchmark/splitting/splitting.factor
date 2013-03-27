USING: kernel math sequences splitting ;
IN: benchmark.splitting

: test-data ( -- seq seps ) 
    1000 iota dup [ 10 /i zero? ] filter ; ! not inline to prevent type inference

: splitting-benchmark ( -- )
    test-data 1,000 [
        over [ even? ] split-when drop
        over [ even? ] split-when-slice drop
        2dup split drop
        2dup split* drop
    ] times 2drop ;

MAIN: splitting-benchmark
