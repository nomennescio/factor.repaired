USING: ui.gadgets ui.render ui.gestures ui.backend help.markup
help.syntax models opengl strings ;
IN: ui.gadgets.worlds

HELP: origin
{ $var-description "Within the dynamic extent of " { $link draw-world } ", holds the co-ordinate system origin for the gadget currently being drawn." } ;

HELP: hand-world
{ $var-description "Global variable. The " { $link world } " containing the gadget at the mouse location." } ;

HELP: set-title
{ $values { "string" string } { "world" world } }
{ $description "Sets the title bar of the native window containing the world." }
{ $notes "This word should not be called directly by user code. Instead, change the " { $snippet "title" } " slot model; see " { $link "models" } "." } ;

HELP: select-gl-context
{ $values { "handle" "a backend-specific handle" } }
{ $description "Selects an OpenGL context to be the implicit destination for subsequent GL rendering calls. This word is called automatically by the UI before drawing a " { $link world } "." } ;

HELP: flush-gl-context
{ $values { "handle" "a backend-specific handle" } }
{ $description "Ensures all GL rendering calls made to an OpenGL context finish rendering to the screen. This word is called automatically by the UI after drawing a " { $link world } "." } ;

HELP: focus-path
{ $values { "world" world } { "seq" "a new sequence" } }
{ $description "If the top-level window containing the world has focus, outputs a sequence of parents of the currently focused gadget, otherwise outputs " { $link f } "." }
{ $notes "This word is used to avoid sending " { $link gain-focus } " gestures to a gadget which requests focus on an unfocused top-level window, so that, for instance, a text editing caret does not appear in this case." } ;

HELP: world
{ $class-description "A gadget which appears at the top of the gadget hieararchy, and in turn may be displayed in a native window. Worlds have the following slots:"
    { $list
        { { $snippet "active?" } " - if set to " { $link f } ", the world will not be drawn. This slot is set to " { $link f } " if an error is thrown while drawing the world; this prevents multiple debugger windows from being shown." }
        { { $snippet "glass" } " - a glass pane in front of the primary gadget, used to implement behaviors such as popup menus which are hidden when the mouse is clicked outside the menu." }
        { { $snippet "title" } " - a string to be displayed in the title bar of the native window containing the world." }
        { { $snippet "status" } " - a " { $link model } " holding a string to be displayed in the world's status bar." }
        { { $snippet "focus" } " - the current owner of the keyboard focus in the world." }
        { { $snippet "focused?" } " - a boolean indicating if the native window containing the world has keyboard focus." }
        { { $snippet "fonts" } " - a hashtable mapping font instances to vectors of " { $link sprite } " instances." }
        { { $snippet "handle" } " - a backend-specific native handle representing the native window containing the world, or " { $link f } " if the world is not grafted." }
        { { $snippet "window-loc" } " - the on-screen location of the native window containing the world. The co-ordinate system here is backend-specific." }
    }
} ;

HELP: <world>
{ $values { "gadget" gadget } { "title" string } { "status" model } { "world" "a new " { $link world } } }
{ $description "Creates a new " { $link world } " delegating to the given gadget." } ;

HELP: find-world
{ $values { "gadget" gadget } { "world" "a " { $link world } " or " { $link f } } }
{ $description "Finds the " { $link world } " containing the gadget, or outputs " { $link f } " if the gadget is not grafted." } ;

HELP: draw-world
{ $values { "world" world } }
{ $description "Redraws a world." }
{ $notes "This word should only be called by the UI backend. To force a gadget to redraw from user code, call " { $link relayout-1 } "." } ;
