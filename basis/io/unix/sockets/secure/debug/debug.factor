! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.sockets.secure kernel ;
IN: io.unix.sockets.secure.debug

: with-test-context ( quot -- )
    <secure-config>
        "resource:basis/openssl/test/server.pem" >>key-file
        "resource:basis/openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    swap with-secure-context ; inline
