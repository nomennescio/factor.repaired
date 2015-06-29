! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators kernel locals math math.constants
math.functions sequences ;

IN: picomath

<PRIVATE

CONSTANT: a1  0.254829592
CONSTANT: a2 -0.284496736
CONSTANT: a3  1.421413741
CONSTANT: a4 -1.453152027
CONSTANT: a5  1.061405429
CONSTANT: p   0.3275911

PRIVATE>

! Standalone error function erf(x)
! http://www.johndcook.com/blog/2009/01/19/stand-alone-error-function-erf/
:: erf ( x -- value )
    x 0 >= 1 -1 ? :> sign
    x abs :> x!
    p x * 1 + recip :> t
    a5 t * a4 + t * a3 + t * a2 + t * a1 + t *
    x x neg * e^ * 1 swap - :> y
    sign y * ;

:: expm1 ( x -- value )
    x abs 1e-5 < [ x sq 0.5 * x + ] [ x e^ 1.0 - ] if ;

! Standalone implementation of phi(x)
:: phi ( x -- value )
    x 0 >= 1 -1 ? :> sign
    x abs 2 sqrt / :> x!
    p x * 1 + recip :> t
    a5 t * a4 + t * a3 + t * a2 + t * a1 + t *
    x x neg * e^ * 1 swap - :> y
    sign y * 1 + 2 / ;

<PRIVATE

CONSTANT: lf {
    0.000000000000000
    0.000000000000000
    0.693147180559945
    1.791759469228055
    3.178053830347946
    4.787491742782046
    6.579251212010101
    8.525161361065415
    10.604602902745251
    12.801827480081469
    15.104412573075516
    17.502307845873887
    19.987214495661885
    22.552163853123421
    25.191221182738683
    27.899271383840894
    30.671860106080675
    33.505073450136891
    36.395445208033053
    39.339884187199495
    42.335616460753485
    45.380138898476908
    48.471181351835227
    51.606675567764377
    54.784729398112319
    58.003605222980518
    61.261701761002001
    64.557538627006323
    67.889743137181526
    71.257038967168000
    74.658236348830158
    78.092223553315307
    81.557959456115029
    85.054467017581516
    88.580827542197682
    92.136175603687079
    95.719694542143202
    99.330612454787428
    102.968198614513810
    106.631760260643450
    110.320639714757390
    114.034211781461690
    117.771881399745060
    121.533081515438640
    125.317271149356880
    129.123933639127240
    132.952575035616290
    136.802722637326350
    140.673923648234250
    144.565743946344900
    148.477766951773020
    152.409592584497350
    156.360836303078800
    160.331128216630930
    164.320112263195170
    168.327445448427650
    172.352797139162820
    176.395848406997370
    180.456291417543780
    184.533828861449510
    188.628173423671600
    192.739047287844900
    196.866181672889980
    201.009316399281570
    205.168199482641200
    209.342586752536820
    213.532241494563270
    217.736934113954250
    221.956441819130360
    226.190548323727570
    230.439043565776930
    234.701723442818260
    238.978389561834350
    243.268849002982730
    247.572914096186910
    251.890402209723190
    256.221135550009480
    260.564940971863220
    264.921649798552780
    269.291097651019810
    273.673124285693690
    278.067573440366120
    282.474292687630400
    286.893133295426990
    291.323950094270290
    295.766601350760600
    300.220948647014100
    304.686856765668720
    309.164193580146900
    313.652829949878990
    318.152639620209300
    322.663499126726210
    327.185287703775200
    331.717887196928470
    336.261181979198450
    340.815058870798960
    345.379407062266860
    349.954118040770250
    354.539085519440790
    359.134205369575340
    363.739375555563470
    368.354496072404690
    372.979468885689020
    377.614197873918670
    382.258588773060010
    386.912549123217560
    391.575988217329610
    396.248817051791490
    400.930948278915760
    405.622296161144900
    410.322776526937280
    415.032306728249580
    419.750805599544780
    424.478193418257090
    429.214391866651570
    433.959323995014870
    438.712914186121170
    443.475088120918940
    448.245772745384610
    453.024896238496130
    457.812387981278110
    462.608178526874890
    467.412199571608080
    472.224383926980520
    477.044665492585580
    481.872979229887900
    486.709261136839360
    491.553448223298010
    496.405478487217580
    501.265290891579240
    506.132825342034830
    511.008022665236070
    515.890824587822520
    520.781173716044240
    525.679013515995050
    530.584288294433580
    535.496943180169520
    540.416924105997740
    545.344177791154950
    550.278651724285620
    555.220294146894960
    560.169054037273100
    565.124881094874350
    570.087725725134190
    575.057539024710200
    580.034272767130800
    585.017879388839220
    590.008311975617860
    595.005524249382010
    600.009470555327430
    605.020105849423770
    610.037385686238740
    615.061266207084940
    620.091704128477430
    625.128656730891070
    630.172081847810200
    635.221937855059760
    640.278183660408100
    645.340778693435030
    650.409682895655240
    655.484856710889060
    660.566261075873510
    665.653857411105950
    670.747607611912710
    675.847474039736880
    680.953419513637530
    686.065407301994010
    691.183401114410800
    696.307365093814040
    701.437263808737160
    706.573062245787470
    711.714725802289990
    716.862220279103440
    722.015511873601330
    727.174567172815840
    732.339353146739310
    737.509837141777440
    742.685986874351220
    747.867770424643370
    753.055156230484160
    758.248113081374300
    763.446610112640200
    768.650616799717000
    773.860102952558460
    779.075038710167410
    784.295394535245690
    789.521141208958970
    794.752249825813460
    799.988691788643450
    805.230438803703120
    810.477462875863580
    815.729736303910160
    820.987231675937890
    826.249921864842800
    831.517780023906310
    836.790779582469900
    842.068894241700490
    847.352097970438420
    852.640365001133090
    857.933669825857460
    863.231987192405430
    868.535292100464630
    873.843559797865740
    879.156765776907600
    884.474885770751830
    889.797895749890240
    895.125771918679900
    900.458490711945270
    905.796028791646340
    911.138363043611210
    916.485470574328820
    921.837328707804890
    927.193914982476710
    932.555207148186240
    937.921183163208070
    943.291821191335660
    948.667099599019820
    954.046996952560450
    959.431492015349480
    964.820563745165940
    970.214191291518320
    975.612353993036210
    981.015031374908400
    986.422203146368590
    991.833849198223450
    997.249949600427840
    1002.670484599700300
    1008.095434617181700
    1013.524780246136200
    1018.958502249690200
    1024.396581558613400
    1029.838999269135500
    1035.285736640801600
    1040.736775094367400
    1046.192096209724900
    1051.651681723869200
    1057.115513528895000
    1062.583573670030100
    1068.055844343701400
    1073.532307895632800
    1079.012946818975000
    1084.497743752465600
    1089.986681478622400
    1095.479742921962700
    1100.976911147256000
    1106.478169357800900
    1111.983500893733000
    1117.492889230361000
    1123.006317976526100
    1128.523770872990800
    1134.045231790853000
    1139.570684729984800
    1145.100113817496100
    1150.633503306223700
    1156.170837573242400
}

