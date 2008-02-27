! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix
USING: alien alien.c-types alien.syntax kernel libc structs
math namespaces system combinators vocabs.loader ;

! ! ! Unix types

TYPEDEF:  long  word
TYPEDEF: ulong uword

TYPEDEF:  long longword
TYPEDEF: ulong ulongword

TYPEDEF: long ssize_t
TYPEDEF: longword blksize_t
TYPEDEF: longword blkcnt_t
TYPEDEF: longlong quad_t
TYPEDEF: ulonglong dev_t
TYPEDEF: uint gid_t
TYPEDEF: uint in_addr_t
TYPEDEF: ulong ino_t
TYPEDEF: int pid_t
TYPEDEF: uint socklen_t
TYPEDEF: uint time_t
TYPEDEF: uint uid_t
TYPEDEF: ulong size_t
TYPEDEF: ulong u_long
TYPEDEF: uint mode_t
TYPEDEF: uword nlink_t
TYPEDEF: void* caddr_t

TYPEDEF: ulong off_t
TYPEDEF-IF: bsd? ulonglong off_t

C-STRUCT: tm
    { "int" "sec" }    ! Seconds: 0-59 (K&R says 0-61?)
    { "int" "min" }    ! Minutes: 0-59
    { "int" "hour" }   ! Hours since midnight: 0-23
    { "int" "mday" }   ! Day of the month: 1-31
    { "int" "mon" }    ! Months *since* january: 0-11
    { "int" "year" }   ! Years since 1900
    { "int" "wday" }   ! Days since Sunday (0-6)
    { "int" "yday" }   ! Days since Jan. 1: 0-365
    { "int" "isdst" }  ! +1 Daylight Savings Time, 0 No DST,
    { "long" "gmtoff" } ! Seconds: 0-59 (K&R says 0-61?)
    { "char*" "zone" } ;

C-STRUCT: timespec
    { "time_t" "sec" }
    { "long" "nsec" } ;

: make-timespec ( ms -- timespec )
    1000 /mod 1000000 *
    "timespec" <c-object>
    [ set-timespec-nsec ] keep
    [ set-timespec-sec ] keep ;

! ! ! Unix constants

! File type
: S_IFMT    OCT: 0170000 ; inline ! type of file
: S_IFIFO   OCT: 0010000 ; inline ! named pipe (fifo)
: S_IFCHR   OCT: 0020000 ; inline ! character special
: S_IFDIR   OCT: 0040000 ; inline ! directory
: S_IFBLK   OCT: 0060000 ; inline ! block special
: S_IFREG   OCT: 0100000 ; inline ! regular
: S_IFLNK   OCT: 0120000 ; inline ! symbolic link
: S_IFSOCK  OCT: 0140000 ; inline ! socket
: S_IFWHT   OCT: 0160000 ; inline ! whiteout
: S_IFXATTR OCT: 0200000 ; inline ! extended attribute

! File mode
! Read, write, execute/search by owner
: S_IRWXU OCT: 0000700 ; inline    ! rwx mask owner
: S_IRUSR OCT: 0000400 ; inline    ! r owner
: S_IWUSR OCT: 0000200 ; inline    ! w owner
: S_IXUSR OCT: 0000100 ; inline    ! x owner
! Read, write, execute/search by group
: S_IRWXG OCT: 0000070 ; inline    ! rwx mask group
: S_IRGRP OCT: 0000040 ; inline    ! r group
: S_IWGRP OCT: 0000020 ; inline    ! w group
: S_IXGRP OCT: 0000010 ; inline    ! x group
! Read, write, execute/search by others
: S_IRWXO OCT: 0000007 ; inline    ! rwx mask other
: S_IROTH OCT: 0000004 ; inline    ! r other
: S_IWOTH OCT: 0000002 ; inline    ! w other
: S_IXOTH OCT: 0000001 ; inline    ! x other

: S_ISUID OCT: 0004000 ; inline    ! set user id on execution
: S_ISGID OCT: 0002000 ; inline    ! set group id on execution
: S_ISVTX OCT: 0001000 ; inline    ! sticky bit

: PROT_NONE   0 ; inline
: PROT_READ   1 ; inline
: PROT_WRITE  2 ; inline
: PROT_EXEC   4 ; inline

: MAP_FILE    0 ; inline
: MAP_SHARED  1 ; inline
: MAP_PRIVATE 2 ; inline

: MAP_FAILED -1 <alien> ; inline

! ! ! Unix functions
LIBRARY: factor
FUNCTION: int err_no ( ) ;

LIBRARY: libc

