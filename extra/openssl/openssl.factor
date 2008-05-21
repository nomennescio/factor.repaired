! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel debugger sequences namespaces math
math.order combinators init alien alien.c-types alien.strings libc
continuations destructors debugger inspector
locals unicode.case
openssl.libcrypto openssl.libssl
io.backend io.ports io.files io.encodings.8-bit io.sockets.secure
io.timeouts ;
IN: openssl

! This code is based on http://www.rtfm.com/openssl-examples/

SINGLETON: openssl

GENERIC: ssl-method ( symbol -- method )

M: SSLv2  ssl-method drop SSLv2_client_method ;
M: SSLv23 ssl-method drop SSLv23_method ;
M: SSLv3  ssl-method drop SSLv3_method ;
M: TLSv1  ssl-method drop TLSv1_method ;

: (ssl-error-string) ( n -- string )
    ERR_clear_error f ERR_error_string ;

: ssl-error-string ( -- string )
    ERR_get_error ERR_clear_error f ERR_error_string ;

: (ssl-error) ( -- * )
    ssl-error-string throw ;

: ssl-error ( obj -- )
    { f 0 } member? [ (ssl-error) ] when ;

: init-ssl ( -- )
    SSL_library_init ssl-error
    SSL_load_error_strings
    OpenSSL_add_all_digests
    OpenSSL_add_all_ciphers ;

SYMBOL: ssl-initiazed?

: maybe-init-ssl ( -- )
    ssl-initiazed? get-global [
        init-ssl
        t ssl-initiazed? set-global
    ] unless ;

[ f ssl-initiazed? set-global ] "openssl" add-init-hook

TUPLE: openssl-context < secure-context aliens ;

: load-certificate-chain ( ctx -- )
    dup config>> key-file>> [
        [ handle>> ] [ config>> key-file>> (normalize-path) ] bi
        SSL_CTX_use_certificate_chain_file
        ssl-error
    ] [ drop ] if ;

: password-callback ( -- alien )
    "int" { "void*" "int" "bool" "void*" } "cdecl"
    [| buf size rwflag password! |
        password [ B{ 0 } password! ] unless

        [let | len [ password strlen ] |
            buf password len 1+ size min memcpy
            len
        ]
    ] alien-callback ;

: default-pasword ( ctx -- alien )
    [ config>> password>> latin1 malloc-string ] [ aliens>> ] bi
    [ push ] [ drop ] 2bi ;

: set-default-password ( ctx -- )
    [ handle>> password-callback SSL_CTX_set_default_passwd_cb ]
    [
        [ handle>> ] [ default-pasword ] bi
        SSL_CTX_set_default_passwd_cb_userdata
    ] bi ;

: use-private-key-file ( ctx -- )
    dup config>> key-file>> [
        [ handle>> ] [ config>> key-file>> (normalize-path) ] bi
        SSL_FILETYPE_PEM SSL_CTX_use_PrivateKey_file
        ssl-error
    ] [ drop ] if ;

: load-verify-locations ( ctx -- )
    dup config>> [ ca-file>> ] [ ca-path>> ] bi or [
        [ handle>> ]
        [
            config>>
            [ ca-file>> dup [ (normalize-path) ] when ]
            [ ca-path>> dup [ (normalize-path) ] when ] bi
        ] bi
        SSL_CTX_load_verify_locations ssl-error
    ] [ drop ] if ;

: set-verify-depth ( ctx -- )
    handle>> 1 SSL_CTX_set_verify_depth ;

TUPLE: bio handle disposed ;

: <bio> f bio boa ;

M: bio dispose* handle>> BIO_free ssl-error ;

: <file-bio> ( path -- bio )
    normalize-path "r" BIO_new_file dup ssl-error <bio> ;

: load-dh-params ( ctx -- )
    dup config>> dh-file>> [
        [ handle>> ] [ config>> dh-file>> ] bi <file-bio> &dispose
        handle>> f f f PEM_read_bio_DHparams dup ssl-error
        SSL_CTX_set_tmp_dh ssl-error
    ] [ drop ] if ;

TUPLE: rsa handle disposed ;

: <rsa> f rsa boa ;

M: rsa dispose* handle>> RSA_free ;

: generate-eph-rsa-key ( ctx -- )
    [ handle>> ]
    [
        config>> ephemeral-key-bits>> RSA_F4 f f RSA_generate_key
        dup ssl-error <rsa> &dispose handle>>
    ] bi
    SSL_CTX_set_tmp_rsa ssl-error ;

M: openssl <secure-context> ( config -- context )
    maybe-init-ssl
    [
        dup method>> ssl-method SSL_CTX_new
        dup ssl-error f V{ } clone openssl-context boa |dispose
        {
            [ load-certificate-chain ]
            [ set-default-password ]
            [ use-private-key-file ]
            [ load-verify-locations ]
            [ set-verify-depth ]
            [ load-dh-params ]
            [ generate-eph-rsa-key ]
            [ ]
        } cleave
    ] with-destructors ;

M: openssl-context dispose*
    [ aliens>> [ free ] each ]
    [ handle>> SSL_CTX_free ]
    bi ;

TUPLE: ssl-handle file handle connected disposed ;

ERROR: no-secure-context ;

M: no-secure-context summary
    drop "Secure socket operations must be wrapped in calls to with-secure-context" ;

: current-ssl-context ( -- ctx )
    secure-context get [ no-secure-context ] unless* ;

: <ssl-handle> ( fd -- ssl )
    current-ssl-context handle>> SSL_new dup ssl-error
    f f ssl-handle boa ;

M: ssl-handle dispose*
    [ handle>> SSL_free ] [ file>> dispose ] bi ;

: check-verify-result ( ssl-handle -- )
    SSL_get_verify_result dup X509_V_OK =
    [ drop ] [ verify-message certificate-verify-error ] if ;

: common-name ( certificate -- host )
    X509_get_subject_name
    NID_commonName 256 <byte-array>
    [ 256 X509_NAME_get_text_by_NID ] keep
    swap -1 = [ drop f ] [ latin1 alien>string ] if ;

: check-common-name ( host ssl-handle -- )
    SSL_get_peer_certificate common-name 2dup [ >lower ] bi@ =
    [ 2drop ] [ common-name-verify-error ] if ;

M: openssl check-certificate ( host ssl -- )
    handle>>
    [ nip check-verify-result ]
    [ check-common-name ]
    2bi ;

openssl secure-socket-backend set-global
