USING: assocs help.markup help.syntax kernel kernel.private quotations
sequences stack-checker.alien stack-checker.values
stack-checker.visitor words ;
IN: compiler.tree

HELP: node
{ $class-description "Base class for all SSA tree nodes." } ;

HELP: #alien-node
{ $class-description "Base class for alien nodes. Its " { $snippet "params" } " slot holds an instance of the " { $link alien-node-params } " class." } ;

HELP: #alien-invoke
{ $class-description "SSA tree node that calls a function in a dynamically linked library." } ;

HELP: #alien-callback
{ $class-description "SSA tree node that constructs an alien callback." } ;

HELP: #call
{ $class-description "SSA tree node that calls a word. It has the following slots:"
  { $table
    { { $slot "word" } { "The " { $link word } " to call." } }
    { { $slot "in-d" } { "Sequence of input variables to the call. The items are ordered from top to bottom of the stack." } }
    { { $slot "out-d" } { "Output values of the call." } }
    { { $slot "method" } { "If the called word is generic and inlined here, then 'method' contains the inlined " { $link quotation } "." } }
    { { $slot "body" } { "If the called word is generic and inlined, then 'body' is a sequence of SSA nodes built from the inlined method." } }
    { { $slot "info" } { "If the called word is generic and inlined, then the info slot contains an assoc of value infos for the body of the inlined generic. It is set during the propagation pass of the optimizer." } }
  }
} ;

HELP: #declare
{ $class-description "SSA tree node emitted when " { $link declare } " declarations are encountered." } ;

HELP: #introduce
{ $class-description "SSA tree node that puts an input value from the \"outside\" on the stack. It is used to \"introduce\" data stack parameter whenever they are needed. It has the following slots:"
  { $table
    { { $slot "out-d" } { "Array of values of the parameters being introduced." } }
  }
} ;

HELP: #push
{ $class-description "SSA tree node that puts a literal value on the stack. It has the following slots:"
  { $table
    { { $slot "out-d" } { "A one item array containing the " { $link <value> } " of the literal being pushed." } }
  }
}
{ $notes "A " { $link quotation } " is also a literal." } ;

HELP: #shuffle
{ $class-description "SSA tree node that represents a stack shuffling operation such as " { $link swap } ". It has the following slots:"
  { $table
    { { $slot "mapping" } { "An " { $link assoc } " that shows how the shuffle output values (the keys) correspond to their inputs (the values)." } }
  }
} ;

HELP: #if
{ $class-description "SSA tree node that implements conditional branching. It has the following slots:"
  { $table
    { { $slot "children" }
      { "A two item " { $link sequence } ". The first item holds the instructions executed if the condition is true and the second those that are executed if it is not true." }
    }
  }
} ;

HELP: node,
{ $values { "node" node } }
{ $description "Emits a node to the " { $link stack-visitor } " variable." } ;

ARTICLE: "compiler.tree" "High-level optimizer operating on lexical tree SSA IR"
"Node types:"
{ $subsections
  #call
  #declare
  #shuffle
} ;

ABOUT: "compiler.tree"
