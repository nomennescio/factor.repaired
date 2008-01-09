! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init command-line namespaces words debugger io
kernel.private math memory continuations kernel io.files
io.backend system parser vocabs sequences prettyprint
vocabs.loader combinators splitting source-files strings
definitions assocs compiler.errors compiler.units ;
IN: bootstrap.stage2

! Wrap everything in a catch which starts a listener so
! you can see what went wrong, instead of dealing with a
! fep
[
    vm file-name windows? [ >lower ".exe" ?tail drop ] when
    ".image" append "output-image" set-global

    "math tools help compiler ui ui.tools io" "include" set-global
    "" "exclude" set-global

    parse-command-line

    "-no-crossref" cli-args member? [
        "Cross-referencing..." print flush
        H{ } clone crossref set-global
        xref-words
        xref-sources
    ] unless

    ! Set dll paths
    wince? [ "windows.ce" require ] when
    winnt? [ "windows.nt" require ] when

    "deploy-vocab" get [
        "stage2: deployment mode" print
    ] [
        "listener" require
        "none" require
    ] if

    [
        "exclude" "include"
        [ get-global " " split [ empty? not ] subset ] 2apply
        seq-diff
        [ "bootstrap." swap append require ] each

        run-bootstrap-init

        "Compiling remaining words..." print flush

        all-words [ compiled? not ] subset recompile-hook get call
    ] with-compiler-errors

    f error set-global
    f error-continuation set-global

    "deploy-vocab" get [
        "tools.deploy.shaker" run
    ] [
        [
            boot
            do-init-hooks
            [
                parse-command-line
                run-user-init
                "run" get run
                stdio get [ stream-flush ] when*
            ] [ print-error 1 exit ] recover
        ] set-boot-quot

        : count-words all-words swap subset length pprint ;

        [ compiled? ] count-words " compiled words" print
        [ symbol? ] count-words " symbol words" print
        [ ] count-words " words total" print

        "Bootstrapping is complete." print
        "Now, you can run Factor:" print
        vm write " -i=" write "output-image" get print flush

        "output-image" get resource-path save-image-and-exit
    ] if
] [
    error. :c "listener" vocab-main execute
] recover
