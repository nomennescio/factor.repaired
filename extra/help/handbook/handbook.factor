USING: help help.markup help.syntax help.definitions help.topics
namespaces words sequences classes assocs vocabs kernel arrays
prettyprint.backend kernel.private io generic math system
strings sbufs vectors byte-arrays bit-arrays float-arrays
quotations ;
IN: help.handbook

ARTICLE: "conventions" "Conventions"
"Various conventions are used throughout the Factor documentation and source code."
{ $heading "Documentation conventions" }
"Factor documentation consists of two distinct bodies of text. There is a hierarchy of articles, much like this one, and there is word documentation. Help articles reference word documentation, and vice versa, but not every documented word is referenced from some help article."
$nl
"Every article has links to parent articles at the top. These can be persued if the article is too specific."
$nl
"Some generic words have " { $strong "Description" } " headings, and others have " { $strong "Contract" } " headings. A distinction is made between words which are not intended to be extended with user-defined methods, and those that are."
{ $heading "Vocabulary naming conventions" }
"A vocabulary name ending in " { $snippet ".private" } " contains words which are either implementation detail, unsafe, or both. For example, the " { $snippet "sequence.private" } " vocabulary contains words which access sequence elements without bounds checking (" { $link "sequences-unsafe" } ")."
$nl
"You should should avoid using internal words from the Factor library unless absolutely necessary. Similarly, your own code can place words in internal vocabularies if you do not want other people to use them unless they have a good reason."
{ $heading "Word naming conventions" }
"These conventions are not hard and fast, but are usually a good first step in understanding a word's behavior:"
{ $table
    { "General form" "Description" "Examples" }
    { { $snippet { $emphasis "foo" } "?" } "outputs a boolean" { { $link empty? } } }
    { { $snippet "?" { $emphasis "foo" } } { "conditionally performs " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "creates a new " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet { $emphasis "foo" } "*" } { "alternative form of " { $snippet "foo" } ", or a generic word called by " { $snippet "foo" } } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { "implementation detail word used by " { $snippet "foo" } } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "sets " { $snippet "foo" } " to a new value" } { $links set-length } }
    { { $snippet { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple accessors) outputs the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "set-" { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple mutators) sets the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "with-" { $emphasis "foo" } } { "performs some kind of initialization and cleanup related to " { $snippet "foo" } ", usually in a new dynamic scope" } { $links with-scope with-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "help markup" } { $links $heading $emphasis } }
}
{ $heading "Stack effect conventions" }
"Stack effect conventions are documented in " { $link "effect-declaration" } "."
{ $heading "Glossary of terms" }
"Common terminology and abbreviations used throughout Factor and its documentation:"
{ $table
    { "Term" "Definition" }
    { "alist" { "an association list. See " { $link "alists" } } }
    { "assoc" "an associative mapping" }
    { "associative mapping" { "an object whose class implements the " { $link "assocs-protocol" } } }
    { "boolean"               { { $link t } " or " { $link f } } }
    { "class"                 { "a set of objects identified by a " { $emphasis "class word" } " together with a discriminating predicate. See " { $link "classes" } } }
    { "definition specifier"  { "a " { $link word } ", " { $link method-spec } ", " { $link link } ", vocabulary specifier, or any other object whose class implements the " { $link "definition-protocol" } } }
    { "generalized boolean"   { "an object interpreted as a boolean; a value of " { $link f } " denotes false and anything else denotes true" } }
    { "generic word"          { "a word whose behavior depends can be specialized on the class of one of its inputs. See " { $link "generic" } } }
    { "method"                { "a specialized behavior of a generic word on a class. See " { $link "generic" } } }
    { "object"                { "any datum which can be identified" } }
    { "pathname string"       { "an OS-specific pathname which identifies a file" } }
    { "sequence" { "an object whose class implements the " { $link "sequence-protocol" } } }
    { "slot"                  { "a component of an object which can store a value" } }
    { "stack effect"          { "a pictorial representation of a word's inputs and outputs, for example " { $snippet "+ ( x y -- z )" } ". See " { $link "effects" } } }
    { "true value"            { "any object not equal to " { $link f } } }
    { "vocabulary" { "a named set of words. See " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "a " { $link vocab } ", " { $link vocab-link } " or a string naming a vocabulary" } }
    { "word"                  { "the basic unit of code, analogous to a function or procedure in other programming languages. See " { $link "words" } } }
} ;

