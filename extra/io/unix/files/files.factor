! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.nonblocking io.unix.backend io.files io
unix kernel math continuations ;
IN: io.unix.files

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

M: unix-io <file-reader> ( path -- stream )
    open-read <reader> ;

: write-flags O_WRONLY O_CREAT O_TRUNC bitor bitor ;

: open-write ( path -- fd )
    write-flags file-mode open dup io-error ;

M: unix-io <file-writer> ( path -- stream )
    open-write <writer> ;

: append-flags O_WRONLY O_APPEND O_CREAT bitor bitor ;

: open-append ( path -- fd )
    append-flags file-mode open dup io-error
    [ dup 0 SEEK_END lseek io-error ] [ ] [ close ] cleanup ;

M: unix-io <file-appender> ( path -- stream )
    open-append <writer> ;

M: unix-io rename-file ( from to -- )
    rename io-error ;

M: unix-io delete-file ( path -- )
    unlink io-error ;

M: unix-io make-directory ( path -- )
    OCT: 777 mkdir io-error ;

M: unix-io delete-directory ( path -- )
    rmdir io-error ;

M: unix-io binary-roots ( -- seq )
    {
        "/bin" "/sbin"
        "/usr/bin" "/usr/sbin"
        "/usr/local/bin" "/usr/local/sbin"
        "/opt/local/bin" "/opt/local/sbin"
        "~/bin"
    } ;

M: unix-io library-roots ( -- seq )
    {
        "/lib"
        "/usr/lib"
        "/usr/local/lib"
        "/opt/local/lib"
        "/lib64"
    } ;
