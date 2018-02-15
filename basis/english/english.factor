! Copyright (C) 2015, 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: arrays accessors assocs assocs.extras combinators fry formatting kernel
literals locals math math.parser sequences splitting words unicode ;
USE: help.markup

IN: english

<PRIVATE

<<
! Irregular pluralizations
CONSTANT: singular-to-plural H{

    ! us -> i
    { "alumnus" "alumni" }
    { "cactus" "cacti" }
    { "octopus" "octopi" }
    { "focus" "foci" }
    { "fungus" "fungi" }
    { "nucleus" "nuclei" }
    { "radius" "radii" }
    { "stimulus" "stimuli" }

    ! is -> es
    { "analysis" "analyses" }
    { "axis" "axes" }
    { "basis" "bases" }
    { "crisis" "crises" }
    { "diagnosis" "diagnoses" }
    { "ellipsis" "ellipses" }
    { "hypothesis" "hypotheses" }
    { "oasis" "oases" }
    { "paralysis" "paralyses" }
    { "parenthesis" "parentheses" }
    { "synopsis" "synopses" }
    { "synthesis" "syntheses" }
    { "thesis" "theses" }

    ! ix -> ices
    { "appendix" "appendices" }
    { "index" "indices" }
    { "matrix" "matrices" }

    ! eau -> eaux
    { "beau" "beaux" }
    { "bureau" "bureaus" }
    { "tableau" "tableaux" }

    ! ? -> en
    { "child" "children" }
    { "man" "men" }
    { "ox" "oxen" }
    { "woman" "women" }

    ! ? -> a
    { "bacterium" "bacteria" }
    { "corpus" "corpora" }
    { "criterion" "criteria" }
    { "curriculum" "curricula" }
    { "datum" "data" }
    { "genus" "genera" }
    { "medium" "media" }
    { "memorandum" "memoranda" }
    { "phenomenon" "phenomena" }
    { "stratum" "strata" }

    ! no change
    { "bison" "bison" }
    { "deer" "deer" }
    { "fish" "fish" }
    { "means" "means" }
    { "moose" "moose" }
    { "offspring" "offspring" }
    { "series" "series" }
    { "sheep" "sheep" }
    { "species" "species" }
    { "swine" "swine" }

    ! oo -> ee
    { "foot" "feet" }
    { "goose" "geese" }
    { "tooth" "teeth" }

    ! a -> ae
    { "antenna" "antennae" }
    { "formula" "formulae" }
    { "nebula" "nebulae" }
    { "vertebra" "vertebrae" }
    { "vita" "vitae" }

    ! ouse -> ice
    { "louse" "lice" }
    { "mouse" "mice" }
}
>>

CONSTANT: plural-to-singular $[ singular-to-plural assoc-invert ]

:: match-case ( master disciple -- master' )
    {
        { [ master >lower master = ] [ disciple >lower ] }
        { [ master >upper master = ] [ disciple >upper ] }
        { [ master >title master = ] [ disciple >title ] }
        [ disciple ]
    } cond ;

PRIVATE>

: singularize ( word -- singular )
    dup >lower {
        { [ dup empty? ] [ ] }
        { [ dup singular-to-plural key? ] [ ] }
        { [ plural-to-singular ?at ] [ ] }
        { [ dup "s" tail? not ] [ ] }
        {
            [
                dup "ies" ?tail [
                    last "aeiou" member? not
                ] [ drop f ] if
            ] [ 3 head* "y" append ]
        }
        { [ dup "es" tail? ] [ 2 head* ] }
        [ but-last ]
    } cond match-case ;

: pluralize ( word -- plural )
    dup >lower {
        { [ dup empty? ] [ ] }
        { [ dup plural-to-singular key? ] [ ] }
        { [ singular-to-plural ?at ] [ ] }
        {
            [
                dup "y" ?tail [
                    last "aeiou" member? not
                ] [ drop f ] if
            ] [ but-last "ies" append ]
        }
        {
            [ dup { "s" "ch" "sh" } [ tail? ] with any? ]
            [ dup "es" tail? [ "es" append ] unless ]
        }
        [ "s" append ]
    } cond match-case ;

: singular? ( word -- ? )
    [ singularize ] [ = ] bi ;

: plural? ( word -- ? )
    [ singularize pluralize ] [ = ] bi ;

: count-of-things ( count word -- str )
    over 1 = [ pluralize ] unless [ number>string ] dip " " glue ;

: ?pluralize ( count singular -- singular/plural )
    swap 1 = [ pluralize ] unless ;

: a10n ( word -- numeronym )
    dup length 3 > [
        [ 1 head ] [ length 2 - number>string ] [ 1 tail* ] tri
        3append
    ] when ;

: a/an ( word -- article )
    [ first ] [ length ] bi 1 = "afhilmnorsx" "aeiou" ?
    member? "an" "a" ? ;

: ?plural-article ( word -- article )
    dup singular? [ a/an ] [ drop "the" ] if ;

: comma-list ( parts conjunction  -- clause-seq )
    [
        V{ } clone [
            [ '[ ", " _ push ] ] [ '[ _ push ] ] bi interleave
        ] keep { } like
    ] dip over length dup 3 >= [
        [ 3 > ", " " " ? " " surround ] [ 2 - pick set-nth ] bi
    ] [ 2drop ] if ;

: or-markup-example ( classes -- markup )
    [
        dup word? [
            [ name>> a/an " " append ] [ \ $link swap 2array ] bi 2array
        ] [
            [ "\"" ?head drop a/an ] keep 1array \ $snippet prefix " " swap 3array
        ] if
    ] map "or" comma-list ;

: $or-markup-example ( classes -- )
    or-markup-example print-element ;
