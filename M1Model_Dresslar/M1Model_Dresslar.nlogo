;; Dresslar_assignment1.nlogo
;; Step 1

;; Step 2 -- Controls. Complete.

extensions [sound]

breed [wolves wolf]  ;; Step 4
breed [houses house]

globals [  ;; iʻve got my dungeon masterʻs guide.
  grass-armor-class
  wood-armor-class
  brick-armor-class
  wolf-level-cap
  max-wolf-size
]

houses-own [grass? wood? brick? hit-points charisma]     ;; step 6
wolves-own [constitution character-level]                ;; for breath weapon, naturally.

to setup       ;; Step 3
  clear-all    ;; Step 3.1
  reset-ticks  ;; Step 3.1

  set grass-armor-class 8
  set wood-armor-class 10
  set brick-armor-class 12
  set max-wolf-size 5
  set wolf-level-cap 12  ;; hope they buff this with the DLC!!!

  create-wolves num-wolves [  ;; Step 4.1 4.2
    setxy random-xcor random-ycor
    set shape "wolf"
    set color gray
    set size 1
    set constitution ((3 * (random 6)) + 3) + wolf-bonus  ;; 3d6 + 2  ;; wolves notably tough
    set character-level 1
  ]

 create-houses num-houses [  ;; Step 4.1 4.2
    setxy random-xcor random-ycor
    set shape "house"
    set size 1

    set grass? false     ;; step 6.1
    set wood? false
    set brick? false

    let chance random 3  ;; 1d6 divided by 2
    if chance = 0 [
      set grass? true
      set color green
      set hit-points ((1 * (random 6)) + 1) * grass-hit-dice     ;; random d6 roll, the extra parens are to keep dice rolls clear (to me?)
      set charisma ((3 * (random 6)) + 3) + house-bonus
    ]
    if chance = 1 [
      set wood? true
      set color brown
      set hit-points ((1 * (random 6)) + 1) * wood-hit-dice
      set charisma ((3 * (random 6)) + 3) + house-bonus
    ]
    if chance = 2 [
      set brick? true
      set color red
      set hit-points ((1 * (random 6)) + 1) * brick-hit-dice
      set charisma ((3 * (random 6)) + 3) + house-bonus
    ]
  ]
end

to go  ;; Step 3
  ask wolves [
    roll-to-move  ;; Step 5.1
    let experience check-for-attack
    set character-level (min list (character-level + experience) wolf-level-cap)
    let new-size ceiling (character-level / 4)

    set size min list new-size max-wolf-size  ;; higher level wolves appear larger
  ]

  ask houses [    ;; Houses turn
    build-new-house
  ]

  update-plot
  tick  ;; Step 3.2
end

to roll-to-move  ;; Step 5.0
  ;; Roll a d10. 2-9 are cardinal directions, 10 is random, 1 is stay put.
  let roll ((1 * (random 10)) + 1)      ;; how does netlogo not have dnd dice primitives
  if roll = 1 [
    ;; pass
  ]
  if roll > 1  [                    ;; how to get to cardinal directions... ?
    rt (45 * (roll - 1))
    fd ((3 * (random 6)) + 3)       ;; I think that is 3d6?
  ]
end

to-report check-for-attack             ;; Step 7
  let experience 0
  if any? houses-here [                ;; Step 7.1
    let this-house one-of houses-here  ;; Step 7.2

    let this-wolf-cl character-level

    let breath-dc ceiling (8 + (constitution / 4))  ;; dnd 5e style breath weapon damage! via reddit, of course.

    ;; determine house "saving throw" based on type (higher is better)
    let save-bonus 0
    if [grass?] of this-house [ set save-bonus (grass-armor-class - 8) / 2 ]
    if [wood?] of this-house [ set save-bonus (wood-armor-class - 8) / 2 ]
    if [brick?] of this-house [ set save-bonus (brick-armor-class - 8) / 2 ]

    let house-destroyed? false

    ;; Saving throw halves damage
    ask this-house [
      output-print (word "Rolling for wolf level " this-wolf-cl " versus house with hp: " hit-points)

      ;; breath weapons deal more damage at higher wolf character-levels
      ;; to do this we use damage dice
      let num-dice ceiling (this-wolf-cl / 2)         ;; add a die every 2 levels, see (imaginary) monster manual
      if num-dice < 1 [ set num-dice 1 ]

      let base-damage 0
      repeat num-dice [  ;; for however many dice
        set base-damage base-damage + ((1 * (random 6)) + 1)  ;; roll a d6, and tally it
      ]
      set base-damage base-damage + wolf-bonus

      let save-roll ((1 * (random 20)) + 1) + save-bonus

      ifelse save-roll < breath-dc [
        ;; this is like trinary?
        let damage base-damage
        output-print (word "Save failed: roll: " save-roll " vs. " breath-dc)
        output-print (word "Damage is: " damage)
        set hit-points hit-points - (damage)
        output-print (word "House hit points are now: " hit-points)
      ] [
        ;; Second case - save succeeded
        let damage base-damage / 2
        output-print (word "Save succeeded: roll: " save-roll " vs. " breath-dc)
        output-print (word "Damage is: " damage " (halved)")
        set hit-points hit-points - (damage)
        output-print (word "House hit points are now: " hit-points)
      ]

      if hit-points <= 0 [  ;; never good
        let house-type "Unknown"
        if grass? [ set house-type "Grass" ]
        if wood? [ set house-type "Wood" ]
        if brick? [ set house-type "Brick" ]

        output-print (word "X X X " house-type " House #" who " has succumbed to a level " this-wolf-cl " wolf! X X X")

        if sound-on [  ;; multimedia experience
          if grass? [ sound:play-drum "SPLASH CYMBAL" 64 ]
          if wood? [ sound:play-drum "LOW WOOD BLOCK" 64 ]
          if brick? [ sound:play-drum "BASS DRUM 1" 64 ]
        ]

        set house-destroyed? true
        die
      ]
    ]

    ;; If the house was destroyed, award wolf experience
    if house-destroyed? [
      set experience 1
    ]
  ]

  report experience  ;; return the experience
