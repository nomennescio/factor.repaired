USING: accessors kernel locals math math.order sequences ;
IN: tensors.tensor-slice

TUPLE: step-slice < slice { step integer read-only } ;
:: <step-slice> ( from to step seq -- step-slice )
    step zero? [ "can't be zero" throw ] when
    seq length :> len
    step 0 > [
        from [ 0 ] unless*
        to [ len ] unless*
    ] [
        from [ len ] unless*
        to [ 0 ] unless*
    ] if
    [ dup 0 < [ len + ] when 0 len clamp ] bi@
    ! FIXME: make this work with steps
    seq dup slice? [ collapse-slice ] when
    step step-slice boa ;

M: step-slice virtual@
    [ step>> * ] [ from>> + ] [ seq>> ] tri ;

M: step-slice length
    [ to>> ] [ from>> - ] [ step>> ] tri
    dup 0 < [ [ neg 0 max ] dip neg ] when /mod
    zero? [ 1 + ] unless ;
