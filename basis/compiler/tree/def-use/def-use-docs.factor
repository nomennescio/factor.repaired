USING: compiler.tree compiler.tree.def-use help.markup
help.syntax sequences ;
IN: compiler.tree.def-use+docs

HELP: node-defs-values
{ $values { "node" node } { "values" sequence } }
{ $description "The sequence of values the node introduces." } ;

ARTICLE: "compiler.tree.def-use" "Def/use chain construction"
"Def/use chain construction" ;

ABOUT: "compiler.tree.def-use"
