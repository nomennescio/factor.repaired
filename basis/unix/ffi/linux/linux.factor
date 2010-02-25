! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct unix.types ;
IN: unix.ffi

CONSTANT: MAXPATHLEN 1024

CONSTANT: O_RDONLY   HEX: 0000
CONSTANT: O_WRONLY   HEX: 0001
CONSTANT: O_RDWR     HEX: 0002
CONSTANT: O_CREAT    HEX: 0040
CONSTANT: O_EXCL     HEX: 0080
CONSTANT: O_NOCTTY   HEX: 0100
CONSTANT: O_TRUNC    HEX: 0200
CONSTANT: O_APPEND   HEX: 0400
CONSTANT: O_NONBLOCK HEX: 0800

ALIAS: O_NDELAY O_NONBLOCK

CONSTANT: SOL_SOCKET 1

CONSTANT: FD_SETSIZE 1024

CONSTANT: SO_REUSEADDR 2
CONSTANT: SO_OOBINLINE 10
CONSTANT: SO_SNDTIMEO HEX: 15
CONSTANT: SO_RCVTIMEO HEX: 14

CONSTANT: F_SETFD 2
CONSTANT: FD_CLOEXEC 1

CONSTANT: F_SETFL 4

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { addr void* }
    { canonname c-string }
    { next addrinfo* } ;

STRUCT: sockaddr-in
    { family ushort }
    { port ushort }
    { addr in_addr_t }
    { unused longlong } ;

STRUCT: sockaddr-in6
    { family ushort }
    { port ushort }
    { flowinfo uint }
    { addr uchar[16] }
    { scopeid uint } ;

CONSTANT: max-un-path 108

STRUCT: sockaddr-un
    { family ushort }
    { path { char max-un-path } } ;

CONSTANT: SOCK_STREAM 1
CONSTANT: SOCK_DGRAM 2

CONSTANT: AF_UNSPEC 0
CONSTANT: AF_UNIX 1
CONSTANT: AF_INET 2
CONSTANT: AF_INET6 10

ALIAS: PF_UNSPEC AF_UNSPEC
ALIAS: PF_UNIX AF_UNIX
ALIAS: PF_INET AF_INET
ALIAS: PF_INET6 AF_INET6

CONSTANT: IPPROTO_TCP 6
CONSTANT: IPPROTO_UDP 17

CONSTANT: AI_PASSIVE 1

CONSTANT: SEEK_SET 0
CONSTANT: SEEK_CUR 1
CONSTANT: SEEK_END 2

STRUCT: passwd
    { pw_name c-string }
    { pw_passwd c-string }
    { pw_uid uid_t }
    { pw_gid gid_t }
    { pw_gecos c-string }
    { pw_dir c-string }
    { pw_shell c-string } ;

! dirent64
STRUCT: dirent
    { d_ino ulonglong }
    { d_off longlong }
    { d_reclen ushort }
    { d_type uchar }
    { d_name char[256] } ;

FUNCTION: int open64 ( c-string path, int flags, int prot ) ;
FUNCTION: dirent* readdir64 ( DIR* dirp ) ;
FUNCTION: int readdir64_r ( void* dirp, dirent* entry, dirent** result ) ;

