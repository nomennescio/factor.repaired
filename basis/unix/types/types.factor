USING: kernel system alien.syntax combinators vocabs.loader
system ;
IN: unix.types

TYPEDEF: void* caddr_t
TYPEDEF: uint in_addr_t
TYPEDEF: uint socklen_t

TYPEDEF: char int8_t
TYPEDEF: short int16_t
TYPEDEF: int int32_t
TYPEDEF: longlong int64_t

TYPEDEF: uchar uint8_t
TYPEDEF: ushort uint16_t
TYPEDEF: uint uint32_t
TYPEDEF: ulonglong uint64_t

TYPEDEF: uchar u_int8_t
TYPEDEF: ushort u_int16_t
TYPEDEF: uint u_int32_t
TYPEDEF: ulonglong u_int64_t

TYPEDEF: char __int8_t
TYPEDEF: short __int16_t
TYPEDEF: int __int32_t
TYPEDEF: longlong __int64_t

TYPEDEF: uchar __uint8_t
TYPEDEF: ushort __uint16_t
TYPEDEF: uint __uint32_t
TYPEDEF: ulonglong __uint64_t


os {
    { linux   [ "unix.types.linux"   require ] }
    { macosx  [ "unix.types.macosx"  require ] }
    { freebsd [ "unix.types.freebsd" require ] }
    { openbsd [ "unix.types.openbsd" require ] }
    { netbsd  [ "unix.types.netbsd"  require ] }
    { winnt [ ] }
} case
