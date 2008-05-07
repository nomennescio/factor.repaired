USING: prettyprint.backend prettyprint.config
prettyprint.sections prettyprint.private help.markup help.syntax
io kernel words definitions quotations strings ;
IN: prettyprint

ARTICLE: "prettyprint-numbers" "Prettyprinting numbers"
"The " { $link . } " word prints numbers in decimal. A set of words in the " { $vocab-link "prettyprint" } " vocabulary is provided to print integers using another base."
{ $subsection .b }
{ $subsection .o }
{ $subsection .h } ;

ARTICLE: "prettyprint-stacks" "Prettyprinting stacks"
"Prettyprinting the current data, retain, call stacks:"
{ $subsection .s }
{ $subsection .r }
{ $subsection .c }
"Prettyprinting any stack:"
{ $subsection stack. }
"Prettyprinting any call stack:"
{ $subsection callstack. } ;

ARTICLE: "prettyprint-variables" "Prettyprint control variables"
"The following variables affect the " { $link . } " and " { $link pprint } " words if set in the current dynamic scope:"
{ $subsection tab-size }
{ $subsection margin }
{ $subsection nesting-limit }
{ $subsection length-limit }
{ $subsection line-limit }
{ $subsection string-limit }
"Note that the " { $link short. } " and " { $link pprint-short } " variables override some of these variables."
{
    $warning "Treat the global variables as essentially being constants. Only ever rebind them in a nested scope."
    $nl
    "Some of the globals are safe to change, like the tab size and wrap margin. However setting limits globally could break code which uses the prettyprinter as a serialization mechanism."
} ;

ARTICLE: "prettyprint-limitations" "Prettyprinter limitations"
"When using the prettyprinter as a serialization mechanism, keep the following points in mind:"
{ $list
    { "When printing words, " { $link POSTPONE: USING: } " declarations are only output if the " { $link pprint-use } " or " { $link unparse-use } "  words are used." }
    { "Long output will be truncated if certain " { $link "prettyprint-variables" } " are set." }
    "Shared structure is not reflected in the printed output; if the output is parsed back in, fresh objects are created for all literal denotations."
    { "Circular structure is not printed in a readable way. For example, try this:"
        { $code "{ f } dup dup set-first ." }
    }
    "Floating point numbers might not equal themselves after being printed and read, since a decimal representation of a float is inexact."
}
"On a final note, the " { $link short. } " and " { $link pprint-short } " words restrict the length and nesting of printed sequences, their output will very likely not be valid syntax. They are only intended for interactive use." ;

ARTICLE: "prettyprint-section-protocol" "Prettyprinter section protocol"
"Prettyprinter sections must subclass " { $link section } ", and they must also obey a protocol."
$nl
"Layout queries:"
{ $subsection section-fits? }
{ $subsection indent-section? }
{ $subsection unindent-first-line? }
{ $subsection newline-after? }
{ $subsection short-section? }
"Printing sections:"
{ $subsection short-section }
{ $subsection long-section }
"Utilities to use when implementing sections:"
{ $subsection new-section }
{ $subsection new-block }
{ $subsection add-section } ;

ARTICLE: "prettyprint-sections" "Prettyprinter sections"
"The prettyprinter's formatting engine can be used directly:"
{ $subsection with-pprint }
"Code in a " { $link with-pprint } " block or a method on " { $link pprint* } " can build up a tree of " { $emphasis "sections" } ". A section is either a text node or a " { $emphasis "block" } " which itself consists of sections."
$nl
"Once the output sections have been generated, the tree of sections is traversed and intelligent decisions are made about indentation and line breaks. Finally, text is output."
{ $subsection section }
"Adding leaf sections:"
{ $subsection line-break }
{ $subsection text }
{ $subsection styled-text }
"Nesting and denesting sections:"
{ $subsection <object }
{ $subsection <block }
{ $subsection <inset }
{ $subsection <flow }
{ $subsection <colon }
{ $subsection block> }
"New types of sections can be defined."
{ $subsection "prettyprint-section-protocol" } ;

ARTICLE: "prettyprint-literal" "Literal prettyprinting protocol"
"Unless a more specialized method exists for the input class, the " { $link pprint* } " word outputs an object in a standard format, ultimately calling two generic words:"
{ $subsection pprint-delims }
{ $subsection >pprint-sequence }
"For example, consider the following data type, together with a parsing word for creating literals:"
{ $code
    "TUPLE: rect w h ;"
    ""
    ": RECT["
    "    scan-word"
    "    scan-word \\ * assert="
    "    scan-word"
    "    scan-word \\ ] assert="
    "    <rect> parsed ; parsing"
}
"An example literal might be:"
{ $code "RECT[ 100 * 200 ]" }
"Without further effort, the literal does not print in the same way:"
{ $unchecked-example "RECT[ 100 * 200 ] ." "T{ rect f 100 200 }" }
"However, we can define two methods easily enough:"
{ $code
    "M: rect pprint-delims drop \\ RECT[ \\ ] ;"
    "M: rect >pprint-sequence dup rect-w \\ * rot rect-h 3array ;"
}
"Now, it will be printed in a custom way:"
{ $unchecked-example "RECT[ 100 * 200 ] ." "RECT[ 100 * 200 ]" } ;

ARTICLE: "prettyprint-literal-more" "Prettyprinting more complex literals"
"If the " { $link "prettyprint-literal" } " is insufficient, a method can be defined to control prettyprinting directly:"
{ $subsection pprint* }
"Some utilities which can be called from methods on " { $link pprint* } ":"
{ $subsection pprint-object }
{ $subsection pprint-word }
{ $subsection pprint-elements }
{ $subsection pprint-string }
{ $subsection pprint-prefix }
"Custom methods defined on " { $link pprint* } " do not perform I/O directly, instead they call prettyprinter words to construct " { $emphasis "sections" } " of output. See " { $link "prettyprint-sections" } "." ;

