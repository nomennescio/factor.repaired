! (c)2009 Joe Groff bsd license
USING: accessors combinators fry game.input game.loop generic kernel math
parser sequences ui ui.gadgets ui.gadgets.worlds ui.gestures threads
words audio.engine destructors ;
IN: game.worlds

TUPLE: game-world < world
    game-loop
    audio-engine
    { tick-interval-micros fixnum }
    { use-game-input? boolean }
    { use-audio-engine? boolean }
    { audio-engine-device initial: f }
    { audio-engine-voice-count initial: 16 }
    { audio-engine-buffer-size initial: 8192 }
    { audio-engine-buffer-count initial: 2 }
    { tick-slice float initial: 0.0 } ;

GENERIC: begin-game-world ( world -- )
M: object begin-game-world drop ;

GENERIC: end-game-world ( world -- )
M: object end-game-world drop ;

GENERIC: tick-game-world ( world -- )
M: object tick-game-world drop ;

M: game-world tick*
    [ tick-game-world ]
    [ audio-engine>> [ update-audio ] when* ] bi ;

M: game-world draw*
    swap >>tick-slice relayout-1 yield ;

<PRIVATE

: open-game-audio-engine ( game-world -- audio-engine )
    {
        [ audio-engine-device>> ]
        [ audio-engine-voice-count>> ]
        [ audio-engine-buffer-size>> ]
        [ audio-engine-buffer-count>> ]
    } cleave <audio-engine>
    [ start-audio* ] keep ; inline

PRIVATE>

M: game-world begin-world
    dup use-game-input?>> [ open-game-input ] when
    dup use-audio-engine?>> [ dup open-game-audio-engine >>audio-engine ] when
    dup begin-game-world
    dup [ tick-interval-micros>> ] [ ] bi <game-loop> [ >>game-loop ] keep start-loop
    drop ;

M: game-world end-world
    [ [ stop-loop ] when* f ] change-game-loop
    [ end-game-world ]
    [ audio-engine>> [ dispose ] when* ]
    [ use-game-input?>> [ close-game-input ] when ] tri ;

TUPLE: game-attributes < world-attributes
    { tick-interval-micros fixnum }
    { use-game-input? boolean initial: f }
    { use-audio-engine? boolean initial: f }
    { audio-engine-device initial: f }
    { audio-engine-voice-count initial: 16 }
    { audio-engine-buffer-size initial: 8192 }
    { audio-engine-buffer-count initial: 2 } ;

M: game-world apply-world-attributes
    {
        [ tick-interval-micros>> >>tick-interval-micros ]
        [ use-game-input?>> >>use-game-input? ]
        [ use-audio-engine?>> >>use-audio-engine? ]
        [ audio-engine-device>> >>audio-engine-device ]
        [ audio-engine-voice-count>> >>audio-engine-voice-count ]
        [ audio-engine-buffer-size>> >>audio-engine-buffer-size ]
        [ audio-engine-buffer-count>> >>audio-engine-buffer-count ]
        [ call-next-method ]
    } cleave ;

SYNTAX: GAME:
    CREATE
    game-attributes parse-main-window-attributes
    parse-definition
    define-main-window ;
