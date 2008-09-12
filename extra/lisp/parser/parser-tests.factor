! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp.parser tools.test peg peg.ebnf lists ;

IN: lisp.parser.tests

{ 1234  }  [
  "1234" "atom" \ lisp-expr rule parse
] unit-test

{ -42  }  [
    "-42" "atom" \ lisp-expr rule parse
] unit-test

{ 37/52 } [
    "37/52" "atom" \ lisp-expr rule parse
] unit-test

{ 123.98 } [
    "123.98" "atom" \ lisp-expr rule parse
] unit-test

{ "" } [
    "\"\"" "atom" \ lisp-expr rule parse
] unit-test

{ "aoeu" } [
    "\"aoeu\"" "atom" \ lisp-expr rule parse
] unit-test

{ "aoeu\"de" } [
    "\"aoeu\\\"de\"" "atom" \ lisp-expr rule parse
] unit-test

{ T{ lisp-symbol f "foobar" } } [
    "foobar" "atom" \ lisp-expr rule parse
] unit-test

{ T{ lisp-symbol f "+" } } [
    "+" "atom" \ lisp-expr rule parse
] unit-test

{ +nil+ } [
    "()" lisp-expr
] unit-test

{ T{
    cons
    f
    T{ lisp-symbol f "foo" }
    T{
        cons
        f
        1
        T{ cons f 2 T{ cons f "aoeu" +nil+ } }
    } } } [
    "(foo 1 2 \"aoeu\")" lisp-expr
] unit-test

{ T{ cons f
       1
       T{ cons f
           T{ cons f 3 T{ cons f 4 +nil+ } }
           T{ cons f 2 +nil+ } }
   }
} [
    "(1 (3 4) 2)" lisp-expr
] unit-test