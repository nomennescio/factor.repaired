USING: help.markup help.syntax words parser quotations strings
system sequences ;
IN: tools.annotations

ARTICLE: "tools.annotations" "Word annotations"
"The word annotation feature modifies word definitions to add debugging code. You can restore the old definition by calling " { $link reset } " on the word in question."
$nl
"Printing messages when a word is called or returns:"
{ $subsection watch }
{ $subsection watch-vars }
"Starting the walker when a word is called:"
{ $subsection breakpoint }
{ $subsection breakpoint-if }
"Timing words:"
{ $subsection reset-word-timing }
{ $subsection add-timing }
{ $subsection word-timing. }
"All of the above words are implemented using a single combinator which applies a quotation to a word definition to yield a new definition:"
{ $subsection annotate } ;

ABOUT: "tools.annotations"

HELP: annotate
{ $values { "word" "a word" } { "quot" { $quotation "( word def -- def )" } } }
{ $description "Changes a word definition to the result of applying a quotation to the old definition." }
{ $notes "This word is used to implement " { $link watch } "." } ;

HELP: watch
{ $values { "word" word } }
{ $description "Annotates a word definition to print the data stack on entry and exit." } ;

{ watch watch-vars reset } related-words

HELP: breakpoint
{ $values { "word" word } }
{ $description "Annotates a word definition to enter the single stepper when executed." } ;

HELP: breakpoint-if
{ $values { "quot" { $quotation "( -- ? )" } } { "word" word } }
{ $description "Annotates a word definition to enter the single stepper if the quotation yields true." } ;

HELP: annotate-methods
{ $values
     { "word" word } { "quot" quotation } }
{ $description "Annotates the word -- for generic words, all its methods -- with the quotation." } ;

HELP: entering
{ $values
     { "str" string } }
{ $description "Prints a message and the inputs to the word before the word has been called." } ;

HELP: leaving
{ $values
     { "str" string } }
{ $description "Prints a message and the outputs from a word after a word has been called." } ;

HELP: reset
{ $values
     { "word" word } }
{ $description "Resets any annotations on a word." }
{ $notes "This word will remove a " { $link watch } "." } ;

HELP: watch-vars
{ $values
     { "word" word } { "vars" "a sequence of symbols" } }
{ $description "Annotates a word definition to print the " { $snippet "vars" } " upon entering the word. This word is useful for debugging." } ;

HELP: word-inputs
{ $values
     { "word" word }
     { "seq" sequence } }
{ $description "Makes a sequence of the inputs to a word by counting the number of inputs in the stack effect and saving that many items from the datastack." } ;

HELP: add-timing
{ $values { "word" word } }
{ $description "Adds timing code to a word, which records its total running time, including that of words it calls, on every invocation." }
{ $see-also "tools.time" } ;

HELP: reset-word-timing
{ $description "Resets the word timing table." } ;

HELP: word-timing.
{ $description "Prints the word timing table." } ;
