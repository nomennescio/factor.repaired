! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line kernel namespaces opengl opengl.gl fry ;
IN: ui.backend

SYMBOL: ui-backend

HOOK: set-title ui-backend ( string world -- )

HOOK: (set-fullscreen) ui-backend ( world ? -- )

HOOK: (fullscreen?) ui-backend ( world -- ? )

HOOK: (open-window) ui-backend ( world -- )

HOOK: (close-window) ui-backend ( handle -- )

HOOK: (open-offscreen-buffer) ui-backend ( world -- )

HOOK: (close-offscreen-buffer) ui-backend ( handle -- )

HOOK: raise-window* ui-backend ( world -- )

GENERIC: select-gl-context ( handle -- )

GENERIC: flush-gl-context ( handle -- )

HOOK: offscreen-pixels ui-backend ( world -- alien w h )

HOOK: (with-ui) ui-backend ( quot -- )

HOOK: (grab-input) ui-backend ( handle -- )

HOOK: (ungrab-input) ui-backend ( handle -- )

HOOK: ui-backend-available? ui-backend ( -- ? )

M: object ui-backend-available?
    f ;

[ ui-backend-available? "ui.tools" "listener" ? ] main-vocab-hook set-global
