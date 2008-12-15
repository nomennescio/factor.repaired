! Copyright (C) 2008 Doug Coleman, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel system sequences combinators
vocabs.loader ;
IN: io.files.info

! File info
TUPLE: file-info type size permissions created modified
accessed ;

HOOK: file-info os ( path -- info )

HOOK: link-info os ( path -- info )

SYMBOL: +regular-file+
SYMBOL: +directory+
SYMBOL: +symbolic-link+
SYMBOL: +character-device+
SYMBOL: +block-device+
SYMBOL: +fifo+
SYMBOL: +socket+
SYMBOL: +whiteout+
SYMBOL: +unknown+

: directory? ( file-info -- ? ) type>> +directory+ = ;

! File systems
HOOK: file-systems os ( -- array )

TUPLE: file-system-info device-name mount-point type
available-space free-space used-space total-space ;

HOOK: file-system-info os ( path -- file-system-info )

{
    { [ os unix? ] [ "io.files.info.unix." os name>> append ] }
    { [ os windows? ] [ "io.files.info.windows" ] }
} cond require