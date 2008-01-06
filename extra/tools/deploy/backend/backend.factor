! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations io.launcher words.private tools.deploy.config
bootstrap.image ;
IN: tools.deploy.backend

: boot-image-name ( -- string )
    "boot." my-arch ".image" 3append ;

: stage1 ( -- )
    #! If stage1 image doesn't exist, create one.
    boot-image-name resource-path exists?
    [ my-arch make-image ] unless ;

: (copy-lines) ( stream -- stream )
    dup stream-readln [ print flush (copy-lines) ] when* ;

: copy-lines ( stream -- )
    [ (copy-lines) ] [ stream-close ] [ ] cleanup ;

: ?append swap [ append ] [ drop ] if ;

: profile-string ( config -- string )
    [
        ""
        deploy-math? get " math" ?append
        deploy-compiler? get " compiler" ?append
        deploy-ui? get " ui" ?append
        native-io? " io" ?append
    ] bind ;

: deploy-command-line ( vm image vocab config -- vm flags )
    [
        "-include=" swap profile-string append ,

        "-deploy-vocab=" swap append ,

        "-output-image=" swap append ,

        "-no-stack-traces" ,

        "-no-user-init" ,
    ] { } make ;

: stage2 ( vm image vocab config -- )
    deploy-command-line
    >r "-i=" boot-image-name append 2array r> append dup .
    <process-stream>
    dup duplex-stream-out stream-close
    copy-lines ;

SYMBOL: deploy-implementation

HOOK: deploy* deploy-implementation ( vocab -- )
