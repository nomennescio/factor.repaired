USING: alien.c-types alien.strings alien.syntax destructors
kernel system ;
IN: libc

LIBRARY: libc

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

CONSTANT: SIGHUP     1
CONSTANT: SIGINT     2
CONSTANT: SIGQUIT    3
CONSTANT: SIGILL     4
CONSTANT: SIGTRAP    5
CONSTANT: SIGABRT    6
CONSTANT: SIGEMT     7
CONSTANT: SIGFPE     8
CONSTANT: SIGKILL    9
CONSTANT: SIGBUS    10
CONSTANT: SIGSEGV   11
CONSTANT: SIGSYS    12
CONSTANT: SIGPIPE   13
CONSTANT: SIGALRM   14
CONSTANT: SIGTERM   15
CONSTANT: SIGURG    16
CONSTANT: SIGSTOP   17
CONSTANT: SIGTSTP   18
CONSTANT: SIGCONT   19
CONSTANT: SIGCHLD   20
CONSTANT: SIGTTIN   21
CONSTANT: SIGTTOU   22
CONSTANT: SIGIO     23
CONSTANT: SIGXCPU   24
CONSTANT: SIGXFSZ   25
CONSTANT: SIGVTALRM 26
CONSTANT: SIGPROF   27
CONSTANT: SIGWINCH  28
CONSTANT: SIGINFO   29
CONSTANT: SIGUSR1   30
CONSTANT: SIGUSR2   31

FUNCTION: int strerror_r ( int errno, char* buf, size_t buflen ) ;

M: macosx strerror ( errno -- str )
    [
        1024 [ malloc &free ] keep [ strerror_r ] 2keep drop nip
        alien>native-string
    ] with-destructors ;
