! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs.loader ;
IN: clutter.json.ffi

<<
"gobject.ffi" require
"gio.ffi" require
>>

LIBRARY: clutter.json

<<
"clutter.json" {
    { [ os winnt? ] [ drop ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libclutter-glx-1.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:clutter/json/Json-1.0.gir

