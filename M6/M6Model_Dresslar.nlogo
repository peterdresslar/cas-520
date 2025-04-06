;Virus Transmission with Super-spreaders
;J M Applegate, 2020

;on interface, thus global variables:
;number-of-nodes, average-node-degree, initial-outbreak-size,
;heterogenous, reproduction, spreader-frequency, spreader-reproduction, non-spreader-reproduction,
;max-recovery-time, morbidity
;test-frequency, quarantine-time

; individual or node state variables

breed [nodes node]
breed [planes plane]

nodes-own
[
  infected?           ;; if true, the turtle is infectious
  resistant?          ;; if true, the turtle can be infected
  quarantine?         ;; if true, the turtle is in quarantine
  dead?               ;; if true, the turtle is dead
  spreader?           ;; when using a heterogenous transmission model, if true the agent is a spreader
  infected-timer      ;; number of ticks since turtle became infected
  test-timer          ;; number of ticks since this turtle's last COVID test
  quarantine-timer    ;; number of ticks since turtle entered quarantine
]

planes-own
[
  airspeed
  nodes-hit
]




; model setup routines
to setup
  clear-all

  ask patches [ set pcolor sky + 4 ]
  setup-nodes
  setup-spatially-clustered-network
  ask n-of initial-outbreak-size nodes
    [ become-infected ]
  if heterogenous
    [ ask n-of floor( spreader-frequency / 100 * population ) nodes
      [ set spreader? true
        set size 1.5]
  ]
  ask links [ set color black ]
  reset-ticks
end

to setup-nodes
  set-default-shape nodes "circle"
  create-nodes population
  [
    ; for visual reasons, we don't put any nodes *too* close to the edges
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    become-susceptible ; this only happens once in setup, could reoccur if immunity wears off
    set test-timer random test-frequency
    set infected-timer 0
    set quarantine-timer 0
    set quarantine? false
    set dead? false
    set spreader? false
  ]
end

