USING: compiler cpu.architecture vocabs.loader system sequences
namespaces parser kernel kernel.private classes classes.private
arrays hashtables vectors tuples sbufs inference.dataflow
hashtables.private sequences.private math tuples.private
growable namespaces.private alien.remote-control assocs words
generator command-line vocabs io prettyprint libc ;

"cpu." cpu append require

"-no-stack-traces" cli-args member? [
    f compiled-stack-traces? set-global
    0 profiler-prologue set-global
] when

! Compile a set of words ahead of our general
! compile-all. This set of words was determined
! semi-empirically using the profiler. It improves
! bootstrap time significantly, because frequenly
! called words which are also quick to compile
! are replaced by compiled definitions as soon as
! possible.
{
    roll -roll declare not

    tuple-class-eq? array? hashtable? vector?
    tuple? sbuf? node? tombstone?

    array-capacity array-nth set-array-nth

    wrap probe

    delegate

    underlying

    find-pair-next namestack*

    bitand bitor bitxor bitnot
} compile

{
    + 1+ 1- 2/ < <= > >= shift min
} compile

{
    new nth push pop peek hashcode* = get set
} compile

{
    . lines
} compile

{
    malloc free memcpy
} compile

[ compile-batch ] recompile-hook set-global
