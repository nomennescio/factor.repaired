USING: alien.syntax alien.c-types math vocabs.loader
classes.struct unix.types unix.time ;
IN: unix.ffi

CONSTANT: FD_SETSIZE 256

STRUCT: addrinfo
    { flags int }
    { family int }
    { socktype int }
    { protocol int }
    { addrlen socklen_t }
    { canonname char* }
    { addr void* }
    { next addrinfo* } ;

STRUCT: dirent
    { d_fileno __uint32_t }
    { d_reclen __uint16_t }
    { d_type __uint8_t }
    { d_namlen __uint8_t }
    { d_name char[256] } ;

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
CONSTANT: EOPNOTSUPP 45
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
CONSTANT: EIDRM 82
CONSTANT: ENOMSG 83
CONSTANT: EOVERFLOW 84
CONSTANT: EILSEQ 85
CONSTANT: ENOTSUP 86
CONSTANT: ECANCELED 87
CONSTANT: EBADMSG 88
CONSTANT: ENODATA 89
CONSTANT: ENOSR 90
CONSTANT: ENOSTR 91
CONSTANT: ETIME 92
CONSTANT: ENOATTR 93
CONSTANT: EMULTIHOP 94
CONSTANT: ENOLINK 95
CONSTANT: EPROTO 96
CONSTANT: ELAST 96

TYPEDEF: __uint8_t sa_family_t

CONSTANT: _UTX_USERSIZE   32
CONSTANT: _UTX_LINESIZE   32
CONSTANT: _UTX_IDSIZE     4
CONSTANT: _UTX_HOSTSIZE   256

<<

CONSTANT: _SS_MAXSIZE 128

: _SS_ALIGNSIZE ( -- n )
    __int64_t heap-size ; inline
    
: _SS_PAD1SIZE ( -- n )
    _SS_ALIGNSIZE 2 - ; inline
    
: _SS_PAD2SIZE ( -- n )
    _SS_MAXSIZE 2 - _SS_PAD1SIZE - _SS_ALIGNSIZE - ; inline

>>

STRUCT: sockaddr_storage
    { ss_len __uint8_t }
    { ss_family sa_family_t }
    { __ss_pad1 { char _SS_PAD1SIZE } }
    { __ss_align __int64_t }
    { __ss_pad2 { char _SS_PAD2SIZE } } ;

STRUCT: exit_struct
    { e_termination uint16_t }
    { e_exit uint16_t } ;

STRUCT: utmpx
    { ut_user { char _UTX_USERSIZE } }
    { ut_id   { char _UTX_IDSIZE   } }
    { ut_line { char _UTX_LINESIZE } }
    { ut_host { char _UTX_HOSTSIZE } }
    { ut_session uint16_t }
    { ut_type uint16_t }
    { ut_pid pid_t }
    { ut_exit exit_struct }
    { ut_ss sockaddr_storage }
    { ut_tv timeval }
    { ut_pad { uint32_t 10 } } ;
