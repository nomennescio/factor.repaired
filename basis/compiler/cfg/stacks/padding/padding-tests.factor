USING: accessors arrays assocs compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.padding compiler.cfg.utilities kernel sequences sorting
vectors tools.test ;
IN: compiler.cfg.stacks.padding.tests

! classify-read: vacant locations
{ 2 2 2 } [
    { 3 { } } 2 classify-read
    { 0 { } } -1 classify-read
    { 3 { } } -1 classify-read
] unit-test

! classify-read: over locations
{ 1 1 1 1 1 } [
    { 1 { 0 } } 1 classify-read
    { 0 { } } 0 classify-read
    { 3 { } } 4 classify-read
    { 0 { } } 4 classify-read
    { 1 { 0 } } 4 classify-read
] unit-test

! classify-read: initialized locations
{ 0 0 0 } [
    { 1 { 0 } } 0 classify-read
    { 2 { 0 1 2 } } 0 classify-read
    { 0 { 0 1 2 } } 0 classify-read
] unit-test

! fill-stack
{
    { 2 { 4 5 0 1 } }
} [
    { 2 { 4 5 } } fill-stack
] unit-test

{
    { -1 { 3 4 } }
} [
    { -1 { 3 4 } } fill-stack
] unit-test

! fill-vacancies
{
    { { 0 { } } { 2 { 0 1 } } }
    { { 0 { } } { 2 { 0 1 } } }
    { { 0 { -1 -2 } } { 2 { 0 1 } } }
} [
    { { 0 { } } { 2 { } } } fill-vacancies
    { { 0 { } } { 2 { 0 } } } fill-vacancies
    { { 0 { -1 -2 } } { 2 { 0 } } } fill-vacancies
] unit-test

! combined-state
{
    { { 4 { } } { 2 { 0 1 } } }
} [
    V{ { { 4 { } } { 2 { 0 1 } } } } combine-states
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{ } combine-states
] unit-test

! States can't be combined if their heights are different
[
    V{ { { 3 { } } { 0 { } } } { { 8 { } } { 0 { } } } } combine-states
] [ height-mismatches? ] must-fail-with

[
    V{ { { 4 { } } { 2 { 0 1 } } } { { 5 { 4 3 2 } } { 0 { } } } }
    combine-states
] [ height-mismatches? ] must-fail-with

! stack>vacant
{
    { 0 1 2 }
    { }
    { 1 }
} [
    { 3 { } } stack>vacant
    { -2 { } } stack>vacant
    { 3 { 0 2 } } stack>vacant
] unit-test

! visit-insn ##inc

