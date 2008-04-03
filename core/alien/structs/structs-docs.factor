IN: alien.structs
USING: alien.c-types strings help.markup help.syntax
alien.syntax sequences io arrays slots.deprecated
kernel words slots assocs namespaces ;

! Deprecated code
: ($spec-reader-values) ( slot-spec class -- element )
    dup ?word-name swap 2array
    over slot-spec-name
    rot slot-spec-type 2array 2array
    [ { $instance } swap suffix ] assoc-map ;

: $spec-reader-values ( slot-spec class -- )
    ($spec-reader-values) $values ;

: $spec-reader-description ( slot-spec class -- )
    [
        "Outputs the value stored in the " ,
        { $snippet } rot slot-spec-name suffix ,
        " slot of " ,
        { $instance } swap suffix ,
        " instance." ,
    ] { } make $description ;

: $spec-reader ( reader slot-specs class -- )
    >r slot-of-reader r>
    over [
        2dup $spec-reader-values
        2dup $spec-reader-description
    ] when 2drop ;

GENERIC: slot-specs ( help-type -- specs )

M: word slot-specs "slots" word-prop ;

: $slot-reader ( reader -- )
    first dup "reading" word-prop [ slot-specs ] keep
    $spec-reader ;

: $spec-writer-values ( slot-spec class -- )
    ($spec-reader-values) reverse $values ;

: $spec-writer-description ( slot-spec class -- )
    [
        "Stores a new value to the " ,
        { $snippet } rot slot-spec-name suffix ,
        " slot of " ,
        { $instance } swap suffix ,
        " instance." ,
    ] { } make $description ;

: $spec-writer ( writer slot-specs class -- )
    >r slot-of-writer r>
    over [
        2dup $spec-writer-values
        2dup $spec-writer-description
        dup ?word-name 1array $side-effects
    ] when 2drop ;

: $slot-writer ( reader -- )
    first dup "writing" word-prop [ slot-specs ] keep
    $spec-writer ;

M: string slot-specs c-type struct-type-fields ;

M: array ($instance) first ($instance) " array" write ;

ARTICLE: "c-structs" "C structure types"
"A " { $snippet "struct" } " in C is essentially a block of memory with the value of each structure field stored at a fixed offset from the start of the block. The C library interface provides some utilities to define words which read and write structure fields given a base address."
{ $subsection POSTPONE: C-STRUCT: }
"Great care must be taken when working with C structures since no type or bounds checking is possible."
$nl
"An example:"
{ $code
    "C-STRUCT: XVisualInfo"
    "    { \"Visual*\" \"visual\" }"
    "    { \"VisualID\" \"visualid\" }"
    "    { \"int\" \"screen\" }"
    "    { \"uint\" \"depth\" }"
    "    { \"int\" \"class\" }"
    "    { \"ulong\" \"red_mask\" }"
    "    { \"ulong\" \"green_mask\" }"
    "    { \"ulong\" \"blue_mask\" }"
    "    { \"int\" \"colormap_size\" }"
    "    { \"int\" \"bits_per_rgb\" } ;"
}
"C structure objects can be allocated by calling " { $link <c-object> } " or " { $link malloc-object } "."
$nl
"Arrays of C structures can be created by calling " { $link <c-array> } " or " { $link malloc-array } ". Elements can be read and written using words named " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } "; these words are automatically generated by " { $link POSTPONE: C-STRUCT: } "." ;

ARTICLE: "c-unions" "C unions"
"A " { $snippet "union" } " in C defines a type large enough to hold its largest member. This is usually used to allocate a block of memory which can hold one of several types of values."
{ $subsection POSTPONE: C-UNION: }
"C structure objects can be allocated by calling " { $link <c-object> } " or " { $link malloc-object } "."
$nl
"Arrays of C unions can be created by calling " { $link <c-array> } " or " { $link malloc-array } ". Elements can be read and written using words named " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } "; these words are automatically generated by " { $link POSTPONE: C-UNION: } "." ;
