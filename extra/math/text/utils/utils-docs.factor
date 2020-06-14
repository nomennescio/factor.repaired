USING: help.markup help.syntax math.text.utils sequences ;
IN: math.text.utils+docs

HELP: digit-groups
{ $values { "n" "a positive integer" } { "k" "a positive integer" } { "seq" sequence } }
{ $description "Decompose a number into groups of " { $snippet "k" } " digits and return them in a sequence starting with the least significant grouped digits first." } ;
