USING: combinators io io.files io.streams.string kernel math
math.parser continuations namespaces pack prettyprint sequences
strings system tools.hexdump io.encodings.binary summary accessors
io.backend symbols byte-arrays ;
IN: tar

: zero-checksum 256 ; inline
: block-size 512 ; inline

TUPLE: tar-header name mode uid gid size mtime checksum typeflag
linkname magic version uname gname devmajor devminor prefix ;
ERROR: checksum-error ;

SYMBOLS: base-dir filename ;

: tar-trim ( seq -- newseq ) [ "\0 " member? ] trim ;

: read-tar-header ( -- obj )
    \ tar-header new
    100 read-c-string* >>name
    8 read-c-string* tar-trim oct> >>mode
    8 read-c-string* tar-trim oct> >>uid
    8 read-c-string* tar-trim oct> >>gid
    12 read-c-string* tar-trim oct> >>size
    12 read-c-string* tar-trim oct> >>mtime
    8 read-c-string* tar-trim oct> >>checksum
    read1 >>typeflag
    100 read-c-string* >>linkname
    6 read >>magic
    2 read >>version
    32 read-c-string* >>uname
    32 read-c-string* >>gname
    8 read tar-trim oct> >>devmajor
    8 read tar-trim oct> >>devminor
    155 read-c-string* >>prefix ;

: header-checksum ( seq -- x )
    148 cut-slice 8 tail-slice
    [ sum ] bi@ + 256 + ;

: read-data-blocks ( tar-header -- )
    dup size>> 0 > [
        block-size read [
            over size>> dup block-size <= [
                head-slice >byte-array write drop
            ] [
                drop write
                [ block-size - ] change-size
                read-data-blocks
            ] if
        ] [
            drop
        ] if*
    ] [
        drop
    ] if ;

: parse-tar-header ( seq -- obj )
    [ header-checksum ] keep over zero-checksum = [
        2drop
        \ tar-header new
            0 >>size
            0 >>checksum
    ] [
        [ read-tar-header ] with-string-reader
        [ checksum>> = [ checksum-error ] unless ] keep
    ] if ;

ERROR: unknown-typeflag ch ;
M: unknown-typeflag summary ( obj -- str )
    ch>> 1string "Unknown typeflag: " prepend ;

: tar-prepend-path ( path -- newpath )
    base-dir get prepend-path ;

: read/write-blocks ( tar-header path -- )
    binary [ read-data-blocks ] with-file-writer ;

! Normal file
: typeflag-0 ( header -- )
    dup name>> tar-prepend-path read/write-blocks ;

! Hard link
: typeflag-1 ( header -- ) unknown-typeflag ;

! Symlink
: typeflag-2 ( header -- )
    [ name>> ] [ linkname>> ] bi
    [ make-link ] 2curry ignore-errors ;

! character special
: typeflag-3 ( header -- ) unknown-typeflag ;

! Block special
: typeflag-4 ( header -- ) unknown-typeflag ;

! Directory
: typeflag-5 ( header -- )
    name>> tar-prepend-path make-directories ;

! FIFO
: typeflag-6 ( header -- ) unknown-typeflag ;

! Contiguous file
: typeflag-7 ( header -- ) unknown-typeflag ;

! Global extended header
: typeflag-8 ( header -- ) unknown-typeflag ;

! Extended header
: typeflag-9 ( header -- ) unknown-typeflag ;

! Global POSIX header
: typeflag-g ( header -- ) typeflag-0 ;

! Extended POSIX header
: typeflag-x ( header -- ) unknown-typeflag ;

! Solaris access control list
: typeflag-A ( header -- ) unknown-typeflag ;

! GNU dumpdir
: typeflag-D ( header -- ) unknown-typeflag ;

! Solaris extended attribute file
: typeflag-E ( header -- ) unknown-typeflag ;

! Inode metadata
: typeflag-I ( header -- ) unknown-typeflag ;

! Long link name
: typeflag-K ( header -- ) unknown-typeflag ;

! Long file name
: typeflag-L ( header -- )
    drop ;
    ! <string-writer> [ read-data-blocks ] keep
    ! >string [ zero? ] trim-right filename set
    ! filename get tar-prepend-path make-directories ;

! Multi volume continuation entry
: typeflag-M ( header -- ) unknown-typeflag ;

! GNU long file name
: typeflag-N ( header -- ) unknown-typeflag ;

! Sparse file
: typeflag-S ( header -- ) unknown-typeflag ;

! Volume header
: typeflag-V ( header -- ) unknown-typeflag ;

! Vendor extended header type
: typeflag-X ( header -- ) unknown-typeflag ;

: (parse-tar) ( -- )
    block-size read dup length 512 = [
        parse-tar-header
        dup typeflag>>
        {
            { 0 [ typeflag-0 ] }
            { CHAR: 0 [ typeflag-0 ] }
            ! { CHAR: 1 [ typeflag-1 ] }
            { CHAR: 2 [ typeflag-2 ] }
            ! { CHAR: 3 [ typeflag-3 ] }
            ! { CHAR: 4 [ typeflag-4 ] }
            { CHAR: 5 [ typeflag-5 ] }
            ! { CHAR: 6 [ typeflag-6 ] }
            ! { CHAR: 7 [ typeflag-7 ] }
            { CHAR: g [ typeflag-g ] }
            ! { CHAR: x [ typeflag-x ] }
            ! { CHAR: A [ typeflag-A ] }
            ! { CHAR: D [ typeflag-D ] }
            ! { CHAR: E [ typeflag-E ] }
            ! { CHAR: I [ typeflag-I ] }
            ! { CHAR: K [ typeflag-K ] }
            ! { CHAR: L [ typeflag-L ] }
            ! { CHAR: M [ typeflag-M ] }
            ! { CHAR: N [ typeflag-N ] }
            ! { CHAR: S [ typeflag-S ] }
            ! { CHAR: V [ typeflag-V ] }
            ! { CHAR: X [ typeflag-X ] }
            { f [ drop ] }
        } case (parse-tar)
    ] [
        drop
    ] if ;

: parse-tar ( path -- )
    normalize-path dup parent-directory base-dir [
         binary [ (parse-tar) ] with-file-reader
    ] with-variable ;
