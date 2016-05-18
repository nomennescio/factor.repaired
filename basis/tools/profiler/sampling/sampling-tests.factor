USING: byte-arrays calendar kernel math memory namespaces parser
random sequences threads tools.profiler.sampling
tools.profiler.sampling.private tools.test ;
IN: tools.profiler.sampling.tests

! Make sure the profiler doesn't blow up the VM
TUPLE: boom ;
{ } [ 10 [ [ ] profile ] times ] unit-test
[ 10 [ [ boom new throw ] profile ] times ] [ boom? ] must-fail-with
{ } [ 10 [ [ 100 [ 1000 random (byte-array) drop ] times gc ] profile ] times ] unit-test
{ } [ 10 [ [ 100 [ 1000 random (byte-array) drop ] times compact-gc ] profile ] times ] unit-test
{ } [ 2 [ [ 1 seconds sleep ] profile ] times ] unit-test

{ } [ [ 300,000 iota [ sq sq sq ] map drop ] profile flat profile. ] unit-test
{ } [ [ 300,000 iota [ sq sq sq ] map drop ] profile top-down profile. ] unit-test

f raw-profile-data set-global
gc

{ t 0 } [
    ! Seed the samples data
    [ "resource:basis/tools/memory/memory.factor" run-file ] profile
    (get-samples) length 0 >
    ! Should clear it
    gc [ ] profile (get-samples) length
] unit-test
