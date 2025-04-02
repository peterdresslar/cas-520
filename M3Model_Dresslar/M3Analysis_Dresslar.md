# M3Analysis_Dresslar.md

In M3Model_Dresslar.nlogo, I have modified the original Paths logo with the following additions:

- Added runnels (blue patches) as water/obstacle paths
- Created a geometric house placement system
- Implemented house network system with numbered houses and connecting lines
- Added inflection point detection to identify significant system changes
- Added basic, experimental analytics (entropy, curvilinearity)
- Enhanced walker behaviors with runnel avoidance and ant-like pathfinding
- Added reporting and statistics tracking
- Implemented line-based connectivity between houses
- Added transition tracking and timing mechanisms for patches
- Minor UI tweaks
- Created predefined experiment setups for this homework
- Integrated multimedia sonic sensorium

Included in this report are results from experiment runs representing the following aspects of the assignment.

- Step 0: The preamble to step 1 using base values and no houses
- Step 1
-- Step 1ʻs "high" suite of questions (5 parameter checks)
-- Step 1ʻs "low" suite of questions (5 parameter checks)
- Step 2: 1 question
- Step 3: Step 3 repeats all of the step 1 questions, but with automatically placed preset houses and barriers called runnels. We then repeat step oneʻs suite of questions.

All experimental outputs appear at the bottom of this document. They can be re-run or reproduced using the suite of controls in the M3Model_Dresslar.nlogo model. Please see the label or contact me for further instructions. 

> Note that you should flip the step-3? switch *before* using a question preset.

# Analysis

There is a wide array of behaviors available in this model. It would be difficult to describe all the behaviors anecdotally, and that was the impetus for the addition of a small experimental apparatus to the model.

Notably, many of the parameters, and much of the instrumentation and even behavior that I have added to the model, are performance-bound; in many ways, the model now represents a significant chunk of the available functionality space that 






# Experimental Outputs

