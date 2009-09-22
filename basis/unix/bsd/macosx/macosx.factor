USING: alien.c-types alien.syntax unix.time unix.types
unix.types.macosx classes.struct ;
IN: unix

CONSTANT: FD_SETSIZE 1024

STRUCT: addrinfo
    { flags int }
    { family int } 
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname char* }
    { addr void* }
    { next addrinfo* } ;

CONSTANT: _UTX_USERSIZE 256
CONSTANT: _UTX_LINESIZE 32
CONSTANT: _UTX_IDSIZE 4
CONSTANT: _UTX_HOSTSIZE 256
    
STRUCT: utmpx
    { ut_user { char _UTX_USERSIZE } }
    { ut_id   { char _UTX_IDSIZE   } }
    { ut_line { char _UTX_LINESIZE } }
    { ut_pid  pid_t }
    { ut_type short }
    { ut_tv   timeval }
    { ut_host { char _UTX_HOSTSIZE } }
    { ut_pad  { uint 16 } } ;

CONSTANT: __DARWIN_MAXPATHLEN 1024
CONSTANT: __DARWIN_MAXNAMELEN 255
CONSTANT: __DARWIN_MAXNAMELEN+1 255

STRUCT: dirent
    { d_ino ino_t }
    { d_reclen __uint16_t }
    { d_type __uint8_t }
    { d_namlen __uint8_t }
    { d_name { char __DARWIN_MAXNAMELEN+1 } } ;

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
CONSTANT: EDEADLK 11
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
CONSTANT: EAGAIN 35
ALIAS: EWOULDBLOCK EAGAIN
CONSTANT: EINPROGRESS 36
CONSTANT: EALREADY 37
CONSTANT: ENOTSOCK 38
CONSTANT: EDESTADDRREQ 39
CONSTANT: EMSGSIZE 40
CONSTANT: EPROTOTYPE 41
CONSTANT: ENOPROTOOPT 42
CONSTANT: EPROTONOSUPPORT 43
CONSTANT: ESOCKTNOSUPPORT 44
CONSTANT: ENOTSUP 45
CONSTANT: EPFNOSUPPORT 46
CONSTANT: EAFNOSUPPORT 47
CONSTANT: EADDRINUSE 48
CONSTANT: EADDRNOTAVAIL 49
CONSTANT: ENETDOWN 50
CONSTANT: ENETUNREACH 51
CONSTANT: ENETRESET 52
CONSTANT: ECONNABORTED 53
CONSTANT: ECONNRESET 54
CONSTANT: ENOBUFS 55
CONSTANT: EISCONN 56
CONSTANT: ENOTCONN 57
CONSTANT: ESHUTDOWN 58
CONSTANT: ETOOMANYREFS 59
CONSTANT: ETIMEDOUT 60
CONSTANT: ECONNREFUSED 61
CONSTANT: ELOOP 62
CONSTANT: ENAMETOOLONG 63
CONSTANT: EHOSTDOWN 64
CONSTANT: EHOSTUNREACH 65
CONSTANT: ENOTEMPTY 66
CONSTANT: EPROCLIM 67
CONSTANT: EUSERS 68
CONSTANT: EDQUOT 69
CONSTANT: ESTALE 70
CONSTANT: EREMOTE 71
CONSTANT: EBADRPC 72
CONSTANT: ERPCMISMATCH 73
CONSTANT: EPROGUNAVAIL 74
CONSTANT: EPROGMISMATCH 75
CONSTANT: EPROCUNAVAIL 76
CONSTANT: ENOLCK 77
CONSTANT: ENOSYS 78
CONSTANT: EFTYPE 79
CONSTANT: EAUTH 80
CONSTANT: ENEEDAUTH 81
CONSTANT: EPWROFF 82
CONSTANT: EDEVERR 83
CONSTANT: EOVERFLOW 84
CONSTANT: EBADEXEC 85
CONSTANT: EBADARCH 86
CONSTANT: ESHLIBVERS 87
CONSTANT: EBADMACHO 88
CONSTANT: ECANCELED 89
CONSTANT: EIDRM 90
CONSTANT: ENOMSG 91
CONSTANT: EILSEQ 92
CONSTANT: ENOATTR 93
CONSTANT: EBADMSG 94
CONSTANT: EMULTIHOP 95
CONSTANT: ENODATA 96
CONSTANT: ENOLINK 97
CONSTANT: ENOSR 98
CONSTANT: ENOSTR 99
CONSTANT: EPROTO 100
CONSTANT: ETIME 101
CONSTANT: EOPNOTSUPP 102
CONSTANT: ENOPOLICY 103
