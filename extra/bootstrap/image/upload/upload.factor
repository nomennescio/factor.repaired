! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http.client checksums checksums.md5 splitting assocs
kernel io.files bootstrap.image sequences io namespaces
io.launcher math io.encodings.ascii ;
IN: bootstrap.image.upload

SYMBOL: upload-images-destination

: destination ( -- dest )
  upload-images-destination get
  "slava@factorcode.org:/var/www/factorcode.org/newsite/images/latest/"
  or ;

: checksums "checksums.txt" temp-file ;

: boot-image-names images [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums ascii [
        boot-image-names [
            [ write bl ] [ md5 checksum-file hex-string print ] bi
        ] each
    ] with-file-writer ;

: upload-images ( -- )
    [
        "scp" ,
        boot-image-names %
        "temp/checksums.txt" , destination ,
    ] { } make try-process ;

: new-images ( -- )
    "" resource-path
      [ make-images compute-checksums upload-images ]
    with-directory ;

MAIN: new-images
