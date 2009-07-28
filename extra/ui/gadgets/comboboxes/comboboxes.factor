USING: accessors arrays kernel math.rectangles sequences
ui.frp.gadgets ui.frp.signals ui.gadgets ui.gadgets.glass
ui.gadgets.labels ui.gadgets.tables ui.gestures ;
IN: ui.gadgets.comboboxes

TUPLE: combo-table < frp-table spawner ;

M: combo-table handle-gesture [ call-next-method drop ] 2keep swap
   T{ button-up } = [
      [ spawner>> ]
      [ selected-row [ swap set-control-value ] [ 2drop ] if ]
      [ hide-glass ] tri
   ] [ drop ] if t ;

TUPLE: combobox < label-control table ;
combobox H{
   { T{ button-down } [ dup table>> over >>spawner <zero-rect> show-glass ] }
} set-gestures

: <combobox> ( options -- combobox ) [ first [ combobox new-label ] keep <basic> >>model ] keep
    <basic> combo-table new-frp-table [ 1array ] >>quot >>table ;