USING: alien.syntax ;
IN: unix

: FD_SETSIZE 1024 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" } 
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "void*" "addr" }
    { "char*" "canonname" }
    { "addrinfo*" "next" } ;

C-STRUCT: dirent
    { "__uint32_t" "d_fileno" }
    { "__uint16_t" "d_reclen" }
    { "__uint8_t"  "d_type" }
    { "__uint8_t"  "d_namlen" }
    { { "char" 256 } "d_name" } ;

: EPERM 1 ; inline
: ENOENT 2 ; inline
: ESRCH 3 ; inline
: EINTR 4 ; inline
: EIO 5 ; inline
: ENXIO 6 ; inline
: E2BIG 7 ; inline
: ENOEXEC 8 ; inline
: EBADF 9 ; inline
: ECHILD 10 ; inline
: EDEADLK 11 ; inline
: ENOMEM 12 ; inline
: EACCES 13 ; inline
: EFAULT 14 ; inline
: ENOTBLK 15 ; inline
: EBUSY 16 ; inline
: EEXIST 17 ; inline
: EXDEV 18 ; inline
: ENODEV 19 ; inline
: ENOTDIR 20 ; inline
: EISDIR 21 ; inline
: EINVAL 22 ; inline
: ENFILE 23 ; inline
: EMFILE 24 ; inline
: ENOTTY 25 ; inline
: ETXTBSY 26 ; inline
: EFBIG 27 ; inline
: ENOSPC 28 ; inline
: ESPIPE 29 ; inline
: EROFS 30 ; inline
: EMLINK 31 ; inline
: EPIPE 32 ; inline
: EDOM 33 ; inline
: ERANGE 34 ; inline
: EAGAIN 35 ; inline
: EWOULDBLOCK EAGAIN ; inline
: EINPROGRESS 36 ; inline
: EALREADY 37 ; inline
: ENOTSOCK 38 ; inline
: EDESTADDRREQ 39 ; inline
: EMSGSIZE 40 ; inline
: EPROTOTYPE 41 ; inline
: ENOPROTOOPT 42 ; inline
: EPROTONOSUPPORT 43 ; inline
: ESOCKTNOSUPPORT 44 ; inline
: EOPNOTSUPP 45 ; inline
: EPFNOSUPPORT 46 ; inline
: EAFNOSUPPORT 47 ; inline
: EADDRINUSE 48 ; inline
: EADDRNOTAVAIL 49 ; inline
: ENETDOWN 50 ; inline
: ENETUNREACH 51 ; inline
: ENETRESET 52 ; inline
: ECONNABORTED 53 ; inline
: ECONNRESET 54 ; inline
: ENOBUFS 55 ; inline
: EISCONN 56 ; inline
: ENOTCONN 57 ; inline
: ESHUTDOWN 58 ; inline
: ETOOMANYREFS 59 ; inline
: ETIMEDOUT 60 ; inline
: ECONNREFUSED 61 ; inline
: ELOOP 62 ; inline
: ENAMETOOLONG 63 ; inline
: EHOSTDOWN 64 ; inline
: EHOSTUNREACH 65 ; inline
: ENOTEMPTY 66 ; inline
: EPROCLIM 67 ; inline
: EUSERS 68 ; inline
: EDQUOT 69 ; inline
: ESTALE 70 ; inline
: EREMOTE 71 ; inline
: EBADRPC 72 ; inline
: ERPCMISMATCH 73 ; inline
: EPROGUNAVAIL 74 ; inline
: EPROGMISMATCH 75 ; inline
: EPROCUNAVAIL 76 ; inline
: ENOLCK 77 ; inline
: ENOSYS 78 ; inline
: EFTYPE 79 ; inline
: EAUTH 80 ; inline
: ENEEDAUTH 81 ; inline
: EIPSEC 82 ; inline
: ENOATTR 83 ; inline
: EILSEQ 84 ; inline
: ENOMEDIUM 85 ; inline
: EMEDIUMTYPE 86 ; inline
: EOVERFLOW 87 ; inline
: ECANCELED 88 ; inline
