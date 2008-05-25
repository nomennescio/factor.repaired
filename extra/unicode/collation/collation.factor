USING: sequences io.files io.encodings.ascii kernel values
splitting accessors math.parser ascii io assocs strings math
namespaces sorting combinators math.order arrays
unicode.normalize unicode.data combinators.lib locals
unicode.syntax macros sequences.deep words unicode.breaks
quotations ;
IN: unicode.collation

VALUE: ducet

TUPLE: weight primary secondary tertiary ignorable? ;

: parse-weight ( string -- weight )
    "]" split but-last [
        weight new swap rest unclip CHAR: * = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-line ( line -- code-poing weight )
    ";" split1 [ [ blank? ] trim ] bi@
    [ " " split [ hex> ] "" map-as ] [ parse-weight ] bi* ;

: parse-ducet ( stream -- ducet )
    lines filter-comments
    [ parse-line ] H{ } map>assoc ;

"resource:extra/unicode/collation/allkeys.txt"
ascii <file-reader> parse-ducet \ ducet set-value

: base ( char -- base )
    {
        { [ dup HEX: 3400 HEX:  4DB5 between? ] [ drop HEX: FB80 ] } ! Extension A
        { [ dup HEX: 20000 HEX: 2A6D6 between? ] [ drop HEX: FB80 ] } ! Extension B
        { [ dup HEX: 4E00 HEX: 9FC3 between? ] [ drop HEX: FB40 ] } ! CJK
        [ drop HEX: FBC0 ] ! Other
    } cond ;

: AAAA ( char -- weight )
    [ base ] [ -15 shift ] bi + HEX: 20 2 f weight boa ;

: BBBB ( char -- weight )
    HEX: 7FFF bitand HEX: 8000 bitor 0 0 f weight boa ;

: illegal? ( char -- ? )
    [ "Noncharacter_Code_Point" property? ]
    [ category "Cs" = ] or? ;

: derive-weight ( char -- weights )
    first dup illegal?
    [ drop { } ]
    [ [ AAAA ] [ BBBB ] bi 2array ] if ;

: last ( -- char )
    building get empty? [ 0 ] [ building get peek peek ] if ;

: blocked? ( char -- ? )
    combining-class [
        last combining-class =
    ] [ last combining-class ] if* ;

: possible-bases ( -- slice-of-building )
    building get dup [ first combining-class not ] find-last
    drop [ 0 ] unless* tail-slice ;

:: ?combine ( char slice i -- ? )
    [let | str [ i slice nth char suffix ] |
        str ducet key? dup
        [ str i slice set-nth ] when
    ] ;

: add ( char -- )
    dup blocked? [ 1string , ] [
        dup possible-bases dup length
        [ ?combine ] 2with contains?
        [ drop ] [ 1string , ] if
    ] if ;

! The terminator method for Hangul syllables
: terminator 1 0 0 f weight boa ;

MACRO: const ( seq -- seq )
    [ dup word? [ execute ] when ] deep-map 1quotation ;

: char, ( char -- )
    [
        building get peek [ first ] bi@ dup jamo? [
            over jamo? [
                [ grapheme-class ] bi@ swap 2array
                { { T L } { V L } { V T } } const
                member? [ terminator , ] when
            ] [ 2drop terminator , ] if
        ] [ 2drop ] if
    ] [ , ] bi ;

: insert-terminators ( graphemes -- graphemes )
    ! Insert a terminator between hangul syllables
    [ unclip , [ char, ] each ] { } make ;
! The above code for the terminator method is not used
! The test suite passes without it

: string>graphemes ( string -- graphemes )
    [ [ add ] each ] { } make ;

: graphemes>weights ( graphemes -- weights )
    [
        dup weight? [ 1array ] ! From tailoring
        [ dup ducet at [ ] [ derive-weight ] ?if ] if
    ] { } map-as concat ;

: append-weights ( weights quot -- )
    swap [ ignorable?>> not ] filter
    swap map [ zero? not ] filter % 0 , ;

: variable-weight ( weight -- )
    dup ignorable?>> [ primary>> ] [ drop HEX: FFFF ] if , ;

: weights>bytes ( weights -- byte-array )
    [
        {
            [ [ primary>> ] append-weights ]
            [ [ secondary>> ] append-weights ]
            [ [ tertiary>> ] append-weights ]
            [ [ variable-weight ] each ]
        } cleave
    ] { } make ;

: completely-ignorable? ( weight -- ? )
    [ primary>> ] [ secondary>> ] [ tertiary>> ] tri
    [ zero? ] tri@ and and ;

: filter-ignorable ( weights -- weights' )
    >r f r> [
        tuck primary>> zero? and
        [ swap ignorable?>> or ]
        [ swap completely-ignorable? or not ] 2bi
    ] filter nip ;

: collation-key ( string -- key )
    nfd string>graphemes graphemes>weights
    filter-ignorable weights>bytes ;

: compare-collation ( {str1,key} {str2,key} -- <=> )
    2dup [ second ] bi@ <=> dup +eq+ =
    [ drop <=> ] [ 2nip ] if ;

: sort-strings ( strings -- sorted )
    [ dup collation-key ] { } map>assoc
    [ compare-collation ] sort
    keys ;

: string<=> ( str1 str2 -- <=> )
    [ dup collation-key 2array ] bi@ compare-collation ;

! Fix up table for long contractions
: help-one ( assoc key -- )
    ! Does this need to be more general?
    2 head 2dup swap key? [ 2drop ] [
        [ [ 1string swap at ] with { } map-as concat ]
        [ swap set-at ] 2bi
    ] if ;

: insert-helpers ( assoc -- )
    dup keys [ length 3 >= ] filter
    [ help-one ] with each ;

ducet insert-helpers
