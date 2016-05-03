! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: io.pathnames sequences ui.images vocabs ;
IN: ui.gadgets.theme

: theme-image ( name -- image-name )
    "vocab:ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;

<< "ui.gadgets.theme.light" require >>
