! Copyright (C) 2017 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: checksums checksums.ripemd strings tools.test ;
IN: checksums.ripemd.tests

{ B{
    0x9c 0x11 0x85 0xa5 0xc5
    0xe9 0xfc 0x54 0x61 0x28
    0x08 0x97 0x7e 0xe8 0xf5
    0x48 0xb2 0x25 0x8d 0x31
} } [ "" ripemd-160 checksum-bytes ] unit-test

{ B{
    0x0b 0xdc 0x9d 0x2d 0x25
    0x6b 0x3e 0xe9 0xda 0xae
    0x34 0x7b 0xe6 0xf4 0xdc
    0x83 0x5a 0x46 0x7f 0xfe
} } [ "a" ripemd-160 checksum-bytes ] unit-test

{ B{
    0x8e 0xb2 0x08 0xf7 0xe0
    0x5d 0x98 0x7a 0x9b 0x04
    0x4a 0x8e 0x98 0xc6 0xb0
    0x87 0xf1 0x5a 0x0b 0xfc
} } [ "abc" ripemd-160 checksum-bytes ] unit-test

{ B{
    0x5d 0x06 0x89 0xef 0x49
    0xd2 0xfa 0xe5 0x72 0xb8
    0x81 0xb1 0x23 0xa8 0x5f
    0xfa 0x21 0x59 0x5f 0x36
} } [ "message digest" ripemd-160 checksum-bytes ] unit-test

{ B{
    0xf7 0x1c 0x27 0x10 0x9c
    0x69 0x2c 0x1b 0x56 0xbb
    0xdc 0xeb 0x5b 0x9d 0x28
    0x65 0xb3 0x70 0x8d 0xbc
} } [ "abcdefghijklmnopqrstuvwxyz" ripemd-160 checksum-bytes ] unit-test

{ B{
    0x12 0xa0 0x53 0x38 0x4a
    0x9c 0x0c 0x88 0xe4 0x05
    0xa0 0x6c 0x27 0xdc 0xf4
    0x9a 0xda 0x62 0xeb 0x2b
} } [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" ripemd-160 checksum-bytes ] unit-test

{ B{
    0xb0 0xe2 0x0b 0x6e 0x31
    0x16 0x64 0x02 0x86 0xed
    0x3a 0x87 0xa5 0x71 0x30
    0x79 0xb2 0x1f 0x51 0x89
} } [ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" ripemd-160 checksum-bytes ] unit-test

{ B{
    0x9b 0x75 0x2e 0x45 0x57
    0x3d 0x4b 0x39 0xf4 0xdb
    0xd3 0x32 0x3c 0xab 0x82
    0xbf 0x63 0x32 0x6b 0xfb
} } [ "12345678901234567890123456789012345678901234567890123456789012345678901234567890" ripemd-160 checksum-bytes ] unit-test


{ B{
0x52 0x78 0x32 0x43 0xc1
0x69 0x7b 0xdb 0xe1 0x6d
0x37 0xf9 0x7f 0x68 0xf0
0x83 0x25 0xdc 0x15 0x28
} } [ 1000000 char: a <string> ripemd-160 checksum-bytes ] unit-test



