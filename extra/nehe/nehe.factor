USING: ui.gadgets.buttons ui.gadgets.packs ui.gadgets ui
nehe.2 nehe.3 nehe.4 nehe.5 kernel ;
IN: nehe

: nehe-window ( -- )
    [
        <filled-pile>
            "Nehe 2" [ drop run2 ] <bevel-button> add-gadget
            "Nehe 3" [ drop run3 ] <bevel-button> add-gadget
            "Nehe 4" [ drop run4 ] <bevel-button> add-gadget
            "Nehe 5" [ drop run5 ] <bevel-button> add-gadget
        "Nehe examples" open-window
    ] with-ui ;

MAIN: nehe-window
