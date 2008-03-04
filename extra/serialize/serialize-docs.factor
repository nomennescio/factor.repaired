! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: serialize

HELP: (serialize) 
{ $values { "obj" "object to serialize" } 
}
{ $description "Serializes the object to the current output stream. Object references within the structure being serialized are maintained. It must be called from within the scope of a " { $link with-serialized } " call." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "[\n  [ { 1 2 } dup  (serialize) (serialize) ] with-serialized\n] with-string-writer\n\n[\n  [ (deserialize) (deserialize) ] with-serialized\n] with-string-reader eq? ." "t" }
}
{ $see-also deserialize (deserialize) serialize with-serialized } ;

HELP: (deserialize) 
{ $values { "obj" "deserialized object" } 
}
{ $description "Deserializes an object by reading from the current input stream. Object references within the structure that was originally serialized are maintained. It must be called from within the scope of a " { $link with-serialized } " call." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "[\n  [ { 1 2 } dup  (serialize) (serialize) ] with-serialized\n] with-string-writer\n\n[\n  [ (deserialize) (deserialize) ] with-serialized\n] with-string-reader eq? ." "t" }
}
{ $see-also (serialize) deserialize serialize with-serialized } ;

HELP: with-serialized
{ $values { "quot" "a quotation" } 
}
{ $description "Creates a scope for serialization and deserialization operations. The quotation is called within this scope. The scope is used for maintaining the structure and object references of serialized objects." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "[\n  [ { 1 2 } dup  (serialize) (serialize) ] with-serialized\n] with-string-writer\n\n[\n  [ (deserialize) (deserialize) ] with-serialized\n] with-string-reader eq? ." "t" }
}
{ $see-also (serialize) (deserialize) serialize deserialize } ;

HELP: serialize
{ $values { "obj" "object to serialize" } 
}
{ $description "Serializes the object to the current output stream. Object references within the structure being serialized are maintained." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "[ { 1 2 } serialize ] with-string-writer\n\n[ deserialize ] with-string-reader ." "{ 1 2 }" }
}
{ $see-also deserialize (deserialize) (serialize) with-serialized } ;

HELP: deserialize
{ $values { "obj" "deserialized object" } 
}
{ $description "Deserializes an object by reading from the current input stream. Object references within the structure that was originally serialized are maintained." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "[ { 1 2 } serialize ] with-string-writer\n\n[ deserialize ] with-string-reader ." "{ 1 2 }" }
}
{ $see-also (serialize) deserialize (deserialize) with-serialized } ;
