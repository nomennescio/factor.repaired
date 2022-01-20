USING: help.markup help.syntax kernel math
sequences math.order ;
IN: sorting

ARTICLE: "sequences-sorting" "Sorting sequences"
"The " { $vocab-link "sorting" } " vocabulary implements the merge-sort algorithm. It runs in " { $snippet "O(n log n)" } " time, and is a " { $emphasis "stable" } " sort, meaning that the order of equal elements is preserved."
$nl
"The algorithm only allocates two additional arrays, both the size of the input sequence, and uses iteration rather than recursion, and thus is suitable for sorting large sequences."
$nl
"Sorting combinators all take comparator quotations with stack effect " { $snippet "( elt1 elt2 -- <=> )" } ", where the output value is one of the three " { $link "order-specifiers" } "."
$nl
"Sorting a sequence with a custom comparator:"
{ $subsections sort }
"Sorting a sequence with common comparators:"
{ $subsections
    sort-with
    inv-sort-with
    natural-sort
    sort-keys
    sort-values
} ;

ABOUT: "sequences-sorting"

HELP: sort
{ $values { "seq" sequence } { "quot" { $quotation ( obj1 obj2 -- <=> ) } } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements of " { $snippet "seq" } " into a new array using a stable sort." }
{ $notes "The algorithm used is the merge sort." } ;

HELP: sort-with
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- key ) } } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements of " { $snippet "seq" } " by applying " { $link compare } " with " { $snippet "quot" } " to each pair of elements in the sequence." } ;

HELP: inv-sort-with
{ $values { "seq" sequence } { "quot" { $quotation ( elt -- key ) } } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements of " { $snippet "seq" } " by applying " { $link compare } " with " { $snippet "quot" } " to each pair of elements in the sequence and inverting the results." } ;

HELP: sort-keys
{ $values { "obj" object } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements of " { $snippet "obj" } " (converting to an alist first if not a sequence), comparing first elements of pairs using the " { $link <=> } " word." } ;

HELP: sort-values
{ $values { "obj" object } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements of " { $snippet "obj" } " (converting to an alist first if not a sequence), comparing second elements of pairs using the " { $link <=> } " word." } ;

HELP: natural-sort
{ $values { "seq" sequence } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts a sequence of objects in natural order using the " { $link <=> } " word." } ;

HELP: sort-pair
{ $values { "a" object } { "b" object } { "c" object } { "d" object } }
{ $description "If " { $snippet "a" } " is greater than " { $snippet "b" } ", exchanges " { $snippet "a" } " with " { $snippet "b" } "." } ;

HELP: compare-with
{ $values { "quots" { $sequence { $quotation ( obj1 obj2 -- <=> ) } } } }
{ $description "Generate a chained comparator using the specified " { $snippet "quots" } " sequence of comparators." } ;

HELP: midpoint@
{ $values { "seq" sequence } { "n" integer } }
{ $description "Outputs the index of the midpoint of " { $snippet "seq" } "." } ;

{ <=> compare compare-with natural-sort sort-with inv-sort-with sort-keys sort-values } related-words
