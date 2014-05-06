USING: compiler.cfg help.markup help.syntax vectors ;

HELP: basic-block
{ $class-description
  "Factors representation of a basic block in the cfg. A basic block is a sequence of instructions that always are executed sequentially and doesn't contain any branching. It has the following slots:"
  { $table
    { { $slot "successors" } { "A " { $link vector } " of basic blocks that may be executed directly after this block. Most blocks only have one successor but a block that checks where an if-condition should branch to would have two for example." } }
  }
} ;

HELP: <basic-block>
{ $values { "bb" basic-block } }
{ $description "Creates a new empty basic block." } ;
