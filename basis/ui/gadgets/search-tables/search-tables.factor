! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel delegate fry sequences
models models.search models.delay calendar locals
ui.gadgets.editors ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.tables ui.gadgets.tracks ui.gadgets.borders
ui.gadgets.buttons ;
IN: ui.gadgets.search-tables

TUPLE: search-field < track field ;

: clear-search-field ( search-field -- )
    field>> editor>> clear-editor ;

: <clear-button> ( search-field -- button )
    "X" swap '[ drop _ clear-search-field ] <roll-button> ;

: <search-field> ( model -- gadget )
    { 1 0 } search-field new-track
        { 5 5 } >>gap
        "Search:" <label> f track-add
        swap <model-field> 10 >>min-width >>field
        dup field>> 1 track-add
        dup <clear-button> f track-add ;

TUPLE: search-table < track table field ;

! We don't want to delegate all slots, just a few setters
PROTOCOL: table-protocol
renderer>> (>>renderer)
selected-value>> (>>selected-value) ;

CONSULT: table-protocol search-table table>> ;

:: <search-table> ( values quot -- gadget )
    f <model> :> search
    { 0 1 } search-table new-track
        values >>model
        search <search-field> >>field
        dup field>> 2 <filled-border> f track-add
        values search 500 milliseconds <delay> quot <search> <table> >>table
        dup table>> <scroller> 1 track-add ;

M: search-table model-changed
    nip field>> clear-search-field ;