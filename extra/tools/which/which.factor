! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators combinators.short-circuit
environment io.backend io.files io.files.info io.pathnames
kernel sequences sets splitting system unicode.case ;

IN: tools.which

<PRIVATE

: executable? ( path -- ? )
    {
        [ exists? ]
        [ file-executable? ]
        [ file-info directory? not ]
    } 1&& ;

: split-path ( paths -- seq )
    os windows? ";" ":" ? split harvest ;

: path-extensions ( command -- commands )
    "PATHEXT" os-env [
        split-path 2dup [ [ >lower ] bi@ tail? ] with any?
        [ drop 1array ] [ [ append ] with map ] if
    ] [ 1array ] if* ;

: ((which)) ( commands paths -- file/f )
    [ normalize-path ] map members
    cartesian-product flip concat
    [ prepend-path ] { } assoc>map
    [ executable? ] find nip ;

: (which) ( command path -- file/f )
    split-path os windows? [
        [ path-extensions ] [ "." prefix ] bi*
    ] [ [ 1array ] dip ] if ((which)) ;

PRIVATE>

: which ( command -- file/f )
    "PATH" os-env (which) ;