```

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 0, Base Question
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Pathness): tick=58, d2t=1 of current value 3
Inflection. (Pathness): tick=114, d2t=2 of current value 31
Inflection. (Pathness): tick=168, d2t=3 of current value 53
Inflection. (Pathness): tick=245, d2t=3 of current value 47
Inflection. (Pathness): tick=301, d2t=4 of current value 54
Inflection. (Pathness): tick=398, d2t=3 of current value 56
Inflection. (Pathness): tick=454, d2t=-3 of current value 57
Inflection. (Pathness): tick=587, d2t=-4 of current value 55
Inflection. (Pathness): tick=641, d2t=-2 of current value 37
Inflection. (Pathness): tick=711, d2t=-3 of current value 53
Inflection. (Pathness): tick=771, d2t=-3 of current value 44
Inflection. (Pathness): tick=823, d2t=-3 of current value 59
Inflection. (Pathness): tick=929, d2t=3 of current value 59
Inflection. (Pathness): tick=994, d2t=-4 of current value 61
Inflection. (Pathness): tick=1053, d2t=3 of current value 54
Inflection. (Pathness): tick=1110, d2t=-6 of current value 55
Inflection. (Pathness): tick=1183, d2t=-4 of current value 62
Inflection. (Pathness): tick=1249, d2t=3 of current value 51
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 5.176
Final Pathness: 51
Final Runnelness: 0
Final Grassness: 22750
Final Entropy: 0.016
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 1, High Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 96%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=51, d2t=0.097 of current value 0.6539132602209916
Inflection. (Pathness): tick=56, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=102, d2t=-0.194 of current value 0.5533179637643375
Inflection. (Pathness): tick=127, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=153, d2t=0.028 of current value 0.6127845688457649
Inflection. (Pathness): tick=198, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=204, d2t=-0.151 of current value 0.5038417970185043
Inflection. (Stdev Pop): tick=255, d2t=-0.079 of current value 0.5062811584200355
Inflection. (Stdev Pop): tick=306, d2t=0.107 of current value 0.4668419539818822
Inflection. (Stdev Pop): tick=357, d2t=-0.146 of current value 0.6424699919446493
Inflection. (Pathness): tick=382, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=408, d2t=0.082 of current value 0.5032416342087054
Inflection. (Pathness): tick=450, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=459, d2t=-0.031 of current value 0.5538038576258802
Inflection. (Stdev Pop): tick=510, d2t=-0.218 of current value 0.5205814196988382
Inflection. (Pathness): tick=517, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=562, d2t=0.071 of current value 0.6545594655427928
Inflection. (Stdev Pop): tick=613, d2t=0.039 of current value 0.6409665128698497
Inflection. (Pathness): tick=615, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=664, d2t=0.091 of current value 0.6269249748704873
Inflection. (Pathness): tick=684, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=715, d2t=0.144 of current value 0.5982185905751024
Inflection. (Pathness): tick=757, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=766, d2t=0.119 of current value 0.7075583299077911
Inflection. (Stdev Pop): tick=817, d2t=-0.354 of current value 0.5688132110105181
Inflection. (Pathness): tick=857, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=868, d2t=0.141 of current value 0.5539062193557294
Inflection. (Pathness): tick=911, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=919, d2t=0.043 of current value 0.6129372779418771
Inflection. (Pathness): tick=962, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=970, d2t=0.009 of current value 0.4669259294705934
Inflection. (Stdev Pop): tick=1021, d2t=0.048 of current value 0.5200362049750575
Inflection. (Pathness): tick=1024, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=1072, d2t=0.053 of current value 0.6408181737154508
Inflection. (Pathness): tick=1081, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=1123, d2t=-0.127 of current value 0.5688133604935399
Inflection. (Pathness): tick=1146, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=1174, d2t=0.044 of current value 0.5685201555645323
Inflection. (Stdev Pop): tick=1225, d2t=-0.06 of current value 0.5685250992319795
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.021
Final Pathness: 0
Final Runnelness: 0
Final Grassness: 22801
Final Entropy: 0
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 1, Low Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 0%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 76.278
Final Pathness: 20699
Final Runnelness: 0
Final Grassness: 2102
Final Entropy: 0.308
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 2, High Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 96
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 10.194
Final Pathness: 11268
Final Runnelness: 0
Final Grassness: 11533
Final Entropy: 0.693
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 2, Low Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 4
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 1.05
Final Pathness: 0
Final Runnelness: 0
Final Grassness: 22801
Final Entropy: 0
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 3, High Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 96
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Pathness): tick=102, d2t=1 of current value 1
Inflection. (Pathness): tick=210, d2t=1 of current value 2
Inflection. (Pathness): tick=322, d2t=1 of current value 2
Inflection. (Pathness): tick=376, d2t=1 of current value 7
Inflection. (Pathness): tick=434, d2t=1 of current value 9
Inflection. (Pathness): tick=494, d2t=-1 of current value 5
Inflection. (Pathness): tick=552, d2t=-1 of current value 2
Inflection. (Pathness): tick=632, d2t=1 of current value 2
Inflection. (Pathness): tick=694, d2t=1 of current value 3
Inflection. (Pathness): tick=754, d2t=-1 of current value 2
Inflection. (Pathness): tick=811, d2t=-1 of current value 1
Inflection. (Pathness): tick=864, d2t=1 of current value 2
Inflection. (Pathness): tick=954, d2t=-1 of current value 1
Inflection. (Pathness): tick=1057, d2t=1 of current value 3
Inflection. (Pathness): tick=1117, d2t=1 of current value 6
Inflection. (Pathness): tick=1192, d2t=-1 of current value 7
Inflection. (Pathness): tick=1246, d2t=-1 of current value 5
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 5.246
Final Pathness: 6
Final Runnelness: 0
Final Grassness: 22795
Final Entropy: 0.002
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 3, Low Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 4
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 2.436
Final Pathness: 8491
Final Runnelness: 0
Final Grassness: 14310
Final Entropy: 0.66
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 4, High Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 500
Walker vision distance: 10
Runnel durability: 175
=======================
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 6.96
Final Pathness: 1394
Final Runnelness: 0
Final Grassness: 21407
Final Entropy: 0.23
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 4, Low Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 25
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=57, d2t=-0.043 of current value 2.3447644842249167
Inflection. (Stdev Pop): tick=354, d2t=-0.037 of current value 2.4201464462076854
Inflection. (Stdev Pop): tick=497, d2t=-0.039 of current value 2.3686697510112547
Inflection. (Stdev Pop): tick=1126, d2t=0.039 of current value 2.4568613659805645
Inflection. (Stdev Pop): tick=1196, d2t=-0.037 of current value 2.3571372955747374
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.518
Final Pathness: 0
Final Runnelness: 0
Final Grassness: 22801
Final Entropy: 0
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 5, High Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 96
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=242, d2t=-0.041 of current value 2.432247728813524
Inflection. (Stdev Pop): tick=652, d2t=0.037 of current value 2.3960370506527155
Inflection. (Stdev Pop): tick=716, d2t=0.038 of current value 2.353133252983806
Inflection. (Stdev Pop): tick=781, d2t=-0.039 of current value 2.399195383180545
Inflection. (Stdev Pop): tick=847, d2t=-0.047 of current value 2.4061663349289937
Inflection. (Stdev Pop): tick=900, d2t=0.042 of current value 2.3596072165682838
Inflection. (Stdev Pop): tick=953, d2t=-0.037 of current value 2.414319182811227
Inflection. (Stdev Pop): tick=1027, d2t=0.049 of current value 2.451074954611283
Inflection. (Stdev Pop): tick=1148, d2t=-0.039 of current value 2.4003629709671284
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.519
Final Pathness: 0
Final Runnelness: 0
Final Grassness: 22801
Final Entropy: 0
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, Question 5, Low Param
Run for ticks: 1250
Houses to setup: 0
House spacing: 0
Weirdness: 0
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 2
Runnel durability: 175
=======================
Inflection. (Pathness): tick=53, d2t=1 of current value 3
Inflection. (Pathness): tick=104, d2t=-1 of current value 10
Inflection. (Pathness): tick=155, d2t=-1 of current value 15
Inflection. (Pathness): tick=209, d2t=-1 of current value 13
Inflection. (Pathness): tick=260, d2t=-1 of current value 18
Inflection. (Pathness): tick=348, d2t=1 of current value 19
Inflection. (Pathness): tick=400, d2t=-1 of current value 15
Inflection. (Pathness): tick=456, d2t=-2 of current value 25
Inflection. (Pathness): tick=527, d2t=-2 of current value 22
Inflection. (Pathness): tick=578, d2t=-1 of current value 19
Inflection. (Pathness): tick=658, d2t=2 of current value 25
Inflection. (Pathness): tick=710, d2t=-1 of current value 19
Inflection. (Pathness): tick=761, d2t=1 of current value 16
Inflection. (Pathness): tick=813, d2t=1 of current value 19
Inflection. (Pathness): tick=879, d2t=-2 of current value 26
Inflection. (Pathness): tick=953, d2t=-2 of current value 22
Inflection. (Pathness): tick=1005, d2t=-1 of current value 19
Inflection. (Pathness): tick=1062, d2t=-1 of current value 19
Inflection. (Pathness): tick=1114, d2t=2 of current value 22
Inflection. (Pathness): tick=1180, d2t=2 of current value 21
Inflection. (Pathness): tick=1233, d2t=-2 of current value 20
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 5.234
Final Pathness: 20
Final Runnelness: 0
Final Grassness: 22781
Final Entropy: 0.007
Final Curvilinearity (works only with houses): 0
=======================

--

=== INITIALIZING SIMULATION ===
2 houses to setup at 180 degrees separation.
constructed line: [1--2 30 0 -30 0]
=== SIMULATION PARAMETERS ===
Simulation name: Step 1, 0
Run for ticks: 1250
Houses to setup: 2
House spacing: 30
Weirdness: 50
Runnels enabled: false
Runnelator: 0
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Pathness): tick=51, d2t=-1 of current value 6
Inflection. (Pathness): tick=109, d2t=5 of current value 96
Inflection. (Stdev Pop): tick=205, d2t=0.055 of current value 2.8949055031171347
Inflection. (Stdev Pop): tick=262, d2t=-0.048 of current value 2.7731938795719002
Inflection. (Stdev Pop): tick=315, d2t=-0.055 of current value 2.611498745594098
Inflection. (Stdev Pop): tick=429, d2t=0.035 of current value 2.141623101492111
Inflection. (Stdev Pop): tick=496, d2t=0.084 of current value 1.7028061293467671
Inflection. (Stdev Pop): tick=556, d2t=0.035 of current value 1.6110881645656558
Inflection. (Stdev Pop): tick=614, d2t=0.059 of current value 1.5543696892702699
Inflection. (Stdev Pop): tick=685, d2t=0.056 of current value 1.54179380944524
Inflection. (Stdev Pop): tick=771, d2t=0.026 of current value 1.2635130217787864
Inflection. (Stdev Pop): tick=822, d2t=0.049 of current value 1.4210645919278202
Inflection. (Stdev Pop): tick=878, d2t=0.063 of current value 1.6487796145637412
Inflection. (Stdev Pop): tick=930, d2t=0.099 of current value 1.701817630655645
Inflection. (Stdev Pop): tick=981, d2t=0.051 of current value 2.0562758011596096
Inflection. (Stdev Pop): tick=1033, d2t=-0.061 of current value 2.8741523818825008
Inflection. (Stdev Pop): tick=1085, d2t=-0.045 of current value 2.7797560606158287
Inflection. (Stdev Pop): tick=1173, d2t=0.064 of current value 2.34947163956156
Inflection. (Stdev Pop): tick=1243, d2t=0.042 of current value 2.1945332727715425
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.129
Final Pathness: 116
Final Runnelness: 0
Final Grassness: 22685
Final Entropy: 0.032
Final Curvilinearity (works only with houses): 0.056
=======================

--

```