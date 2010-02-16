USING: help.markup help.syntax strings ;
IN: vocabs.metadata

ARTICLE: "vocabs.metadata" "Vocabulary metadata"
"Vocabulary summaries:"
{ $subsections
    vocab-summary
    set-vocab-summary
}
"Vocabulary authors:"
{ $subsections
    vocab-authors
    set-vocab-authors
}
"Vocabulary tags:"
{ $subsections
    vocab-tags
    set-vocab-tags
    add-vocab-tags
}
"Vocabulary resources:"
{ $subsections
    vocab-resources
    set-vocab-resources
}
"Getting and setting arbitrary vocabulary metadata:"
{ $subsections
    vocab-file-contents
    set-vocab-file-contents
} ;

ABOUT: "vocabs.metadata"

HELP: vocab-file-contents
{ $values { "vocab" "a vocabulary specifier" } { "name" string } { "seq" "a sequence of lines, or " { $link f } } }
{ $description "Outputs the contents of the file named " { $snippet "name" } " from the vocabulary's directory, or " { $link f } " if the file does not exist." } ;

HELP: set-vocab-file-contents
{ $values { "seq" "a sequence of lines" } { "vocab" "a vocabulary specifier" } { "name" string } }
{ $description "Stores a sequence of lines to the file named " { $snippet "name" } " from the vocabulary's directory." } ;

HELP: vocab-summary
{ $values { "vocab" "a vocabulary specifier" } { "summary" "a string or " { $link f } } }
{ $description "Outputs a one-line string description of the vocabulary's intended purpose from the " { $snippet "summary.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: set-vocab-summary
{ $values { "string" "a string or " { $link f } } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a one-line string description of the vocabulary to the " { $snippet "summary.txt" } " file in the vocabulary's directory." } ;

HELP: vocab-tags
{ $values { "vocab" "a vocabulary specifier" } { "tags" "a sequence of strings" } }
{ $description "Outputs a list of short tags classifying the vocabulary from the " { $snippet "tags.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: set-vocab-tags
{ $values { "tags" "a sequence of strings" } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a list of short tags classifying the vocabulary to the " { $snippet "tags.txt" } " file in the vocabulary's directory." } ;

HELP: vocab-resources
{ $values { "vocab" "a vocabulary specifier" } { "patterns" "a sequence of glob patterns" } }
{ $description "Outputs a list of glob patterns matching files that will be deployed with an application that includes " { $snippet "vocab" } ", as specified by the " { $snippet "resources.txt" } " file in the vocabulary's directory. Outputs an empty array if the file doesn't exist." }
{ $notes "The " { $vocab-link "vocabs.metadata.resources" } " vocabulary contains words that will expand the glob patterns and directory names in " { $snippet "patterns" } " and return all the matching files." } ;

HELP: set-vocab-resources
{ $values { "patterns" "a sequence of glob patterns" } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a list of glob patterns matching files that will be deployed with an application that includes " { $snippet "vocab" } " to the " { $snippet "resources.txt" } " file in the vocabulary's directory." } ;
