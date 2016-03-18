USING: accessors io.directories io.directories.hierarchy
io.encodings.ascii io.files io.files.info io.files.temp
io.files.unique io.pathnames kernel namespaces sequences strings
tools.test ;
IN: io.files.unique.tests

{ 123 } [
    [
        "core" ".test" [
            [ [ 123 CHAR: a <string> ] dip ascii set-file-contents ]
            [ file-info size>> ] bi
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ t } [
    [
        current-directory get
        [ [ "FAILDOG" throw ] cleanup-unique-directory ] [ drop ] recover
        current-directory get =
    ] with-temp-directory
] unit-test

{ t } [
    [
        [
            "asdf" "" unique-file drop
            "asdf2" "" unique-file drop
            "." directory-files length 2 =
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test

{ t } [
    [
        [ ] with-unique-directory
        [ exists? ] [ delete-tree ] bi
    ] with-temp-directory
] unit-test

{ t } [
    [
        [
            "asdf" "" unique-file drop
            "asdf" "" unique-file drop
            "." directory-files length 2 =
        ] with-unique-directory drop
    ] with-temp-directory
] unit-test
