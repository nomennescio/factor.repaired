
USING: kernel namespaces arrays sequences threads math math.vectors
       ui random bake
       springies springies.ui ;

IN: springies.models.urchin

: model ( -- )

{ } clone >nodes
{ } clone >springs
0.007 >time-slice
gravity on

1 507.296953 392.174236 -11.451186 -71.267273 1.0 1.0 mass
2 514.879820 372.128025 11.950035 -70.858717 1.0 1.0 mass
3 536.571268 364.423706 18.394466 -41.159445 1.0 1.0 mass
4 554.886966 369.953895 15.173664 -11.009243 1.0 1.0 mass
5 572.432935 379.927626 8.228103 -1.120846 1.0 1.0 mass
6 585.774508 392.380791 5.443281 -8.186599 1.0 1.0 mass
7 584.650543 411.934530 -15.582843 -24.911756 1.0 1.0 mass
8 569.409148 424.155713 -24.100159 -42.285960 1.0 1.0 mass
9 553.751996 434.663690 -26.069217 -41.610454 1.0 1.0 mass
10 536.684374 444.915694 -30.702349 -45.021926 1.0 1.0 mass
11 516.677286 435.936238 -33.128410 -60.977340 1.0 1.0 mass
12 514.170680 414.649472 -24.471518 -64.104425 1.0 1.0 mass
13 602.101547 478.298945 1.612646 -53.040881 1.0 1.0 mass
14 637.0 427.598266 0.0 0.0 1.0 1.0 mass
15 608.000171 350.425575 31.812856 23.456940 1.0 1.0 mass
16 484.367809 332.414622 42.575378 -91.238351 1.0 1.0 mass
17 480.857379 475.215663 -24.240991 -53.909049 1.0 1.0 mass
18 548.580015 492.173168 -34.565312 -52.436468 1.0 1.0 mass
19 578.155338 487.173526 22.544495 -71.920721 1.0 1.0 mass
20 630.992588 379.333707 16.662115 37.873709 1.0 1.0 mass
21 591.256916 324.817423 63.036114 27.988433 1.0 1.0 mass
22 539.051461 311.597938 159.501014 -27.955219 1.0 1.0 mass
23 448.396171 396.882674 -15.045910 -138.652372 1.0 1.0 mass
24 448.194414 419.993896 -27.625008 -84.936708 1.0 1.0 mass
1 1 2 200.0 3.0 20.0 spng
2 2 3 200.0 3.0 20.0 spng
3 3 4 200.0 3.0 20.0 spng
4 4 5 200.0 3.0 20.0 spng
5 5 6 200.0 3.0 20.0 spng
6 6 7 200.0 3.0 20.0 spng
7 7 8 200.0 3.0 20.0 spng
8 8 9 200.0 3.0 20.0 spng
9 9 10 200.0 3.0 20.0 spng
10 10 11 200.0 3.0 20.0 spng
11 11 12 200.0 3.0 20.0 spng
12 1 3 200.0 3.0 40.0 spng
13 2 4 200.0 3.0 40.0 spng
14 3 5 200.0 3.0 40.0 spng
15 4 6 200.0 3.0 40.0 spng
16 6 8 200.0 3.0 40.0 spng
17 7 9 200.0 3.0 40.0 spng
18 8 10 200.0 3.0 40.0 spng
19 9 11 200.0 3.0 40.0 spng
20 10 12 200.0 3.0 40.0 spng
21 12 1 200.0 3.0 21.0 spng
22 12 2 200.0 3.0 41.0 spng
23 11 1 200.0 3.0 41.0 spng
24 6 12 200.0 3.0 72.681733 spng
25 5 11 200.0 3.0 81.191259 spng
26 10 4 200.0 3.0 76.026311 spng
27 3 9 200.0 3.0 72.615425 spng
28 8 2 200.0 3.0 74.966659 spng
29 1 7 200.0 3.0 80.280757 spng
30 17 11 200.0 3.0 55.036352 spng
31 10 18 200.0 3.0 49.819675 spng
32 19 9 200.0 3.0 54.918121 spng
33 8 13 200.0 3.0 62.201286 spng
34 14 7 200.0 3.0 58.600341 spng
35 6 20 200.0 3.0 46.400431 spng
36 15 5 200.0 3.0 44.045431 spng
37 4 21 200.0 3.0 57.454330 spng
38 22 3 200.0 3.0 53.823787 spng
39 2 16 200.0 3.0 51.039201 spng
40 23 1 200.0 3.0 58.668561 spng
41 12 24 200.0 3.0 64.404969 spng
42 24 11 200.0 3.0 71.217975 spng
43 17 12 200.0 3.0 65.0 spng
44 11 18 200.0 3.0 60.745370 spng
45 18 9 200.0 3.0 60.406953 spng
46 9 13 200.0 3.0 67.779053 spng
47 13 7 200.0 3.0 66.708320 spng
48 7 20 200.0 3.0 55.659680 spng
49 20 5 200.0 3.0 60.0 spng
50 5 21 200.0 3.0 61.846584 spng
51 21 3 200.0 3.0 64.031242 spng
52 3 16 200.0 3.0 63.568860 spng
53 16 1 200.0 3.0 59.774577 spng
54 1 24 200.0 3.0 65.802736 spng
55 17 10 200.0 3.0 64.845971 spng
56 10 19 200.0 3.0 58.249464 spng
57 19 8 200.0 3.0 67.268120 spng
58 8 14 200.0 3.0 67.268120 spng
59 14 6 200.0 3.0 64.629715 spng
60 6 15 200.0 3.0 50.089919 spng
61 15 4 200.0 3.0 56.320511 spng
62 4 22 200.0 3.0 60.728906 spng
63 22 2 200.0 3.0 61.032778 spng
64 2 23 200.0 3.0 66.528190 spng
65 23 12 200.0 3.0 72.277244 spng

nodes>
    75 random -75 + 0 2array [ over node-vel v+ swap set-node-vel ]
curry each

;

: go ( -- ) [ model ] go* ;

MAIN: go