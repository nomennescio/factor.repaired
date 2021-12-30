! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays colors colors.yiq kernel locals math.functions
ranges sequences tools.test ;

{ t } [
    0.0 1.0 0.1 <range> [| r |
        0.0 1.0 0.1 <range> [| g |
            0.0 1.0 0.1 <range> [| b |
                r g b 1.0 <rgba> dup >yiqa >rgba
                [ >rgba-components 4array ] bi@
                [ 0.00000001 ~ ] 2all?
            ] all?
        ] all?
    ] all?
] unit-test
