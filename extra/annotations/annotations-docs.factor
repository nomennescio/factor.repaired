USING: accessors arrays combinators definitions generalizations
help help.markup help.topics kernel sequences sorting vocabs
words ;
IN: annotations

<PRIVATE
: comment-word ( base -- word ) "!" prepend "annotations" lookup ; 
: comment-usage-word ( base -- word ) "s" append "annotations" lookup ; 
: comment-usage.-word ( base -- word ) "s." append "annotations" lookup ; 
PRIVATE>

: $annotation ( element -- )
    P first
    [ "!" " your comment here" surround 1array $syntax ]
    [ [ "Treats the rest of the line after the exclamation point as a code annotation that can be looked up with the " \ $link ] dip comment-usage.-word 2array " word." 3array $description ]
    [ ": foo ( x y z -- w )\n    !" " --w-ó()ò-w-- kilroy was here\n    + * ;" surround 1array $unchecked-example ]
    tri ;

: $annotation-usage. ( element -- )
    first
    [ "Displays a list of words, help articles, and vocabularies that contain " \ $link ] dip comment-word 2array " annotations." 3array $description ;

: $annotation-usage ( element -- )
    first
    { "usages" sequence } $values
    [ "Returns a list of words, help articles, and vocabularies that contain " \ $link ] dip [ comment-word 2array " annotations. For a more user-friendly display, use the " \ $link ] [ comment-usage.-word 2array " word." 6 narray ] bi 1array $description ;

"Code annotations"
{
    "The " { $vocab-link "annotations" } " vocabulary provides syntax for comment-like annotations that can be looked up with Factor's " { $link usage } " mechanism."
}
annotation-tags natural-sort
[
    [ \ $subsection swap comment-word 2array ] map append
    "To look up annotations:" suffix
] [
    [ \ $subsection swap comment-usage.-word 2array ] map append
] bi
<article> "annotations" add-article

"annotations" vocab "annotations" >>help drop

annotation-tags [
    {
        [ [ \ $annotation swap 2array 1array ] [ comment-word set-word-help ] bi ]
        [ [ \ $annotation-usage swap 2array 1array ] [ comment-usage-word set-word-help ] bi ]
        [ [ \ $annotation-usage. swap 2array 1array ] [ comment-usage.-word set-word-help ] bi ]
        [ [ comment-word ] [ comment-usage-word ] [ comment-usage.-word ] tri 3array related-words ]
    } cleave
] each
