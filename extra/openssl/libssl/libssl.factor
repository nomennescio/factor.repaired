! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with OpenSSL 0.9.8a_0 on Mac OS X 10.4.9 PowerPC
!
! export LD_LIBRARY_PATH=/opt/local/lib

USING: alien alien.syntax combinators kernel system ;

IN: openssl.libssl

<< "libssl" {
    { [ os winnt? ]  [ "ssleay32.dll" "cdecl" ] }
    { [ os macosx? ] [ "libssl.dylib" "cdecl" ] }
    { [ os unix? ]   [ "libssl.so" "cdecl" ] }
} cond add-library >>

: X509_FILETYPE_PEM       1 ; inline
: X509_FILETYPE_ASN1      2 ; inline
: X509_FILETYPE_DEFAULT   3 ; inline

: SSL_FILETYPE_ASN1  X509_FILETYPE_ASN1 ; inline
: SSL_FILETYPE_PEM   X509_FILETYPE_PEM ; inline

: SSL_CTRL_NEED_TMP_RSA      1 ; inline
: SSL_CTRL_SET_TMP_RSA       2 ; inline
: SSL_CTRL_SET_TMP_DH        3 ; inline
: SSL_CTRL_SET_TMP_RSA_CB    4 ; inline
: SSL_CTRL_SET_TMP_DH_CB     5 ; inline

: SSL_ERROR_NONE             0 ; inline
: SSL_ERROR_SSL              1 ; inline
: SSL_ERROR_WANT_READ        2 ; inline
: SSL_ERROR_WANT_WRITE       3 ; inline
: SSL_ERROR_WANT_X509_LOOKUP 4 ; inline
: SSL_ERROR_SYSCALL          5 ; inline ! consult errno for details
: SSL_ERROR_ZERO_RETURN      6 ; inline
: SSL_ERROR_WANT_CONNECT     7 ; inline
: SSL_ERROR_WANT_ACCEPT      8 ; inline

! Error messages table
: error-messages ( -- hash )
    H{
        { 0  "SSL_ERROR_NONE" }
        { 1  "SSL_ERROR_SSL" }
        { 2  "SSL_ERROR_WANT_READ" }
        { 3  "SSL_ERROR_WANT_WRITE" }
        { 4  "SSL_ERROR_WANT_X509_LOOKUP" }
        { 5  "SSL_ERROR_SYSCALL" }
        { 6  "SSL_ERROR_ZERO_RETURN" }
        { 7  "SSL_ERROR_WANT_CONNECT" }
        { 8  "SSL_ERROR_WANT_ACCEPT" }
    } ;

TYPEDEF: void* ssl-method
TYPEDEF: void* ssl-ctx
TYPEDEF: void* ssl-pointer

LIBRARY: libssl

! ===============================================
! ssl.h
! ===============================================

FUNCTION: char* SSL_get_version ( ssl-pointer ssl ) ;

! Maps OpenSSL errors to strings
FUNCTION: void SSL_load_error_strings (  ) ;

! Must be called before any other action takes place
FUNCTION: int SSL_library_init (  ) ;

! Sets the default SSL version
FUNCTION: ssl-method SSLv2_client_method (  ) ;

FUNCTION: ssl-method SSLv23_client_method (  ) ;

FUNCTION: ssl-method SSLv23_server_method (  ) ;

FUNCTION: ssl-method SSLv23_method (  ) ; ! SSLv3 but can rollback to v2

FUNCTION: ssl-method SSLv3_client_method (  ) ;

FUNCTION: ssl-method SSLv3_server_method (  ) ;

FUNCTION: ssl-method SSLv3_method (  ) ;

FUNCTION: ssl-method TLSv1_client_method (  ) ;

FUNCTION: ssl-method TLSv1_server_method (  ) ;

FUNCTION: ssl-method TLSv1_method (  ) ;

! Creates the context
FUNCTION: ssl-ctx SSL_CTX_new ( ssl-method method ) ;

! Load the certificates and private keys into the SSL_CTX
FUNCTION: int SSL_CTX_use_certificate_chain_file ( ssl-ctx ctx,
                                                   char* file ) ; ! PEM type

FUNCTION: ssl-pointer SSL_new ( ssl-ctx ctx ) ;

FUNCTION: int SSL_set_fd ( ssl-pointer ssl, int fd ) ;

FUNCTION: void SSL_set_bio ( ssl-pointer ssl, void* rbio, void* wbio ) ;

FUNCTION: int SSL_get_error ( ssl-pointer ssl, int ret ) ;

FUNCTION: void SSL_set_connect_state ( ssl-pointer ssl ) ;

FUNCTION: void SSL_set_accept_state ( ssl-pointer ssl ) ;

FUNCTION: int SSL_connect ( ssl-pointer ssl ) ;

FUNCTION: int SSL_accept ( ssl-pointer ssl ) ;

FUNCTION: int SSL_write ( ssl-pointer ssl, void* buf, int num ) ;

FUNCTION: int SSL_read ( ssl-pointer ssl, void* buf, int num ) ;

FUNCTION: int SSL_shutdown ( ssl-pointer ssl ) ;

FUNCTION: void SSL_free ( ssl-pointer ssl ) ;

