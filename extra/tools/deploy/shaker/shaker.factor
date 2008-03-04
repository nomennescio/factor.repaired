! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations words.private tools.deploy.config compiler.units ;
IN: tools.deploy.shaker

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
    "command-line" init-hooks get delete-at
    "libc" init-hooks get delete-at
    deploy-threads? get [
        "threads" init-hooks get delete-at
    ] unless
    native-io? [
        "io.thread" init-hooks get delete-at
    ] unless
    strip-io? [
        "io.backend" init-hooks get delete-at
    ] when ;

: strip-debugger ( -- )
    strip-debugger? [
        "Stripping debugger" show
        "resource:extra/tools/deploy/shaker/strip-debugger.factor"
        run-file
    ] when ;

: strip-libc ( -- )
    "libc" vocab [
        "Stripping manual memory management debug code" show
        "resource:extra/tools/deploy/shaker/strip-libc.factor"
        run-file
    ] when ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "resource:extra/tools/deploy/shaker/strip-cocoa.factor"
        run-file
    ] when ;

: strip-assoc ( retained-keys assoc -- newassoc )
    swap [ nip member? ] curry assoc-subset ;

: strip-word-names ( words -- )
    "Stripping word names" show
    [ f over set-word-name f swap set-word-vocabulary ] each ;

: strip-word-defs ( words -- )
    "Stripping symbolic word definitions" show
    [ [ ] swap set-word-def ] each ;

: strip-word-props ( retain-props words -- )
    "Stripping word properties" show
    [
        [ word-props strip-assoc f assoc-like ] keep
        set-word-props
    ] with each ;

: retained-props ( -- seq )
    [
        "class" ,
        "metaclass" ,
        "slot-names" ,
        deploy-ui? get [
            "gestures" ,
            "commands" ,
            { "+nullary+" "+listener+" "+description+" }
            [ "ui.commands" lookup , ] each
        ] when
    ] { } make ;

: strip-words ( props -- )
    [ word? ] instances
    deploy-word-props? get [ 2dup strip-word-props ] unless
    deploy-word-defs? get [ dup strip-word-defs ] unless
    strip-word-names? [ dup strip-word-names ] when
    2drop ;

: strip-environment ( retain-globals -- )
    strip-globals? [
        "Stripping environment" show
        global strip-assoc 21 setenv
    ] [ drop ] if ;

: finish-deploy ( final-image -- )
    "Finishing up" show
    >r { } set-datastack r>
    { } set-retainstack
    V{ } set-namestack
    V{ } set-catchstack
    
    "Saving final image" show
    [ save-image-and-exit ] call-clear ;

SYMBOL: deploy-vocab

: set-boot-quot* ( word -- )
    [
        \ boot ,
        init-hooks get values concat %
        ,
        strip-io? [ \ flush , ] unless
    ] [ ] make "Boot quotation: " write dup . flush
    set-boot-quot ;

: retained-globals ( -- seq )
    [
        builtins ,
        strip-io? [ io-backend , ] unless

        strip-dictionary? [
            {
                dictionary
                inspector-hook
                lexer-factory
                load-vocab-hook
                num-tags
                num-types
                tag-bits
                tag-mask
                tag-numbers
                typemap
                vocab-roots
            } %
        ] unless

        strip-prettyprint? [
            {
                tab-size
                margin
            } %
        ] unless

        deploy-c-types? get [
            "c-types" "alien.c-types" lookup ,
        ] when

        native-io? [
            "default-buffer-size" "io.nonblocking" lookup ,
        ] when

        deploy-ui? get [
            "ui" child-vocabs
            "cocoa" child-vocabs
            deploy-vocab get child-vocabs 3append
            global keys [ word? ] subset
            swap [ >r word-vocabulary r> member? ] curry
            subset %
        ] when
    ] { } make dup . ;

: strip-recompile-hook ( -- )
    [ [ f ] { } map>assoc ] recompile-hook set-global ;

: strip ( -- )
    strip-libc
    strip-cocoa
    strip-debugger
    strip-recompile-hook
    strip-init-hooks
    deploy-vocab get vocab-main set-boot-quot*
    retained-props >r
    retained-globals strip-environment
    r> strip-words ;

: (deploy) ( final-image vocab config -- )
    #! Does the actual work of a deployment in the slave
    #! stage2 image
    [
        [
            deploy-vocab set
            deploy-vocab get require
            strip
            finish-deploy
        ] [
            print-error flush 1 exit
        ] recover
    ] bind ;

: do-deploy ( -- )
    "output-image" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    dup deploy-config dup .
    (deploy) ;

MAIN: do-deploy