PRIVATE>

: log-factorial ( n -- value )
    {
        { [ dup 0 < ] [ "invalid input" throw ] }
        { [ dup 254 > ] [
                            1 + [| x |
                                x 0.5 - x log * x -
                                0.5 2 pi * log * +
                                1.0 12.0 x * / +
                            ] call
                        ] }
        [ lf nth ]
    } cond ;

:: log-one-plus-x ( x -- value )
    x -1.0 <= [ "argument must be > -1" throw ] when
    x abs 1e-4 > [ 1.0 x + log ] [ -0.5 x * 1.0 + x * ] if ;

<PRIVATE

CONSTANT: c0 2.515517
CONSTANT: c1 0.802853
CONSTANT: c2 0.010328

CONSTANT: d0 1.432788
CONSTANT: d1 0.189269
CONSTANT: d2 0.001308

PRIVATE>

:: rational-approximation ( t -- value )
    c2 t * c1 + t * c0 + :> numerator
    d2 t * d1 + t * d0 + t * 1.0 + :> denominator
    t numerator denominator / - ;

:: normal-cdf-inverse ( p -- value )
    p [ 0 > ] [ 1 < ] bi and [ p throw ] unless
    p 0.5 <
    [ p log -2.0 * sqrt rational-approximation neg ]
    [ p 1.0 - log -2.0 * sqrt rational-approximation ] if ;

<PRIVATE

! Abramowitz and Stegun 6.1.41
! Asymptotic series should be good to at least 11 or 12 figures
! For error analysis, see Whittiker and Watson
! A Course in Modern Analysis (1927), page 252
CONSTANT: c {
     1/12
    -1/360
     1/1260
    -1/1680
     1/1188
    -691/360360
     1/156
    -3617/122400
}

CONSTANT: halfLogTwoPi 0.91893853320467274178032973640562

PRIVATE>

DEFER: gamma

:: log-gamma ( x -- value )
    x 0 <= [ "Invalid input" throw ] when
    x 12 < [ x gamma abs log ] [
        1.0 x x * / :> z
        7 c nth 7 iota reverse [ [ z * ] [ c nth ] bi* + ] each x / :> series
        x 0.5 - x log * x - halfLogTwoPi + series +
    ] if ;

<PRIVATE

CONSTANT: GAMMA 0.577215664901532860606512090 ! Euler's gamma constant

! numerator coefficients for approximation over the interval (1,2)
CONSTANT: P {
    -1.71618513886549492533811E+0
     2.47656508055759199108314E+1
    -3.79804256470945635097577E+2
     6.29331155312818442661052E+2
     8.66966202790413211295064E+2
    -3.14512729688483675254357E+4
    -3.61444134186911729807069E+4
     6.64561438202405440627855E+4
}

! denominator coefficients for approximation over the interval (1,2)
CONSTANT: Q {
    -3.08402300119738975254353E+1
     3.15350626979604161529144E+2
    -1.01515636749021914166146E+3
    -3.10777167157231109440444E+3
     2.25381184209801510330112E+4
     4.75584627752788110767815E+3
    -1.34659959864969306392456E+5
    -1.15132259675553483497211E+5
}

:: (gamma) ( x -- value )
    ! The algorithm directly approximates gamma over (1,2) and uses
    ! reduction identities to reduce other arguments to this interval.
    x :> y!
    0 :> n!
    y 1.0 < :> arg-was-less-than-one
    arg-was-less-than-one
    [ y 1.0 + y! ] [ y floor >integer 1 - n! y n - y! ] if
    0.0 :> num!
    1.0 :> den!
    y 1 - :> z!
    8 iota [
        [ P nth num + z * num! ]
        [ Q nth den z * + den! ] bi
    ] each
    num den / 1.0 +
    arg-was-less-than-one
    [ y 1.0 - / ] [ n [ y * y 1.0 + y! ] times ] if ;

PRIVATE>

:: gamma ( x -- value )
    x 0 <= [ "Invalid input" throw ] when
    x {
        { [ dup   0.001 < ] [ GAMMA * 1.0 + x * 1.0 swap / ] }
        { [ dup    12.0 < ] [ (gamma) ] }
        { [ dup 171.624 > ] [ drop 1/0. ] }
        [ log-gamma e^ ]
    } cond ;
