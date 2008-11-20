USING: benchmark.regex-dna io io.files io.encodings.ascii
io.streams.string kernel tools.test splitting ;
IN: benchmark.regex-dna.tests

[ t ] [
    "resource:extra/benchmark/regex-dna/regex-dna-test-in.txt"
    [ regex-dna ] with-string-writer <string-reader> lines
    "resource:extra/benchmark/regex-dna/regex-dna-test-out.txt"
    ascii file-lines =
] unit-test
