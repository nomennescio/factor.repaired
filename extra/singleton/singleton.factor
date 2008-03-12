! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.predicate kernel namespaces parser quotations
sequences words ;
IN: singleton

: define-singleton ( token -- )
    \ word swap create-class-in
    dup [ eq? ] curry define-predicate-class ;

: SINGLETON:
    scan define-singleton ; parsing

: SINGLETONS:
    ";" parse-tokens [ define-singleton ] each ; parsing
