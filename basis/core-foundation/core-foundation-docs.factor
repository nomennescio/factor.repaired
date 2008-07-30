USING: alien strings arrays help.markup help.syntax destructors ;
IN: core-foundation

HELP: CF>array
{ $values { "alien" "a " { $snippet "CFArray" } } { "array" "an array of " { $link alien } " instances" } }
{ $description "Creates a Factor array from a Core Foundation array." } ;

HELP: <CFArray>
{ $values { "seq" "a sequence of " { $link alien } " instances" } { "alien" "a " { $snippet "CFArray" } } }
{ $description "Creates a Core Foundation array from a Factor array." } ;

HELP: <CFString>
{ $values { "string" string } { "alien" "a " { $snippet "CFString" } } }
{ $description "Creates a Core Foundation string from a Factor string." } ;

HELP: CF>string
{ $values { "alien" "a " { $snippet "CFString" } } { "string" string } }
{ $description "Creates a Factor string from a Core Foundation string." } ;

HELP: CF>string-array
{ $values { "alien" "a " { $snippet "CFArray" } " of " { $snippet "CFString" } " instances" } { "seq" string } }
{ $description "Creates an array of Factor strings from a " { $snippet "CFArray" } " of " { $snippet "CFString" } "s." } ;

HELP: <CFFileSystemURL>
{ $values { "string" "a pathname string" } { "dir?" "a boolean indicating if the pathname is a directory" } { "url" "a " { $snippet "CFURL" } } }
{ $description "Creates a new " { $snippet "CFURL" } " pointing to the given local pathname." } ;

HELP: <CFURL>
{ $values { "string" "a URL string" } { "url" "a " { $snippet "CFURL" } } }
{ $description "Creates a new " { $snippet "CFURL" } "." } ;

HELP: <CFBundle>
{ $values { "string" "a pathname string" } { "bundle" "a " { $snippet "CFBundle" } } }
{ $description "Creates a new " { $snippet "CFBundle" } "." } ;

HELP: load-framework
{ $values { "name" "a pathname string" } }
{ $description "Loads a Core Foundation framework." } ;

HELP: &CFRelease
{ $values { "alien" "Pointer to a Core Foundation object" } }
{ $description "Marks the given Core Foundation object for unconditional release via " { $link CFRelease } " at the end of the enclosing " { $link with-destructors } " scope." } ;

HELP: |CFRelease
{ $values { "interface" "Pointer to a Core Foundation object" } }
{ $description "Marks the given Core Foundation object for release via " { $link CFRelease } " in the event of an error at the end of the enclosing " { $link with-destructors } " scope." } ;

{ CFRelease |CFRelease &CFRelease } related-words

ARTICLE: "core-foundation" "Core foundation utilities"
"The " { $vocab-link "core-foundation" } " vocabulary defines bindings for some frequently-used Core Foundation functions. It also provides some utility words."
$nl
"Strings:"
{ $subsection <CFString> }
{ $subsection CF>string }
"Arrays:"
{ $subsection <CFArray> }
{ $subsection CF>array }
{ $subsection CF>string-array }
"URLs:"
{ $subsection <CFFileSystemURL> }
{ $subsection <CFURL> }
"Frameworks:"
{ $subsection load-framework }
"Memory management:"
{ $subsection &CFRelease }
{ $subsection |CFRelease } ;

ABOUT: "core-foundation"
