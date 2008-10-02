! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with OpenSSL 0.9.8a_0 on Mac OS X 10.4.9 PowerPC
!
! export LD_LIBRARY_PATH=/opt/local/lib

USING: alien alien.syntax combinators kernel system ;

IN: openssl.libcrypto

<<
{
    { [ os openbsd? ] [ ] } ! VM is linked with it
    { [ os winnt? ] [ "libcrypto" "libeay32.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "libcrypto" "libcrypto.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ "libcrypto" "libcrypto.so" "cdecl" add-library ] }
} cond
>>

C-STRUCT: bio-method
    { "int" "type" }
    { "void*" "name" }
    { "void*" "bwrite" }
    { "void*" "bread" }
    { "void*" "bputs" }
    { "void*" "bgets" }
    { "void*" "ctrl" }
    { "void*" "create" }
    { "void*" "destroy" }
    { "void*" "callback-ctrl" } ;

C-STRUCT: bio
    { "void*" "method" }
    { "void*" "callback" }
    { "void*" "cb-arg" }
    { "int" "init" }
    { "int" "shutdown" }
    { "int" "flags" }
    { "int" "retry-reason" }
    { "int" "num" }
    { "void*" "ptr" }
    { "void*" "next-bio" }
    { "void*" "prev-bio" }
    { "int" "references" } 
    { "ulong" "num-read" }
    { "ulong" "num-write" } 
    { "void*" "crypto-ex-data-stack" }
    { "int" "crypto-ex-data-dummy" } ;

: BIO_NOCLOSE       HEX: 00 ; inline
: BIO_CLOSE         HEX: 01 ; inline

: RSA_3             HEX: 3 ; inline
: RSA_F4            HEX: 10001 ; inline

: BIO_C_SET_SSL     109 ; inline
: BIO_C_GET_SSL     110 ; inline

LIBRARY: libcrypto

! ===============================================
! bio.h
! ===============================================

FUNCTION: bio* BIO_new_file ( char* filename, char* mode ) ;

FUNCTION: int BIO_printf ( bio* bio, char* format ) ;

FUNCTION: long BIO_ctrl ( void* bio, int cmd, long larg, void* parg ) ;

FUNCTION: void* BIO_new_socket ( int fd, int close-flag ) ;

FUNCTION: void* BIO_new ( void* method ) ;

FUNCTION: int BIO_set ( void* bio, void* method ) ;

FUNCTION: int BIO_free ( void* bio ) ;

FUNCTION: void* BIO_push ( void* bio, void* append ) ;

FUNCTION: int BIO_read ( void* b, void* buf, int len ) ;

FUNCTION: int BIO_gets ( void* b, char* buf, int size ) ;

FUNCTION: int BIO_write ( void* b, void* buf, int len ) ;

FUNCTION: int BIO_puts ( void* bp, char* buf ) ;

FUNCTION: ulong ERR_get_error (  ) ;

FUNCTION: void ERR_clear_error ( ) ;

FUNCTION: char* ERR_error_string ( ulong e, void* buf ) ;

FUNCTION: void* BIO_f_buffer (  ) ;

! ===============================================
! evp.h
! ===============================================

: EVP_MAX_MD_SIZE 64 ;

C-STRUCT: EVP_MD_CTX
    { "EVP_MD*" "digest" }
    { "ENGINE*" "engine" }
    { "ulong" "flags" }
    { "void*" "md_data" } ;

TYPEDEF: void* EVP_MD*
TYPEDEF: void* ENGINE*

! Initialize ciphers and digest tables
FUNCTION: void OpenSSL_add_all_ciphers (  ) ;

FUNCTION: void OpenSSL_add_all_digests (  ) ;

! Clean them up before exiting
FUNCTION: void EVP_cleanup (  ) ;

FUNCTION: EVP_MD* EVP_get_digestbyname ( char* name ) ;

FUNCTION: void EVP_MD_CTX_init ( EVP_MD* ctx ) ;

FUNCTION: int EVP_MD_CTX_cleanup ( EVP_MD_CTX* ctx ) ;

FUNCTION: EVP_MD_CTX* EVP_MD_CTX_create ( ) ;

FUNCTION: void EVP_MD_CTX_destroy ( EVP_MD_CTX* ctx ) ;

FUNCTION: int EVP_MD_CTX_copy_ex ( EVP_MD_CTX* out, EVP_MD_CTX* in ) ;  

FUNCTION: int EVP_DigestInit_ex ( EVP_MD_CTX* ctx, EVP_MD* type, ENGINE* impl ) ;

FUNCTION: int EVP_DigestUpdate ( EVP_MD_CTX* ctx, void* d, uint cnt ) ;

FUNCTION: int EVP_DigestFinal_ex ( EVP_MD_CTX* ctx, void* md, uint* s ) ;

FUNCTION: int EVP_Digest ( void* data, uint count, void* md, uint* size, EVP_MD* type, ENGINE* impl ) ;

FUNCTION: int EVP_MD_CTX_copy ( EVP_MD_CTX* out, EVP_MD_CTX* in ) ;  

FUNCTION: int EVP_DigestInit ( EVP_MD_CTX* ctx, EVP_MD* type ) ;

FUNCTION: int EVP_DigestFinal ( EVP_MD_CTX* ctx, void* md, uint* s ) ;

FUNCTION: void* PEM_read_bio_DHparams ( void* bp, void* x, void* cb,
                                        void* u ) ;

! ===============================================
! rsa.h
! ===============================================

FUNCTION: void* RSA_generate_key ( int num, ulong e, void* callback,
                                   void* cb_arg ) ;

FUNCTION: int RSA_check_key ( void* rsa ) ;

FUNCTION: void RSA_free ( void* rsa ) ;

FUNCTION: int RSA_print_fp ( void* fp, void* x, int offset ) ;
