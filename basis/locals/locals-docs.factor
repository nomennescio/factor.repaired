USING: help.syntax help.markup kernel macros prettyprint
memoize combinators arrays ;
IN: locals

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "A lambda abstraction. When called, reads stack values into the bindings from left to right; the body may then refer to these bindings." }
{ $examples
    { $example
        "USING: kernel locals math prettyprint ;"
        "IN: scratchpad"
        ":: adder ( n -- quot ) [| m | m n + ] ;"
        "3 5 adder call ."
        "8"
    }
} ;

HELP: [let
{ $syntax "[let | binding1 [ value1... ]\n       binding2 [ value2... ]\n       ... |\n    body... ]" }
{ $description "Introduces a set of lexical bindings and evaluates the body. The values are evaluated in parallel, and may not refer to other bindings within the same " { $link POSTPONE: [let } " form; for Lisp programmers, this means that " { $link POSTPONE: [let } " is equivalent to the Lisp " { $snippet "let" } ", not " { $snippet "let*" } "." }
{ $examples
    { $example
        "USING: kernel locals math math.functions prettyprint sequences ;"
        "IN: scratchpad"
        ":: frobnicate ( n seq -- newseq )"
        "    [let | n' [ n 6 * ] |"
        "        seq [ n' gcd nip ] map ] ;"
        "6 { 36 14 } frobnicate ."
        "{ 36 2 }"
    }
} ;

HELP: [let*
{ $syntax "[let* | binding1 [ value1... ]\n        binding2 [ value2... ]\n        ... |\n    body... ]" }
{ $description "Introduces a set of lexical bindings and evaluates the body. The values are evaluated sequentially, and may refer to previous bindings from the same " { $link POSTPONE: [let* } " form; for Lisp programmers, this means that " { $link POSTPONE: [let* } " is equivalent to the Lisp " { $snippet "let*" } ", not " { $snippet "let" } "." }
{ $examples
    { $example
        "USING: kernel locals math math.functions prettyprint sequences ;"
        "IN: scratchpad"
        ":: frobnicate ( n seq -- newseq )"
        "    [let* | a [ n 3 + ]"
        "            b [ a 4 * ] |"
        "        seq [ b / ] map ] ;"
        "1 { 32 48 } frobnicate ."
        "{ 2 3 }"
    }
} ;

{ POSTPONE: [let POSTPONE: [let* } related-words

HELP: [wlet
{ $syntax "[wlet | binding1 [ body1... ]\n        binding2 [ body2... ]\n        ... |\n     body... ]" }
{ $description "Introduces a set of lexically-scoped non-recursive local functions. The bodies may not refer to other bindings within the same " { $link POSTPONE: [wlet } " form; for Lisp programmers, this means that Factor's " { $link POSTPONE: [wlet } " is equivalent to the Lisp " { $snippet "flet" } ", not " { $snippet "labels" } "." }
{ $examples
    { $example
        "USING: locals math prettyprint sequences ;"
        "IN: scratchpad"
        ":: quuxify ( n seq -- newseq )"
        "    [wlet | add-n [| m | m n + ] |"
        "        seq [ add-n ] map ] ;"
        "2 { 1 2 3 } quuxify ."
        "{ 3 4 5 }"
    }
} ;

HELP: ::
{ $syntax ":: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a word with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." }
{ $examples "See " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " and " { $link POSTPONE: [wlet } "." } ;

{ POSTPONE: : POSTPONE: :: } related-words

HELP: MACRO::
{ $syntax "MACRO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

HELP: MEMO::
{ $syntax "MEMO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a memoized word with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." } ;

{ POSTPONE: MEMO: POSTPONE: MEMO:: } related-words

ARTICLE: "locals-literals" "Locals in array and hashtable literals"
"Certain data type literals are permitted to contain free variables. Any such literals are written into code which constructs an instance of the type with the free variable values spliced in. Conceptually, this is similar to the transformation applied to quotations containing free variables."
$nl
"The data types which receive this special handling are the following:"
{ $list
    { $link "arrays" }
    { $link "hashtables" }
    { $link "vectors" }
    { $link "tuples" }
}
"This feature changes the semantics of literal object identity. An ordinary word containing a literal pushes the same literal on the stack every time it is invoked:"
{ $example
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ": ordinary-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "ordinary-word-test ordinary-word-test eq? ."
    "t"
}
"In a word with locals, literals expand into code which constructs the literal, and so every invocation pushes a new object:"
{ $example
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: ordinary-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "ordinary-word-test ordinary-word-test eq? ."
    "f"
}
"One exception to the above rule is that array instances containing no free variables do retain identity. This allows macros such as " { $link cond } " to recognize that the array is constant and expand at compile-time."
$nl
"For example, here is an implementation of the " { $link 3array } " word which uses this feature:"
{ $code ":: 3array ( x y z -- array ) { x y z } ;" } ;

ARTICLE: "locals-mutable" "Mutable locals"
"In the list of bindings supplied to " { $link POSTPONE: :: } ", " { $link POSTPONE: [let } ", " { $link POSTPONE: [let* } " or " { $link POSTPONE: [| } ", a mutable binding may be introduced by suffixing its named with " { $snippet "!" } ". Mutable bindings are read by giving their name as usual; the suffix is not part of the binding's name. To write to a mutable binding, use the binding's name with the " { $snippet "!" } " suffix."
$nl
"Here is a example word which outputs a pair of quotations which increment and decrement an internal counter, and then return the new value. The quotations are closed over the counter and each invocation of the word yields new quotations with their unique internal counter:"
{ $code
    ":: counter ( -- )"
    "    [let | value! [ 0 ] |"
    "        [ value 1+ dup value! ]"
    "        [ value 1- dup value! ] ] ;"
}
"Mutable bindings are implemented in a manner similar to the ML language; each mutable binding is actually an immutable binding of a mutable cell (in Factor's case, a 1-element array); reading the binding automatically dereferences the array, and writing to the binding stores into the array."
$nl
"Unlike some languages such as Python and Java, writing to mutable locals in outer scopes is fully supported and has the expected semantics." ;

ARTICLE: "locals-limitations" "Limitations of locals"
"The first limitation is that the " { $link >r } " and " { $link r> } " words may not be used together with locals. Instead, use the " { $link dip } " combinator."
$nl
"Another limitation concerns combinators implemented as macros. Locals can only be used with such combinators if the input array immediately precedes the combinator call. For example, the following will work:"
{ $code
    ":: good-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } cond ;"
}
"But not the following:"
{ $code
    ": my-cond ( alist -- ) cond ; inline"
    ""
    ":: bad-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } my-cond ;"
}
"The reason is that locals are rewritten into stack code at parse time, whereas macro expansion is performed later during compile time. To circumvent this problem, the " { $vocab-link "macros.expander" } " vocabulary is used to rewrite simple macro usages prior to local transformation, however "{ $vocab-link "macros.expander" } " does not deal with more complicated cases where the literal inputs to the macro do not immediately precede the macro call in the source." ;

ARTICLE: "locals" "Local variables and lexical closures"
"The " { $vocab-link "locals" } " vocabulary implements lexical scope with full closures, both downward and upward. Mutable bindings are supported, including assignment to bindings in outer scope."
$nl
"Compile-time transformation is used to compile local variables to efficient code; prettyprinter extensions are defined so that " { $link see } " can display original word definitions with local variables and not the closure-converted concatenative code which results."
$nl
"Applicative word definitions where the inputs are named local variables:"
{ $subsection POSTPONE: :: }
{ $subsection POSTPONE: MEMO:: }
{ $subsection POSTPONE: MACRO:: }
"Lexical binding forms:"
{ $subsection POSTPONE: [let }
{ $subsection POSTPONE: [let* }
{ $subsection POSTPONE: [wlet }
"Lambda abstractions:"
{ $subsection POSTPONE: [| }
"Additional topics:"
{ $subsection "locals-literals" }
{ $subsection "locals-mutable" }
{ $subsection "locals-limitations" }
"Locals complement dynamically scoped variables implemented in the " { $vocab-link "namespaces" } " vocabulary." ;

ABOUT: "locals"