CONSTANT: EPERM 1
CONSTANT: ENOENT 2
CONSTANT: ESRCH 3
CONSTANT: EINTR 4
CONSTANT: EIO 5
CONSTANT: ENXIO 6
CONSTANT: E2BIG 7
CONSTANT: ENOEXEC 8
CONSTANT: EBADF 9
CONSTANT: ECHILD 10
CONSTANT: EAGAIN 11
CONSTANT: ENOMEM 12
CONSTANT: EACCES 13
CONSTANT: EFAULT 14
CONSTANT: ENOTBLK 15
CONSTANT: EBUSY 16
CONSTANT: EEXIST 17
CONSTANT: EXDEV 18
CONSTANT: ENODEV 19
CONSTANT: ENOTDIR 20
CONSTANT: EISDIR 21
CONSTANT: EINVAL 22
CONSTANT: ENFILE 23
CONSTANT: EMFILE 24
CONSTANT: ENOTTY 25
CONSTANT: ETXTBSY 26
CONSTANT: EFBIG 27
CONSTANT: ENOSPC 28
CONSTANT: ESPIPE 29
CONSTANT: EROFS 30
CONSTANT: EMLINK 31
CONSTANT: EPIPE 32
CONSTANT: EDOM 33
CONSTANT: ERANGE 34
CONSTANT: EDEADLK 35
CONSTANT: ENAMETOOLONG 36
CONSTANT: ENOLCK 37
CONSTANT: ENOSYS 38
CONSTANT: ENOTEMPTY 39
CONSTANT: ELOOP 40
ALIAS: EWOULDBLOCK EAGAIN
CONSTANT: ENOMSG 42
CONSTANT: EIDRM 43
CONSTANT: ECHRNG 44
CONSTANT: EL2NSYNC 45
CONSTANT: EL3HLT 46
CONSTANT: EL3RST 47
CONSTANT: ELNRNG 48
CONSTANT: EUNATCH 49
CONSTANT: ENOCSI 50
CONSTANT: EL2HLT 51
CONSTANT: EBADE 52
CONSTANT: EBADR 53
CONSTANT: EXFULL 54
CONSTANT: ENOANO 55
CONSTANT: EBADRQC 56
CONSTANT: EBADSLT 57
ALIAS: EDEADLOCK EDEADLK
CONSTANT: EBFONT 59
CONSTANT: ENOSTR 60
CONSTANT: ENODATA 61
CONSTANT: ETIME 62
CONSTANT: ENOSR 63
CONSTANT: ENONET 64
CONSTANT: ENOPKG 65
CONSTANT: EREMOTE 66
CONSTANT: ENOLINK 67
CONSTANT: EADV 68
CONSTANT: ESRMNT 69
CONSTANT: ECOMM 70
CONSTANT: EPROTO 71
CONSTANT: EMULTIHOP 72
CONSTANT: EDOTDOT 73
CONSTANT: EBADMSG 74
CONSTANT: EOVERFLOW 75
CONSTANT: ENOTUNIQ 76
CONSTANT: EBADFD 77
CONSTANT: EREMCHG 78
CONSTANT: ELIBACC 79
CONSTANT: ELIBBAD 80
CONSTANT: ELIBSCN 81
CONSTANT: ELIBMAX 82
CONSTANT: ELIBEXEC 83
CONSTANT: EILSEQ 84
CONSTANT: ERESTART 85
CONSTANT: ESTRPIPE 86
CONSTANT: EUSERS 87
CONSTANT: ENOTSOCK 88
CONSTANT: EDESTADDRREQ 89
CONSTANT: EMSGSIZE 90
CONSTANT: EPROTOTYPE 91
CONSTANT: ENOPROTOOPT 92
CONSTANT: EPROTONOSUPPORT 93
CONSTANT: ESOCKTNOSUPPORT 94
CONSTANT: EOPNOTSUPP 95
CONSTANT: EPFNOSUPPORT 96
CONSTANT: EAFNOSUPPORT 97
CONSTANT: EADDRINUSE 98
CONSTANT: EADDRNOTAVAIL 99
CONSTANT: ENETDOWN 100
CONSTANT: ENETUNREACH 101
CONSTANT: ENETRESET 102
CONSTANT: ECONNABORTED 103
CONSTANT: ECONNRESET 104
CONSTANT: ENOBUFS 105
CONSTANT: EISCONN 106
CONSTANT: ENOTCONN 107
CONSTANT: ESHUTDOWN 108
CONSTANT: ETOOMANYREFS 109
CONSTANT: ETIMEDOUT 110
CONSTANT: ECONNREFUSED 111
CONSTANT: EHOSTDOWN 112
CONSTANT: EHOSTUNREACH 113
CONSTANT: EALREADY 114
CONSTANT: EINPROGRESS 115
CONSTANT: ESTALE 116
CONSTANT: EUCLEAN 117
CONSTANT: ENOTNAM 118
CONSTANT: ENAVAIL 119
CONSTANT: EISNAM 120
CONSTANT: EREMOTEIO 121
CONSTANT: EDQUOT 122
CONSTANT: ENOMEDIUM 123
CONSTANT: EMEDIUMTYPE 124
CONSTANT: ECANCELED 125
CONSTANT: ENOKEY 126
CONSTANT: EKEYEXPIRED 127
CONSTANT: EKEYREVOKED 128
CONSTANT: EKEYREJECTED 129
CONSTANT: EOWNERDEAD 130
CONSTANT: ENOTRECOVERABLE 131
