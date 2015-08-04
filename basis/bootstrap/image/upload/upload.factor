! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image checksums checksums.openssl fry io
io.directories io.encodings.ascii io.encodings.utf8 io.files
io.files.temp io.files.unique io.launcher io.pathnames kernel
make math.parser namespaces sequences splitting system ;
IN: bootstrap.image.upload

SYMBOL: upload-images-destination
SYMBOL: build-images-destination

: latest-destination ( -- dest )
    upload-images-destination get
    "slava_pestov@downloads.factorcode.org:downloads.factorcode.org/images/latest/"
    or ;

: build-destination ( -- dest )
    build-images-destination get
    "slava_pestov@downloads.factorcode.org:downloads.factorcode.org/images/build/"
    or ;

: checksums-path ( -- temp ) "checksums.txt" temp-file ;

: boot-image-names ( -- seq )
    images [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums-path ascii [
        boot-image-names [
            [ write bl ]
            [ openssl-md5 checksum-file hex-string print ]
            bi
        ] each
    ] with-file-writer ;

! Windows scp doesn't like pathnames with colons, it treats them as hostnames.
! Workaround for uploading checksums.txt created with temp-file.
! e.g. C:\Users\\Doug\\AppData\\Local\\Temp/factorcode.org\\Factor/checksums.txt
! ssh: Could not resolve hostname c: no address associated with name

HOOK: scp-name os ( -- path )
M: object scp-name "scp" ;
M: windows scp-name "pscp" ;

: upload-images ( -- )
    [
        \ scp-name get-global scp-name or ,
        boot-image-names %
        checksums-path , latest-destination ,
    ] { } make try-process ;

: append-build ( path -- path' )
    build number>string "." glue ;

: checksum-lines-append-build ( -- )
    "checksums.txt" utf8 [
        [ " " split1 [ append-build ] dip " " glue ] map
    ] change-file-lines ;

: with-build-images ( quot -- )
    '[
        ! Copy boot images
        boot-image-names current-temporary-directory get copy-files-into
        ! Copy checksums
        checksums-path current-temporary-directory get copy-file-into
        current-temporary-directory get [
            ! Rewrite checksum lines with build number
            checksum-lines-append-build
            ! Rename file to file.build-number
            current-directory get directory-files [ dup append-build move-file ] each
            ! Run the quot in the current-directory, which is the unique directory
            @
        ] with-directory
    ] cleanup-unique-directory ; inline

: upload-build-images ( -- )
    [
        [
            \ scp-name get-global scp-name or ,
            current-directory get directory-files %
            build-destination ,
        ] { } make try-process
    ] with-build-images ;

: upload-new-images ( -- )
    [
        make-images
        "Computing checksums..." print flush
        compute-checksums
        "Uploading images..." print flush
        upload-images
        "Uploading build images..." print flush
        upload-build-images
    ] with-resource-directory ;

MAIN: upload-new-images
