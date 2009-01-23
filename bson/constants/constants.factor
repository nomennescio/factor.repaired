USING: alien.c-types accessors kernel calendar random math.bitwise math unix ;

IN: bson.constants

TUPLE: oid { a initial: 0 } { b initial: 0 } ;

: <oid> ( -- oid )
    oid new
    now timestamp>micros >>a
    8 random-bits 16 shift HEX: FF0000 mask
    getpid HEX: FFFF mask
    bitor >>b ;

TUPLE: dbref ns oid ;


CONSTANT: T_EOO  0  
CONSTANT: T_Double  1  
CONSTANT: T_Integer  16  
CONSTANT: T_Boolean  8  
CONSTANT: T_String  2  
CONSTANT: T_Object  3  
CONSTANT: T_Array  4  
CONSTANT: T_Binary  5  
CONSTANT: T_Undefined  6  
CONSTANT: T_OID  7  
CONSTANT: T_Date  9  
CONSTANT: T_NULL  10  
CONSTANT: T_Regexp  11  
CONSTANT: T_DBRef  12  
CONSTANT: T_Code  13  
CONSTANT: T_ScopedCode  17  
CONSTANT: T_Symbol  14  
CONSTANT: T_JSTypeMax  16  
CONSTANT: T_MaxKey  127  

CONSTANT: T_Binary_Bytes 2  
CONSTANT: T_Binary_Function 1   


