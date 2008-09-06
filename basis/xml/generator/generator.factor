! Copyright (C) 2006, 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel xml.data xml.utilities assocs sequences ;
IN: xml.generator

: comment, ( string -- ) <comment> , ;
: directive, ( string -- ) <directive> , ;
: instruction, ( string -- ) <instruction> , ;
: nl, ( -- ) "\n" , ;

: (tag,) ( name attrs quot -- tag )
    -rot >r >r V{ } make r> r> rot <tag> ; inline
: tag*, ( name attrs quot -- )
    (tag,) , ; inline

: contained*, ( name attrs -- )
    f <tag> , ;

: tag, ( name quot -- ) f swap tag*, ; inline
: contained, ( name -- ) f contained*, ; inline

: make-xml* ( name attrs quot -- xml )
    (tag,) build-xml ; inline
: make-xml ( name quot -- xml )
    f swap make-xml* ; inline
