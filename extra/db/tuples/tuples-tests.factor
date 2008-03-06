! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.tuples
db.types continuations namespaces db.postgresql math
prettyprint tools.walker db.sqlite calendar ;
IN: db.tuples.tests

TUPLE: person the-id the-name the-number the-real ts date time blob ;
: <person> ( name age real -- person )
    {
        set-person-the-name
        set-person-the-number
        set-person-the-real
        set-person-ts
        set-person-date
        set-person-time
        set-person-blob
    } person construct ;

: <assigned-person> ( id name number the-real -- obj )
    <person> [ set-person-the-id ] keep ;

SYMBOL: person1
SYMBOL: person2
SYMBOL: person3
SYMBOL: person4

: test-tuples ( -- )
    [ person drop-table ] [ drop ] recover
    [ ] [ person create-table ] unit-test
    [ person create-table ] must-fail
    
    [ ] [ person1 get insert-tuple ] unit-test

    [ 1 ] [ person1 get person-the-id ] unit-test

    200 person1 get set-person-the-number

    [ ] [ person1 get update-tuple ] unit-test

    [ T{ person f 1 "billy" 200 3.14 } ]
    [ T{ person f 1 } select-tuple ] unit-test
    [ ] [ person2 get insert-tuple ] unit-test
    [
        {
            T{ person f 1 "billy" 200 3.14 }
            T{ person f 2 "johnny" 10 3.14 }
        }
    ] [ T{ person f f f f 3.14 } select-tuples ] unit-test
    [
        {
            T{ person f 1 "billy" 200 3.14 }
            T{ person f 2 "johnny" 10 3.14 }
        }
    ] [ T{ person f } select-tuples ] unit-test


    [ ] [ person1 get delete-tuple ] unit-test
    [ f ] [ T{ person f 1 } select-tuple ] unit-test

    [ ] [ person3 get insert-tuple ] unit-test

    [
        T{
            person
            f
            3
            "teddy"
            10
            3.14
            T{ timestamp f 2008 3 5 16 24 11 0 }
            T{ timestamp f 2008 11 22 f f f f }
            T{ timestamp f f f f 12 34 56 f }
            B{ 115 116 111 114 101 105 110 97 98 108 111 98 }
        }
    ] [ T{ person f 3 } select-tuple ] unit-test

    [ ] [ person drop-table ] unit-test ;

: make-native-person-table ( -- )
    [ person drop-table ] [ drop ] recover
    person create-table
    T{ person f f "billy" 200 3.14 } insert-tuple
    T{ person f f "johnny" 10 3.14 } insert-tuple
    ;

: native-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" +native-id+ }
        { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
        { "the-number" "AGE" INTEGER { +default+ 0 } }
        { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
        { "ts" "TS" TIMESTAMP }
        { "date" "D" DATE }
        { "time" "T" TIME }
        { "blob" "B" BLOB }
    } define-persistent
    "billy" 10 3.14 f f f f <person> person1 set
    "johnny" 10 3.14 f f f f <person> person2 set
    "teddy" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" B{ 115 116 111 114 101 105 110 97 98 108 111 98 } <person> person3 set ;

: assigned-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" INTEGER +assigned-id+ }
        { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
        { "the-number" "AGE" INTEGER { +default+ 0 } }
        { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
        { "ts" "TS" TIMESTAMP }
        { "date" "D" DATE }
        { "time" "T" TIME }
        { "blob" "B" BLOB }
    } define-persistent
    1 "billy" 10 3.14 f f f f <assigned-person> person1 set
    2 "johnny" 10 3.14 f f f f <assigned-person> person2 set
    3 "teddy" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" B{ 115 116 111 114 101 105 110 97 98 108 111 98 } <assigned-person> person3 set ;

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

: native-paste-schema ( -- )
    paste "PASTE"
    {
        { "n" "ID" +native-id+ }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "channel" "CHANNEL" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
        { "date" "DATE" TIMESTAMP }
        { "annotations" { +has-many+ annotation } }
    } define-persistent

    annotation "ANNOTATION"
    {
        { "n" "ID" +native-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "n" } }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

! { "localhost" "postgres" "" "factor-test" } postgresql-db [
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ ] [ paste create-table ] unit-test
    ! [ ] [ annotation create-table ] unit-test
! ] with-db


: test-sqlite ( quot -- )
    >r "tuples-test.db" resource-path sqlite-db r> with-db ;

: test-postgresql ( -- )
    >r { "localhost" "postgres" "" "factor-test" } postgresql-db r> with-db ;


[ native-person-schema test-tuples ] test-sqlite
[ assigned-person-schema test-tuples ] test-sqlite

TUPLE: serialize-me id data ;
[
    serialize-me "SERIALIZED"
    {
        { "id" "ID" +native-id+ }
        { "data" "DATA" FACTOR-BLOB }
    } define-persistent
    [ serialize-me drop-table ] [ drop ] recover
    [ ] [ serialize-me create-table ] unit-test

    [ ] [ T{ serialize-me f f H{ { 1 2 } } } insert-tuple ] unit-test
    [
        { T{ serialize-me f 1 H{ { 1 2 } } } }
    ] [ T{ serialize-me f 1 } select-tuples ] unit-test
] test-sqlite

! [ make-native-person-table ] test-sqlite
