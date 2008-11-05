! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel system accessors namespaces splitting sequences
mason.config ;
IN: mason.platform

: platform ( -- string )
    target-os get "-" target-cpu get "." split "-" join 3append ;

: gnu-make ( -- string )
    target-os get { "freebsd" "openbsd" "netbsd" } member? "gmake" "make" ? ;

: boot-image-arch ( -- string )
    target-cpu get dup "ppc" = [ target-os get "-" append prepend ] when ;

: boot-image-name ( -- string )
    "boot." boot-image-arch ".image" 3append ;
