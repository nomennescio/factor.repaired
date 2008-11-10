! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint combinators windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dll ( bundle-name -- )
    "resource:factor.dll" swap copy-file-into ;

: copy-freetype ( bundle-name -- )
    {
        "resource:freetype6.dll"
        "resource:zlib1.dll"
    } swap copy-files-into ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dll
    deploy-ui? get [
        dup copy-freetype
        dup "" copy-fonts
    ] when
    ".exe" copy-vm ;

M: winnt deploy*
    "resource:" [
        dup deploy-config [
            deploy-name get
            [
                [ create-exe-dir ]
                [ image-name ]
                [ drop ]
                2tri namespace make-deploy-image
            ]
            [ nip open-in-explorer ] 2bi
        ] bind
    ] with-directory ;
