! Copyright (C) 2008 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string ;
IN: http.server.static

HELP: <file-responder>
{ $values { "root" "a pathname string" } { "hook" "a quotation with stack effect " { $snippet "( path mime-type -- response )" } } { "responder" file-responder } }
{ $description "Creates a file responder which serves content from " { $snippet "path" } " by using the hook to generate a response." } ;

HELP: <static>
{ $values
     { "root" "a pathname string" }
     { "responder" file-responder } }
 { $description "Creates a file responder which serves content from " { $snippet "path" } "." } ;

HELP: enable-fhtml
{ $values { "responder" file-responder } }
{ $description "Enables the responder to serve " { $snippet ".fhtml" } " files by running them." }
{ $notes "See " { $link "html.templates.fhtml" } "." }
{ $side-effects "responder" } ;

ARTICLE: "http.server.static" "Serving static content"
"The " { $vocab-link "http.server.static" } " vocabulary implements a responder for serving static files."
{ $subsection <static> }
"The static responder does not serve directory listings by default, as a security measure. Directory listings can be enabled by storing a true value in the " { $slot "allow-listings" } " slot."
$nl
"The static responder can be extended for dynamic content by associating quotations with MIME types in the hashtable stored in the " { $slot "special" } " slot. The quotations have stack effect " { $snippet "( path -- )" } "."
$nl
"A utility word uses the above feature to enable server-side " { $snippet ".fhtml" } " scripts, allowing a development style much like PHP:"
{ $subsection enable-fhtml }
"This feature is also used by " { $vocab-link "http.server.cgi" } " to run " { $snippet ".cgi" } " files."
$nl
"It is also possible to override the hook used when serving static files to the client:"
{ $subsection <file-responder> }
"The default just sends the file's contents with the request; " { $vocab-link "xmode.code2html.responder" } " provides an alternate hook which sends a syntax-highlighted version of the file." ;

ABOUT: "http.server.static"
