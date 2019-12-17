! Copyright (C) 2010 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants game.debug game.loop
game.worlds gpu gpu.framebuffers gpu.util.wasd kernel literals
locals make math math.matrices math.matrices.extras math.parser
math.trig sequences specialized-arrays ui.gadgets.worlds
ui.pixel-formats ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: game.debug.tests

:: clear-screen ( color -- )
    system-framebuffer {
        { default-attachment color }
    } clear-framebuffer ;

:: draw-debug-tests ( world -- )
    world [ wasd-p-matrix ] [ wasd-mv-matrix ] bi m. :> mvp-matrix
    { 0 0 0 } clear-screen

    [
        { 0 0 0 } { 1 0 0 } color: red   debug-line
        { 0 0 0 } { 0 1 0 } color: green debug-line
        { 0 0 0 } { 0 0 1 } color: blue  debug-line
        { -1.2 0 0 } { 0 1 0 } 0 deg>rad <rotation-matrix3> debug-axes
        { 3 5 -2 } { 3 2 1 } color: white debug-box
        { 0 9 0 } 8 2 color: blue debug-cylinder
    ] float-array{ } make
    mvp-matrix draw-debug-lines

    [
        { 0 4.0 0 } color: red debug-point
        { 0 4.1 0 } color: green debug-point
        { 0 4.2 0 } color: blue debug-point
    ] float-array{ } make
    mvp-matrix draw-debug-points

    "Frame: " world frame#>> number>string append
    color: purple { 5 5 } world dim>> draw-text
    world [ 1 + ] change-frame# drop ;

TUPLE: tests-world < wasd-world frame# ;
M: tests-world draw-world* draw-debug-tests ;
M: tests-world wasd-movement-speed drop 1/16. ;
M: tests-world wasd-near-plane drop 1/32. ;
M: tests-world wasd-far-plane drop 1024.0 ;
M: tests-world begin-game-world
    init-gpu
    0 >>frame#
    { 0.0 0.0 2.0 } 0 0 set-wasd-view drop ;

GAME: run-tests {
        { world-class tests-world }
        { title "game.debug.tests" }
        { pixel-format-attributes {
            windowed
            double-buffered
            T{ depth-bits { value 24 } }
        } }
        { grab-input? t }
        { use-game-input? t }
        { pref-dim { 1024 768 } }
        { tick-interval-nanos $[ 60 fps ] }
    } ;

MAIN: run-tests
