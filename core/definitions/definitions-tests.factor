USING: tools.test generic kernel definitions sequences
compiler.units words ;
IN: definitions.tests

GENERIC: some-generic ( a -- b )

USE: arrays

M: array some-generic ;

USE: bit-arrays

M: bit-array some-generic ;

USE: byte-arrays

M: byte-array some-generic ;

TUPLE: some-class ;

M: some-class some-generic ;

{ } [
    [
        \ some-generic
        \ some-class
        2array
        forget-all
    ] with-compilation-unit
] unit-test
