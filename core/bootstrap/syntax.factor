! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.units kernel sequences vocabs words ;
IN: bootstrap.syntax

[
    "syntax" create-vocab drop

    {
        "\""
        "("
        ":"
        ";"
        "<PRIVATE"
        "<UNIX" "UNIX>"
        "<LINUX" "LINUX>"
        "<MACOS" "MACOS>"
        "<WINDOWS" "WINDOWS>"
        "<FACTOR" "FACTOR>"
        "B{"
        "BV{"
        "C:"
        "char:"
        "DEFER:"
        "ERROR:"
        "FORGET:"
        "GENERIC#:"
        "GENERIC:"
        "HOOK:"
        "H{"
        "HS{"
        "IN:"
        "INSTANCE:"
        "M:"
        "MAIN:"
        "MATH:"
        "MIXIN:"
        "nan:"
        "path\""
        "postpone:"
        "PREDICATE:"
        "PRIMITIVE:"
        "PRIVATE>"
        "sbuf\""
        "SINGLETON:"
        "SINGLETONS:"
        "BUILTIN:"
        "INITIALIZED-SYMBOL:"
        "SYMBOL:"
        "SYMBOLS:"
        "CONSTANT:"
        "TUPLE:"
        "final"
        "SLOT:"
        "T{"
        "TH{"
        "UNION:"
        "INTERSECTION:"
        "USE:"
        "UNUSE:"
        "USING:"
        "QUALIFIED:"
        "QUALIFIED-WITH:"
        "FROM:"
        "EXCLUDE:"
        "RENAME:"
        "ALIAS:"
        "SYNTAX:"
        "V{"
        "W{"
        "["
        "\\"
        "M\\\\"
        "]"
        "delimiter"
        "deprecated"
        "f"
        "flushable"
        "foldable"
        "inline"
        "private"
        "recursive"
        "t"
        "{"
        "}"
        "CS{"
        "<<"
        ">>"
        "call-next-method"
        "not{"
        "maybe{"
        "union{"
        "intersection{"
        "initial:"
        "read-only"
        "call("
        "execute("
        "IH{"
        "::"
        "M::"
        "MACRO:"
        "MACRO::"
        "TYPED:"
        "TYPED::"
        "MEMO:"
        "MEMO::"
        "MEMO["
        "IDENTITY-MEMO:"
        "IDENTITY-MEMO::"
        "PROTOCOL:"
        "CONSULT:"
        "BROADCAST:"
        "SLOT-PROTOCOL:"
        "HINTS:"
        "':"
        "'["
        "@"
        "_"
        "[["
        "[=["
        "[==["
        "[===["
        "[====["
        "[=====["
        "[======["

        "factor[["
        "factor[=["
        "factor[==["
        "factor[===["
        "factor[====["
        "factor[=====["
        "factor[======["

        "![["
        "![=["
        "![==["
        "![===["
        "![====["
        "![=====["
        "![======["

        "#[["
        "#[=["
        "#[==["
        "#[===["
        "#[====["
        "#[=====["
        "#[======["

        "I[["
        "I[=["
        "I[==["
        "I[===["
        "I[====["
        "I[=====["
        "I[======["

        ":>"
        "|["
        "let["
        "'let["
        "FUNCTOR:"
        "VARIABLES-FUNCTOR:"
        "STARTUP-HOOK:"
        "SHUTDOWN-HOOK:"

        "]]"
        "}}"
        ":::"
        "q[["
        "'{{"
        "q[["
        "q{{"
        "{{"
        "'{{"
        "H{{"
        "'H{{"
        "'[["
    } [ "syntax" create-word drop ] each
] with-compilation-unit
