! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.commands ui.gadgets ui.gadgets.buttons
ui.gadgets.worlds ui.gestures generic hashtables kernel math
models namespaces opengl sequences math.vectors
ui.gadgets.theme ui.gadgets.packs ui.gadgets.borders colors
math.geometry.rect ;
IN: ui.gadgets.menus

: menu-loc ( world menu -- loc )
    >r rect-dim r> pref-dim [v-] hand-loc get-global vmin ;

TUPLE: menu-glass < gadget ;

: <menu-glass> ( menu world -- glass )
    menu-glass new-gadget
    >r over menu-loc over set-rect-loc r>
    [ swap add-gadget drop ] keep ;

M: menu-glass layout* gadget-child prefer ;

: hide-glass ( world -- )
    dup glass>> [ unparent ] when*
    f swap (>>glass) ;

: show-glass ( gadget world -- )
    over hand-clicked set-global
    [ hide-glass ] keep
    [ swap add-gadget drop ] 2keep
    (>>glass) ;

: show-menu ( gadget owner -- )
    find-world [ <menu-glass> ] keep show-glass ;

\ menu-glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures

: <menu-item> ( hook target command -- button )
    dup command-name -rot command-button-quot
    swapd
    [ hand-clicked get find-world hide-glass ]
    3append <roll-button> ;

: menu-theme ( gadget -- gadget )
    light-gray solid-interior
    faint-boundary ;

: <commands-menu> ( hook target commands -- gadget )
  <filled-pile>
  -roll
    [ <menu-item> add-gadget ] with with each
  5 <border> menu-theme ;
