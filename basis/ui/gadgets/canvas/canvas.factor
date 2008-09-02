! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.backend ui.gadgets ui.gadgets.theme ui.gadgets.lib
ui.gadgets.worlds ui.render opengl opengl.gl kernel namespaces
classes.tuple colors accessors ;
IN: ui.gadgets.canvas

TUPLE: canvas < gadget dlist ;

: new-canvas ( class -- canvas )
    new-gadget black solid-interior ; inline

: delete-canvas-dlist ( canvas -- )
    [ find-gl-context ]
    [ dlist>> [ delete-dlist ] when* ]
    [ f >>dlist drop ] tri ;

: make-canvas-dlist ( canvas quot -- dlist )
    [ GL_COMPILE ] dip make-dlist
    [ >>dlist drop ] keep ;

: cache-canvas-dlist ( canvas quot -- dlist )
    over dlist>> dup
    [ 2nip ] [ drop make-canvas-dlist ] if ; inline

: draw-canvas ( canvas quot -- )
    origin get [
        cache-canvas-dlist glCallList
    ] with-translation ; inline

M: canvas ungraft* delete-canvas-dlist ;
