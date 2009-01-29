! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup io strings xml.data ;
IN: xml.writer

ABOUT: "xml.writer"

ARTICLE: "xml.writer" "Writing XML"
    "These words are used to print XML preserving whitespace in text nodes"
    { $subsection write-xml }
    { $subsection xml>string }
    "These words are used to prettyprint XML"
    { $subsection pprint-xml>string }
    { $subsection pprint-xml }
    "Certain variables can be changed to mainpulate prettyprinting"
    { $subsection sensitive-tags }
    { $subsection indenter }
    "All of these words operate on arbitrary pieces of XML: they can take, as in put, XML documents, comments, tags, strings (text nodes), XML chunks, etc." ;

HELP: xml>string
{ $values { "xml" "an XML document" } { "string" "a string" } }
{ $description "This converts an XML document " { $link xml } " into a string. It can also be used to convert any piece of XML to a string, eg an " { $link xml-chunk } " or " { $link comment } "." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: pprint-xml>string
{ $values { "xml" "an XML document" } { "string" "a string" } }
{ $description "converts an XML document into a string in a prettyprinted form." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: write-xml
{ $values { "xml" "an XML document" } }
{ $description "prints the contents of an XML document to " { $link output-stream } "." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. The whitespace in the text nodes of the original document is preserved." } ;

HELP: pprint-xml
{ $values { "xml" "an XML document" } }
{ $description "prints the contents of an XML document to " { $link output-stream } " in a prettyprinted form." }
{ $notes "This does not preserve what type of quotes were used or what data was omitted from version declaration, as that information isn't present in the XML data representation. Whitespace is also not preserved." } ;

{ xml>string write-xml pprint-xml pprint-xml>string } related-words

