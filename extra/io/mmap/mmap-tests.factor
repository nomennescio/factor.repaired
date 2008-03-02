USING: io io.mmap io.files kernel tools.test continuations sequences ;
IN: io.mmap.tests

[ "mmap-test-file.txt" resource-path delete-file ] ignore-errors
[ ] [ "mmap-test-file.txt" resource-path [ "12345" write ] with-file-writer ] unit-test
[ ] [ "mmap-test-file.txt" resource-path dup file-length [ CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" resource-path dup file-length [ length ] with-mapped-file ] unit-test
[ "22345" ] [ "mmap-test-file.txt" resource-path file-contents ] unit-test
[ "mmap-test-file.txt" resource-path delete-file ] ignore-errors