FUNCTION: long SSL_get_verify_result ( SSL* ssl ) ;

FUNCTION: X509* SSL_get_peer_certificate ( SSL* s ) ;

FUNCTION: void SSL_CTX_free ( ssl-ctx ctx ) ;

FUNCTION: void RAND_seed ( void* buf, int num ) ;

FUNCTION: int SSL_set_cipher_list ( ssl-pointer ssl, char* str ) ;

FUNCTION: int SSL_use_RSAPrivateKey_file ( ssl-pointer ssl, char* str ) ;

FUNCTION: int SSL_CTX_use_RSAPrivateKey_file ( ssl-ctx ctx, int type ) ;

FUNCTION: int SSL_use_certificate_file ( ssl-pointer ssl,
                                         char* str, int type ) ;

FUNCTION: int SSL_CTX_load_verify_locations ( ssl-ctx ctx, char* CAfile,
                                              char* CApath ) ;

FUNCTION: void SSL_CTX_set_client_CA_list ( ssl-ctx ctx, ssl-pointer list ) ;

FUNCTION: ssl-pointer SSL_load_client_CA_file ( char* file ) ;

! Used to manipulate settings of the SSL_CTX and SSL objects.
! This function should never be called directly
FUNCTION: long SSL_CTX_ctrl ( ssl-ctx ctx, int cmd, long larg, void* parg ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb ( ssl-ctx ctx, void* cb ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb_userdata ( ssl-ctx ctx,
                                                        void* u ) ;

FUNCTION: int SSL_CTX_use_PrivateKey_file ( ssl-ctx ctx, char* file,
                                            int type ) ;

! Sets the maximum depth for the allowed ctx certificate chain verification 
FUNCTION: void SSL_CTX_set_verify_depth ( ssl-ctx ctx, int depth ) ;

! Sets DH parameters to be used to be dh.
! The key is inherited by all ssl objects created from ctx
FUNCTION: void SSL_CTX_set_tmp_dh_callback ( ssl-ctx ctx, void* dh ) ;

FUNCTION: void SSL_CTX_set_tmp_rsa_callback ( ssl-ctx ctx, void* rsa ) ;

FUNCTION: void* BIO_f_ssl (  ) ;

! ===============================================
! x509.h
! ===============================================

TYPEDEF: void* X509_NAME*

TYPEDEF: void* X509*

FUNCTION: int X509_NAME_get_text_by_NID ( X509_NAME* name, int nid, void* buf, int len ) ;
FUNCTION: X509_NAME* X509_get_subject_name ( X509* a ) ;

! ===============================================
! x509_vfy.h
! ===============================================

: X509_V_OK 0 ; inline
: X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT 2 ; inline
: X509_V_ERR_UNABLE_TO_GET_CRL 3 ; inline
: X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE 4 ; inline
: X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE 5 ; inline
: X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY 6 ; inline
: X509_V_ERR_CERT_SIGNATURE_FAILURE 7 ; inline
: X509_V_ERR_CRL_SIGNATURE_FAILURE 8 ; inline
: X509_V_ERR_CERT_NOT_YET_VALID 9 ; inline
: X509_V_ERR_CERT_HAS_EXPIRED 10 ; inline
: X509_V_ERR_CRL_NOT_YET_VALID 11 ; inline
: X509_V_ERR_CRL_HAS_EXPIRED 12 ; inline
: X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD 13 ; inline
: X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD 14 ; inline
: X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD 15 ; inline
: X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD 16 ; inline
: X509_V_ERR_OUT_OF_MEM 17 ; inline
: X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT 18 ; inline
: X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN 19 ; inline
: X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY 20 ; inline
: X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE 21 ; inline
: X509_V_ERR_CERT_CHAIN_TOO_LONG 22 ; inline
: X509_V_ERR_CERT_REVOKED 23 ; inline
: X509_V_ERR_INVALID_CA 24 ; inline
: X509_V_ERR_PATH_LENGTH_EXCEEDED 25 ; inline
: X509_V_ERR_INVALID_PURPOSE 26 ; inline
: X509_V_ERR_CERT_UNTRUSTED 27 ; inline
: X509_V_ERR_CERT_REJECTED 28 ; inline
: X509_V_ERR_SUBJECT_ISSUER_MISMATCH 29 ; inline
: X509_V_ERR_AKID_SKID_MISMATCH 30 ; inline
: X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH 31 ; inline
: X509_V_ERR_KEYUSAGE_NO_CERTSIGN 32 ; inline
: X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER 33 ; inline
: X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION 34 ; inline
: X509_V_ERR_KEYUSAGE_NO_CRL_SIGN 35 ; inline
: X509_V_ERR_UNHANDLED_CRITICAL_CRL_EXTENSION 36 ; inline
: X509_V_ERR_INVALID_NON_CA 37 ; inline
: X509_V_ERR_PROXY_PATH_LENGTH_EXCEEDED 38 ; inline
: X509_V_ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE 39 ; inline
: X509_V_ERR_PROXY_CERTIFICATES_NOT_ALLOWED 40 ; inline
: X509_V_ERR_APPLICATION_VERIFICATION 50 ; inline

! ===============================================
! obj_mac.h
! ===============================================

: NID_commonName 13 ; inline