ARTICLE: "prettyprint-extension" "Extending the prettyprinter"
"One can define literal syntax for a new class using the " { $link "parser" } " together with corresponding prettyprinting methods which print instances of the class using this syntax."
{ $subsection "prettyprint-literal" }
{ $subsection "prettyprint-literal-more" }
"The prettyprinter actually exposes a general source code output engine and is not limited to printing object structure."
{ $subsection "prettyprint-sections" } ;

ARTICLE: "prettyprint" "The prettyprinter"
"One of Factor's key features is the ability to print almost any object as a valid source literal expression. This greatly aids debugging and provides the building blocks for light-weight object serialization facilities."
$nl
"Prettyprinter words are found in the " { $vocab-link "prettyprint" } " vocabulary."
$nl
"The key words to print an object to " { $link output-stream } "; the first two emit a trailing newline, the second two do not:"
{ $subsection . }
{ $subsection short. }
{ $subsection pprint }
{ $subsection pprint-short }
{ $subsection pprint-use }
"The string representation of an object can be requested:"
{ $subsection unparse }
{ $subsection unparse-use }
"Utility for tabular output:"
{ $subsection pprint-cell }
"Printing a definition (see " { $link "definitions" } "):"
{ $subsection see }
"More prettyprinter usage:"
{ $subsection "prettyprint-numbers" }
{ $subsection "prettyprint-stacks" }
"Prettyprinter customization:"
{ $subsection "prettyprint-variables" }
{ $subsection "prettyprint-extension" }
{ $subsection "prettyprint-limitations" }
{ $see-also "number-strings" } ;

ABOUT: "prettyprint"

HELP: with-pprint
{ $values { "obj" object } { "quot" quotation } }
{ $description "Sets up the prettyprinter and calls the quotation in a new scope. The quotation should add sections to the top-level block. When the quotation returns, the top-level block is printed to " { $link output-stream } "." } ;

HELP: pprint
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } ". Output is influenced by many variables; see " { $link "prettyprint-variables" } "." } ;

{ pprint pprint* with-pprint } related-words

HELP: .
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } " with a trailing line break. Output is influenced by many variables; see " { $link "prettyprint-variables" } "." } ;

HELP: unparse
{ $values { "obj" object } { "str" "Factor source string" } }
{ $description "Outputs a prettyprinted string representation of an object. Output is influenced by many variables; see " { $link "prettyprint-variables" } "." } ;

HELP: pprint-short
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } ". This word rebinds printer control variables to enforce ``shorter'' output. See " { $link "prettyprint-variables" } "." } ;

HELP: short.
{ $values { "obj" object } }
{ $description "Prettyprints an object to " { $link output-stream } " with a trailing line break. This word rebinds printer control variables to enforce ``shorter'' output." } ;

HELP: .b
{ $values { "n" "an integer" } }
{ $description "Outputs an integer in binary." } ;

HELP: .o
{ $values { "n" "an integer" } }
{ $description "Outputs an integer in octal." } ;

HELP: .h
{ $values { "n" "an integer" } }
{ $description "Outputs an integer in hexadecimal." } ;

HELP: stack.
{ $values { "seq" "a sequence" } }
{ $description "Prints a the elements of the sequence, one per line." }
{ $notes "This word is used in the implementation of " { $link .s } " and " { $link .r } "." } ;

HELP: callstack.
{ $values { "callstack" callstack } }
{ $description "Displays a sequence output by " { $link callstack } " in a nice way, by highlighting the current execution point in every call frame with " { $link -> } "." } ;

HELP: .c
{ $description "Displays the contents of the call stack, with the top of the stack printed first." } ;

HELP: .r
{ $description "Displays the contents of the retain stack, with the top of the stack printed first." } ;

HELP: .s
{ $description "Displays the contents of the data stack, with the top of the stack printed first." } ;

HELP: in.
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Prettyprints a " { $snippet "IN:" } " declaration." }
$prettyprinting-note ;

HELP: synopsis
{ $values { "defspec" "a definition specifier" } { "str" string } }
{ $contract "Prettyprints the prologue of a definition." } ;

HELP: synopsis*
{ $values { "defspec" "a definition specifier" } }
{ $contract "Adds sections to the current block corresponding to a the prologue of a definition, in source code-like form." }
{ $notes "This word should only be called from inside the " { $link with-pprint } " combinator. Client code should call " { $link synopsis } " instead." } ;

HELP: comment.
{ $values { "string" "a string" } }
{ $description "Prettyprints some text with the comment style." }
$prettyprinting-note ;

HELP: see
{ $values { "defspec" "a definition specifier" } }
{ $contract "Prettyprints a definition." } ;

HELP: definer
{ $values { "defspec" "a definition specifier" } { "start" word } { "end" "a word or " { $link f } } }
{ $contract "Outputs the parsing words which delimit the definition." }
{ $examples
    { $example "USING: definitions prettyprint ;"
               "IN: scratchpad"
               ": foo ; \\ foo definer . ."
               ";\nPOSTPONE: :"
    }
    { $example "USING: definitions prettyprint ;"
               "IN: scratchpad"
               "SYMBOL: foo \\ foo definer . ."
               "f\nPOSTPONE: SYMBOL:"
    }
}
{ $notes "This word is used in the implementation of " { $link see } "." } ;

HELP: definition
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence" } }
{ $contract "Outputs the body of a definition." }
{ $examples
    { $example "USING: definitions math prettyprint ;" "\\ sq definition ." "[ dup * ]" }
}
{ $notes "This word is used in the implementation of " { $link see } "." } ;
