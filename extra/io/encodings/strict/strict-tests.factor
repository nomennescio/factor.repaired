USING: io.encodings.strict io.encodings.ascii tools.test
arrays io.encodings.string ;
IN: io.encodings.strict.test

[ { HEX: fffd } ] [ { 128 } ascii decode >array ] unit-test
[ { 128 } ascii strict decode ] must-fail
