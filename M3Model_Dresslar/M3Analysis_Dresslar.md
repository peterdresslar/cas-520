# M3Analysis_Dresslar.md

![Example image](https://raw.githubusercontent.com/peterdresslar/cas-520/refs/heads/main/public/M3.png)

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

## Analysis

The base [NetLogo Paths model](https://ccl.northwestern.edu/netlogo/models/Paths) exhibits a wide range of behaviors, and with the modifications in my model, that range is increased significantly. It would be difficult to describe all the behaviors anecdotally, and that was the impetus for the addition of a small experimental apparatus to the model. It might be noted that the models (both the base model and the modified model) can exhibit phase-changing behavior over time, where path geometries change and total system measurements rise or fall in inflections: but, the occurence of this phase chasing is generally limited to a small subset of possible parameters. Many starting states lead to fairly static system dynamics.

### Execution Modifications

The primary execution modification is the addition of runnels. Runnels are implemented using a patch `pcolor` of `blue` and represent the idea that paths overused by agents will, in reality, tend to wear down, fill with mud or water (or sand), and generally become undesirable or impassible for foot traffic. As implemented in the model, runnels are a barrier to passage for the "walker" turtle agents, and in fact the turtles can occassionally become entirely stuck when very popular locations close around them with runnels. 

In order to cope with this emergent phenomenon, a radius is set up around houses that will not spawn runnels. This no-runnel radius might be thought of as paving or some other kind of improvement as seen in real-world buildings with similar needs.

Most turtle behavior is left as it was in the base model, with the exception of pathfinding interactions with runnels.

In order to provide for pathfinding in the presence of impermeable barriers, the modified model borrows heavily from the pathfinding of the [NetLogo Ants Model](https://ccl.northwestern.edu/netlogo/models/Ants). Instead of scenting food or chemical, agents in this model "scent" for paths and popularity. The Ants model is a movement based (not direction based) pathfinder and care has been taken to adapt those methods to our base behavior.

### Parameters

The following is a discussion of the modelʻs original parameters and the majoe new parameter, runnealtor.

1. `popularity-decay-rate` has significant control over whether paths form, and how frequently. As a result there is also a major secondary effect from the param on the orderliness of pathing from segment to segment.

2. `popularity-per-step` controls how quickly paths form, and as a product of this, how quickly runnels result from popular paths. Since high values of the parameter make it "easy" for agents to generate paths, such high values cause a sort of indiscriminatoriness with regard to attraction to the best paths, and so the system tends to remain disordered at high settings. This is reflected somewhat in the entropy plot.

3. `minimum-route-popularity` controls how easily popular patches turn to paths and, if the option is on, runnels. Low values lead to lower ordering of paths, similar to the effects of high `popularity-per-step`. Higher values lead stable pathing and eye-pleasing configurations of path geometry.

4. `walker-count` is a simple parameter whose most notable contribution to system behavior is to slow it down or speed it up. On the other hand, some geometries that are stable at a certain walker count might change at higher proportions.

5. `walker-vision-dist` has a very pronounced effect on turtle pathing, and seems to lead generally to more straightline approaches to goals. On the other hand, the variable has a pronounced impact on system performance at high values, since it controls the "scanning" by turtles of large numbers of patches every turn.

6. `runnelator`, a novel parameter for the system, generates "water" barriers on highly-travelled patches. The phenomenon leads to pronounced chaotic system effects at higher values, and watching the turtles divert to other goals due to path blockage is interesting. Most notably, the system of runnel creation and decay leads to cyclic impacts not only on base system statistics, but on secondary measures like entropy. These are best seen at higher values of `runnelator`. Runnel counts are capped at an arbitrary ceiling for system performance considerations.

7. `weirdness` is a geometry-controlling parameter added solely for the reviewerʻs enjoyment.

### Measurements

Many of the added parameters and inspection tools are performance-bound. For instance, the curvilinearity scan compares the position of a gray patch to all the line segements in the model, but doing so once a tick is prohibitively expensive.

- Pathness and Runnelness: These are simply summary counts of patches currently exhibiting `gray` or `blue` colors representing state. The runnel count cap will be visible in telemetry for some runs.

- Popularity: These are the mean and standard deviation measurements of `popularity`, a patch property that is modified through agent proximity. Paths are generated from higher `popularity` patches. Note that standard deviation is a dynamic measurement of system behaviour, as would be expected given that paths between destinations would grow in particular popularity as they are "found" by agents.

- Entropy: as an experimental measure, the model adapts an implementation of Shannon Entropy. This adaptation could be described as: 

\[
H(t) = -\sum_{i \in \{path,grass\}} p_i(t) \ln(p_i(t) + \epsilon)
\]

where:
- \(p_i(t)\) is the proportion of state \(i\) at time \(t\)
- \(\epsilon = 10^{-10}\)
- \(p_i(t) = \frac{n_i(t)}{n_{path}(t) + n_{grass}(t)}\)

There are many sources for the well-known Shannon Entropy measure, but in partcular this model adapts a Python implementation described here: https://stackoverflow.com/a/50313657. Runnels are not included in this impplementation. We might observe that the system does not exhibit significant entropy changes in many states, but perturbations can be seen in particular with highe values for `popularity-decay-rate` (for example).

- Finally, we have a very limited version of path curvilinearity testing. This was difficult to implement and is problematic to run from a performance perspective. Upon setup, the system computes lines between all of the houses. Then to compute curvilinearity, the system measures and averages the distance from sampled patches to the locations of these lines (which are implemented to imbue patches with an `on-line?` property.) This approach has limitations that will doubtless be immediatley obvious to the reviewer, but nonetheless the measure does exhibit some satisfying sensitivity to path "curviness" under certain situations.

## Results

The following data are run results corresponding to each of the assignment questions. It might be interesting to note in particular the presence or abscence of inflection points under the various requested starting conditions. Note that the model is not deterministic in behavior (both starting points and pathfinding involve random checks) and that additional runs under the same starting conditions can generate somewhat different outputs.

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

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 1, High Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 96%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=51, d2t=-0.095 of current value 0.5035767278449058
Inflection. (Pathness): tick=61, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=102, d2t=-0.057 of current value 0.6948582844645355
Inflection. (Pathness): tick=113, d2t=-1 of current value 8
Inflection. (Stdev Pop): tick=155, d2t=0.152 of current value 1.96734714949719
Inflection. (Pathness): tick=164, d2t=-7 of current value 24
Inflection. (Stdev Pop): tick=206, d2t=-0.515 of current value 1.5218692209227918
Inflection. (Pathness): tick=215, d2t=-6 of current value 14
Inflection. (Stdev Pop): tick=257, d2t=0.261 of current value 1.639193411325567
Inflection. (Pathness): tick=266, d2t=5 of current value 13
Inflection. (Stdev Pop): tick=308, d2t=0.158 of current value 1.4900204345030104
Inflection. (Pathness): tick=317, d2t=-7 of current value 19
Inflection. (Stdev Pop): tick=359, d2t=0.072 of current value 1.4877375538183948
Inflection. (Pathness): tick=368, d2t=-4 of current value 7
Inflection. (Stdev Pop): tick=410, d2t=0.288 of current value 1.9161354501479746
Inflection. (Pathness): tick=419, d2t=-6 of current value 11
Inflection. (Stdev Pop): tick=461, d2t=-0.399 of current value 1.3068995486818318
Inflection. (Pathness): tick=470, d2t=-2 of current value 18
Inflection. (Stdev Pop): tick=512, d2t=0.317 of current value 1.6737746291502607
Inflection. (Pathness): tick=521, d2t=3 of current value 10
Inflection. (Stdev Pop): tick=563, d2t=0.212 of current value 1.7799971763455154
Inflection. (Pathness): tick=573, d2t=4 of current value 15
Inflection. (Stdev Pop): tick=614, d2t=0.082 of current value 1.6504700431793626
Inflection. (Pathness): tick=624, d2t=-7 of current value 4
Inflection. (Stdev Pop): tick=665, d2t=-0.36 of current value 1.789082106388187
Inflection. (Pathness): tick=675, d2t=2 of current value 11
Inflection. (Stdev Pop): tick=716, d2t=0.386 of current value 1.337607097412948
Inflection. (Pathness): tick=726, d2t=-4 of current value 12
Inflection. (Stdev Pop): tick=767, d2t=0.319 of current value 1.7638333036535285
Inflection. (Pathness): tick=777, d2t=-1 of current value 19
Inflection. (Stdev Pop): tick=818, d2t=0.125 of current value 1.656617900589913
Inflection. (Pathness): tick=828, d2t=7 of current value 21
Inflection. (Stdev Pop): tick=869, d2t=0.111 of current value 1.8206468363646724
Inflection. (Pathness): tick=879, d2t=-3 of current value 13
Inflection. (Stdev Pop): tick=920, d2t=-0.104 of current value 1.2699471373428042
Inflection. (Pathness): tick=930, d2t=-6 of current value 14
Inflection. (Stdev Pop): tick=971, d2t=-0.032 of current value 1.5550707216753081
Inflection. (Pathness): tick=982, d2t=4 of current value 13
Inflection. (Stdev Pop): tick=1022, d2t=-0.186 of current value 1.7659210881188876
Inflection. (Pathness): tick=1034, d2t=-7 of current value 10
Inflection. (Stdev Pop): tick=1073, d2t=0.124 of current value 1.7184129729822857
Inflection. (Pathness): tick=1085, d2t=5 of current value 23
Inflection. (Stdev Pop): tick=1124, d2t=0.626 of current value 1.8978309606233918
Inflection. (Pathness): tick=1136, d2t=-6 of current value 19
Inflection. (Stdev Pop): tick=1175, d2t=-0.218 of current value 1.8489057474273893
Inflection. (Pathness): tick=1187, d2t=5 of current value 15
Inflection. (Stdev Pop): tick=1226, d2t=0.116 of current value 2.2324194253410443
Inflection. (Pathness): tick=1238, d2t=-2 of current value 25
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.077
Final Pathness: 18
Final Runnelness: 0
Final Grassness: 22783
Final Entropy: 0.006
Final Curvilinearity (works only with houses): 0.764
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 1, Low Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 0%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Runnelness): tick=51, d2t=-1 of current value 4
Inflection. (Runnelness): tick=292, d2t=18 of current value 342
Inflection. (Runnelness): tick=469, d2t=18 of current value 342
Inflection. (Runnelness): tick=646, d2t=18 of current value 342
Inflection. (Runnelness): tick=823, d2t=18 of current value 342
Inflection. (Runnelness): tick=1000, d2t=18 of current value 342
Inflection. (Runnelness): tick=1177, d2t=18 of current value 342
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 30.769
Final Pathness: 3482
Final Runnelness: 351
Final Grassness: 18968
Final Entropy: 0.44
Final Curvilinearity (works only with houses): 4.899
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 2, High Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 96
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Runnelness): tick=164, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=187, d2t=0.208 of current value 12.429543084067573
Inflection. (Stdev Pop): tick=249, d2t=0.182 of current value 9.435057854816423
Inflection. (Runnelness): tick=272, d2t=1 of current value 2
Inflection. (Stdev Pop): tick=305, d2t=-0.153 of current value 9.748437677144086
Inflection. (Runnelness): tick=333, d2t=1 of current value 5
Inflection. (Stdev Pop): tick=371, d2t=0.17 of current value 8.898693623298504
Inflection. (Stdev Pop): tick=422, d2t=-0.153 of current value 8.630614821349955
Inflection. (Runnelness): tick=448, d2t=-1 of current value 3
Inflection. (Stdev Pop): tick=473, d2t=-0.231 of current value 8.994846330672738
Inflection. (Runnelness): tick=509, d2t=-1 of current value 1
Inflection. (Stdev Pop): tick=524, d2t=-0.215 of current value 8.520450054216075
Inflection. (Runnelness): tick=568, d2t=1 of current value 5
Inflection. (Stdev Pop): tick=580, d2t=-0.223 of current value 8.532601002554603
Inflection. (Runnelness): tick=622, d2t=1 of current value 6
Inflection. (Stdev Pop): tick=641, d2t=-0.209 of current value 8.669631782475017
Inflection. (Runnelness): tick=683, d2t=1 of current value 12
Inflection. (Stdev Pop): tick=698, d2t=0.263 of current value 8.265321766602007
Inflection. (Runnelness): tick=736, d2t=1 of current value 12
Inflection. (Stdev Pop): tick=749, d2t=-0.149 of current value 8.577295133123387
Inflection. (Runnelness): tick=795, d2t=1 of current value 18
Inflection. (Stdev Pop): tick=801, d2t=0.13 of current value 8.38136299139183
Inflection. (Runnelness): tick=846, d2t=-2 of current value 20
Inflection. (Stdev Pop): tick=852, d2t=0.138 of current value 9.044779658839607
Inflection. (Stdev Pop): tick=905, d2t=0.149 of current value 8.65309552588221
Inflection. (Runnelness): tick=931, d2t=-2 of current value 24
Inflection. (Stdev Pop): tick=956, d2t=0.144 of current value 8.362285015194855
Inflection. (Runnelness): tick=989, d2t=-2 of current value 33
Inflection. (Stdev Pop): tick=1022, d2t=-0.17 of current value 8.3862473186615
Inflection. (Stdev Pop): tick=1073, d2t=-0.193 of current value 8.603968551017507
Inflection. (Runnelness): tick=1075, d2t=2 of current value 31
Inflection. (Stdev Pop): tick=1125, d2t=-0.158 of current value 8.841993591474921
Inflection. (Runnelness): tick=1136, d2t=2 of current value 28
Inflection. (Stdev Pop): tick=1179, d2t=-0.157 of current value 8.911303498862395
Inflection. (Runnelness): tick=1200, d2t=2 of current value 24
Inflection. (Stdev Pop): tick=1231, d2t=-0.134 of current value 8.822509219776062
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 1.672
Final Pathness: 1737
Final Runnelness: 25
Final Grassness: 21039
Final Entropy: 0.27
Final Curvilinearity (works only with houses): 2.291
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 2, Low Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 4
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Pathness): tick=107, d2t=1 of current value 1
Inflection. (Pathness): tick=163, d2t=1 of current value 9
Inflection. (Runnelness): tick=194, d2t=1 of current value 1
Inflection. (Runnelness): tick=246, d2t=1 of current value 13
Inflection. (Pathness): tick=247, d2t=-3 of current value 59
Inflection. (Runnelness): tick=400, d2t=3 of current value 45
Inflection. (Pathness): tick=442, d2t=-5 of current value 90
Inflection. (Runnelness): tick=451, d2t=-2 of current value 35
Inflection. (Runnelness): tick=538, d2t=2 of current value 26
Inflection. (Runnelness): tick=602, d2t=-2 of current value 28
Inflection. (Runnelness): tick=689, d2t=2 of current value 35
Inflection. (Pathness): tick=744, d2t=5 of current value 83
Inflection. (Runnelness): tick=758, d2t=-2 of current value 28
Inflection. (Pathness): tick=816, d2t=4 of current value 73
Inflection. (Runnelness): tick=820, d2t=3 of current value 31
Inflection. (Runnelness): tick=886, d2t=2 of current value 26
Inflection. (Pathness): tick=934, d2t=-4 of current value 67
Inflection. (Runnelness): tick=948, d2t=-2 of current value 27
Inflection. (Runnelness): tick=1028, d2t=-2 of current value 30
Inflection. (Pathness): tick=1048, d2t=-4 of current value 65
Inflection. (Runnelness): tick=1092, d2t=-2 of current value 31
Inflection. (Pathness): tick=1142, d2t=-4 of current value 65
Inflection. (Runnelness): tick=1145, d2t=2 of current value 30
Inflection. (Pathness): tick=1197, d2t=4 of current value 76
Inflection. (Runnelness): tick=1219, d2t=2 of current value 28
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.992
Final Pathness: 75
Final Runnelness: 24
Final Grassness: 22702
Final Entropy: 0.023
Final Curvilinearity (works only with houses): 1.589
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 3, Low Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 4
Walker count: 250
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=200, d2t=-0.051 of current value 2.831612751451311
Inflection. (Stdev Pop): tick=263, d2t=0.04 of current value 2.443599379930083
Inflection. (Stdev Pop): tick=315, d2t=0.035 of current value 2.3190463666205106
Inflection. (Stdev Pop): tick=366, d2t=-0.037 of current value 2.248166078182038
Inflection. (Stdev Pop): tick=418, d2t=-0.039 of current value 2.07232470081754
Inflection. (Stdev Pop): tick=472, d2t=0.049 of current value 2.11908104613935
Inflection. (Stdev Pop): tick=524, d2t=-0.039 of current value 2.1356578195812586
Inflection. (Stdev Pop): tick=579, d2t=0.076 of current value 2.065939726402895
Inflection. (Stdev Pop): tick=634, d2t=-0.032 of current value 2.106393267698271
Inflection. (Stdev Pop): tick=692, d2t=-0.038 of current value 2.127536495909955
Inflection. (Stdev Pop): tick=750, d2t=-0.032 of current value 1.986586327575619
Inflection. (Stdev Pop): tick=806, d2t=0.043 of current value 1.990816319293793
Inflection. (Stdev Pop): tick=870, d2t=-0.038 of current value 2.1020625706504275
Inflection. (Stdev Pop): tick=932, d2t=0.035 of current value 2.086854902051272
Inflection. (Stdev Pop): tick=985, d2t=0.047 of current value 2.0802369490018795
Inflection. (Stdev Pop): tick=1042, d2t=-0.04 of current value 1.9823489256743514
Inflection. (Stdev Pop): tick=1103, d2t=0.04 of current value 2.0823614564204633
Inflection. (Stdev Pop): tick=1156, d2t=0.066 of current value 2.166601545811892
Inflection. (Stdev Pop): tick=1207, d2t=0.043 of current value 2.0706515721125087
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.428
Final Pathness: 1479
Final Runnelness: 0
Final Grassness: 21322
Final Entropy: 0.24
Final Curvilinearity (works only with houses): 3.666
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 4, High Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 500
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Pathness): tick=51, d2t=5 of current value 72
Inflection. (Runnelness): tick=92, d2t=1 of current value 1
Inflection. (Runnelness): tick=145, d2t=-4 of current value 64
Inflection. (Stdev Pop): tick=256, d2t=0.185 of current value 9.08269292334658
Inflection. (Stdev Pop): tick=360, d2t=0.13 of current value 8.631060387605485
Inflection. (Stdev Pop): tick=562, d2t=-0.143 of current value 8.29822498285255
Inflection. (Stdev Pop): tick=974, d2t=-0.139 of current value 8.81789507583243
Inflection. (Stdev Pop): tick=1063, d2t=0.141 of current value 8.561212996031985
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 1.834
Final Pathness: 905
Final Runnelness: 344
Final Grassness: 21552
Final Entropy: 0.181
Final Curvilinearity (works only with houses): 1.731
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 4, Low Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 25
Walker vision distance: 10
Runnel durability: 175
=======================
Inflection. (Stdev Pop): tick=118, d2t=-0.047 of current value 2.5309944221899667
Inflection. (Pathness): tick=136, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=184, d2t=-0.057 of current value 3.384337962079126
Inflection. (Pathness): tick=195, d2t=2 of current value 7
Inflection. (Pathness): tick=251, d2t=1 of current value 19
Inflection. (Pathness): tick=302, d2t=1 of current value 19
Inflection. (Pathness): tick=353, d2t=-2 of current value 21
Inflection. (Stdev Pop): tick=431, d2t=0.062 of current value 3.197847740675343
Inflection. (Pathness): tick=439, d2t=2 of current value 24
Inflection. (Pathness): tick=499, d2t=1 of current value 14
Inflection. (Stdev Pop): tick=551, d2t=-0.05 of current value 3.2359980156223003
Inflection. (Pathness): tick=565, d2t=2 of current value 20
Inflection. (Pathness): tick=617, d2t=-2 of current value 26
Inflection. (Stdev Pop): tick=621, d2t=0.05 of current value 3.292857779727842
Inflection. (Pathness): tick=668, d2t=2 of current value 39
Inflection. (Stdev Pop): tick=721, d2t=0.077 of current value 3.0488270679029124
Inflection. (Pathness): tick=739, d2t=-2 of current value 28
Inflection. (Stdev Pop): tick=789, d2t=-0.082 of current value 3.0931608942092557
Inflection. (Pathness): tick=790, d2t=-1 of current value 18
Inflection. (Pathness): tick=841, d2t=-1 of current value 15
Inflection. (Stdev Pop): tick=856, d2t=-0.07 of current value 3.2627527506912952
Inflection. (Pathness): tick=898, d2t=-1 of current value 10
Inflection. (Pathness): tick=949, d2t=-1 of current value 19
Inflection. (Stdev Pop): tick=995, d2t=-0.051 of current value 3.1724576105816817
Inflection. (Pathness): tick=1046, d2t=-2 of current value 22
Inflection. (Stdev Pop): tick=1090, d2t=-0.054 of current value 3.2647186801358266
Inflection. (Pathness): tick=1100, d2t=-2 of current value 14
Inflection. (Pathness): tick=1159, d2t=-2 of current value 25
Inflection. (Stdev Pop): tick=1199, d2t=0.049 of current value 3.2374902426780747
Inflection. (Pathness): tick=1218, d2t=2 of current value 35
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 0.476
Final Pathness: 27
Final Runnelness: 0
Final Grassness: 22774
Final Entropy: 0.009
Final Curvilinearity (works only with houses): 0.17
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 5, High Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 96
Runnel durability: 175
=======================
Inflection. (Pathness): tick=51, d2t=-1 of current value 7
Inflection. (Runnelness): tick=345, d2t=1 of current value 1
Inflection. (Runnelness): tick=404, d2t=1 of current value 4
Inflection. (Stdev Pop): tick=446, d2t=-0.118 of current value 7.487404515432329
Inflection. (Runnelness): tick=498, d2t=2 of current value 10
Inflection. (Runnelness): tick=552, d2t=1 of current value 18
Inflection. (Stdev Pop): tick=564, d2t=0.122 of current value 7.76337491230598
Inflection. (Runnelness): tick=617, d2t=2 of current value 27
Inflection. (Runnelness): tick=694, d2t=2 of current value 38
Inflection. (Runnelness): tick=745, d2t=-2 of current value 35
Inflection. (Runnelness): tick=804, d2t=3 of current value 44
Inflection. (Runnelness): tick=914, d2t=-3 of current value 54
Inflection. (Runnelness): tick=989, d2t=3 of current value 49
Inflection. (Stdev Pop): tick=1137, d2t=0.116 of current value 7.454332655294363
Inflection. (Stdev Pop): tick=1222, d2t=0.14 of current value 7.604903369322465
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 1.665
Final Pathness: 691
Final Runnelness: 53
Final Grassness: 22057
Final Entropy: 0.138
Final Curvilinearity (works only with houses): 2.342
=======================

