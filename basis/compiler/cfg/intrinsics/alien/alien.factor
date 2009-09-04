! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences alien math classes.algebra fry
locals combinators combinators.short-circuit cpu.architecture
compiler.tree.propagation.info compiler.cfg.hats
compiler.cfg.stacks compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.builder.blocks ;
IN: compiler.cfg.intrinsics.alien

: emit-<displaced-alien>? ( node -- ? )
    node-input-infos {
        [ first class>> fixnum class<= ]
        [ second class>> c-ptr class<= ]
    } 1&& ;

: emit-<displaced-alien> ( node -- )
    dup emit-<displaced-alien>? [
        [ 2inputs [ ^^untag-fixnum ] dip ] dip
        node-input-infos second class>>
        ^^box-displaced-alien ds-push
    ] [ emit-primitive ] if ;

: prepare-alien-accessor ( infos -- offset-vreg )
    <reversed> second class>>
    [ 2inputs ^^untag-fixnum swap ] dip ^^unbox-c-ptr ^^add ;

:: inline-alien ( node quot test -- )
    [let | infos [ node node-input-infos ] |
        infos test call
        [ infos quot call ]
        [ node emit-primitive ]
        if
    ] ; inline

: inline-alien-getter? ( infos -- ? )
    [ first class>> c-ptr class<= ]
    [ second class>> fixnum class<= ]
    bi and ;

: inline-alien-getter ( node quot -- )
    '[ prepare-alien-accessor @ ds-push ]
    [ inline-alien-getter? ] inline-alien ; inline

: inline-alien-setter? ( infos class -- ? )
    '[ first class>> _ class<= ]
    [ second class>> c-ptr class<= ]
    [ third class>> fixnum class<= ]
    tri and and ;

: inline-alien-integer-setter ( node quot -- )
    '[ prepare-alien-accessor ds-pop ^^untag-fixnum @ ]
    [ fixnum inline-alien-setter? ]
    inline-alien ; inline

: inline-alien-cell-setter ( node quot -- )
    '[ [ prepare-alien-accessor ds-pop ] [ first class>> ] bi ^^unbox-c-ptr @ ]
    [ pinned-c-ptr inline-alien-setter? ]
    inline-alien ; inline

: inline-alien-float-setter ( node quot -- )
    '[ prepare-alien-accessor ds-pop @ ]
    [ float inline-alien-setter? ]
    inline-alien ; inline

: emit-alien-unsigned-getter ( node n -- )
    '[
        _ {
            { 1 [ ^^alien-unsigned-1 ] }
            { 2 [ ^^alien-unsigned-2 ] }
            { 4 [ ^^alien-unsigned-4 ] }
        } case ^^tag-fixnum
    ] inline-alien-getter ;

: emit-alien-signed-getter ( node n -- )
    '[
        _ {
            { 1 [ ^^alien-signed-1 ] }
            { 2 [ ^^alien-signed-2 ] }
            { 4 [ ^^alien-signed-4 ] }
        } case ^^tag-fixnum
    ] inline-alien-getter ;

: emit-alien-integer-setter ( node n -- )
    '[
        _ {
            { 1 [ ##set-alien-integer-1 ] }
            { 2 [ ##set-alien-integer-2 ] }
            { 4 [ ##set-alien-integer-4 ] }
        } case
    ] inline-alien-integer-setter ;

: emit-alien-cell-getter ( node -- )
    [ ^^alien-cell ^^box-alien ] inline-alien-getter ;

: emit-alien-cell-setter ( node -- )
    [ ##set-alien-cell ] inline-alien-cell-setter ;

: emit-alien-float-getter ( node rep -- )
    '[
        _ {
            { float-rep [ ^^alien-float ] }
            { double-rep [ ^^alien-double ] }
        } case
    ] inline-alien-getter ;

: emit-alien-float-setter ( node rep -- )
    '[
        _ {
            { float-rep [ ##set-alien-float ] }
            { double-rep [ ##set-alien-double ] }
        } case
    ] inline-alien-float-setter ;
