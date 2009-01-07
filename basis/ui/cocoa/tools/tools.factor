! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.nibs cocoa.application
cocoa.classes cocoa.dialogs cocoa.pasteboard cocoa.subclassing
core-foundation core-foundation.strings help.topics kernel
memory namespaces parser system ui ui.tools.browser
ui.tools.listener ui.cocoa eval locals ;
IN: ui.cocoa.tools

: finder-run-files ( alien -- )
    CF>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    -> replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image save-panel [ save-image ] when* ;

! Handle Open events from the Finder
CLASS: {
    { +superclass+ "FactorApplicationDelegate" }
    { +name+ "FactorWorkspaceApplicationDelegate" }
}

{ "application:openFiles:" "void" { "id" "SEL" "id" "id" }
    [ [ 3drop ] dip finder-run-files ]
}

{ "newFactorWorkspace:" "id" { "id" "SEL" "id" }
    [ 3drop listener-window f ]
}

{ "runFactorFile:" "id" { "id" "SEL" "id" }
    [ 3drop menu-run-files f ]
}

{ "saveFactorImage:" "id" { "id" "SEL" "id" }
    [ 3drop save f ]
}

{ "saveFactorImageAs:" "id" { "id" "SEL" "id" }
    [ 3drop menu-save-image f ]
}

{ "showFactorHelp:" "id" { "id" "SEL" "id" }
    [ 3drop "handbook" com-follow f ]
} ;

: install-app-delegate ( -- )
    NSApp FactorWorkspaceApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
:: do-service ( pboard error quot -- )
    pboard error ?pasteboard-string
    dup [ quot call ] when
    [ pboard set-pasteboard-string ] when* ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorServiceProvider" }
} {
    "evalInListener:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
    [ nip [ eval-listener f ] do-service 2drop ]
} {
    "evalToString:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
    [ nip [ eval>string ] do-service 2drop ]
} ;

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ;

[
    install-app-delegate
    "Factor.nib" load-nib
    register-services
] cocoa-init-hook set-global
