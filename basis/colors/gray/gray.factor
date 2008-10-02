! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: colors kernel accessors ;
IN: colors.gray

TUPLE: gray < color gray alpha ;

C: <gray> gray

M: gray >rgba ( gray -- rgba )
    [ gray>> dup dup ] [ alpha>> ] bi <rgba> ;
