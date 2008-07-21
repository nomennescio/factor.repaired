! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences vocabs kernel ;
IN: bootstrap.syntax

"syntax" create-vocab drop

{
    "!"
    "\""
    "#!"
    "("
    "(("
    ":"
    ";"
    "<PRIVATE"
    "BIN:"
    "B{"
    "BV{"
    "C:"
    "CHAR:"
    "DEFER:"
    "ERROR:"
    "FORGET:"
    "GENERIC#"
    "GENERIC:"
    "HEX:"
    "HOOK:"
    "H{"
    "IN:"
    "INSTANCE:"
    "M:"
    "MAIN:"
    "MATH:"
    "MIXIN:"
    "OCT:"
    "P\""
    "POSTPONE:"
    "PREDICATE:"
    "PRIMITIVE:"
    "PRIVATE>"
    "SBUF\""
    "SINGLETON:"
    "SYMBOL:"
    "TUPLE:"
    "SLOT:"
    "T{"
    "UNION:"
    "INTERSECTION:"
    "USE:"
    "USING:"
    "V{"
    "W{"
    "["
    "\\"
    "]"
    "delimiter"
    "f"
    "flushable"
    "foldable"
    "inline"
    "recursive"
    "parsing"
    "t"
    "{"
    "}"
    "CS{"
    "<<"
    ">>"
    "call-next-method"
    "initial:"
    "read-only"
} [ "syntax" create drop ] each

"t" "syntax" lookup define-symbol
