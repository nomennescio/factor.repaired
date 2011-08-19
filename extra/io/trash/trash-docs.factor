! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax io.trash ;

IN: io.trash

HELP: send-to-trash
{ $values { "path" "a file path" } }
{ $description
    "Send a file path to the trash bin."
} ;
