USING: help.markup help.syntax io.encodings strings ;
IN: io.encodings.utf16

ARTICLE: "io.encodings.utf16" "UTF-16"
"The UTF-16 encoding is a variable-width encoding. Unicode code points are encoded as 2 or 4 byte sequences. There are three encoding descriptor classes for working with UTF-16, depending on endianness or the presence of a BOM:"
{ $subsection utf16 }
{ $subsection utf16le }
{ $subsection utf16be }
{ $subsection utf16n } ;

ABOUT: "io.encodings.utf16"

HELP: utf16le
{ $class-description "The encoding descriptor for UTF-16LE, that is, UTF-16 in little endian, without a byte order mark. Streams can be made which read or write wth this encoding." } ;

HELP: utf16be
{ $class-description "The encoding descriptor for UTF-16BE, that is, UTF-16 in big endian, without a byte order mark. Streams can be made which read or write wth this encoding." } ;

HELP: utf16
{ $class-description "The encoding descriptor for UTF-16, that is, UTF-16 with a byte order mark. This is the most useful for general input and output in UTF-16. Streams can be made which read or write wth this encoding." } ;

HELP: utf16n
{ $class-description "The encoding descriptor for UTF-16 without a byte order mark in native endian order. This is useful mostly for FFI calls which take input of strings in of wide_t*." } ;

{ utf16 utf16le utf16be utf16n } related-words