to setup-spatially-clustered-network
  let num-links (average-degree * population) / 2
  while [count links < num-links ]
  [
    ask one-of nodes
    [
      let choice (min-one-of (other nodes with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]
  ; make the network look a little prettier
  repeat 10
  [
    layout-spring nodes links 0.3 (world-width / (sqrt population)) 1
  ]
end

;simulation routines
to go
  if all? nodes [not infected?]
    [ stop ]
  if planes-on? [
    maybe-spawn-plane
    ;; move-planes
  ]
  update-timers
  spread-virus
  quarantine
  recover
  leave-quarantine
  update-links
  tick
end

;individual is susceptible
to become-susceptible  ;; turtle procedure
  set infected? false
  set resistant? false
  set color sky - 1
end

;individual is infected
to become-infected  ;; turtle procedure
  set infected? true
  set resistant? false
  set infected-timer 1 + floor ( random ( max-recovery-time / 2 ) )
  set color red - 1
end

;recovery, test and quarantine timers are updated
to update-timers
  ask nodes [
    set test-timer test-timer + 1
    if test-timer >= test-frequency
      [ set test-timer 0 ]
    if infected?
      [ set infected-timer infected-timer + 1
        if infected-timer >= max-recovery-time
           [ set infected-timer 0 ]
    ]
    if quarantine?
      [ set quarantine-timer quarantine-timer + 1
        if quarantine-timer >= quarantine-time
           [ set quarantine-timer 0 ]
    ]
  ]
end

;infected individuals spread virus, either through homogenous or heterogenous transmission
to spread-virus
  ifelse heterogenous
  [ ask nodes with [ infected? and not quarantine? and spreader? ]
    [ ask link-neighbors with [ not resistant? and not quarantine? and not infected? and not dead? ]
        [ if random-float 100 < spreader-reproduction
            [ become-infected ]
        ]
    ]
    ask nodes with [ infected? and not quarantine? and not spreader? ]
    [ ask link-neighbors with [ not resistant? and not quarantine? and not infected? and not dead? ]
        [ if random-float 100 < non-spreader-reproduction
            [ become-infected ]
        ]
    ]
  ]
  [ ask nodes with [ infected? and not quarantine? ]
    [ ask link-neighbors with [ not resistant? and not quarantine? and not infected? and not dead? ]
     [ if random-float 100 < reproduction
            [ become-infected ]
    ]
  ]
  ]
end

;positive test individual is quarantined
to quarantine
  ask nodes with [ infected? and test-timer = 0 ]
  [ set quarantine? true
    set quarantine-timer 1
    set color pink
    ]
end

;individual leaves quarantine
to leave-quarantine
  ask nodes with [ quarantine? and quarantine-timer = 0 ]
  [ set quarantine? false
    ifelse infected?
      [ set color red - 1
    ]
      [ set color white ]
  ]
end

; infected individual recovers
to recover
  ask nodes with [ infected? and infected-timer = 0 ]
    [
      ifelse random-float 100 < morbidity
      [ do-death ]
      [ set infected? false
        set resistant? true
        set color white
      ]
  ]
end

;infected individual dies
to do-death
  set dead? true
  set quarantine? false
  set infected? false
  set resistant? false
  set color black
end

;links to resistant, quarantined or dead individuals are updated
to update-links
  ask nodes [
    ask my-links [ set color black ]
  ]
  ask nodes [ if resistant? or dead? or quarantine?
    [  ask my-links [ set color gray + 2 ]
    ]
  ]

end

;; DRESSLAR

to maybe-spawn-plane
  let frequency_damper 2
  let wall-size max-pxcor

  ;; check plane-frequency and roll 2d20 to go under its inverse. we don't want planes all the time
  let this-roll ((random 20) + 1) * frequency_damper
  output-print(word "rolled " this-roll " vs " plane-frequency)
  if this-roll < plane-frequency [
    let wall (random 4)  ;;; upper right lower left
    let x 0
    let y 0
    let init-heading 0


  (ifelse
    wall = 0 [   ;; upper
      set x random-xcor
      set y max-pycor
      set init-heading 180 + (random 45) - 22.5 ;;; face opposite the top wall, use cone 45 (with middle)
    ]
    wall = 1 [   ;; right
      set y random-ycor
      set x max-pxcor
      set init-heading 270 + (random 45) - 22.5 ;;; face opposite the right wall
    ]
    wall = 2 [   ;; lower
      set x random-xcor
      set y min-pycor
      set init-heading 0 + (random 45) - 22.5 ;;; face opposite the bottom wall
    ]
    wall = 3 [   ;; left
      set y random-ycor
      set x min-pxcor
      set init-heading 90 + (random 45) - 22.5 ;;; face opposite the left wall
    ]
   )

   create-planes 1 [
     set shape "airplane"
     setxy x y
     set heading init-heading
     set size 1.5
     set nodes-hit []
     set airspeed 1
   ]
  ]


  ;;]

end

to move-planes
  ;; okay, we need to move all the planes
  ;; if they hit the edge they are removed
  ;; if they hit any node, that node is linked to all the other nodes the plane has hit
  ;;ask planes [
   ;; fd airspeed
    ;; if (xcor > max-pxcor) or (xcor < min-pxcor) or (ycor > max-pycor) or (ycor < min-pycor) [  ;; right left top bottom, i think
    ;;  die
    ;;]

    ;; check for nearby node turtles within plane-radius


    ;;if any? nodes-hit with [ distance myself < 1 ] [
     ;; output-print(word "Plane hit node" first one-of nodes-hit with [ distance myself < 1 ])
    ;;  output-print(word "Plane nodes-hit now " nodes-hit)
    ;;  let hit-node first one-of nodes-hit with [ distance myself < 1 ]
     ;; ask hit-node [
     ;;   create-link-with first one-of nodes-hit with [ distance myself < 1 ]
     ;; ]
    ;; ]
  ;;]
end




; copyright J M Applegate, Arizona State University School of Complex Adaptive Systems, 2021
; This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.
; To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/
; or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

; This model is built on the Virus Transmission on a Network model:
; Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/.;
; Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
GRAPHICS-WINDOW
271
10
730
470
-1
-1
11.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

SLIDER
25
619
230
652
quarantine-time
quarantine-time
0.0
40
14.0
1
1
days
HORIZONTAL

SLIDER
25
477
230
510
max-recovery-time
max-recovery-time
0.0
40
21.0
1
1
days
HORIZONTAL

SLIDER
25
301
247
334
reproduction
reproduction
0.0
100
20.0
1
1
%
HORIZONTAL

BUTTON
24
185
119
225
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
126
185
221
225
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
757
10
1193
353
Population Status
time
% of population
0.0
20.0
0.0
100.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -13345367 true "" "plot (count turtles with [not infected? and not resistant? and not dead?]) / (count turtles) * 100"
"infected" 1.0 0 -2674135 true "" "plot (count turtles with [ infected?] ) / (count turtles) * 100"
"dead" 1.0 0 -16777216 true "" "plot (count turtles with [ dead? ]) / (count turtles) * 100"
"resistant" 1.0 0 -7500403 true "" "plot (count turtles with [ resistant? ]) / (count turtles) * 100"

SLIDER
25
72
230
105
population
population
10
300
300.0
5
1
NIL
HORIZONTAL

SLIDER
25
584
230
617
test-frequency
test-frequency
1
20
14.0
1
1
days
HORIZONTAL

SLIDER
25
142
230
175
initial-outbreak-size
initial-outbreak-size
1
population
20.0
1
1
NIL
HORIZONTAL

SLIDER
25
107
230
140
average-degree
average-degree
1
population - 1
6.0
1
1
NIL
HORIZONTAL

BUTTON
627
474
725
507
Single Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
513
230
546
morbidity
morbidity
0
100
10.0
1
1
%
HORIZONTAL

TEXTBOX
30
21
218
65
Virus Transmission\nwith Super-spreaders
18
0.0
1

SWITCH
25
265
186
298
heterogenous
heterogenous
0
1
-1000

SLIDER
25
336
247
369
spreader-frequency
spreader-frequency
0
100
20.0
1
1
%
HORIZONTAL

SLIDER
25
372
247
405
spreader-reproduction
spreader-reproduction
0
100
80.0
1
1
%
HORIZONTAL

MONITOR
757
361
859
410
% susceptible
count turtles with [ not resistant? and not infected? and not dead? ] / count turtles * 100
0
1
12

MONITOR
867
361
947
410
% infected
count turtles with [ infected?]  / count turtles * 100
0
1
12

MONITOR
954
361
1028
410
 resistant
count turtles with [ resistant? ]  / count turtles * 100
0
1
12

MONITOR
1036
361
1098
410
% dead
count turtles with [ dead? ]  / (count turtles) * 100
0
1
12

SLIDER
25
408
247
441
non-spreader-reproduction
non-spreader-reproduction
0
100
10.0
1
1
%
HORIZONTAL

TEXTBOX
26
241
176
259
Transmission type
14
0.0
1

TEXTBOX
26
453
247
487
Contagion characteristics
14
0.0
1

TEXTBOX
27
560
177
578
Interventions
14
0.0
1

SWITCH
271
544
397
577
planes-on?
planes-on?
0
1
-1000

SLIDER
406
544
578
577
plane-frequency
plane-frequency
0
20
10.0
5
1
NIL
HORIZONTAL

SLIDER
585
544
757
577
plane-radius
plane-radius
0
5
1.0
1
1
NIL
HORIZONTAL

MONITOR
935
475
992
520
planes
count planes
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model demonstrates the spread of a virus through a network of individuals with either a homogenous transmission or a superspreader transmission.

## ATTRIBUTIONS
This model was built on the Virus Transmission on a Network Model

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2021 J M Applegate, Arizona State University School of Complex Adaptive Systems

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="March10" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [ not resistant? and not infected? and not dead? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ resistant? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ quarantine? ]</metric>
    <enumeratedValueSet variable="test-frequency">
      <value value="2"/>
      <value value="7"/>
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-outbreak-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-degree">
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quarantine-time">
      <value value="0"/>
      <value value="7"/>
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="morbidity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-recovery-time">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-spread">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="virus-spread-chance">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
