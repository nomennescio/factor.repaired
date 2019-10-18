
USING: help.markup help.syntax ui.baseline-alignment ui.gadgets ;

HELP: aligned-gadget
{ $class-description "A " { $link gadget } " that adds the following slots:"
    { $list
        { { $slot "baseline" } " - a cached value for " { $link baseline } "; do not read or write this slot directly." }
        { { $slot "cap-height" } " - a cached value for " { $link cap-height } "; do not read or write this slot directly." }
    }
} ;