FUNCTION: int accept ( int s, void* sockaddr, socklen_t* socklen ) ;
FUNCTION: int bind ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int chdir ( char* path ) ;
FUNCTION: int chmod ( char* path, mode_t mode ) ;
FUNCTION: int chown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int chroot ( char* path ) ;
FUNCTION: void close ( int fd ) ;
FUNCTION: int connect ( int s, void* name, socklen_t namelen ) ;
FUNCTION: int dup2 ( int oldd, int newd ) ;
! FUNCTION: int dup ( int oldd ) ;
FUNCTION: int execv ( char* path, char** argv ) ;
FUNCTION: int execvp ( char* path, char** argv ) ;
FUNCTION: int execve ( char* path, char** argv, char** envp ) ;
FUNCTION: int fchdir ( int fd ) ;
FUNCTION: int fchmod ( int fd, mode_t mode ) ;
FUNCTION: int fchown ( int fd, uid_t owner, gid_t group ) ;
FUNCTION: int fcntl ( int fd, int cmd, int arg ) ;
FUNCTION: int flock ( int fd, int operation ) ;
FUNCTION: pid_t fork ( ) ;
FUNCTION: void freeaddrinfo ( addrinfo* ai ) ;
FUNCTION: int futimes ( int id, timeval[2] times ) ;
FUNCTION: char* gai_strerror ( int ecode ) ;
FUNCTION: int getaddrinfo ( char* hostname, char* servname, addrinfo* hints, addrinfo** res ) ;
FUNCTION: char* getcwd ( char* buf, size_t size ) ;
FUNCTION: pid_t getpid ;
FUNCTION: int getdtablesize ;
FUNCTION: gid_t getegid ;
FUNCTION: uid_t geteuid ;
FUNCTION: gid_t getgid ;
FUNCTION: int getgroups ( int gidsetlen, gid_t* gidset ) ;
FUNCTION: int gethostname ( char* name, int len ) ;
FUNCTION: uid_t getuid ;
FUNCTION: uint htonl ( uint n ) ;
FUNCTION: ushort htons ( ushort n ) ;
! FUNCTION: int issetugid ;
FUNCTION: int ioctl ( int fd, ulong request, char* argp ) ;
FUNCTION: int lchown ( char* path, uid_t owner, gid_t group ) ;
FUNCTION: int listen ( int s, int backlog ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;
FUNCTION: off_t lseek ( int fildes, off_t offset, int whence ) ;
FUNCTION: int mkdir ( char* path, mode_t mode ) ;
FUNCTION: void* mmap ( void* addr, size_t len, int prot, int flags, int fd, off_t offset ) ;
FUNCTION: int munmap ( void* addr, size_t len ) ;
FUNCTION: uint ntohl ( uint n ) ;
FUNCTION: ushort ntohs ( ushort n ) ;
FUNCTION: int open ( char* path, int flags, int prot ) ;
FUNCTION: int pclose ( void* file ) ;
FUNCTION: int pipe ( int* filedes ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: ssize_t read ( int fd, void* buf, size_t nbytes ) ;
FUNCTION: ssize_t recv ( int s, void* buf, size_t nbytes, int flags ) ;
FUNCTION: ssize_t recvfrom ( int s, void* buf, size_t nbytes, int flags, sockaddr-in* from, socklen_t* fromlen ) ;
FUNCTION: int rename ( char* from, char* to ) ;
FUNCTION: int rmdir ( char* path ) ;
FUNCTION: int select ( int nfds, void* readfds, void* writefds, void* exceptfds, timeval* timeout ) ;
FUNCTION: ssize_t sendto ( int s, void* buf, size_t len, int flags, sockaddr-in* to, socklen_t tolen ) ;
FUNCTION: int setegid ( gid_t egid ) ;
FUNCTION: int seteuid ( uid_t euid ) ;
FUNCTION: int setgid ( gid_t gid ) ;
FUNCTION: int setgroups ( int ngroups, gid_t* gidset ) ;
FUNCTION: int setregid ( gid_t rgid, gid_t egid ) ;
FUNCTION: int setreuid ( uid_t ruid, uid_t euid ) ;
FUNCTION: int setsockopt ( int s, int level, int optname, void* optval, socklen_t optlen ) ;
FUNCTION: int setuid ( uid_t uid ) ;
FUNCTION: int socket ( int domain, int type, int protocol ) ;
FUNCTION: char* strerror ( int errno ) ;
FUNCTION: int system ( char* command ) ;
FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: int unlink ( char* path ) ;
FUNCTION: int utimes ( char* path, timeval[2] times ) ;

: SIGKILL 9 ; inline
: SIGTERM 15 ; inline

FUNCTION: int kill ( pid_t pid, int sig ) ;

! Flags for waitpid

: WNOHANG   1 ; inline
: WUNTRACED 2 ; inline

: WSTOPPED   2 ; inline
: WEXITED    4 ; inline
: WCONTINUED 8 ; inline
: WNOWAIT    HEX: 1000000 ; inline

! Examining status

: WTERMSIG ( status -- value )
    HEX: 7f bitand ; inline

: WIFEXITED ( status -- ? )
    WTERMSIG zero? ; inline

: WEXITSTATUS ( status -- value )
    HEX: ff00 bitand -8 shift ; inline

: WIFSIGNALED ( status -- ? )
    HEX: 7f bitand 1+ -1 shift 0 > ; inline

: WCOREFLAG ( -- value )
    HEX: 80 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand zero? not ; inline

: WIFSTOPPED ( status -- ? )
    HEX: ff bitand HEX: 7f = ; inline

: WSTOPSIG ( status -- value )
    WEXITSTATUS ; inline

FUNCTION: pid_t wait ( int* status ) ;
FUNCTION: pid_t waitpid ( pid_t wpid, int* status, int options ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: ssize_t write ( int fd, void* buf, size_t nbytes ) ;

{
    { [ linux? ] [ "unix.linux" require ] }
    { [ bsd? ] [ "unix.bsd" require ] }
    { [ solaris? ] [ "unix.solaris" require ] }
    { [ t ] [ ] }
} cond