ARTICLE: "evaluator" "Evaluation semantics"
{ $link "quotations" } " are evaluated sequentially from beginning to end. When the end is reached, the quotation returns to its caller. As each object in the quotation is evaluated in turn, an action is taken based on its type:"
{ $list
    { "a " { $link word } " - the word's definition quotation is called. See " { $link "words" } }
    { "a " { $link wrapper } " - the wrapped object is pushed on the data stack. Wrappers are used to push word objects directly on the stack when they would otherwise execute. See the " { $link POSTPONE: \ } " parsing word." }
    { "All other types of objects are pushed on the data stack." }
}
"If the last action performed is the execution of a word, the current quotation is not saved on the call stack; this is known as " { $snippet "tail-recursion" } " and allows iterative algorithms to execute without incurring unbounded call stack usage."
{ $see-also "compiler" } ;

ARTICLE: "dataflow" "Data and control flow"
{ $subsection "evaluator" }
{ $subsection "words" }
{ $subsection "effects" }
{ $subsection "shuffle-words" }
{ $subsection "booleans" }
{ $subsection "conditionals" }
{ $subsection "basic-combinators" }
{ $subsection "combinators" }
{ $subsection "continuations" } ;

USING: concurrency.combinators
concurrency.messaging
concurrency.promises
concurrency.futures
concurrency.locks
concurrency.semaphores
concurrency.count-downs
concurrency.exchangers
concurrency.flags ;

ARTICLE: "concurrency" "Concurrency"
"Factor supports a variety of concurrency abstractions, however they are mostly used to multiplex input/output operations since the thread scheduling is co-operative and only one CPU is used at a time."
$nl
"Factor's concurrency support was insipired by Erlang, Termite, Scheme48 and Java's " { $snippet "java.util.concurrent" } " library."
$nl
"The basic building blocks:"
{ $subsection "threads" }
"High-level abstractions:"
{ $subsection "concurrency.combinators" }
{ $subsection "concurrency.promises" }
{ $subsection "concurrency.futures" }
{ $subsection "concurrency.mailboxes" }
{ $subsection "concurrency.messaging" }
"Shared-state abstractions:"
{ $subsection "concurrency.locks" }
{ $subsection "concurrency.semaphores" }
{ $subsection "concurrency.count-downs" }
{ $subsection "concurrency.exchangers" }
{ $subsection "concurrency.flags" }
"Other concurrency abstractions include " { $vocab-link "concurrency.distributed" } " and " { $vocab-link "channels" } "." ;

ARTICLE: "objects" "Objects"
"An " { $emphasis "object" } " is any datum which may be identified. All values are objects in Factor. Each object carries type information, and types are checked at runtime; Factor is dynamically typed."
{ $subsection "equality" }
{ $subsection "classes" }
{ $subsection "tuples" }
{ $subsection "generic" }
{ $subsection "mirrors" } ;

USE: random

ARTICLE: "numbers" "Numbers"
{ $subsection "arithmetic" }
{ $subsection "math-constants" }
{ $subsection "math-functions" }
{ $subsection "number-strings" }
{ $subsection "random-numbers" }
"Number implementations:"
{ $subsection "integers" }
{ $subsection "rationals" }
{ $subsection "floats" }
{ $subsection "complex-numbers" }
"Advanced features:"
{ $subsection "math-vectors" }
{ $subsection "math-intervals" }
{ $subsection "math-bitfields" } ;

USE: io.buffers

