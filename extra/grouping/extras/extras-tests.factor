USING: arrays tools.test ;
IN: grouping.extras

{ { } } [ { 1 } [ 2array ] 2clump-map ] unit-test
{ { { 1 2 } } } [ { 1 2 } [ 2array ] 2clump-map ] unit-test
{ { { 1 2 } { 2 3 } } } [ { 1 2 3 } [ 2array ] 2clump-map ] unit-test
{ { { 1 2 } { 2 3 } { 3 4 } } } [ { 1 2 3 4 } [ 2array ] 2clump-map ] unit-test

{ { } } [ { 1 } [ 3array ] 3clump-map ] unit-test
{ { } } [ { 1 2 } [ 3array ] 3clump-map ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 } [ 3array ] 3clump-map ] unit-test
{ { { 1 2 3 } { 2 3 4 } } } [ { 1 2 3 4 } [ 3array ] 3clump-map ] unit-test

{ { } } [ { 1 } [ 4array ] 4 nclump-map ] unit-test
{ { } } [ { 1 2 } [ 4array ] 4 nclump-map ] unit-test
{ { { 1 2 3 4 } } } [ { 1 2 3 4 } [ 4array ] 4 nclump-map ] unit-test
{ { { 1 2 3 4 } { 2 3 4 5 } } } [ { 1 2 3 4 5 } [ 4array ] 4 nclump-map ] unit-test

{ { "tail" "ail" "il" "l" } } [ "tail" tail-clump ] unit-test
{ { "h" "he" "hea" "head" } } [ "head" head-clump ] unit-test

{ { B{ 97 115 } B{ 100 102 } } } [ "asdf" 2 B{ } group-as ] unit-test
{ { { 97 115 } { 115 100 } { 100 102 } } } [ "asdf" 2 { } clump-as ] unit-test
