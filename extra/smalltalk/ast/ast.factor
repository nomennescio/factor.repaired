! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays memoize kernel sequences accessors ;
IN: smalltalk.ast

SINGLETONS: nil self super ;

TUPLE: ast-comment { string string } ;
TUPLE: ast-block { arguments array } { body array } ;
TUPLE: ast-message-send receiver { selector string } { arguments array } ;
TUPLE: ast-message { selector string } { arguments array } ;
TUPLE: ast-cascade receiver { messages array } ;
TUPLE: ast-name { name string } ;
TUPLE: ast-return value ;
TUPLE: ast-assignment { name ast-name } value ;
TUPLE: ast-local-variables { names array } ;
TUPLE: ast-method { name string } { body ast-block } ;
TUPLE: ast-class { name string } { superclass string } { ivars array } { methods array } ;
TUPLE: ast-foreign { class string } { name string } ;
TUPLE: ast-sequence { statements array } ;

: <ast-cascade> ( receiver messages -- ast )
    dup length 1 =
    [ first [ selector>> ] [ arguments>> ] bi ast-message-send boa ]
    [ ast-cascade boa ]
    if ;

TUPLE: symbol { name string } ;
MEMO: intern ( name -- symbol ) symbol boa ;