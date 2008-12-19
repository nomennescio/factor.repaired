! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.encodings.utf8 io.encodings.string
kernel sequences unix.stat accessors unix combinators math
grouping system alien.strings math.bitwise alien.syntax ;
IN: unix.statfs.macosx

CONSTANT: MNT_RDONLY  HEX: 00000001
CONSTANT: MNT_SYNCHRONOUS HEX: 00000002
CONSTANT: MNT_NOEXEC  HEX: 00000004
CONSTANT: MNT_NOSUID  HEX: 00000008
CONSTANT: MNT_NODEV   HEX: 00000010
CONSTANT: MNT_UNION   HEX: 00000020
CONSTANT: MNT_ASYNC   HEX: 00000040
CONSTANT: MNT_EXPORTED HEX: 00000100
CONSTANT: MNT_QUARANTINE  HEX: 00000400
CONSTANT: MNT_LOCAL   HEX: 00001000
CONSTANT: MNT_QUOTA   HEX: 00002000
CONSTANT: MNT_ROOTFS  HEX: 00004000
CONSTANT: MNT_DOVOLFS HEX: 00008000
CONSTANT: MNT_DONTBROWSE  HEX: 00100000
CONSTANT: MNT_IGNORE_OWNERSHIP HEX: 00200000
CONSTANT: MNT_AUTOMOUNTED HEX: 00400000
CONSTANT: MNT_JOURNALED   HEX: 00800000
CONSTANT: MNT_NOUSERXATTR HEX: 01000000
CONSTANT: MNT_DEFWRITE    HEX: 02000000
CONSTANT: MNT_MULTILABEL  HEX: 04000000
CONSTANT: MNT_NOATIME HEX: 10000000
ALIAS: MNT_UNKNOWNPERMISSIONS MNT_IGNORE_OWNERSHIP

: MNT_VISFLAGMASK ( -- n )
    {
        MNT_RDONLY MNT_SYNCHRONOUS MNT_NOEXEC
        MNT_NOSUID MNT_NODEV MNT_UNION
        MNT_ASYNC MNT_EXPORTED MNT_QUARANTINE
        MNT_LOCAL MNT_QUOTA
        MNT_ROOTFS MNT_DOVOLFS MNT_DONTBROWSE
        MNT_IGNORE_OWNERSHIP MNT_AUTOMOUNTED MNT_JOURNALED
        MNT_NOUSERXATTR MNT_DEFWRITE MNT_MULTILABEL MNT_NOATIME
    } flags ; inline

CONSTANT: MNT_UPDATE  HEX: 00010000
CONSTANT: MNT_RELOAD  HEX: 00040000
CONSTANT: MNT_FORCE   HEX: 00080000

: MNT_CMDFLAGS ( -- n )
    { MNT_UPDATE MNT_RELOAD MNT_FORCE } flags ; inline

CONSTANT: VFS_GENERIC 0
CONSTANT: VFS_NUMMNTOPS 1
CONSTANT: VFS_MAXTYPENUM 1
CONSTANT: VFS_CONF 2
CONSTANT: VFS_SET_PACKAGE_EXTS 3

CONSTANT: MNT_WAIT    1
CONSTANT: MNT_NOWAIT  2

CONSTANT: VFS_CTL_VERS1   HEX: 01

CONSTANT: VFS_CTL_STATFS  HEX: 00010001
CONSTANT: VFS_CTL_UMOUNT  HEX: 00010002
CONSTANT: VFS_CTL_QUERY   HEX: 00010003
CONSTANT: VFS_CTL_NEWADDR HEX: 00010004
CONSTANT: VFS_CTL_TIMEO   HEX: 00010005
CONSTANT: VFS_CTL_NOLOCKS HEX: 00010006

C-STRUCT: vfsquery
    { "uint32_t" "vq_flags" }
    { { "uint32_t" 31 } "vq_spare" } ;

CONSTANT: VQ_NOTRESP  HEX: 0001
CONSTANT: VQ_NEEDAUTH HEX: 0002
CONSTANT: VQ_LOWDISK  HEX: 0004
CONSTANT: VQ_MOUNT    HEX: 0008
CONSTANT: VQ_UNMOUNT  HEX: 0010
CONSTANT: VQ_DEAD     HEX: 0020
CONSTANT: VQ_ASSIST   HEX: 0040
CONSTANT: VQ_NOTRESPLOCK  HEX: 0080
CONSTANT: VQ_UPDATE   HEX: 0100
CONSTANT: VQ_FLAG0200 HEX: 0200
CONSTANT: VQ_FLAG0400 HEX: 0400
CONSTANT: VQ_FLAG0800 HEX: 0800
CONSTANT: VQ_FLAG1000 HEX: 1000
CONSTANT: VQ_FLAG2000 HEX: 2000
CONSTANT: VQ_FLAG4000 HEX: 4000
CONSTANT: VQ_FLAG8000 HEX: 8000

CONSTANT: NFSV4_MAX_FH_SIZE 128
CONSTANT: NFSV3_MAX_FH_SIZE 64
CONSTANT: NFSV2_MAX_FH_SIZE 32
ALIAS: NFS_MAX_FH_SIZE NFSV4_MAX_FH_SIZE

CONSTANT: MFSNAMELEN 15
CONSTANT: MNAMELEN 90
CONSTANT: MFSTYPENAMELEN 16

C-STRUCT: fsid_t
    { { "int32_t" 2 } "val" } ;

C-STRUCT: statfs64
    { "uint32_t"        "f_bsize" }
    { "int32_t"         "f_iosize" }
    { "uint64_t"        "f_blocks" }
    { "uint64_t"        "f_bfree" }
    { "uint64_t"        "f_bavail" }
    { "uint64_t"        "f_files" }
    { "uint64_t"        "f_ffree" }
    { "fsid_t"          "f_fsid" }
    { "uid_t"           "f_owner" }
    { "uint32_t"        "f_type" }
    { "uint32_t"        "f_flags" }
    { "uint32_t"        "f_fssubtype" }
    { { "char" MFSTYPENAMELEN } "f_fstypename" }
    { { "char" MAXPATHLEN } "f_mntonname" }
    { { "char" MAXPATHLEN } "f_mntfromname" }
    { { "uint32_t" 8 } "f_reserved" } ;

FUNCTION: int statfs64 ( char* path, statfs64* buf ) ;
FUNCTION: int getmntinfo64 ( statfs64** mntbufp, int flags ) ;
