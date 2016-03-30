USING: assocs help.markup help.syntax quotations strings words ;
IN: bootstrap.image.primitives

HELP: all-primitives
{ $description "A constant " { $link assoc } " containing all primitives. Keys are vocab names and values are sequences of tuples declaring words. The format of the tuples are { name effect vm-func }. If 'vm-func' is a " { $link string } " then the primitive will call a function implemented in C++ code. If 'vm-func' is " { $link f } " then it is a sub-primitive and implemented in one of the files in 'basis/bootstrap/assembler/'." } ;

HELP: primitive-quot
{ $values { "word" word } { "vm-func" $maybe { string } } { "quot" quotation } }
{ $description "Creates the defining quotation for the primitive. If 'vm-func' is a string, then it is prefixed with 'primitive_' and a quotation calling that C++ function is generated." } ;

ARTICLE: "bootstrap.image.primitives" "Bootstrap primitives"
"This vocab contains utilities for declaring primitives to be added to the bootstrap image. It is used by " { $vocab-link "bootstrap.primitives" }
$nl
{ $link all-primitives } " is an assoc where all primitives are declared." ;

ABOUT: "bootstrap.image.primitives"
