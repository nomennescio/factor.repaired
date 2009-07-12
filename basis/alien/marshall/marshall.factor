! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.inline.types
alien.marshall.private alien.strings byte-arrays classes
combinators combinators.short-circuit destructors fry
io.encodings.utf8 kernel libc sequences
specialized-arrays.alien specialized-arrays.bool
specialized-arrays.char specialized-arrays.double
specialized-arrays.float specialized-arrays.int
specialized-arrays.long specialized-arrays.longlong
specialized-arrays.short specialized-arrays.uchar
specialized-arrays.uint specialized-arrays.ulong
specialized-arrays.ulonglong specialized-arrays.ushort strings
unix.utilities vocabs.parser words libc.private struct-arrays ;
IN: alien.marshall

<< primitive-types [ "void*" = not ] filter
[ define-primitive-marshallers ] each >>

TUPLE: alien-wrapper { underlying alien } ;
TUPLE: struct-wrapper < alien-wrapper disposed ;

GENERIC: unmarshall-cast ( alien-wrapper -- alien-wrapper' )

M: alien-wrapper unmarshall-cast ;
M: struct-wrapper unmarshall-cast ;

: marshall-pointer ( obj -- alien )
    {
        { [ dup alien? ] [ ] }
        { [ dup not ] [ ] }
        { [ dup byte-array? ] [ malloc-byte-array ] }
        { [ dup alien-wrapper? ] [ underlying>> ] }
        { [ dup struct-array? ] [ underlying>> ] }
    } cond ;

: marshall-void* ( obj -- alien )
    marshall-pointer ;

: marshall-void** ( obj -- alien )
    [ marshall-void* ] map >void*-array malloc-underlying ;

: (marshall-char*-or-string) ( n/string -- alien )
    dup string?
    [ utf8 string>alien malloc-byte-array ]
    [ (marshall-char*) ] if ;

: marshall-char*-or-string ( n/string -- alien )
    [ (marshall-char*-or-string) ] ptr-pass-through ;

: (marshall-char**-or-strings) ( seq -- alien )
    dup first string?
    [ utf8 strings>alien malloc-byte-array ]
    [ (marshall-char**) ] if ;

: marshall-char**-or-strings ( n/string -- alien )
    [ (marshall-char**-or-strings) ] ptr-pass-through ;

: primitive-marshaller ( type -- quot/f )
    {
        { "bool"        [ [ marshall-bool ] ] }
        { "char"        [ [ marshall-char ] ] }
        { "uchar"       [ [ marshall-uchar ] ] }
        { "short"       [ [ marshall-short ] ] }
        { "ushort"      [ [ marshall-ushort ] ] }
        { "int"         [ [ marshall-int ] ] }
        { "uint"        [ [ marshall-uint ] ] }
        { "long"        [ [ marshall-long ] ] }
        { "ulong"       [ [ marshall-ulong ] ] }
        { "long"        [ [ marshall-longlong ] ] }
        { "ulong"       [ [ marshall-ulonglong ] ] }
        { "float"       [ [ marshall-float ] ] }
        { "double"      [ [ marshall-double ] ] }
        { "bool*"       [ [ marshall-bool* ] ] }
        { "char*"       [ [ marshall-char*-or-string ] ] }
        { "uchar*"      [ [ marshall-uchar* ] ] }
        { "short*"      [ [ marshall-short* ] ] }
        { "ushort*"     [ [ marshall-ushort* ] ] }
        { "int*"        [ [ marshall-int* ] ] }
        { "uint*"       [ [ marshall-uint* ] ] }
        { "long*"       [ [ marshall-long* ] ] }
        { "ulong*"      [ [ marshall-ulong* ] ] }
        { "longlong*"   [ [ marshall-longlong* ] ] }
        { "ulonglong*"  [ [ marshall-ulonglong* ] ] }
        { "float*"      [ [ marshall-float* ] ] }
        { "double*"     [ [ marshall-double* ] ] }
        { "bool&"       [ [ marshall-bool* ] ] }
        { "char&"       [ [ marshall-char* ] ] }
        { "uchar&"      [ [ marshall-uchar* ] ] }
        { "short&"      [ [ marshall-short* ] ] }
        { "ushort&"     [ [ marshall-ushort* ] ] }
        { "int&"        [ [ marshall-int* ] ] }
        { "uint&"       [ [ marshall-uint* ] ] }
        { "long&"       [ [ marshall-long* ] ] }
        { "ulong&"      [ [ marshall-ulong* ] ] }
        { "longlong&"   [ [ marshall-longlong* ] ] }
        { "ulonglong&"  [ [ marshall-ulonglong* ] ] }
        { "float&"      [ [ marshall-float* ] ] }
        { "double&"     [ [ marshall-double* ] ] }
        { "void*"       [ [ marshall-void* ] ] }
        { "bool**"      [ [ marshall-bool** ] ] }
        { "char**"      [ [ marshall-char**-or-strings ] ] }
        { "uchar**"     [ [ marshall-uchar** ] ] }
        { "short**"     [ [ marshall-short** ] ] }
        { "ushort**"    [ [ marshall-ushort** ] ] }
        { "int**"       [ [ marshall-int** ] ] }
        { "uint**"      [ [ marshall-uint** ] ] }
        { "long**"      [ [ marshall-long** ] ] }
        { "ulong**"     [ [ marshall-ulong** ] ] }
        { "longlong**"  [ [ marshall-longlong** ] ] }
        { "ulonglong**" [ [ marshall-ulonglong** ] ] }
        { "float**"     [ [ marshall-float** ] ] }
        { "double**"    [ [ marshall-double** ] ] }
        { "void**"      [ [ marshall-void** ] ] }
        [ drop f ]
    } case ;

: marshall-non-pointer ( obj -- byte-array/f )
    {
        { [ dup byte-array? ] [ ] }
        { [ dup alien-wrapper? ]
          [ [ underlying>> ] [ class name>> heap-size ] bi
            memory>byte-array ] }
    } cond ;


: marshaller ( type -- quot )
    factorize-type dup primitive-marshaller [ nip ] [
        pointer?
        [ [ marshall-pointer ] ]
        [ [ marshall-non-pointer ] ] if
    ] if* ;


: unmarshall-char*-to-string ( alien -- string )
    utf8 alien>string ;

: unmarshall-char*-to-string-free ( alien -- string )
    [ unmarshall-char*-to-string ] keep add-malloc free ;

: unmarshall-bool ( n -- ? )
    0 = not ;

: primitive-unmarshaller ( type -- quot/f )
    {
        { "bool"       [ [ unmarshall-bool ] ] }
        { "char"       [ [ ] ] }
        { "uchar"      [ [ ] ] }
        { "short"      [ [ ] ] }
        { "ushort"     [ [ ] ] }
        { "int"        [ [ ] ] }
        { "uint"       [ [ ] ] }
        { "long"       [ [ ] ] }
        { "ulong"      [ [ ] ] }
        { "longlong"   [ [ ] ] }
        { "ulonglong"  [ [ ] ] }
        { "float"      [ [ ] ] }
        { "double"     [ [ ] ] }
        { "bool*"      [ [ unmarshall-bool*-free ] ] }
        { "char*"      [ [ unmarshall-char*-to-string-free ] ] }
        { "uchar*"     [ [ unmarshall-uchar*-free ] ] }
        { "short*"     [ [ unmarshall-short*-free ] ] }
        { "ushort*"    [ [ unmarshall-ushort*-free ] ] }
        { "int*"       [ [ unmarshall-int*-free ] ] }
        { "uint*"      [ [ unmarshall-uint*-free ] ] }
        { "long*"      [ [ unmarshall-long*-free ] ] }
        { "ulong*"     [ [ unmarshall-ulong*-free ] ] }
        { "longlong*"  [ [ unmarshall-long*-free ] ] }
        { "ulonglong*" [ [ unmarshall-ulong*-free ] ] }
        { "float*"     [ [ unmarshall-float*-free ] ] }
        { "double*"    [ [ unmarshall-double*-free ] ] }
        { "bool&"      [ [ unmarshall-bool*-free ] ] }
        { "char&"      [ [ unmarshall-char*-free ] ] }
        { "uchar&"     [ [ unmarshall-uchar*-free ] ] }
        { "short&"     [ [ unmarshall-short*-free ] ] }
        { "ushort&"    [ [ unmarshall-ushort*-free ] ] }
        { "int&"       [ [ unmarshall-int*-free ] ] }
        { "uint&"      [ [ unmarshall-uint*-free ] ] }
        { "long&"      [ [ unmarshall-long*-free ] ] }
        { "ulong&"     [ [ unmarshall-ulong*-free ] ] }
        { "longlong&"  [ [ unmarshall-longlong*-free ] ] }
        { "ulonglong&" [ [ unmarshall-ulonglong*-free ] ] }
        { "float&"     [ [ unmarshall-float*-free ] ] }
        { "double&"    [ [ unmarshall-double*-free ] ] }
        [ drop f ]
    } case ;

: struct-primitive-unmarshaller ( type -- quot/f )
    {
        { "bool"       [ [ unmarshall-bool ] ] }
        { "char"       [ [ ] ] }
        { "uchar"      [ [ ] ] }
        { "short"      [ [ ] ] }
        { "ushort"     [ [ ] ] }
        { "int"        [ [ ] ] }
        { "uint"       [ [ ] ] }
        { "long"       [ [ ] ] }
        { "ulong"      [ [ ] ] }
        { "longlong"   [ [ ] ] }
        { "ulonglong"  [ [ ] ] }
        { "float"      [ [ ] ] }
        { "double"     [ [ ] ] }
        { "bool*"      [ [ unmarshall-bool* ] ] }
        { "char*"      [ [ unmarshall-char*-to-string ] ] }
        { "uchar*"     [ [ unmarshall-uchar* ] ] }
        { "short*"     [ [ unmarshall-short* ] ] }
        { "ushort*"    [ [ unmarshall-ushort* ] ] }
        { "int*"       [ [ unmarshall-int* ] ] }
        { "uint*"      [ [ unmarshall-uint* ] ] }
        { "long*"      [ [ unmarshall-long* ] ] }
        { "ulong*"     [ [ unmarshall-ulong* ] ] }
        { "longlong*"  [ [ unmarshall-long* ] ] }
        { "ulonglong*" [ [ unmarshall-ulong* ] ] }
        { "float*"     [ [ unmarshall-float* ] ] }
        { "double*"    [ [ unmarshall-double* ] ] }
        { "bool&"      [ [ unmarshall-bool* ] ] }
        { "char&"      [ [ unmarshall-char* ] ] }
        { "uchar&"     [ [ unmarshall-uchar* ] ] }
        { "short&"     [ [ unmarshall-short* ] ] }
        { "ushort&"    [ [ unmarshall-ushort* ] ] }
        { "int&"       [ [ unmarshall-int* ] ] }
        { "uint&"      [ [ unmarshall-uint* ] ] }
        { "long&"      [ [ unmarshall-long* ] ] }
        { "ulong&"     [ [ unmarshall-ulong* ] ] }
        { "longlong&"  [ [ unmarshall-longlong* ] ] }
        { "ulonglong&" [ [ unmarshall-ulonglong* ] ] }
        { "float&"     [ [ unmarshall-float* ] ] }
        { "double&"    [ [ unmarshall-double* ] ] }
        [ drop f ]
    } case ;


: ?malloc-byte-array ( c-type -- alien )
    dup alien? [ malloc-byte-array ] unless ;

: struct-unmarshaller ( type -- quot )
    current-vocab lookup [
        dup superclasses [ \ struct-wrapper = ] any? [
            '[ ?malloc-byte-array _ new swap >>underlying ]
        ] [ drop [ ] ] if
    ] [ [ ] ] if* ;

: pointer-unmarshaller ( type -- quot )
    type-sans-pointer current-vocab lookup [
        dup superclasses [ \ alien-wrapper = ] any? [
            '[ _ new swap >>underlying dynamic-cast ]
        ] [ drop [ ] ] if
    ] [ [ ] ] if* ;

: unmarshaller ( type -- quot )
    factorize-type dup primitive-unmarshaller [ nip ] [
        dup pointer?
        [ pointer-unmarshaller ]
        [ struct-unmarshaller ] if
    ] if* ;

: struct-field-unmarshaller ( type -- quot )
    factorize-type dup struct-primitive-unmarshaller [ nip ] [
        dup pointer?
        [ pointer-unmarshaller ]
        [ struct-unmarshaller ] if
    ] if* ;

: out-arg-unmarshaller ( type -- quot )
    dup {
        [ pointer-to-const? not ]
        [ factorize-type pointer-to-primitive? ]
    } 1&&
    [ factorize-type primitive-unmarshaller ]
    [ drop [ drop ] ] if ;
