! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax math sequences kernel ;
IN: math.bitwise

HELP: bitfield
{ $values { "values..." "a series of objects" } { "bitspec" "an array" } { "n" integer } }
{ $description "Constructs an integer from a series of values on the stack together with a bit field specifier, which is an array whose elements have one of the following shapes:"
    { $list
        { { $snippet "{ constant shift }" } " - the resulting bit field is bitwise or'd with " { $snippet "constant" } " shifted to the right by " { $snippet "shift" } " bits" }
        { { $snippet "{ word shift }" } " - the resulting bit field is bitwise or'd with " { $snippet "word" } " applied to the top of the stack; the result is shifted to the right by " { $snippet "shift" } " bits" }
        { { $snippet "shift" } " - the resulting bit field is bitwise or'd with the top of the stack; the result is shifted to the right by " { $snippet "shift" } " bits" }
    }
"The bit field specifier is processed left to right, so stack values should be supplied in reverse order." }
{ $examples
    "Consider the following specification:"
    { $list
        { "bits 0-10 are set to the value of " { $snippet "x" } }
        { "bits 11-14 are set to the value of " { $snippet "y" } }
        { "bit 15 is always on" }
        { "bits 16-20 are set to the value of " { $snippet "fooify" } " applied to " { $snippet "z" } }
    }
    "Such a bit field construction can be specified with a word like the following:"
    { $code
        ": baz-bitfield ( x y z -- n )"
        "    {"
        "        { fooify 16 }"
        "        { 1 15 }"
        "        11"
        "        0"
        "    } ;"
    }
} ;

HELP: bits
{ $values { "m" integer } { "n" integer } { "m'" integer } }
{ $description "Keep only n bits from the integer m." }
{ $example "USING: math.bitwise prettyprint ;" "0x123abcdef 16 bits .h" "cdef" } ;

HELP: bit-range
{ $values { "x" integer } { "high" integer } { "low" integer } { "y" integer } }
{ $description "Extract a range of bits from an integer, inclusive of each boundary." }
{ $example "USING: math.bitwise prettyprint ;" "0b1100 3 2 bit-range .b" "11" } ;

HELP: bitroll
{ $values { "x" integer } { "s" "a shift integer" } { "w" "a wrap integer" } { "y" integer }
}
{ $description "Roll n by s bits to the left, wrapping around after w bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;" "1 -1 32 bitroll .b" "10000000000000000000000000000000" }
    { $example "USING: math.bitwise prettyprint ;" "0xffff0000 8 32 bitroll .h" "ff0000ff" }
} ;

HELP: bit-clear?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Returns " { $link t } " if the nth bit is set to zero." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0xff 8 bit-clear? ."
               "t"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "0xff 7 bit-clear? ."
               "f"
    }
} ;

{ bit? bit-clear? set-bit clear-bit } related-words

HELP: bit-count
{ $values
     { "obj" object }
     { "n" integer }
}
{ $description "Returns the number of set bits as an object. This word only works on non-negative integers or objects that can be represented as a byte-array." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0xf0 bit-count ."
               "4"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "-1 32 bits bit-count ."
               "32"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "B{ 1 0 1 } bit-count ."
               "2"
    }
} ;

HELP: bitroll-32
{ $values
     { "m" integer } { "s" integer }
     { "n" integer }
}
{ $description "Rolls the number " { $snippet "m" } " by " { $snippet "s" } " bits to the left, wrapping around after 32 bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 10 bitroll-32 .h"
               "400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 -10 bitroll-32 .h"
               "400000"
    }
} ;

HELP: bitroll-64
{ $values
     { "m" integer } { "s" "a shift integer" }
     { "n" integer }
}
{ $description "Rolls the number " { $snippet "m" } " by " { $snippet "s" } " bits to the left, wrapping around after 64 bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 10 bitroll-64 .h"
               "400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 -10 bitroll-64 .h"
               "40000000000000"
    }
} ;

{ bitroll bitroll-32 bitroll-64 } related-words

HELP: clear-bit
{ $values
     { "x" integer } { "n" integer }
     { "y" integer }
}
{ $description "Sets the nth bit of " { $snippet "x" } " to zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 7 clear-bit .h"
        "7f"
    }
} ;

HELP: symbols>flags
{ $values { "symbols" sequence } { "assoc" assoc } { "flag-bits" integer } }
{ $description "Constructs an integer value by mapping the values in the " { $snippet "symbols" } " sequence to integer values using " { $snippet "assoc" } " and " { $link bitor } "ing the values together." }
{ $examples
    { $example "USING: math.bitwise prettyprint ui.gadgets.worlds ;"
        "IN: scratchpad"
        "CONSTANT: window-controls>flags H{"
        "    { close-button 1 }"
        "    { minimize-button 2 }"
        "    { maximize-button 4 }"
        "    { resize-handles 8 }"
        "    { small-title-bar 16 }"
        "    { normal-title-bar 32 }"
        "}"
        "{ resize-handles close-button small-title-bar } window-controls>flags symbols>flags ."
        "25"
    }
} ;

HELP: >even
{ $values
    { "m" integer }
    { "n" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "7 >even ."
        "6"
    }
}
{ $description "Sets the lowest bit in the integer to 0, which either does nothing or outputs 1 less than the input integer." } ;

HELP: >odd
{ $values
    { "m" integer }
    { "n" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "4 >odd ."
        "5"
    }
}
{ $description "Sets the lowest bit in the integer to 1, which either does nothing or outputs 1 more than the input integer." } ;

