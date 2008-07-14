
USING: combinators.short-circuit kernel namespaces
       math
       math.functions
       math.vectors
       math.parser
       hashtables sequences threads
       colors
       opengl
       opengl.gl
       ui
       ui.gadgets
       ui.gadgets.handler
       ui.gadgets.slate
       ui.gadgets.theme
       ui.gadgets.frames
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.packs
       ui.gadgets.grids
       ui.gestures
       assocs.lib vars rewrite-closures boids accessors
       math.geometry.rect
       newfx ;

IN: boids.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! draw-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point-a ( boid -- a ) pos>> ;

: point-b ( boid -- b ) [ pos>> ] [ vel>> normalize* 20 v*n ] bi v+ ;

: boid-points ( boid -- point-a point-b ) [ point-a ] [ point-b ] bi ;

: draw-boid ( boid -- ) boid-points gl-line ;

: draw-boids ( -- ) boids> [ draw-boid ] each ;

: display ( -- ) black gl-color draw-boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

VAR: loop

: run ( -- )
  slate> rect-dim >world-size
  iterate-boids
  slate> relayout-1
  yield
  loop> [ run ] when ;

: button* ( string quot -- button ) closed-quot <bevel-button> ;

: toggle-loop ( -- ) loop> [ loop off ] [ loop on [ run ] in-thread ] if ;

VARS: population-label cohesion-label alignment-label separation-label ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update-population-label ( -- )
  "Population: " boids> length number>string append
  20 32 pad-right population-label> set-label-string ;

: add-10-boids ( -- )
  boids> 10 random-boids append >boids update-population-label ;

: sub-10-boids ( -- )
  boids> 10 tail >boids update-population-label ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: truncate-value ( n -- n ) 10 * round 10 / ;

: update-cohesion-label ( -- )
  "Cohesion: " cohesion-weight> truncate-value number>string append
  20 32 pad-right cohesion-label> set-label-string ;

: update-alignment-label ( -- )
  "Alignment: " alignment-weight> truncate-value number>string append
  20 32 pad-right alignment-label> set-label-string ;

: update-separation-label ( -- )
  "Separation: " separation-weight> truncate-value number>string append
  20 32 pad-right separation-label> set-label-string ;

: inc-cohesion-weight ( -- ) cohesion-weight inc* update-cohesion-label ;
: dec-cohesion-weight ( -- ) cohesion-weight dec* update-cohesion-label ;

: inc-alignment-weight ( -- ) alignment-weight inc* update-alignment-label ;
: dec-alignment-weight ( -- ) alignment-weight dec* update-alignment-label ;

: inc-separation-weight ( -- ) separation-weight inc* update-separation-label ;
: dec-separation-weight ( -- ) separation-weight dec* update-separation-label ;

: boids-window* ( -- )
  init-variables init-world-size init-boids loop on

  C[ display ] <slate> >slate
    t                      slate> set-gadget-clipped?
    { 600 400 }            slate> set-slate-dim
    C[ [ run ] in-thread ] slate> set-slate-graft
    C[ loop off ]          slate> set-slate-ungraft

  "" <label> reverse-video-theme >population-label update-population-label

  "" <label> reverse-video-theme >cohesion-label   update-cohesion-label
  "" <label> reverse-video-theme >alignment-label  update-alignment-label
  "" <label> reverse-video-theme >separation-label update-separation-label

  <frame>

  <shelf>

  {
    [ "ESC - Pause" [ drop toggle-loop ] button* ]

    [ "1 - Randomize" [ drop randomize ] button* ]

    [ <pile> 1 over set-pack-fill
      population-label> add-gadget
      "3 - Add 10" [ drop add-10-boids ] button* add-gadget
      "2 - Sub 10" [ drop sub-10-boids ] button* add-gadget ]

    [ <pile> 1 over set-pack-fill
      cohesion-label> add-gadget
      "q - +0.1" [ drop inc-cohesion-weight ] button* add-gadget
      "a - -0.1" [ drop dec-cohesion-weight ] button* add-gadget ]

    [ <pile> 1 over set-pack-fill
      alignment-label> add-gadget
      "w - +0.1" [ drop inc-alignment-weight ] button* add-gadget
      "s - -0.1" [ drop dec-alignment-weight ] button* add-gadget ]

    [ <pile> 1 over set-pack-fill
      separation-label> add-gadget
      "e - +0.1" [ drop inc-separation-weight ] button* add-gadget
      "d - -0.1" [ drop dec-separation-weight ] button* add-gadget ]

  } [ call ] map [ add-gadget ] each
    1 over set-pack-fill
    over @top grid-add

  slate> over @center grid-add

  H{ } clone
    T{ key-down f f "1" } C[ drop randomize    ] is
    T{ key-down f f "2" } C[ drop sub-10-boids ] is
    T{ key-down f f "3" } C[ drop add-10-boids ] is

    T{ key-down f f "q" } C[ drop inc-cohesion-weight ] is
    T{ key-down f f "a" } C[ drop dec-cohesion-weight ] is

    T{ key-down f f "w" } C[ drop inc-alignment-weight ] is
    T{ key-down f f "s" } C[ drop dec-alignment-weight ] is

    T{ key-down f f "e" } C[ drop inc-separation-weight ] is
    T{ key-down f f "d" } C[ drop dec-separation-weight ] is

    T{ key-down f f "ESC" } C[ drop toggle-loop ] is
  <handler> tuck set-gadget-delegate "Boids" open-window ;

: boids-window ( -- ) [ [ boids-window* ] with-scope ] with-ui ;

MAIN: boids-window
