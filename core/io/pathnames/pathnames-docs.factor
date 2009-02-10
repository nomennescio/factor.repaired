USING: help.markup help.syntax io.backend io.files io.directories strings ;
IN: io.pathnames

HELP: path-separator?
{ $values { "ch" "a code point" } { "?" "a boolean" } }
{ $description "Tests if the code point is a platform-specific path separator." }
{ $examples
    "On Unix:"
    { $example "USING: io.pathnames prettyprint ;" "CHAR: / path-separator? ." "t" }
} ;

HELP: parent-directory
{ $values { "path" "a pathname string" } { "parent" "a pathname string" } }
{ $description "Strips the last component off a pathname." }
{ $examples { $example "USING: io io.pathnames ;" "\"/etc/passwd\" parent-directory print" "/etc/" } } ;

HELP: file-name
{ $values { "path" "a pathname string" } { "string" string } }
{ $description "Outputs the last component of a pathname string." }
{ $examples
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/bin/gcc\" file-name ." "\"gcc\"" }
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/libexec/awk/\" file-name ." "\"awk\"" }
} ;

HELP: append-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Appends " { $snippet "str1" } " and " { $snippet "str2" } " to form a pathname." } ;

HELP: prepend-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Appends " { $snippet "str2" } " and " { $snippet "str1" } " to form a pathname." } ;

{ append-path prepend-path } related-words

HELP: absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute. Examples of absolute pathnames are " { $snippet "/foo/bar" } " on Unix and " { $snippet "c:\\foo\\bar" } " on Windows." } ;

HELP: windows-absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute on Windows. Examples of absolute pathnames on Windows are " { $snippet "c:\\foo\\bar" } " and " { $snippet "\\\\?\\c:\\foo\\bar" } " for absolute Unicode pathnames." } ;

HELP: root-directory?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is a root directory. Examples of root directory pathnames are " { $snippet "/" } " on Unix and " { $snippet "c:\\" } " on Windows." } ;

{ absolute-path? windows-absolute-path? root-directory? } related-words

HELP: resource-path
{ $values { "path" "a pathname string" } { "newpath" "a pathname string" } }
{ $description "Resolve a path relative to the Factor source code location." } ;

HELP: pathname
{ $class-description "Class of path name objects. Path name objects can be created by calling " { $link <pathname> } "." } ;

HELP: normalize-path
{ $values { "str" "a pathname string" } { "newstr" "a new pathname string" } }
{ $description "Prepends the " { $link current-directory } " to the pathname, resolves a " { $snippet "resource:" } " prefix, if present, and performs any platform-specific pathname normalization." }
{ $notes "High-level words, such as " { $link <file-reader> } " and " { $link delete-file } " call this word for you. It only needs to be called directly when passing pathnames to C functions or external processes. This is because Factor does not use the operating system's notion of a current directory, and instead maintains its own dynamically-scoped " { $link current-directory } " variable." }
{ $examples
  "For example, if you create a file named " { $snippet "data.txt" } " in the current directory, and wish to pass it to a process, you must normalize it:"
  { $code
    "\"1 2 3\" \"data.txt\" ascii set-file-contents"
    "\"munge\" \"data.txt\" normalize-path 2array run-process"
  }
} ;

HELP: <pathname>
{ $values { "string" "a pathname string" } { "pathname" pathname } }
{ $description "Creates a new " { $link pathname } "." } ;

HELP: home
{ $values { "dir" string } }
{ $description "Outputs the user's home directory." } ;

ARTICLE: "io.pathnames" "Pathname manipulation"
"Pathname manipulation:"
{ $subsection parent-directory }
{ $subsection file-name }
{ $subsection last-path-separator }
{ $subsection append-path }
"Pathname presentations:"
{ $subsection pathname }
{ $subsection <pathname> }
"Literal pathnames:"
{ $subsection POSTPONE: P" }
"Low-level word:"
{ $subsection normalize-path } ;

ABOUT: "io.pathnames"
