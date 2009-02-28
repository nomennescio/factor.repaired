! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: io.encodings.korean

ARTICLE: "io.encodings.korean" "Korean text encodings"
"The " { $vocab-link "io.encodings.korean" } " vocabulary implements encodings used for Korean text besides the standard UTF encodings for Unicode strings."
{ $subsection cp949 }
{ $subsection johab }
{ $see-also "encodings-introduction" }
;

ABOUT: "io.encodings.korean"

HELP: cp949
{ $class-description "This encoding class implements Microsoft's code page #949 encoding, also called Unified Hangul Code (KSC5601-1987), UHC. CP949 is extended version of EUC-KR and downward-compatibility to EUC-KR." }
;

HELP: johab
{ $class-description "Korean Johab encoding (KSC5601-1992). Although Johab encoding is not used anymore." }
;