! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup io.encodings.8-bit.private ;
IN: io.encodings.8-bit

ARTICLE: "io.encodings.8-bit" "8-bit encodings"
"Many encodings are a simple mapping of bytes onto characters. The " { $vocab-link "io.encodings.8-bit" } " vocabulary implements these generically using existing resource files. These encodings should be used with extreme caution, as fully general Unicode encodings like UTF-8 are nearly always more appropriate. The following 8-bit encodings are already defined:"
{ $subsection latin1 }
{ $subsection latin2 }
{ $subsection latin3 }
{ $subsection latin4 }
{ $subsection latin/cyrillic }
{ $subsection latin/arabic }
{ $subsection latin/greek }
{ $subsection latin/hebrew }
{ $subsection latin5 }
{ $subsection latin6 }
{ $subsection latin/thai }
{ $subsection latin7 }
{ $subsection latin8 }
{ $subsection latin9 }
{ $subsection latin10 }
{ $subsection koi8-r }
{ $subsection windows-1252 }
{ $subsection ebcdic }
{ $subsection mac-roman }
"Other encodings can be defined using the following utility"
{ $subsection define-8-bit-encoding } ;

ABOUT: "io.encodings.8-bit"

HELP: define-8-bit-encoding
{ $values { "name" "a string" } { "path" "a path" } }
{ $description "Creates a new encoding with the given name, using the resource file at the path to tell how to encode and decode octets. The resource file should be in a similar format to those at ftp://ftp.unicode.org/Public/MAPPINGS/ISO8859/" } ;

HELP: latin1
{ $description "This is the ISO-8859-1 encoding, also called Latin-1: Western European. It is an 8-bit superset of ASCII which is the default for a mimetype starting with 'text' and provides the characters necessary for most western European languages." } ;

HELP: latin2
{ $description "This is the ISO-8859-2 encoding, also called Latin-2: Eastern European. It is an 8-bit superset of ASCII and provides the characters necessary for most eastern European languages." } ;

HELP: latin3
{ $description "This is the ISO-8859-3 encoding, also called Latin-3: South European. It is an 8-bit superset of ASCII and provides the characters necessary for Turkish, Maltese and Esperanto." } ;

HELP: latin4
{ $description "This is the ISO-8859-4 encoding, also called Latin-4: North European. It is an 8-bit superset of ASCII and provides the characters necessary for Latvian, Lithuanian, Estonian, Greenlandic and Sami." } ;

HELP: latin/cyrillic
{ $description "This is the ISO-8859-5 encoding, also called Latin/Cyrillic. It is an 8-bit superset of ASCII and provides the characters necessary for most languages which use Cyrilic, including Russian, Macedonian, Belarusian, Bulgarian, Serbian, and Ukrainian. KOI8-R is used much more commonly." } ;

HELP: latin/arabic
{ $description "This is the ISO-8859-6 encoding, also called Latin/Arabic. It is an 8-bit superset of ASCII and provides the characters necessary for Arabic, though not other languages which use Arabic script." } ;

HELP: latin/greek
{ $description "This is the ISO-8859-7 encoding, also called Latin/Greek. It is an 8-bit superset of ASCII and provides the characters necessary for Greek written in modern monotonic orthography, or ancient Greek without accent marks." } ;

HELP: latin/hebrew
{ $description "This is the ISO-8859-8 encoding, also called Latin/Hebrew. It is an 8-bit superset of ASCII and provides the characters necessary for modern Hebrew without explicit vowels. Generally, this is interpreted in logical order, making it ISO-8859-8-I, technically." } ; 

HELP: latin5
{ $description "This is the ISO-8859-9 encoding, also called Latin-5: Turkish. It is an 8-bit superset of ASCII and provides the characters necessary for Turkish, similar to Latin-1 but replacing the spots used for Icelandic with characters used in Turkish." } ;

HELP: latin6
{ $description "This is the ISO-8859-10 encoding, also called Latin-6: Nordic. It is an 8-bit superset of ASCII containing the same characters as Latin-4, but rearranged to be of better use to nordic languages." } ;

HELP: latin/thai
{ $description "This is the ISO-8859-11 encoding, also called Latin/Thai. It is an 8-bit superset of ASCII containing the characters necessary to represent Thai. It is basically identical to TIS-620." } ;

HELP: latin7
{ $description "This is the ISO-8859-13 encoding, also called Latin-7: Baltic Rim. It is an 8-bit superset of ASCII containing all characters necesary to represent Baltic Rim languages, as previous character sets were incomplete." } ;

HELP: latin8
{ $description "This is the ISO-8859-14 encoding, also called Latin-8: Celtic. It is an 8-bit superset of ASCII designed for Celtic languages like Gaelic and Breton." } ;

HELP: latin9
{ $description "This is the ISO-8859-15 encoding, also called Latin-9 and unoffically as Latin-0. It is an 8-bit superset of ASCII designed as a modification of Latin-1, removing little-used characters in favor of the Euro symbol and other characters." } ;

HELP: latin10
{ $description "This is the ISO-8859-16 encoding, also called Latin-10: South-Eastern European. It is an 8-bit superset of ASCII." } ;

HELP: windows-1252
{ $description "Windows 1252 is an 8-bit superset of ASCII which is closely related to Latin-1. Control characters in the 0x80 to 0x9F range are replaced with printable characters such as the Euro symbol." } ;

HELP: ebcdic
{ $description "EBCDIC is an 8-bit legacy encoding designed for IBM mainframes like System/360 in the 1960s. It has since fallen into disuse. It contains large unallocated regions, and the version included here (code page 37) contains auxiliary characters in this region for English- and Portugese-speaking countries." } ;

HELP: mac-roman
{ $description "Mac Roman is an 8-bit superset of ASCII which was the standard encoding on Mac OS prior to version 10. It is incompatible with Latin-1 in all but a few places and ASCII, and it is suitable for encoding many Western European languages." } ;

HELP: koi8-r
{ $description "KOI8-R is an 8-bit superset of ASCII which encodes the Cyrillic alphabet, as used in Russian and Bulgarian. Characters are in such an order that, if the eight bit is stripped, text is still interpretable as ASCII. Block-building characters also exist." } ;
