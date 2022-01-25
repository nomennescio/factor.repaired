! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs ;

IN: io.files.trash

HOOK: send-to-trash os ( path -- )

{
    { [ os windows? ] [ "io.files.trash.windows" ] }
    { [ os macosx? ] [ "io.files.trash.macosx" ] }
    { [ os unix? ] [ "io.files.trash.unix" ] }
} cond require
