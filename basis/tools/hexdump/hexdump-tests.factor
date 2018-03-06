USING: tools.hexdump kernel sequences tools.test byte-arrays ;

{ t } [ B{ } hexdump "Length: 0, 0h\n" = ] unit-test
{ t } [ "abcdefghijklmnopqrstuvwxyz" >byte-array hexdump "Length: 26, 1ah\n00000000h: 61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f 70 abcdefghijklmnop\n00000010h: 71 72 73 74 75 76 77 78 79 7a                   qrstuvwxyz\n" = ] unit-test

{ t } [ 256 <iota> [ ] B{ } map-as hexdump "Length: 256, 100h\n00000000h: 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f ................\n00000010h: 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f ................\n00000020h: 20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f  !\"#$%&'()*+,-./\n00000030h: 30 31 32 33 34 35 36 37 38 39 3a 3b 3c 3d 3e 3f 0123456789:;<=>?\n00000040h: 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f @ABCDEFGHIJKLMNO\n00000050h: 50 51 52 53 54 55 56 57 58 59 5a 5b 5c 5d 5e 5f PQRSTUVWXYZ[\\]^_\n00000060h: 60 61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f `abcdefghijklmno\n00000070h: 70 71 72 73 74 75 76 77 78 79 7a 7b 7c 7d 7e 7f pqrstuvwxyz{|}~.\n00000080h: 80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f ................\n00000090h: 90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f ................\n000000a0h: a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af ................\n000000b0h: b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 ba bb bc bd be bf ................\n000000c0h: c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf ................\n000000d0h: d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 da db dc dd de df ................\n000000e0h: e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 ea eb ec ed ee ef ................\n000000f0h: f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc fd fe ff ................\n" = ] unit-test


{
    "Length: 3, 3h\n00000000h: 01 02 03                                        ...\n" } [ B{ 1 2 3 } hexdump ] unit-test
