! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.units words arrays strings math.parser sequences 
       quotations vectors namespaces math assocs continuations peg
       peg.parsers unicode.categories multiline combinators combinators.lib 
       splitting accessors effects sequences.deep peg.search inference 
       io.streams.string io prettyprint parser ;
IN: peg.ebnf

: rule ( name word -- parser )
  #! Given an EBNF word produced from EBNF: return the EBNF rule
  "ebnf-parser" word-prop at ;

TUPLE: ebnf-non-terminal symbol ;
TUPLE: ebnf-terminal symbol ;
TUPLE: ebnf-foreign word rule ;
TUPLE: ebnf-any-character ;
TUPLE: ebnf-range pattern ;
TUPLE: ebnf-ensure group ;
TUPLE: ebnf-ensure-not group ;
TUPLE: ebnf-choice options ;
TUPLE: ebnf-sequence elements ;
TUPLE: ebnf-repeat0 group ;
TUPLE: ebnf-repeat1 group ;
TUPLE: ebnf-optional group ;
TUPLE: ebnf-whitespace group ;
TUPLE: ebnf-rule symbol elements ;
TUPLE: ebnf-action parser code ;
TUPLE: ebnf-var parser name ;
TUPLE: ebnf-semantic parser code ;
TUPLE: ebnf rules ;

C: <ebnf-non-terminal> ebnf-non-terminal
C: <ebnf-terminal> ebnf-terminal
C: <ebnf-foreign> ebnf-foreign
C: <ebnf-any-character> ebnf-any-character
C: <ebnf-range> ebnf-range
C: <ebnf-ensure> ebnf-ensure
C: <ebnf-ensure-not> ebnf-ensure-not
C: <ebnf-choice> ebnf-choice
C: <ebnf-sequence> ebnf-sequence
C: <ebnf-repeat0> ebnf-repeat0
C: <ebnf-repeat1> ebnf-repeat1
C: <ebnf-optional> ebnf-optional
C: <ebnf-whitespace> ebnf-whitespace
C: <ebnf-rule> ebnf-rule
C: <ebnf-action> ebnf-action
C: <ebnf-var> ebnf-var
C: <ebnf-semantic> ebnf-semantic
C: <ebnf> ebnf

: filter-hidden ( seq -- seq )
  #! Remove elements that produce no AST from sequence
  [ ebnf-ensure-not? not ] filter [ ebnf-ensure? not ] filter ;

: syntax ( string -- parser )
  #! Parses the string, ignoring white space, and
  #! does not put the result in the AST.
  token sp hide ;

: syntax-pack ( begin parser end -- parser )
  #! Parse 'parser' surrounded by syntax elements
  #! begin and end.
  [ syntax ] 2dip syntax pack ;

