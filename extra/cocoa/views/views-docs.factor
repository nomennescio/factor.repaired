USING: help.syntax help.markup ;
IN: cocoa.views

HELP: <PixelFormat>
{ $values { "pixelfmt" "an " { $snippet "NSOpenGLPixelFormat" } } }
{ $description "Creates an " { $snippet "NSOpenGLPixelFormat" } " with some reasonable defaults." } ;

HELP: <GLView>
{ $values { "class" "an subclass of " { $snippet "NSOpenGLView" } } { "dim" "a pair of real numbers" } { "view" "a new " { $snippet "NSOpenGLView" } } }
{ $description "Creates a new instance of the specified class, giving it a default pixel format and the given size." } ;

HELP: view-dim
{ $values { "view" "an " { $snippet "NSView" } } { "dim" "a pair of real numbers" } }
{ $description "Outputs the dimensions of the given view." } ;

HELP: mouse-location
{ $values { "view" "an " { $snippet "NSView" } } { "event" "an " { $snippet "NSEvent" } } { "loc" "a pair of real numbers" } }
{ $description "Outputs the current mouse location." } ;

ARTICLE: "cocoa-view-utils" "Cocoa view utilities"
{ $subsection <PixelFormat> }
{ $subsection <GLView> }
{ $subsection view-dim }
{ $subsection mouse-location } ;

IN: cocoa.views
ABOUT: "cocoa-view-utils"
