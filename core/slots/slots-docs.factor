USING: help.markup help.syntax generic kernel.private parser
words kernel quotations namespaces sequences words arrays
effects generic.standard classes.tuple classes.builtin
slots.private classes strings math ;
IN: slots

ARTICLE: "accessors" "Slot accessors"
"For every tuple slot, a " { $emphasis "reader" } " method is defined in the " { $vocab-link "accessors" } " vocabulary. The reader is named " { $snippet { $emphasis "slot" } ">>" } " and given a tuple, pushes the slot value on the stack."
$nl
"Writable slots - that is, those not attributed " { $link read-only } " - also have a " { $emphasis "writer" } ". The writer is named " { $snippet "(>>" { $emphasis "slot" } ")" } " and stores a value into a slot. It has stack effect " { $snippet "( value object -- )" } ". If the slot is specialized to a specific class, the writer checks that the value being written into the slot is an instance of that class first."
$nl
"In addition, two utility words are defined for each writable slot."
$nl
"The " { $emphasis "setter" } " is named " { $snippet ">>" { $emphasis "slot" } } " and stores a value into a slot. It has stack effect " { $snippet "( object value -- object )" } "."
$nl
"The " { $emphasis "changer" } " is named " { $snippet "change-" { $emphasis "slot" } } ". It applies a quotation to the current slot value and stores the result back in the slot; it has stack effect " { $snippet "( object quot -- object )" } "."
$nl
"Since the reader and writer are generic, words can be written which do not depend on the specific class of tuple passed in, but instead work on any tuple that defines slots with certain names."
$nl
"In most cases, using the setter is preferred over the writer because the stack effect is better suited to the common case where the tuple is needed again, and where the new slot value was just computed and so is at the top of the stack. For example, consider the case where you want to create a tuple and fill in the slots with literals. The following version uses setters:"
{ $code
    "<email>"
    "    \"Happy birthday\" >>subject"
    "    { \"bob@bigcorp.com\" } >>to"
    "    \"alice@bigcorp.com\" >>from"
    "send-email"
}
"The following uses writers, and requires some stack shuffling:"
{ $code
    "<email>"
    "    \"Happy birthday\" over (>>subject)"
    "    { \"bob@bigcorp.com\" } over (>>to)"
    "    \"alice@bigcorp.com\" over (>>from)"
    "send-email"
}
"Even if some of the slot values come from the stack underneath the tuple being constructed, setters win:"
{ $code
    "<email>"
    "    swap >>subject"
    "    swap >>to"
    "    \"alice@bigcorp.com\" >>from"
    "send-email"
}
"This is because " { $link swap } " is easier to understand than " { $link tuck } ":"
{ $code
    "<email>"
    "    tuck (>>subject)"
    "    tuck (>>to)"
    "    \"alice@bigcorp.com\" over (>>from)"
    "send-email"
}
"The changer word abstracts a common pattern where a slot value is read then stored again; so the following is not idiomatic code:"
{ $code
    "find-manager"
    "    salary>> 0.75 * >>salary"
}
"The following version is preferred:"
{ $code
    "find-manager"
    "    [ 0.75 * ] change-salary"
}
{ $see-also "slots" "mirrors" } ;

ARTICLE: "slots" "Slots"
"A " { $emphasis "slot" } " is a component of an object which can store a value."
$nl
{ $link "tuples" } " are composed entirely of slots, and instances of " { $link "builtin-classes" } " consist of slots together with intrinsic data."
"The " { $vocab-link "slots" } " vocabulary contains words for introspecting the slots of an object."
$nl
"The " { $snippet "\"slots\"" } " word property of built-in and tuple classes holds an array of " { $emphasis "slot specifiers" } " describing the slot layout of each instance."
{ $subsection slot-spec }
"The four words associated with a slot can be looked up in the " { $vocab-link "accessors" } " vocabulary:"
{ $subsection reader-word }
{ $subsection writer-word }
{ $subsection setter-word }
{ $subsection changer-word }
"Looking up a slot by name:"
{ $subsection slot-named }
"Defining slots dynamically:"
{ $subsection define-reader }
{ $subsection define-writer }
{ $subsection define-setter }
{ $subsection define-changer }
{ $subsection define-slot-methods }
{ $subsection define-accessors }
{ $see-also "accessors" "mirrors" } ;

ABOUT: "slots"

HELP: slot-spec
{ $class-description "A slot specification. The " { $snippet "\"slots\"" } " word property of " { $link builtin-class } " and " { $link tuple-class } " instances holds sequences of slot specifications."
$nl
"The slots of a slot specification are:"
{ $list
    { { $snippet "name" } " - a " { $link string } " identifying the slot." }
    { { $snippet "offset" } " - an " { $link integer } " offset specifying where the slot value is stored inside instances of the relevant class. This is an implementation detail." }
    { { $snippet "class" } " - a " { $link class } " declaring the set of possible values for the slot." }
    { { $snippet "initial" } " - an initial value for the slot." }
    { { $snippet "read-only" } " - a boolean indicating whether the slot is read only or not. Read only slots do not have a writer method associated with them." }
} } ;

HELP: define-typecheck
{ $values { "class" class } { "generic" "a generic word" } { "quot" quotation } }
{ $description
    "Defines a generic word with the " { $link standard-combination } " using dispatch position 0, and having one method on " { $snippet "class" } "."
    $nl
    "This creates a definition analogous to the following code:"
    { $code
        "GENERIC: generic"
        "M: class generic quot ;"
    }
    "It checks if the top of the stack is an instance of " { $snippet "class" } ", and if so, executes the quotation. Delegation is respected."
}
{ $notes "This word is used internally to wrap unsafe low-level code in a type-checking stub." } ;

HELP: define-reader
{ $values { "class" class } { "name" string } { "slot" integer } }
{ $description "Defines a reader word to read a slot from instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: define-writer
{ $values { "class" class } { "name" string } { "slot" integer } }
{ $description "Defines a generic word " { $snippet "writer" } " to write a new value to a slot in instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: define-slot-methods
{ $values { "class" class } { "name" string } { "slot" integer } }
{ $description "Defines a reader, writer, setter and changer for a slot in instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: define-accessors
{ $values { "class" class } { "specs" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Defines slot methods." }
$low-level-note ;

HELP: slot ( obj m -- value )
{ $values { "obj" object } { "m" "a non-negative fixnum" } { "value" object } }
{ $description "Reads the object stored at the " { $snippet "n" } "th slot of " { $snippet "obj" } "." }
{ $warning "This word is in the " { $vocab-link "slots.private" } " vocabulary because it does not perform type or bounds checks, and slot numbers are implementation detail." } ;

HELP: set-slot ( value obj n -- )
{ $values { "value" object } { "obj" object } { "n" "a non-negative fixnum" } }
{ $description "Writes " { $snippet "value" } " to the " { $snippet "n" } "th slot of " { $snippet "obj" } "." }
{ $warning "This word is in the " { $vocab-link "slots.private" } " vocabulary because it does not perform type or bounds checks, and slot numbers are implementation detail." } ;

HELP: slot-named
{ $values { "name" string } { "specs" "a sequence of " { $link slot-spec } " instances" } { "spec/f" "a " { $link slot-spec } " or " { $link f } } }
{ $description "Outputs the " { $link slot-spec } " with the given name." } ;
