USING: vocabs.loader sequences system
random random.mersenne-twister combinators init
namespaces random ;
IN: bootstrap.random

"random.mersenne-twister" require

{
    { [ os windows? ] [ "random.windows" require ] }
    { [ os unix? ] [ "random.unix" require ] }
} cond

[
    [ 32 random-bits ] with-system-random
    <mersenne-twister> random-generator set-global
] "generator.random" add-init-hook
