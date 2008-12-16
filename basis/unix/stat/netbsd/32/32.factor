USING: kernel alien.syntax math ;
IN: unix.stat

! NetBSD 4.0

C-STRUCT: stat
    { "dev_t" "st_dev" }
    { "mode_t" "st_mode" }
    { "ino_t" "st_ino" }
    { "nlink_t" "st_nlink" }
    { "uid_t" "st_uid" }
    { "gid_t" "st_gid" }
    { "dev_t" "st_rdev" }
    { "timespec" "st_atimespec" }
    { "timespec" "st_mtimespec" }
    { "timespec" "st_ctimespec" }
    { "timespec" "st_birthtimespec" }
    { "off_t" "st_size" }
    { "blkcnt_t" "st_blocks" }
    { "blksize_t" "st_blksize" }
    { "uint32_t" "st_flags" }
    { "uint32_t" "st_gen" }
    { { "uint32_t" 2 } "st_qspare" } ;

FUNCTION: int __stat30  ( char* pathname, stat* buf ) ;
FUNCTION: int __lstat30 ( char* pathname, stat* buf ) ;

CONSTANT: stat ( pathname buf -- n ) __stat30
CONSTANT: lstat ( pathname buf -- n ) __lstat30
