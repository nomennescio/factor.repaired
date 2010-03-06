! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel prettyprint io debugger
sequences assocs stack-checker.errors summary effects ;
IN: stack-checker.errors.prettyprint

M: unknown-macro-input summary
    macro>> name>> "Cannot apply “" "” to an input parameter of a non-inline word" surround ;

M: bad-macro-input summary
    macro>> name>> "Cannot apply “" "” to a run-time computed value" surround ;

M: unbalanced-branches-error summary
    drop "Unbalanced branches" ;

: quots-and-branches. ( quots branches -- )
    zip [ [ first pprint-short bl ] [ second effect>string print ] bi ] each ;

M: unbalanced-branches-error error.
    dup summary print
    [ quots>> ] [ branches>> [ length [ "x" <array> ] bi@ <effect> ] { } assoc>map ] bi
    quots-and-branches. ;

M: too-many->r summary
    drop "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop "Quotation pops retain stack elements which it did not push" ;

M: missing-effect summary
    drop "Missing stack effect declaration" ;

M: effect-error summary
    drop "Stack effect declaration is wrong" ;

M: recursive-quotation-error summary
    drop "Recursive quotation" ;

M: undeclared-recursion-error summary
    word>> name>>
    "The inline recursive word " " must be declared recursive" surround ;

M: diverging-recursion-error summary
    word>> name>>
    "The recursive word " " digs arbitrarily deep into the stack" surround ;

M: unbalanced-recursion-error summary
    word>> name>>
    "The recursive word " " leaves with the stack having the wrong height" surround ;

M: inconsistent-recursive-call-error summary
    word>> name>>
    "The recursive word "
    " calls itself with a different set of quotation parameters than were input" surround ;

M: transform-expansion-error summary
    word>> name>> "Macro expansion of " " threw an error" surround ;

M: transform-expansion-error error.
    [ summary print ]
    [ nl "The error was:" print error>> error. nl ]
    [ continuation>> traceback-link. ]
    tri ;

M: do-not-compile summary
    word>> name>> "Cannot compile call to " prepend ;

M: invalid-quotation-input summary
    word>> name>>
    "The input quotations to " " don't match their expected effects" surround ;

M: invalid-quotation-input error.
    dup summary print
    [ quots>> ] [ branches>> ] bi quots-and-branches. ;

M: invalid-effect-variable summary
    drop "Stack effect variables can only occur as the first input or output" ;
M: effect-variable-can't-have-type summary
    drop "Stack effect variables cannot have a declared type" ;