ARTICLE: "collections" "Collections" 
{ $heading "Sequences" }
{ $subsection "sequences" }
"Fixed-length sequences:"
{ $subsection "arrays" }
{ $subsection "quotations" }
"Fixed-length specialized sequences:"
{ $subsection "strings" }
{ $subsection "bit-arrays" }
{ $subsection "byte-arrays" }
{ $subsection "float-arrays" }
"Resizable sequence:"
{ $subsection "vectors" }
"Resizable specialized sequences:"
{ $subsection "sbufs" }
{ $subsection "bit-vectors" }
{ $subsection "byte-vectors" }
{ $subsection "float-vectors" }
{ $heading "Associative mappings" }
{ $subsection "assocs" }
{ $subsection "namespaces" }
"Implementations:"
{ $subsection "hashtables" }
{ $subsection "alists" }
{ $heading "Other collections" }
{ $subsection "boxes" }
{ $subsection "dlists" }
{ $subsection "heaps" }
{ $subsection "graphs" }
{ $subsection "buffers" } ;

USING: io.sockets io.launcher io.mmap io.monitors ;

ARTICLE: "io" "Input and output" 
{ $subsection "streams" }
"External streams:"
{ $subsection "file-streams" }
{ $subsection "network-streams" }
"Wrapper streams:"
{ $subsection "io.streams.duplex" }
{ $subsection "io.streams.lines" }
{ $subsection "io.streams.plain" }
{ $subsection "io.streams.string" }
"Stream utilities:"
{ $subsection "stream-binary" }
{ $subsection "styles" }
"Advanced features:"
{ $subsection "io.launcher" }
{ $subsection "io.mmap" }
{ $subsection "io.monitors" }
{ $subsection "io.timeouts" } ;

ARTICLE: "tools" "Developer tools"
"Exploratory tools:"
{ $subsection "editor" }
{ $subsection "tools.crossref" }
{ $subsection "inspector" }
"Debugging tools:"
{ $subsection "tools.annotations" }
{ $subsection "tools.test" }
"Performance tools:"
{ $subsection "tools.memory" }
{ $subsection "profiling" }
{ $subsection "timing" }
{ $subsection "tools.disassembler" }
"Deployment tools:"
{ $subsection "tools.deploy" } ;

ARTICLE: "article-index" "Article index"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index" "Primitive index"
{ $index [ all-words [ primitive? ] subset ] } ;

ARTICLE: "error-index" "Error index"
{ $index [ all-errors ] } ;

ARTICLE: "type-index" "Type index"
{ $index [ builtins get [ ] subset ] } ;

ARTICLE: "class-index" "Class index"
{ $index [ classes ] } ;

ARTICLE: "program-org" "Program organization"
{ $subsection "definitions" }
{ $subsection "vocabularies" }
{ $subsection "parser" }
{ $subsection "vocabs.loader" } ;

USING: help.cookbook help.tutorial ;

ARTICLE: "handbook" "Factor documentation"
"Welcome to Factor. Factor is dynamically-typed, stack-based, and very expressive. It is one of the most powerful and flexible programming languages ever invented. Have fun with Factor!"
{ $heading "Starting points" }
{ $subsection "cookbook" }
{ $subsection "first-program" }
{ $subsection "vocab-index" }
{ $heading "Language reference" }
{ $subsection "conventions" }
{ $subsection "syntax" }
{ $subsection "dataflow" }
{ $subsection "objects" }
{ $subsection "program-org" }
{ $heading "Library reference" }
{ $subsection "numbers" }
{ $subsection "collections" }
{ $subsection "io" }
{ $subsection "concurrency" }
{ $subsection "os" }
{ $subsection "alien" }
{ $heading "Environment reference" }
{ $subsection "cli" }
{ $subsection "images" }
{ $subsection "prettyprint" }
{ $subsection "tools" }
{ $subsection "help" }
{ $subsection "inference" }
{ $subsection "compiler" }
{ $heading "User interface" }
{ $about "ui" }
{ $about "ui.tools" }
{ $heading "Index" }
{ $subsection "primitive-index" }
{ $subsection "error-index" }
{ $subsection "type-index" }
{ $subsection "class-index" } ;

{ <array> <string> <sbuf> <vector> <byte-array> <bit-array> <float-array> }
related-words

{ >array >quotation >string >sbuf >vector >byte-array >bit-array >float-array }
related-words
