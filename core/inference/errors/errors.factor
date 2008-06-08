! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference.errors
USING: inference.backend inference.dataflow kernel generic
sequences prettyprint io words arrays inspector effects debugger
assocs accessors ;

M: inference-error error.
    dup rstate>>
    keys [ dup value? [ value-literal ] when ] map
    dup empty? [ "Word: " write dup peek . ] unless
    swap error>> error. "Nesting: " write . ;

M: inference-error error-help drop f ;

M: unbalanced-branches-error error.
    "Unbalanced branches:" print
    [ quots>> ] [ in>> ] [ out>> [ length ] map ] tri 3array flip
    [ [ bl ] [ pprint ] interleave nl ] each ;

M: literal-expected summary
    drop "Literal value expected" ;

M: too-many->r summary
    drop
    "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop
    "Quotation pops retain stack elements which it did not push" ;

M: no-effect error.
    "Unable to infer stack effect of " write word>> . ;

M: no-recursive-declaration error.
    "The recursive word " write
    word>> pprint
    " must declare a stack effect" print ;

M: effect-error error.
    "Stack effects of the word " write
    dup word>> pprint
    " do not match." print
    "Declared: " write
    dup word>> stack-effect effect>string .
    "Inferred: " write effect>> effect>string . ;

M: recursive-quotation-error error.
    "The quotation " write
    quot>> pprint
    " calls itself." print
    "Stack effect inference is undecidable when quotation-level recursion is permitted." print ;

M: cannot-unify-specials summary
    drop
    "Cannot unify branches with inconsistent special values" ;
