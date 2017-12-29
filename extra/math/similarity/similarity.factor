! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.functions math.statistics math.vectors
sequences sequences.extras sets ;

IN: math.similarity

: euclidian-similarity ( a b -- n )
    v- norm 1 + recip ;

: pearson-similarity ( a b -- n )
    over length 3 < [ 2drop 1.0 ] [ population-corr 0.5 * 0.5 + ] if ;

: cosine-similarity ( a b -- n )
    [ v* sum ] [ [ norm ] bi@ * ] 2bi / 0.5 * 0.5 + ;

: jaccard-similarity ( a b -- n )
    [ intersect cardinality dup ]
    [ [ cardinality ] bi@ + swap - ] 2bi
    [ drop 0 ] [ /f ] if-zero ;

<PRIVATE

: weighted-v. ( w a b -- n )
    [ * * ] [ + ] 3map-reduce ;

: weighted-norm ( w a -- n )
    [ absq * ] [ + ] 2map-reduce ;

PRIVATE>

: weighted-cosine-similarity ( w a b -- n )
    [ weighted-v. ]
    [ [ over ] dip [ weighted-norm ] 2bi@ * ] 3bi / ;
