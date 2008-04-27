USING: help.markup help.syntax kernel math sequences quotations
math.private ;
IN: math.order

HELP: <=>
{ $values { "obj1" object } { "obj2" object } { "n" real } }
{ $contract
    "Compares two objects using an intrinsic total order, for example, the natural order for real numbers and lexicographic order for strings."
    $nl
    "The output value is one of the following:"
    { $list
        { "positive - indicating that " { $snippet "obj1" } " follows " { $snippet "obj2" } }
        { "zero - indicating that " { $snippet "obj1" } " is equal to " { $snippet "obj2" } }
        { "negative - indicating that " { $snippet "obj1" } " precedes " { $snippet "obj2" } }
    }
    "The default implementation treats the two objects as sequences, and recursively compares their elements. So no extra work is required to compare sequences lexicographically."
} ;

HELP: compare
{ $values { "obj1" object } { "obj2" object } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } { "n" integer } }
{ $description "Compares the results of applying the quotation to both objects via " { $link <=> } "." }
{ $examples { $example "USING: kernel math.order prettyprint sequences ;" "\"hello\" \"hi\" [ length ] compare ." "3" }
} ;

HELP: max
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Outputs the greatest of two real numbers." } ;

HELP: min
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Outputs the smallest of two real numbers." } ;

HELP: between?
{ $values { "x" real } { "y" real } { "z" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is in the interval " { $snippet "[y,z]" } "." }
{ $notes "As per the closed interval notation, the end-points are included in the interval." } ;

HELP: before?
{ $values { "obj1" "an object" } { "obj2" "an object" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "obj1" } " comes before " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: after?
{ $values { "obj1" "an object" } { "obj2" "an object" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "obj1" } " comes after " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: before=?
{ $values { "obj1" "an object" } { "obj2" "an object" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "obj1" } " comes before or equals " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: after=?
{ $values { "obj1" "an object" } { "obj2" "an object" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "obj1" } " comes after or equals " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

{ before? after? before=? after=? } related-words

HELP: [-]
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Subtracts " { $snippet "y" } " from " { $snippet "x" } ". If the result is less than zero, outputs zero." } ;

