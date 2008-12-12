USING: ui.gadgets help.markup help.syntax kernel quotations
continuations debugger ui ;
IN: ui.tools.debugger

HELP: <debugger>
{ $values { "error" "an error" } { "restarts" "a sequence of " { $link restart } " instances" } { "restart-hook" { $quotation "( list -- )" } } { "gadget" "a new " { $link gadget } } }
{ $description
    "Creates a gadget displaying a description of the error, along with buttons to print the contents of the stacks in the listener, and a list of restarts."
} ;

{ <debugger> debugger-window } related-words

HELP: debugger-window
{ $values { "error" "an error" } }
{ $description "Opens a window with a description of the error." } ;