--

=== INITIALIZING SIMULATION ===
7 houses to setup at 51.42857142857143 degrees separation.
=== SIMULATION PARAMETERS ===
Simulation name: Step 3, Question 5, Low Param
Run for ticks: 1250
Houses to setup: 7
House spacing: 30
Weirdness: 0
Runnels enabled: true
Runnelator: 15
Popularity decay rate: 4%
Popularity per step: 20
Minimum route popularity: 80
Walker count: 250
Walker vision distance: 2
Runnel durability: 175
=======================
Inflection. (Pathness): tick=61, d2t=2 of current value 5
Inflection. (Runnelness): tick=142, d2t=1 of current value 1
Inflection. (Stdev Pop): tick=205, d2t=-0.111 of current value 6.687987123597071
Inflection. (Runnelness): tick=235, d2t=1 of current value 9
Inflection. (Stdev Pop): tick=257, d2t=0.113 of current value 5.007252189764835
Inflection. (Runnelness): tick=307, d2t=1 of current value 10
Inflection. (Stdev Pop): tick=341, d2t=-0.13 of current value 8.529158917272023
Inflection. (Runnelness): tick=359, d2t=-1 of current value 4
Inflection. (Stdev Pop): tick=398, d2t=-0.134 of current value 6.6368265378184
Inflection. (Runnelness): tick=411, d2t=-1 of current value 6
Inflection. (Runnelness): tick=483, d2t=-1 of current value 6
Inflection. (Runnelness): tick=546, d2t=1 of current value 11
Inflection. (Runnelness): tick=605, d2t=1 of current value 8
Inflection. (Runnelness): tick=656, d2t=1 of current value 10
Inflection. (Stdev Pop): tick=672, d2t=0.153 of current value 7.696066911516527
Inflection. (Runnelness): tick=707, d2t=1 of current value 8
Inflection. (Runnelness): tick=827, d2t=-1 of current value 8
Inflection. (Stdev Pop): tick=831, d2t=-0.116 of current value 7.668859427671869
Inflection. (Runnelness): tick=878, d2t=1 of current value 11
Inflection. (Runnelness): tick=933, d2t=1 of current value 18
Inflection. (Runnelness): tick=1004, d2t=-1 of current value 18
Inflection. (Runnelness): tick=1058, d2t=-1 of current value 12
Inflection. (Runnelness): tick=1109, d2t=-1 of current value 5
Inflection. (Runnelness): tick=1173, d2t=1 of current value 6
Inflection. (Runnelness): tick=1245, d2t=-1 of current value 5
=== SIMULATION STATISTICS ===
Ticks completed: 1250
Final Average popularity: 1.719
Final Pathness: 713
Final Runnelness: 5
Final Grassness: 22083
Final Entropy: 0.139
Final Curvilinearity (works only with houses): 0.153
=======================

```