end

to build-new-house   ;; Step 8
  let build-chance 0

  let crowding-factor count houses in-radius 5      ;; Get the count of houses
  if crowding-factor = 0 [ set crowding-factor 1 ]  ;; Avoid division by zero

  let reproduction-factor house-repro-factor                        ;; slider 1-100 make sure no zeros allowed!
  if grass? [ set reproduction-factor (house-repro-factor * 1.3) ]  ;; Repro differences per Step 8 instructions.
  if wood? [ set reproduction-factor (house-repro-factor * 1.0) ]
  if brick? [ set reproduction-factor (house-repro-factor * 0.7) ]

  set build-chance ((reproduction-factor + (charisma * 2)) / crowding-factor)  ;; Only charisma can help with crowding

  ;; output-print (word "charisma: " charisma " | crowding-factor: " crowding-factor)
  ;; output-print (word "build-chance: " build-chance)

  let build-roll random 100  ;; 1d100! weʻll just leave it like this
  ;; output-print (word "build-roll: " build-roll)

  if build-roll < build-chance [  ;; higher build change is easier
    ;; tricky bit: trying to hatch in a full radius will crash the hatch
    let empty-patch one-of patches in-radius 5 with [not any? houses-here]
    if empty-patch = nobody [
      stop  ;; nope
    ]

    hatch-houses 1 [
      ;; We've already confirmed empty-patch is not nobody
      move-to empty-patch

      (ifelse
        grass? [
          set hit-points ((1 * (random 6)) + 1) * grass-hit-dice
          output-print (word "Grass house hatched with " hit-points " hp.")
        ]
        wood? [
          set hit-points ((1 * (random 6)) + 1) * wood-hit-dice
          output-print (word "Wood house hatched with " hit-points " hp.")
        ]
        brick? [
          set hit-points ((1 * (random 6)) + 1) * brick-hit-dice
          output-print (word "Brick house hatched with " hit-points " hp.")
        ])
    ]
  ]
end

to update-plot
  set-current-plot "Wolf and House Stats"

  ;; Plot average wolf character level
  set-current-plot-pen "Wolf Level"
  ifelse any? wolves
    [ plot mean [character-level] of wolves ]
    [ plot 0 ]

  ;; Plot average house charisma
  set-current-plot-pen "House Charisma"
  ifelse any? houses
    [ plot mean [charisma] of houses ]
    [ plot 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
8
10
180
43
num-wolves
num-wolves
1
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
8
47
180
80
num-houses
num-houses
1
100
20.0
1
1
NIL
HORIZONTAL

BUTTON
9
212
173
245
G for go forever
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
9
169
107
202
S for setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SWITCH
688
18
807
51
sound-on
sound-on
0
1
-1000

SLIDER
8
88
195
121
wolf-bonus
wolf-bonus
0
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
8
124
195
157
house-bonus
house-bonus
0
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
296
43
446
brick-hit-dice
brick-hit-dice
1
6
4.0
1
1
d6
VERTICAL

SLIDER
56
296
89
446
wood-hit-dice
wood-hit-dice
1
6
2.0
1
1
d6
VERTICAL

SLIDER
102
296
135
446
grass-hit-dice
grass-hit-dice
1
6
1.0
1
1
d6
VERTICAL

SLIDER
9
252
186
285
house-repro-factor
house-repro-factor
1
100
20.0
1
1
NIL
HORIZONTAL

PLOT
687
61
1079
270
Wolf and House Stats
time
avg
0.0
10.0
0.0
25.0
true
false
"" ""
PENS
"Wolf Level" 1.0 0 -9276814 true "" ""
"House Charisma" 1.0 0 -14070903 true "" ""

@#$#@#$#@
## WHAT IS IT?

This is a class model that does not explain anything in particular. I am learning netlogo and that is the intent of the model

## HOW IT WORKS

Wolves move randomly and when they encounter houses they inflict damage using well-known huff-puff breath weapon mechanics. Different houses have different damage tolerance according to building materials.

## HOW TO USE IT

Press Setup, and then press Go. You can use keyboard commands, in particular to stop and start the model with "g".

## THINGS TO NOTICE

The command center has verbose output. Too verbose.

## THINGS TO TRY

Note that wolves gain experience over time, which improves their ability to damage. The houses do not level up. So, this is more of a Skyrim experience than a Souls experience. You know, from science.

When setting the sliders, consider that houses should lose power over time... but, wait! Charisma impacts reproduction. And, there is an inheritance function for charisma! Maybe we should expect charisma to provide some kind of fitness? A plot is provided so we can see.

## EXTENDING THE MODEL

Itʻs a toy. Extend something good.

## NETLOGO FEATURES

EPIC MULTIMEDIA EXPERIENCE SOUND ON SPEAKERS ***UP***

## RELATED MODELS

Come on man, nobodyʻs ever going to read this.

## CREDITS AND REFERENCES

Adapted from homework assignment Prof. S. Bergin, Arizona State University, 2025
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

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
