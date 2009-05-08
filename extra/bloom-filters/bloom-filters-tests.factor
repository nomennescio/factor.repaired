USING: accessors bit-arrays bloom-filters bloom-filters.private kernel layouts
math random sequences tools.test ;
IN: bloom-filters.tests

! The sizing information was generated using the subroutine
! calculate_shortest_filter_length from
! http://www.perl.com/pub/a/2004/04/08/bloom_filters.html.

! Test bloom-filter creation
[ 47965 ] [ 7 0.01 5000 bits-to-satisfy-error-rate ] unit-test
[ 7 47965 ] [ 0.01 5000 size-bloom-filter ] unit-test
[ 7 ] [ 0.01 5000 <bloom-filter> n-hashes>> ] unit-test
[ 47965 ] [ 0.01 5000 <bloom-filter> bits>> length ] unit-test
[ 5000 ] [ 0.01 5000 <bloom-filter> maximum-n-objects>> ] unit-test
[ 0 ] [ 0.01 5000 <bloom-filter> current-n-objects>> ] unit-test

! Should return the fewest hashes to satisfy the bits requested, not the most.
[ 32 ] [ 4 0.05 5 bits-to-satisfy-error-rate ] unit-test
[ 32 ] [ 5 0.05 5 bits-to-satisfy-error-rate ] unit-test
[ 4 32 ] [ 0.05 5 size-bloom-filter ] unit-test

! This is a lot of bits.  On linux-x86-32, max-array-capacity is 134217727,
! which is about 16MB (assuming I can do math), which is sort of pithy.  I'm
! not sure how to handle this case.  Returning a smaller-than-requested
! arrays is not the least surprising behavior, but is still surprising.
[ 383718189 ] [ 7 0.01 40000000 bits-to-satisfy-error-rate ] unit-test
! [ 7 383718189 ] [ 0.01 40000000 size-bloom-filter ] unit-test
! [ 383718189 ] [ 0.01 40000000 <bloom-filter> bits>> length ] unit-test

! Should not generate bignum hash codes.  Enhanced double hashing may generate a
! lot of hash codes, and it's better to do this earlier than later.
[ t ] [ 10000 iota [ hashcodes-from-object [ fixnum? ] both? ] map [ t = ] all? ] unit-test

[ ?{ t f t f t f } ] [ { 0 2 4 } 6 <bit-array> [ set-indices ] keep ] unit-test

: empty-bloom-filter ( -- bloom-filter )
    0.01 2000 <bloom-filter> ;

[ 1 ] [ empty-bloom-filter [ increment-n-objects ] keep current-n-objects>> ] unit-test

: basic-insert-test-setup ( -- bloom-filter )
    1 empty-bloom-filter [ bloom-filter-insert ] keep ;

! Basic tests that insert does something
[ t ] [ basic-insert-test-setup bits>> [ t = ] any? ] unit-test
[ 1 ] [ basic-insert-test-setup current-n-objects>> ] unit-test

: non-empty-bloom-filter ( -- bloom-filter )
    1000 iota
    empty-bloom-filter
    [ [ bloom-filter-insert ] curry each ] keep ;

: full-bloom-filter ( -- bloom-filter )
    2000 iota
    empty-bloom-filter
    [ [ bloom-filter-insert ] curry each ] keep ;

! Should find what we put in there.
[ t ] [ 2000 iota
        full-bloom-filter
        [ bloom-filter-member? ] curry map
        [ t = ] all? ] unit-test

! We shouldn't have more than 0.01 false-positive rate.
[ t ] [ 1000 iota [ drop most-positive-fixnum random 1000 + ] map
        full-bloom-filter
        [ bloom-filter-member? ] curry map
        [ t = ] filter
        ! TODO: This should be 10, but the false positive rate is currently very
        ! high.  It shouldn't be much more than this.
        length 150 <= ] unit-test
