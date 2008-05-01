USING: kernel help.markup help.syntax sequences ;
IN: sets

ARTICLE: "sets" "Set-theoretic operations on sequences"
"Set-theoretic operations on sequences are defined on the " { $vocab-link "sets" } " vocabulary. These operations use hashtables internally to achieve linear running time."
$nl
"Remove duplicates:"
{ $subsection prune }
"Test for duplicates:"
{ $subsection all-unique? }
"Set operations on sequences:"
{ $subsection diff }
{ $subsection intersect }
{ $subsection union }
{ $see-also member? memq? contains? all? "assocs-sets" } ;

HELP: unique
{ $values { "seq" "a sequence" } { "assoc" "an assoc" } }
{ $description "Outputs a new assoc where the keys and values are equal." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 1 2 2 3 3 } unique ." "H{ { 1 1 } { 2 2 } { 3 3 } }" }
} ;

HELP: prune
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Outputs a new sequence with each distinct element of " { $snippet "seq" } " appearing only once. Elements are compared for equality using " { $link = } " and elements are ordered according to their position in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 1 t 3 t } prune ." "V{ 1 t 3 }" }
} ;

HELP: all-unique?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests whether a sequence contains any repeated elements." }
{ $example
    "USING: sets prettyprint ;"
    "{ 0 1 1 2 3 5 } all-unique? ."
    "f"
} ;

HELP: diff
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq1" } " but not " { $snippet "seq2" } ", comparing elements for equality." 
} { $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } diff ." "{ 1 }" }
} ;

HELP: intersect
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in both " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } intersect ." "{ 2 3 }" }
} ;

HELP: union
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq1" } " and " { $snippet "seq2" } " which does not contain duplicate values." }
{ $examples
    { $example "USING: sets prettyprint ;" "{ 1 2 3 } { 2 3 4 } union ." "V{ 1 2 3 4 }" }
} ;

{ diff intersect union } related-words