! We assume that overinitialized locations are always dead.
{
    { { 0 { } } { 0 { } } }
} [
    { { 3 { 0 } } { 0 { } } } T{ ##inc { loc D -3 } } visit-insn
] unit-test

! visit-insn ##call
{
    { { 3 { 0 1 2 } } { 0 { } } }
} [
    initial-state T{ ##call { height 3 } } visit-insn
] unit-test


{
    { { -1 { } } { 0 { } } }
} [
    initial-state T{ ##call { height -1 } } visit-insn
] unit-test


{
    { { 4 { 2 3 0 1 } } { 0 { } } }
} [
    { { 2 { 0 1 } } { 0 { } } } T{ ##call { height 2 } } visit-insn
] unit-test

! This looks weird but is right.
{
    { { 0 { 0 1 } } { 0 { } } }
} [
    { { -2 { } } { 0 { } } } T{ ##call { height 2 } } visit-insn
] unit-test


! if any of the stack locations are uninitialized when ##call is
! visisted then something is wrong. ##call might gc and the
! uninitialized locations would cause a crash.
[
    { { 3 { } } { 0 { } } } T{ ##call { height 3 } } visit-insn
] [ vacant-when-calling? ] must-fail-with

! ! Overinitialized locations can't be live when ##call is visited. They
! ! could be garbage collected in the called word so they maybe wouldn't
! ! survive.
! [
!     { { 0 { -1 -2 } } { 0 { -1 -2 } } } T{ ##call { height 0 } } visit-insn
! ] [ overinitialized-when-calling? ] must-fail-with

! This is tricky. Normally, there should be no overinitialized
! locations before a ##call (I think). But if they are, we can at
! least be sure they are dead after the call.
{
    { { 2 { 0 1 } } { 0 { } } }
} [
    { { 2 { 0 1 -1 } } { 0 { } } } T{ ##call { height 0 } } visit-insn
] unit-test

! visit-insn ##call-gc

! ##call-gc ofcourse fills all uninitialized locations.
{
    { { 4 { 0 1 2 3 } } { 0 { } } }
} [
    { { 4 { } } { 0 { } } } T{ ##call-gc } visit-insn
] unit-test


[
    { { 2 { -1 0 1 } } { 0 { } } } T{ ##call-gc } visit-insn
] [ overinitialized-when-gc? ] must-fail-with

! visit-insn ##peek
{
    { { 3 { 0 } } { 0 { } } }
} [
    { { 3 { 0 } } { 0 { } } } T{ ##peek { dst 1 } { loc D 0 } } visit-insn
] unit-test

! After a ##peek that can cause a stack underflow, it is certain that
! all stack locations are initialized.
{
    { { 0 { } } { 2 { 0 1 2 } } }
    { { 2 { 0 1 2 } } { 0 { } } }
} [
    { { 0 { } } { 2 { } } } T{ ##peek { dst 1 } { loc R 2 } } visit-insn
    { { 2 { } } { 0 { } } } T{ ##peek { dst 1 } { loc D 2 } } visit-insn
] unit-test

{
    { { 2 { 0 1 } } { 2 { 0 1 2 } } }
} [
    { { 2 { } } { 2 { } } } T{ ##peek { dst 1 } { loc R 2 } } visit-insn
] unit-test

! If the ##peek can't cause a stack underflow, then we don't have the
! same guarantees.
[
    { { 3 { } } { 0 { } } } T{ ##peek { dst 1 } { loc D 0 } } visit-insn
] [ vacant-peek? ] must-fail-with

: following-stack-state ( insns -- state )
    T{ ##branch } suffix insns>cfg trace-stack-state2
    >alist [ first ] sort-with last second ;

! trace-stack-state2
{
    H{
        {
            0
            { { 0 { } } { 0 { } } }
        }
        {
            1
            { { 2 { } } { 0 { } } }
        }
        {
            2
            { { 2 { 0 1 2 } } { 0 { } } }
        }
    }
} [
    {
        T{ ##inc f D 2 }
        T{ ##peek f f D 2 }
        T{ ##inc f D 0 }
    } insns>cfg trace-stack-state2
] unit-test

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { } } { 0 { } } } }
        { 2 { { 0 { } } { 0 { } } } }
    }
} [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    insns>cfg trace-stack-state2
] unit-test

! The peek "causes" the vacant locations to become populated.
{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 3 { } } { 0 { } } } }
        { 2 { { 3 { 0 1 2 3 } } { 0 { } } } }
    }
} [
    V{
        T{ ##inc f D 3 }
        T{ ##peek { loc D 3 } }
        T{ ##branch }
    }
    insns>cfg trace-stack-state2
] unit-test

! Replace -1 then peek is ok.
{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { -1 } } { 0 { } } } }
        { 2 { { 0 { -1 } } { 0 { } } } }
    }
} [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##peek { loc D -1 } }
        T{ ##branch }
    }
    insns>cfg trace-stack-state2
] unit-test

: cfg1 ( -- cfg )
    V{
        T{ ##inc f D 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } 0 insns>block
    V{
        T{ ##peek { dst 37 } { loc D 0 } }
        T{ ##inc f D -1 }
    } 1 insns>block
    1vector >>successors block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 1 { } } { 0 { } } } }
        { 2 { { 1 { 0 } } { 0 { } } } }
        { 3 { { 1 { 0 } } { 0 { } } } }
    }
} [ cfg1 trace-stack-state2 ] unit-test

! Same cfg structure as the bug1021:run-test word but with
! non-datastack instructions mostly omitted.
: bug1021-cfg ( -- cfg )
    {
        { 0 V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } } }
        {
            1 V{
                T{ ##inc f D 2 }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 0 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } { height 0 } }
            }
        }
        {
            3 V{
                T{ ##peek { dst 0 } { loc D 0 } }
                T{ ##peek { dst 0 } { loc D 1 } }
                T{ ##inc f D 2 }
                T{ ##replace { src 0 } { loc D 2 } }
                T{ ##replace { src 0 } { loc D 3 } }
                T{ ##replace { src 0 } { loc D 1 } }
            }
        }
        {
            8 V{
                T{ ##peek { dst 0 } { loc D 2 } }
                T{ ##peek { dst 0 } { loc D 1 } }
                T{ ##inc f D 3 }
                T{ ##replace { src 0 } { loc D 0 } }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 2 } }
                T{ ##replace { src 0 } { loc D 3 } }
            }
        }
        {
            10 V{
                T{ ##inc f D -3 }
                T{ ##peek { dst 0 } { loc D 0 } }
                T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
            }
        }
    } [ over insns>block ] assoc-map dup
    { { 0 1 } { 1 2 } { 2 3 } { 3 8 } { 8 10 } } make-edges 0 of block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { } } { 0 { } } } }
        { 2 { { 0 { } } { 0 { } } } }
        { 3 { { 0 { } } { 0 { } } } }
        { 4 { { 2 { } } { 0 { } } } }
        { 5 { { 2 { 1 } } { 0 { } } } }
        { 6 { { 2 { 1 0 } } { 0 { } } } }
        { 7 { { 2 { 1 0 } } { 0 { } } } }
        { 8 { { 2 { 1 0 } } { 0 { } } } }
        { 9 { { 2 { 1 0 } } { 0 { } } } }
        { 10 { { 4 { 3 2 } } { 0 { } } } }
        { 11 { { 4 { 3 2 } } { 0 { } } } }
        { 12 { { 4 { 3 2 } } { 0 { } } } }
        { 13 { { 4 { 3 2 1 } } { 0 { } } } }
        { 14 { { 4 { 3 2 1 } } { 0 { } } } }
        { 15 { { 4 { 3 2 1 } } { 0 { } } } }
        { 16 { { 7 { 6 5 4 } } { 0 { } } } }
        { 17 { { 7 { 6 5 4 0 } } { 0 { } } } }
        { 18 { { 7 { 6 5 4 0 1 } } { 0 { } } } }
        { 19 { { 7 { 6 5 4 0 1 2 } } { 0 { } } } }
        { 20 { { 7 { 6 5 4 0 1 2 3 } } { 0 { } } } }
        { 21 { { 4 { 3 2 1 0 } } { 0 { } } } }
        { 22 { { 4 { 3 2 1 0 } } { 0 { } } } }
    }
} [
    bug1021-cfg trace-stack-state2
] unit-test

! Same cfg structure as the bug1289:run-test word but with
! non-datastack instructions mostly omitted.
: bug1289-cfg ( -- cfg )
    {
        { 0 V{ } }
        {
            1 V{
                T{ ##inc f D 3 }
                T{ ##replace { src 0 } { loc D 2 } }
                T{ ##replace { src 0 } { loc D 0 } }
                T{ ##replace { src 0 } { loc D 1 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } { height -1 } }
            }
        }
        {
            3 V{
                T{ ##peek { dst 0 } { loc D 1 } }
                T{ ##peek { dst 0 } { loc D 0 } }
                T{ ##inc f D 1 }
                T{ ##inc f R 1 }
                T{ ##replace { src 0 } { loc R 0 } }
            }
        }
        {
            4 V{ }
        }
        {
            5 V{
                T{ ##inc f D -2 }
                T{ ##inc f R 5 }
                T{ ##replace { src 0 } { loc R 3 } }
                T{ ##replace { src 0 } { loc D 0 } }
                T{ ##replace { src 0 } { loc R 4 } }
                T{ ##replace { src 0 } { loc R 2 } }
                T{ ##replace { src 0 } { loc R 1 } }
                T{ ##replace { src 0 } { loc R 0 } }
            }
        }
        {
            6 V{
                T{ ##call { word f } { height 0 } }
            }
        }
        {
            7 V{
                T{ ##peek { dst 0 } { loc D 0 } }
                T{ ##peek { dst 0 } { loc R 3 } }
                T{ ##peek { dst 0 } { loc R 2 } }
                T{ ##peek { dst 0 } { loc R 1 } }
                T{ ##peek { dst 0 } { loc R 0 } }
                T{ ##peek { dst 0 } { loc R 4 } }
                T{ ##inc f D 2 }
                T{ ##inc f R -5 }
            }
        }
        { 8 V{ } }
        { 9 V{ } }
        { 10 V{ } }
        {
            11 V{
                T{ ##call-gc }
            }
        }
        {
            12 V{
                T{ ##peek { dst 0 } { loc R 0 } }
                T{ ##inc f D -3 }
                T{ ##inc f D 1 }
                T{ ##inc f R -1 }
                T{ ##replace { src 0 } { loc D 0 } }
            }
        }
        {
            13 V{ }
        }
    } [ over insns>block ] assoc-map dup
    {
        { 0 1 }
        { 1 2 }
        { 2 3 }
        { 3 4 }
        { 4 9 }
        { 5 6 }
        { 6 7 }
        { 7 8 }
        { 8 9 }
        { 9 5 }
        { 9 10 }
        { 10 12 }
        { 10 11 }
        { 11 12 }
        { 12 13 }
    } make-edges 0 of block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 3 { } } { 0 { } } } }
        { 2 { { 3 { 2 } } { 0 { } } } }
        { 3 { { 3 { 2 0 } } { 0 { } } } }
        { 4 { { 3 { 2 0 1 } } { 0 { } } } }
        { 5 { { 2 { 1 0 } } { 0 { } } } }
        { 6 { { 2 { 1 0 } } { 0 { } } } }
        { 7 { { 2 { 1 0 } } { 0 { } } } }
        { 8 { { 3 { 2 1 } } { 0 { } } } }
        { 9 { { 3 { 2 1 } } { 1 { } } } }
        { 10 { { 3 { 2 } } { 1 { 0 } } } }
        { 11 { { 1 { 0 } } { 1 { 0 } } } }
        { 12 { { 1 { 0 } } { 6 { 5 } } } }
        { 13 { { 1 { 0 } } { 6 { 5 3 } } } }
        { 14 { { 1 { 0 } } { 6 { 5 3 } } } }
        { 15 { { 1 { 0 } } { 6 { 5 3 4 } } } }
        { 16 { { 1 { 0 } } { 6 { 5 3 4 2 } } } }
        { 17 { { 1 { 0 } } { 6 { 5 3 4 2 1 } } } }
        { 18 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 19 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 20 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 21 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 22 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 23 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 24 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 25 { { 1 { 0 } } { 6 { 5 3 4 2 1 0 } } } }
        { 26 { { 3 { 2 } } { 6 { 5 3 4 2 1 0 } } } }
        { 27 { { 3 { 2 } } { 1 { 0 } } } }
        { 28 { { 3 { 2 } } { 1 { 0 } } } }
        { 29 { { 3 { 2 } } { 1 { 0 } } } }
        { 30 { { 0 { } } { 1 { 0 } } } }
        { 31 { { 1 { } } { 1 { 0 } } } }
        { 32 { { 1 { } } { 0 { } } } }
    }
} [ bug1289-cfg trace-stack-state2 ] unit-test

! following-stack-state
{
    { { 0 { } } { 0 { } } }
} [ V{ } following-stack-state ] unit-test

{
    { { 1 { } } { 0 { } } }
} [ V{ T{ ##inc f D 1 } } following-stack-state ] unit-test

{
    { { 0 { } } { 1 { } } }
} [ V{ T{ ##inc f R 1 } } following-stack-state ] unit-test

! Here the peek refers to a parameter of the word.
{
    { { 0 { 25 } } { 0 { } } }
} [
    V{
        T{ ##peek { loc D 25 } }
    } following-stack-state
] unit-test

! Should be ok because the value was at 0 when the gc ran.
{
    { { -1 { -1 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##inc f D -1 }
        T{ ##peek { loc D -1 } }
    } following-stack-state
] unit-test

{
    { { 0 { 0 1 2 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##replace { src 10 } { loc D 1 } }
        T{ ##replace { src 10 } { loc D 2 } }
    } following-stack-state
] unit-test

{
    { { 1 { 1 0 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc f D 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } following-stack-state
] unit-test

{
    { { 0 { 0 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc f D 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc f D -1 }
    } following-stack-state
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{
        T{ ##inc f D 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc f D -1 }
    } following-stack-state
] unit-test

! ##call clears the overinitialized slots.
{
    { { -1 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc f D -1 }
        T{ ##call { height 0 } }
    } following-stack-state
] unit-test

! Should not be ok because the value wasn't initialized when gc ran.
[
    V{
        T{ ##inc f D 1 }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##peek { loc D 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc f D 1 }
        T{ ##peek { loc D 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc f R 1 }
        T{ ##peek { loc R 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with
