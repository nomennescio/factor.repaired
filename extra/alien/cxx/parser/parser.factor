! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: parser lexer alien.inline ;
IN: alien.cxx.parser

: parse-c++-class-definition ( -- class superclass-mixin )
    scan scan-word ;

: parse-c++-method-definition ( -- class-name name types effect )
    scan function-types-effect ;