: 'identifier' ( -- parser )
  #! Return a parser that parses an identifer delimited by
  #! a quotation character. The quotation can be single
  #! or double quotes. The AST produced is the identifier
  #! between the quotes.
  [
    [ CHAR: " = not ] satisfy repeat1 "\"" "\"" surrounded-by ,
    [ CHAR: ' = not ] satisfy repeat1 "'" "'" surrounded-by ,
  ] choice* [ >string ] action ;
  
: 'non-terminal' ( -- parser )
  #! A non-terminal is the name of another rule. It can
  #! be any non-blank character except for characters used
  #! in the EBNF syntax itself.
  [
    {
      [ dup blank?    ]
      [ dup CHAR: " = ]
      [ dup CHAR: ' = ]
      [ dup CHAR: | = ]
      [ dup CHAR: { = ]
      [ dup CHAR: } = ]
      [ dup CHAR: = = ]
      [ dup CHAR: ) = ]
      [ dup CHAR: ( = ]
      [ dup CHAR: ] = ]
      [ dup CHAR: [ = ]
      [ dup CHAR: . = ]
      [ dup CHAR: ! = ]
      [ dup CHAR: & = ]
      [ dup CHAR: * = ]
      [ dup CHAR: + = ]
      [ dup CHAR: ? = ]
      [ dup CHAR: : = ]
      [ dup CHAR: ~ = ]
      [ dup CHAR: < = ]
      [ dup CHAR: > = ]
    } 0|| not nip    
  ] satisfy repeat1 [ >string <ebnf-non-terminal> ] action ;

: 'terminal' ( -- parser )
  #! A terminal is an identifier enclosed in quotations
  #! and it represents the literal value of the identifier.
  'identifier' [ <ebnf-terminal> ] action ;

: 'foreign-name' ( -- parser )
  #! Parse a valid foreign parser name
  [
    {
      [ dup blank?    ]
      [ dup CHAR: > = ]
    } 0|| not nip    
  ] satisfy repeat1 [ >string ] action ;

: 'foreign' ( -- parser )
  #! A foreign call is a call to a rule in another ebnf grammar
  [
    "<foreign" syntax ,
    'foreign-name' sp ,
    'foreign-name' sp optional ,
    ">" syntax ,
  ] seq* [ first2 <ebnf-foreign> ] action ;

: 'any-character' ( -- parser )
  #! A parser to match the symbol for any character match.
  [ CHAR: . = ] satisfy [ drop <ebnf-any-character> ] action ;

: 'range-parser' ( -- parser )
  #! Match the syntax for declaring character ranges
  [
    [ "[" syntax , "[" token ensure-not , ] seq* hide ,
    [ CHAR: ] = not ] satisfy repeat1 , 
    "]" syntax ,
  ] seq* [ first >string <ebnf-range> ] action ;
 
: ('element') ( -- parser )
  #! An element of a rule. It can be a terminal or a 
  #! non-terminal but must not be followed by a "=". 
  #! The latter indicates that it is the beginning of a
  #! new rule.
  [
    [
      [ 
        'non-terminal' ,
        'terminal' ,
        'foreign' ,
        'range-parser' ,
        'any-character' ,
      ] choice* 
      [ dup , "*" token hide , ] seq* [ first <ebnf-repeat0> ] action ,
      [ dup , "+" token hide , ] seq* [ first <ebnf-repeat1> ] action ,
      [ dup , "?[" token ensure-not , "?" token hide , ] seq* [ first <ebnf-optional> ] action ,
      ,
    ] choice* ,
    [
      "=" syntax ensure-not ,
      "=>" syntax ensure ,
    ] choice* ,
  ] seq* [ first ] action ;

DEFER: 'action'

: 'element' ( -- parser )
  [
    [ ('element') , ":" syntax , "a-zA-Z" range-pattern repeat1 [ >string ] action , ] seq* [ first2 <ebnf-var> ] action ,
    ('element') ,
  ] choice* ;

DEFER: 'choice'

: grouped ( quot suffix  -- parser )
  #! Parse a group of choices, with a suffix indicating
  #! the type of group (repeat0, repeat1, etc) and
  #! an quot that is the action that produces the AST.
  2dup
  [
    "(" [ 'choice' sp ] delay ")" syntax-pack 
    swap 2seq  
    [ first ] rot compose action ,
    "{" [ 'choice' sp ] delay "}" syntax-pack 
    swap 2seq  
    [ first <ebnf-whitespace> ] rot compose action ,
  ] choice* ;
  
: 'group' ( -- parser )
  #! A grouping with no suffix. Used for precedence.
  [ ] [
    "*" token sp ensure-not ,
    "+" token sp ensure-not ,
    "?" token sp ensure-not ,
  ] seq* hide grouped ; 

: 'repeat0' ( -- parser )
  [ <ebnf-repeat0> ] "*" syntax grouped ;

: 'repeat1' ( -- parser )
  [ <ebnf-repeat1> ] "+" syntax grouped ;

: 'optional' ( -- parser )
  [ <ebnf-optional> ] "?" syntax grouped ;

: 'factor-code' ( -- parser )
  [
    "]]" token ensure-not ,
    "]?" token ensure-not ,
    [ drop t ] satisfy ,
  ] seq* [ first ] action repeat0 [ >string ] action ;

: 'ensure-not' ( -- parser )
  #! Parses the '!' syntax to ensure that 
  #! something that matches the following elements do
  #! not exist in the parse stream.
  [
    "!" syntax ,
    'group' sp ,
  ] seq* [ first <ebnf-ensure-not> ] action ;

: 'ensure' ( -- parser )
  #! Parses the '&' syntax to ensure that 
  #! something that matches the following elements does
  #! exist in the parse stream.
  [
    "&" syntax ,
    'group' sp ,
  ] seq* [ first <ebnf-ensure> ] action ;

: ('sequence') ( -- parser )
  #! A sequence of terminals and non-terminals, including
  #! groupings of those. 
  [
    [ 
      'ensure-not' sp ,
      'ensure' sp ,
      'element' sp ,
      'group' sp , 
      'repeat0' sp ,
      'repeat1' sp ,
      'optional' sp , 
    ] choice* 
    [ dup  , ":" syntax , "a-zA-Z" range-pattern repeat1 [ >string ] action , ] seq* [ first2 <ebnf-var> ] action ,
    ,
  ] choice* ;

: 'action' ( -- parser )
   "[[" 'factor-code' "]]" syntax-pack ;

: 'semantic' ( -- parser )
   "?[" 'factor-code' "]?" syntax-pack ;

: 'sequence' ( -- parser )
  #! A sequence of terminals and non-terminals, including
  #! groupings of those. 
  [
    [ ('sequence') , 'action' , ] seq* [ first2 <ebnf-action> ] action ,
    [ ('sequence') , 'semantic' , ] seq* [ first2 <ebnf-semantic> ] action ,
    ('sequence') ,
  ] choice* repeat1 [ 
     dup length 1 = [ first ] [ <ebnf-sequence> ] if
  ] action ;

: 'actioned-sequence' ( -- parser )
  [
    [ 'sequence' , "=>" syntax , 'action' , ] seq* [ first2 <ebnf-action> ] action ,
    'sequence' ,
  ] choice* ;
  
: 'choice' ( -- parser )
  'actioned-sequence' sp repeat1 [ dup length 1 = [ first ] [ <ebnf-sequence> ] if  ] action "|" token sp list-of [ 
    dup length 1 = [ first ] [ <ebnf-choice> ] if
  ] action ;
 
: 'rule' ( -- parser )
  [
    'non-terminal' [ symbol>> ] action  ,
    "=" syntax  ,
    ">" token ensure-not ,
    'choice' ,
  ] seq* [ first2 <ebnf-rule> ] action ;

: 'ebnf' ( -- parser )
  'rule' sp repeat1 [ <ebnf> ] action ;

GENERIC: (transform) ( ast -- parser )

SYMBOL: parser
SYMBOL: main
SYMBOL: ignore-ws

: transform ( ast -- object )
  H{ } clone dup dup [ 
    f ignore-ws set 
    parser set 
    swap (transform) 
    main set 
  ] bind ;

M: ebnf (transform) ( ast -- parser )
  rules>> [ (transform) ] map peek ;
  
M: ebnf-rule (transform) ( ast -- parser )
  dup elements>> 
  (transform) [
    swap symbol>> set
  ] keep ;

M: ebnf-sequence (transform) ( ast -- parser )
  #! If ignore-ws is set then each element of the sequence
  #! ignores leading whitespace. This is not inherited by
  #! subelements of the sequence.
  elements>> [ 
    f ignore-ws [ (transform) ] with-variable
    ignore-ws get [ sp ] when
  ] map seq [ dup length 1 = [ first ] when ] action ;

M: ebnf-choice (transform) ( ast -- parser )
  options>> [ (transform) ] map choice ;

M: ebnf-any-character (transform) ( ast -- parser )
  drop any-char ;

M: ebnf-range (transform) ( ast -- parser )
  pattern>> range-pattern ;

: transform-group ( ast -- parser ) 
  #! convert a ast node with groups to a parser for that group
  group>> (transform) ;

M: ebnf-ensure (transform) ( ast -- parser )
  transform-group ensure ;

M: ebnf-ensure-not (transform) ( ast -- parser )
  transform-group ensure-not ;

M: ebnf-repeat0 (transform) ( ast -- parser )
  transform-group repeat0 ;

M: ebnf-repeat1 (transform) ( ast -- parser )
  transform-group repeat1 ;

M: ebnf-optional (transform) ( ast -- parser )
  transform-group optional ;

M: ebnf-whitespace (transform) ( ast -- parser )
  t ignore-ws [ transform-group ] with-variable ;

GENERIC: build-locals ( code ast -- code )

M: ebnf-sequence build-locals ( code ast -- code )
  #! Note the need to filter out this ebnf items that
  #! leave nothing in the AST
  elements>> filter-hidden dup length 1 = [ 
    first build-locals 
  ]  [
    dup [ ebnf-var? ] filter empty? [
      drop 
    ] [ 
      [
        "USING: locals sequences ;  [let* | " %
          dup length swap [
            dup ebnf-var? [
              name>> % 
              " [ " % # " over nth ] " %
            ] [
              2drop
            ] if
          ] 2each
          " | " %
          %  
          " nip ]" %     
      ] "" make 
    ] if
  ] if ;

M: ebnf-var build-locals ( code ast -- )
  [
    "USING: locals kernel ;  [let* | " %
    name>> % " [ dup ] " %
    " | " %
    %  
    " nip ]" %     
  ] "" make ;

M: object build-locals ( code ast -- )
  drop ;
   
: check-action-effect ( quot -- quot )
  dup infer {
    { [ dup (( a -- b )) effect<= ] [ drop ] }
    { [ dup (( -- b )) effect<= ] [ drop [ drop ] prepose ] }
    [
      [ 
        "Bad effect: " write effect>string write 
        " for quotation " write pprint
      ] with-string-writer throw
    ]
  } cond ;
 
M: ebnf-action (transform) ( ast -- parser )
  [ parser>> (transform) ] [ code>> ] [ parser>> ] tri build-locals  
  string-lines parse-lines check-action-effect action ;

M: ebnf-semantic (transform) ( ast -- parser )
  [ parser>> (transform) ] [ code>> ] [ parser>> ] tri build-locals 
  string-lines parse-lines semantic ;

M: ebnf-var (transform) ( ast -- parser )
  parser>> (transform) ;

M: ebnf-terminal (transform) ( ast -- parser )
  symbol>> [ token ] keep [ = ] curry satisfy 2choice ;

M: ebnf-foreign (transform) ( ast -- parser )
  dup word>> search
  [ "Foreign word '" swap word>> append "' not found" append throw ] unless*
  swap rule>> [ main ] unless* dupd swap rule [
    nip
  ] [
    execute
  ] if* ;

: parser-not-found ( name -- * )
  [
    "Parser '" % % "' not found." %
  ] "" make throw ;

M: ebnf-non-terminal (transform) ( ast -- parser )
  symbol>>  [
    , \ dup , parser get , \ at , [ parser-not-found ] , \ unless* , \ nip ,    
  ] [ ] make box ;

: transform-ebnf ( string -- object )
  'ebnf' parse parse-result-ast transform ;

: check-parse-result ( result -- result )
  dup [
    dup parse-result-remaining [ blank? ] trim empty? [
      [ 
        "Unable to fully parse EBNF. Left to parse was: " %
        parse-result-remaining % 
      ] "" make throw
    ] unless
  ] [
    "Could not parse EBNF" throw
  ] if ;

: ebnf>quot ( string -- hashtable quot )
  'ebnf' parse check-parse-result 
  parse-result-ast transform dup dup parser [ main swap at compile ] with-variable
  [ compiled-parse ] curry [ with-scope ] curry ;

: replace-escapes ( string -- string )
  [
    "\\t" token [ drop "\t" ] action ,
    "\\n" token [ drop "\n" ] action ,
    "\\r" token [ drop "\r" ] action ,
  ] choice* replace ;

: [EBNF "EBNF]" parse-multiline-string replace-escapes ebnf>quot nip parsed ; parsing

: EBNF: 
  CREATE-WORD dup 
  ";EBNF" parse-multiline-string replace-escapes
  ebnf>quot swapd 1 1 <effect> define-declared "ebnf-parser" set-word-prop ; parsing

