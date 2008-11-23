USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces vocabs sequences
parser vocabs.loader vocabs.loader.private accessors assocs ;
IN: bootstrap.help

: load-help ( -- )
    "alien.syntax" require
    "compiler" require

    t load-help? set-global

    [ drop ] load-vocab-hook [
        dictionary get values
        [ docs-loaded?>> not ] filter
        [ load-docs ] each
    ] with-variable ;

load-help
