! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: arrays errors freetype gadgets gadgets-launchpad
gadgets-layouts gadgets-listener hashtables kernel
kernel-internals math namespaces opengl sequences
strings x11 ;

! In the X11 backend, world-handle is a pair { window context }.
! The window is an X11 window ID, and the context is a
! GLX context pointer.

M: world expose-event ( event world -- ) nip relayout ;

M: world resize-event ( event world -- )
    >r
    dup XConfigureEvent-width swap XConfigureEvent-height 0
    3array
    r> set-gadget-dim ;

: button&loc ( event -- button# loc )
    dup XButtonEvent-button
    over XButtonEvent-x
    rot XButtonEvent-y 0 3array ;

M: world button-down-event ( event world -- )
    >r button&loc r> send-button-down ;

M: world button-up-event ( event world -- )
    >r button&loc r> send-button-up ;

M: world wheel-event ( event world -- )
    >r button&loc >r 4 = r> r> send-wheel ;

M: world motion-event ( event world -- )
    >r dup XMotionEvent-x swap XMotionEvent-y 0 3array r>
    move-hand ;

: modifiers
    {
        { S+ HEX: 1 }
        { C+ HEX: 4 }
        { A+ HEX: 8 }
    } ;
    
: key-codes
    H{
        { HEX: FF08 "BACKSPACE" }
        { HEX: FF09 "TAB"       }
        { HEX: FF0D "RETURN"    }
        { HEX: FF1B "ESCAPE"    }
        { HEX: FFFF "DELETE"    }
        { HEX: FF50 "HOME"      }
        { HEX: FF51 "LEFT"      }
        { HEX: FF52 "UP"        }
        { HEX: FF53 "RIGHT"     }
        { HEX: FF54 "DOWN"      }
        { HEX: FF55 "PAGE_UP"   }
        { HEX: FF56 "PAGE_DOWN" }
        { HEX: FF57 "END"       }
        { HEX: FF58 "BEGIN"     }
    } ;

: ignored-key? ( keycode -- ? )
    {
        HEX: FFE1 HEX: FFE2 HEX: FFE3 HEX: FFE4 HEX: FFE5
        HEX: FFE6 HEX: FFE7 HEX: FFE8 HEX: FFE9 HEX: FFEA
        HEX: FFEB HEX: FFEC HEX: FFED HEX: FFEE
    } member? ;

: key-code ( event -- keycode )
    lookup-string drop dup ignored-key? [
        drop f
    ] [
        dup key-codes hash [ ] [ ch>string ] ?if
    ] if ;

: event>gesture ( event quot -- gesture )
    >r dup XKeyEvent-state modifiers modifier swap key-code
    r> [ drop f ] if* ;

M: world key-down-event ( event world -- )
    world-focus over [ <key-down> ] event>gesture [
        over handle-gesture
        [ swap lookup-string nip swap user-input ] [ 2drop ] if
    ] [
        2drop
    ] if* ;

M: world key-up-event ( event world -- )
    world-focus over [ <key-up> ] event>gesture [
        over handle-gesture drop
    ] [
        2drop
    ] if* ;

: close-box? ( event -- ? )
    dup XClientMessageEvent-message_type "WM_PROTOCOLS" x-atom =
    swap XClientMessageEvent-data "WM_DELETE_WINDOW" x-atom =
    and ;

M: world client-event ( event world -- )
    swap close-box? [
        dup world-handle
        >r close-world
        r> first2 destroy-window*
    ] [
        drop
    ] if ;

: gadget-window ( world -- )
    [ dup rect-dim glx-window* 2array ] keep set-world-handle ;

IN: gadgets

: set-title ( string world -- )
    world-handle first dpy get -rot swap XStoreName drop ;

: open-window* ( world -- )
    dup gadget-window dup add-notify
    dup gadget-title swap set-title ;

: select-gl-context ( handle -- )
    dpy get swap first2 glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

: flush-gl-context ( handle -- )
    dpy get swap first glXSwapBuffers ;

IN: shells

: ui ( -- )
    [
        f [
            init-ui
            launchpad-window
            listener-window
            event-loop
        ] with-x
    ] with-freetype ;

IN: kernel

: default-shell "DISPLAY" os-env empty? "tty" "ui" ? ;