HELP: >signed
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "0xff 8 >signed ."
        "-1"
    }
}
{ $description "Interprets a number " { $snippet "x" } " as an " { $snippet "n" } "-bit number and converts it to a negative number " { $snippet "n" } "-bit number if the topmost bit is set." } ;

HELP: mask
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "After the operation, only the bits that were set in both the mask and the original number are set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0b11111111 0b101 mask .b"
        "101"
    }
} ;

HELP: mask-bit
{ $values
     { "m" integer } { "n" integer }
     { "m'" integer }
}
{ $description "Turns off all bits besides the nth bit." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 2 mask-bit .b"
        "100"
    }
} ;

HELP: mask?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Returns true if all of the bits in the mask " { $snippet "n" } " are set in the integer input " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0xf mask? ."
        "t"
    }

    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xf0 0x1 mask? ."
        "f"
    }
} ;

HELP: even-parity?
{ $values
    { "obj" object }
    { "?" boolean }
}
{ $description "Returns true if the number of set bits in an object is even." } ;

HELP: odd-parity?
{ $values
    { "obj" object }
    { "?" boolean }
}
{ $description "Returns true if the number of set bits in an object is odd." } ;

HELP: on-bits
{ $values
     { "m" integer }
     { "n" integer }
}
{ $description "Returns an integer with " { $snippet "m" } " bits set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "6 on-bits .h"
        "3f"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "64 on-bits .h"
        "ffffffffffffffff"
    }
} ;

HELP: toggle-bit
{ $values
     { "m" integer }
     { "n" integer }
     { "m'" integer }
}
{ $description "Toggles the nth bit of an integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 3 toggle-bit .b"
        "1000"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0b1000 3 toggle-bit .b"
        "0"
    }
} ;

HELP: set-bit
{ $values
     { "x" integer } { "n" integer }
     { "y" integer }
}
{ $description "Sets the nth bit of " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 5 set-bit .h"
        "20"
    }
} ;

HELP: shift-mod
{ $values
     { "m" integer } { "s" integer } { "w" integer }
     { "n" integer }
}
{ $description "Calls " { $link shift } " on " { $snippet "n" } " and " { $snippet "s" } ", wrapping the result to " { $snippet "w" } " bits." } ;

HELP: unmask
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Clears the bits in " { $snippet "x" } " if they are set in the mask " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0x0f unmask .h"
        "f0"
    }
} ;

HELP: unmask?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Tests whether unmasking the bits in " { $snippet "x" } " would return an integer greater than zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0x0f unmask? ."
        "t"
    }
} ;

HELP: w*
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Multiplies two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffff 0x2 w* ."
        "4294967294"
    }
} ;

HELP: w+
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Adds two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffff 0x2 w+ ."
        "1"
    }
} ;

HELP: w-
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Subtracts two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0x0 0xff w- ."
        "4294967041"
    }
} ;

HELP: W*
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Multiplies two integers and wraps the result to a 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffffffffffff 0x2 W* ."
        "18446744073709551614"
    }
} ;

HELP: W+
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Adds two integers and wraps the result to 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffffffffffff 0x2 W+ ."
        "1"
    }
} ;

HELP: W-
{ $values
     { "x" integer } { "y" integer }
     { "z" integer }
}
{ $description "Subtracts two integers and wraps the result to a 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0x0 0xff W- ."
        "18446744073709551361"
    }
} ;

HELP: wrap
{ $values
     { "m" integer } { "n" integer }
     { "m'" integer }
}
{ $description "Wraps an integer " { $snippet "m" } " by modding it by " { $snippet "n" } ". This word is uses bitwise arithmetic and does not actually call the modulus word, and as such can only mod by powers of two." }
{ $examples "Equivalent to modding by 8:"
    { $example
        "USING: math.bitwise prettyprint ;"
        "0xffff 8 wrap .h"
        "7"
    }
} ;

ARTICLE: "math-bitfields" "Constructing bit fields"
"Some applications, such as binary communication protocols and assemblers, need to construct integers from elaborate bit field specifications. Hand-coding this using " { $link shift } " and " { $link bitor } " results in repetitive code. A higher-level facility exists to factor out this repetition:"
{ $subsections bitfield } ;

ARTICLE: "math.bitwise" "Additional bitwise arithmetic"
"The " { $vocab-link "math.bitwise" } " vocabulary provides bitwise arithmetic words extending " { $link "bitwise-arithmetic" } ". They are useful for efficiency, low-level programming, and interfacing with C libraries."
$nl
"Setting and clearing bits:"
{ $subsections
    set-bit
    clear-bit
}
"Testing if bits are set or clear:"
{ $subsections
    bit?
    bit-clear?
}
"Extracting bits from an integer:"
{ $subsections
    bit-range
    bits
}
"Toggling a bit:"
{ $subsections
    toggle-bit
}
"Operations with bitmasks:"
{ $subsections
    mask
    unmask
    mask?
    unmask?
}
"Generating an integer with n set bits:"
{ $subsections on-bits }
"Counting the number of set bits:"
{ $subsections bit-count }
"Testing the parity of an object:"
{ $subsections even-parity? odd-parity? }
"More efficient modding by powers of two:"
{ $subsections wrap }
"Bit-rolling:"
{ $subsections
    bitroll
    bitroll-32
    bitroll-64
}
"32-bit arithmetic:"
{ $subsections
    w+
    w-
    w*
}
"64-bit arithmetic:"
{ $subsections
    W+
    W-
    W*
}
"Converting a number to the nearest even/odd:"
{ $subsections
    >even
    >odd
}
"Bitfields:"
{ $subsections
    "math-bitfields"
} ;

ABOUT: "math.bitwise"
