! Copyright (C) 2008 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs biassocs classes.mixin classes.singleton
fry io io.encodings io.encodings.iana kernel lexer namespaces
parser sequences simple-flat-file ;
IN: io.encodings.8-bit

<<
<PRIVATE

: encoding-file ( file-name -- stream )
    "vocab:io/encodings/8-bit/" ".TXT" surround ;

SYMBOL: 8-bit-encodings
8-bit-encodings [ H{ } clone ] initialize

TUPLE: 8-bit { biassoc biassoc read-only } ;

: 8-bit-encode ( char 8-bit -- byte )
    biassoc>> value-at [ encode-error ] unless* ; inline

M: 8-bit encode-char
    swap [ 8-bit-encode ] dip stream-write1 ;

M: 8-bit encode-string
    swap [ '[ _ 8-bit-encode ] B{ } map-as ] dip stream-write ;

M: 8-bit decode-char
    swap stream-read1 dup
    [ swap biassoc>> at [ replacement-char ] unless* ]
    [ 2drop f ]
    if ;

MIXIN: 8-bit-encoding

M: 8-bit-encoding <encoder>
    8-bit-encodings get-global at <encoder> ;

M: 8-bit-encoding <decoder>
    8-bit-encodings get-global at <decoder> ;

: create-encoding ( name -- word )
    create-word-in
    [ define-singleton-class ]
    [ 8-bit-encoding add-mixin-instance ]
    [ ] tri ;

: load-encoding ( name iana-name file-name -- )
    [ create-encoding dup ]
    [ register-encoding ]
    [ encoding-file load-codetable-file 8-bit boa ] tri*
    swap 8-bit-encodings get-global set-at ;

PRIVATE>

SYNTAX: 8-BIT: scan-token scan-token scan-token load-encoding ;
>>

8-BIT: cp437 IBM437 CP437
8-BIT: cp500 IBM500 CP500
8-BIT: cp775 IBM775 CP775
8-BIT: cp850 IBM850 CP850
8-BIT: cp852 IBM852 CP852
8-BIT: cp855 IBM855 CP855
8-BIT: cp857 IBM857 CP857
8-BIT: cp860 IBM860 CP860
8-BIT: cp861 IBM861 CP861
8-BIT: cp862 IBM862 CP862
8-BIT: cp863 IBM863 CP863
8-BIT: cp864 IBM864 CP864
8-BIT: cp865 IBM865 CP865
8-BIT: cp866 IBM866 CP866
8-BIT: cp869 IBM869 CP869
8-BIT: cp1026 IBM1026 CP1026
8-BIT: ebcdic IBM037 CP037
8-BIT: koi8-r KOI8-R KOI8-R
8-BIT: latin/arabic ISO_8859-6:1987 8859-6
8-BIT: latin/cyrillic ISO_8859-5:1988 8859-5
8-BIT: latin/greek ISO_8859-7:1987 8859-7
8-BIT: latin/hebrew ISO_8859-8:1988 8859-8
8-BIT: latin/thai TIS-620 8859-11
8-BIT: latin1 ISO_8859-1:1987 8859-1
8-BIT: latin2 ISO_8859-2:1987 8859-2
8-BIT: latin3 ISO_8859-3:1988 8859-3
8-BIT: latin4 ISO_8859-4:1988 8859-4
8-BIT: latin5 ISO_8859-9:1989 8859-9
8-BIT: latin6 ISO-8859-10 8859-10
8-BIT: latin7 ISO-8859-13 8859-13
8-BIT: latin8 ISO-8859-14 8859-14
8-BIT: latin9 ISO-8859-15 8859-15
8-BIT: latin10 ISO-8859-16 8859-16
8-BIT: mac-roman macintosh ROMAN
! 8-BIT: mac-cyrillic mac-cyrillic CYRILLIC
! 8-BIT: mac-greek mac-greek GREEK
! 8-BIT: mac-icelandic mac-icelandic ICELAND
! 8-BIT: mac-latin2 mac-latin2 LATIN2
! 8-BIT: mac-turkish mac-turkish TURKISH
8-BIT: windows-874 windows-874 CP874
8-BIT: windows-1250 windows-1250 CP1250
8-BIT: windows-1251 windows-1251 CP1251
8-BIT: windows-1252 windows-1252 CP1252
8-BIT: windows-1253 windows-1253 CP1253
8-BIT: windows-1254 windows-1254 CP1254
8-BIT: windows-1255 windows-1255 CP1255
8-BIT: windows-1256 windows-1256 CP1256
8-BIT: windows-1257 windows-1257 CP1257
8-BIT: windows-1258 windows-1258 CP1258
