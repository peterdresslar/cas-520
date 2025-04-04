extensions [ sound ]

breed [ houses house ]  ;; kept forgetting these were called buildings, so they are not anymore.

breed [ walkers walker ]
walkers-own [ goal ]

houses-own [ house-number ]

patches-own [  ;; one-lining these is annoying, sorry.
  popularity
  transition-tick ;; date of last transition
  on-line?   ;; is on a line between houses?
  line       ;; line-name for line that patch is on
             ;; patches could be on more than one line, but here we just store the latest one.
]

globals [
  mouse-clicked?
  avg-popularity
  stdev-popularity
  pathness
  runnelness
  grassness
  curvilinearity
  entropy
  houses-built
  lines
  eps
  new-lines-buffer
  runnel-durability
  runnelation-factor
  simulation-name
  step-2?

  ;;;; inflection point detection
  ;; in order to detect inflection points we need to track current and past states and some derivatives also
  ;; a chore, but would be worth it if it works

  dt-stdev-popularity
  d2t-stdev-popularity
  dt-pathness
  d2t-pathness
  dt-runnelness
  d2t-runnelness

  ;; priors
  pathness-prev
  dt-pathness-prev
  runnelness-prev
  dt-runnelness-prev
  stdev-popularity-prev
  dt-stdev-popularity-prev

  ;; more thresholds! different d2ts in particular are going to need to be monitored with differnt sensitivities

  d2t-pathness-threshold
  d2t-runnelness-threshold
  d2t-stdev-popularity-threshold

  ;;
  d2t-pathness-last-inflection
  d2t-runnelness-last-inflection
  d2t-stdev-popularity-last-inflection

  ;; cooldown

  inflection-cooldown

]

to setup
  set simulation-name ""
  clear-all
  set houses-built 0
  set lines []  ;; empty list
  set new-lines-buffer []
  set-default-shape houses "house"
  ask patches [
     set pcolor green
     set transition-tick 0
     set on-line? false
     set line ""
  ]
  create-walkers walker-count [
    setxy random-xcor random-ycor
    set goal one-of patches
    set color yellow
    set size 2
  ]
  set runnel-durability 175   ;; why isnʻt this a slider, idk just not feeling it

  ;; Initialize previous state variables
  set dt-stdev-popularity 0
  set d2t-stdev-popularity 0
  set dt-pathness 0
  set d2t-pathness 0
  set dt-runnelness 0
  set d2t-runnelness 0
  set pathness-prev 0
  set dt-pathness-prev 0
  set runnelness-prev 0
  set dt-runnelness-prev 0
  set stdev-popularity-prev 0
  set dt-stdev-popularity-prev 0

  ;; Set thresholds
  set d2t-pathness-threshold .05
  set d2t-runnelness-threshold .05
  set d2t-stdev-popularity-threshold .015

  set d2t-pathness-last-inflection 0  ;; alerts right away are fine
  set d2t-runnelness-last-inflection 0
  set d2t-stdev-popularity-last-inflection 0

  set inflection-cooldown 50

  reset-ticks
  update-globals
end

to setup-with-houses
  set simulation-name ""
  clear-all
  set houses-built 0
  set lines []
  set new-lines-buffer []
  set-default-shape houses "house"
    ask patches [
      set pcolor green
      set transition-tick 0
      set on-line? false
      set line ""
  ]
  houses-setup
  process-new-lines-buffer  ;; gotta call it here
  create-walkers walker-count [
    setxy random-xcor random-ycor
    set goal one-of patches
    set color yellow
    set size 2
  ]
  set runnel-durability 175

  ;; Initialize previous state variables
  set dt-stdev-popularity 0
  set d2t-stdev-popularity 0
  set dt-pathness 0
  set d2t-pathness 0
  set dt-runnelness 0
  set d2t-runnelness 0
  set pathness-prev 0
  set dt-pathness-prev 0
  set runnelness-prev 0
  set dt-runnelness-prev 0
  set stdev-popularity-prev 0
  set dt-stdev-popularity-prev 0


  ;; Set thresholds
  set d2t-pathness-threshold .05
  set d2t-runnelness-threshold .05
  set d2t-stdev-popularity-threshold .015


  set d2t-pathness-last-inflection 0  ;; alerts right away are fine
  set d2t-runnelness-last-inflection 0
  set d2t-stdev-popularity-last-inflection 0

  set inflection-cooldown 50

  reset-ticks
  update-globals
end


;; Click to place houses
;; Have stuff unbecome path once it decays below a certain popularity threshold
to go
  check-house-placement
  process-new-lines-buffer  ;; but also here
  move-walkers
  decay-popularity
  check-degrade-runnels-to-grass
  recolor-patches
  update-globals
  tick
end

to houses-setup
  ;; use houses-to-setup and weirdness to spawn houses
  ;; we will adapt something like RegularPolygon(n) from Wolfram
  ;; note that theta is angle in radians
  ;; https://reference.wolfram.com/language/ref/RegularPolygon.html.en
  let houses-range (range 0 houses-to-setup)
  let degrees-per-house 360 / houses-to-setup
  ;; let radians-per-house (degrees-per-house * (pi / 180))  ;; canʻt use radians in NL without extensions, though
  output-print(word houses-to-setup " houses to setup at " degrees-per-house " degrees separation.")
  let house-i 0
  let this-degrees 0
  let this-xcor 0
  let this-ycor house-spacing  ;; house-spacing is the unit-circle-radius we will use to our delight below.

  if houses-to-setup > 0 [  ;; it should be!
    ;; for each additional house
    foreach houses-range [
      ;; set this-radians (house-i * radians-per-house)
      set this-degrees (house-i * degrees-per-house)  ;; welp this works
      let random-posneg (1 - (random 2 * 1))  ;; heh.
      set this-xcor (house-spacing * (cos this-degrees)) + (random-posneg * ((weirdness * (13 - (houses-to-setup / 2))) / house-spacing))  ;; parens are free baby
      set this-ycor (house-spacing * (sin this-degrees)) + (random-posneg * ((weirdness * (13 - (houses-to-setup / 2))) / house-spacing))
      ask patch this-xcor this-ycor [toggle-house]
      set house-i (house-i + 1)
    ]
  ]
end

to check-house-placement
  ifelse mouse-down? [
    if not mouse-clicked? [
      set mouse-clicked? true
      ask patch mouse-xcor mouse-ycor [ toggle-house ]
    ]
  ] [
    set mouse-clicked? false
  ]
end

to toggle-house
  let nearby-houses houses in-radius 4
  ifelse any? nearby-houses [
    ; if there is a house near where the mouse was clicked
    ; (and there should always only be one), we remove it and
    ask nearby-houses [ die ]
    set houses-built (houses-built - 1)
    ; remove-line houses-built
  ] [
    ; if there was no houses near where
    ; the mouse was clicked, we create one
    let this-new-house nobody
    sprout-houses 1 [
      set color red
      set size 4
      set house-number houses-built + 1  ;; since we technically donʻt have a sprout-houses callback.
      set this-new-house self
    ]
    set houses-built (houses-built + 1)
    add-lines this-new-house  ;; self has a house-number
  ]
end

to decay-popularity
  ask patches with [ not any? walkers-here ] [
    set popularity popularity * (100 - popularity-decay-rate) / 100
    ; when popularity is below 1, the patch becomes (or stays) grass
    if popularity < 1 and pcolor = gray [
      set transition-tick ticks
      set pcolor green
    ]
  ]
end

to become-more-popular
  set popularity popularity + popularity-per-step
  ; if the increase in popularity takes us above the threshold, become a route
  if popularity >= minimum-route-popularity [
    if pcolor != gray [ ;; newly path
        set transition-tick ticks ;; date of transition
    ]
    set pcolor gray  ;; path
  ]
end

to check-for-runnel
  ;; if the increase in pop takes us over the (inverse) runnelator, become a runnel

  ;; check if we are maxed out on runnels
  if (count patches with [ pcolor = blue ] > 350) [
    stop
  ]

  ;; donʻt build moats (well hopefully)
  if any? houses in-radius 4 [
    stop
  ]

  ;; check established paths
  if (ticks - transition-tick > 25)  [
    let roll random(100) + 1

    let runnel-roll (roll * (popularity + popularity) / 100)
    ;; output-print(word roll "rolled " runnel-roll " vs. " (100 - runnelator) " popularity here " popularity )
    if runnel-roll > 100 - runnelator [
      if pcolor != blue [ ;; new runnel
        set transition-tick ticks  ;; set date
      ]
      set pcolor blue  ;; runnel
    ]
  ]
end

to check-degrade-runnels-to-grass
  ask patches with [ pcolor = blue ] [
    if (ticks - transition-tick) > runnel-durability  [
      ; output-print(word "transitioning to grass" ticks " " runnel-durability " " transition-tick)
      if pcolor != green [  ;; should not happen
         set transition-tick ticks
      ]
      set pcolor green
    ]
  ]
end

to move-walkers
  ask walkers [
    ifelse patch-here = goal [
      ifelse count houses >= 2 [
        set goal [ patch-here ] of one-of houses
      ] [
        set goal one-of patches
      ]
    ] [
      walk-towards-goal
    ]
  ]
end

to walk-towards-goal
  if pcolor != gray and pcolor != blue [
    ; boost the popularity of the patch we're on
    ask patch-here [ become-more-popular ]
  ]

  ;; walking through a patch can trigger a runnel as part of increased popularity
  if pcolor = gray and runnels?  [
    ask patch-here [ check-for-runnel ]
  ]

  face best-way-to goal

  ;; okay, walking. it just got treacherous
  if [pcolor] of patch-ahead 1 = blue [  ;; trouble. best-way-to goal has let us down
    ;; If there's a runnel directly ahead, look for another direction
    let potential-moves (patches at-points [[0 1] [1 1] [1 0] [1 -1] [0 -1] [-1 -1] [-1 0] [-1 1]])  ;; a CA is here
    let safe-moves potential-moves with [pcolor != blue] ;; simular to our pathfinding from before

    ifelse any? safe-moves [
      face min-one-of safe-moves [distance [goal] of myself]
    ] [
      ;; bad news, we are at the bottom of the ifelse stack
      ;; we can try resetting goal but it likely wonʻt work
      set goal one-of patches  ;; anywhere
      ;; if all else fails
      wiggle
      ; output-print("a turtle is runneled")
      stop  ;; Don't execute the fd 1 below
    ]
  ]

  ;;; hey hopefully we found land
  fd 1
end


;; destinations and paths are a lot like chemical and nest for ants
;; see the ants model https://www.netlogoweb.org/launch#https://www.netlogoweb.org/assets/modelslib/Sample%20Models/Biology/Ants.nlogo
;; our challenge is to preserve the original best-way-to
;; and also to avoid overwhelming the processor

to-report best-way-to [ destination ]
  ;; only use the runnel-aware pathfinding if there are runnels in sight --> performance
  ifelse any? patches in-cone walker-vision-dist 45 with [pcolor = blue] [   ;; instead of in-radius from below, we just worry about whatʻs in front of us
    report best-way-to-avoid-runnels destination
  ] [
    ; (original)
    ; of all the visible route patches, select the ones
    ; that would take me closer to my destination
    let visible-patches patches in-radius walker-vision-dist
    let visible-routes visible-patches with [ pcolor = gray ]
    let routes-that-take-me-closer visible-routes with [
      distance destination < [ distance destination - 1 ] of myself
    ]

    ifelse any? routes-that-take-me-closer [
      ; from those route patches, choose the one that is the closest to me
      report min-one-of routes-that-take-me-closer [ distance self ]
    ] [
      ; if there are no nearby routes to my destination
      report destination
    ]
  ]
end

;; this is the tricky part. we have seen blue and need to deal with it.
;; we want to intgegrate our ant scenting procs into something that looks like
;; best-way-to from the original procedure
to-report best-way-to-avoid-runnels [ destination ]
  ;; just like uphill-* from ants
  ;; but we will combine pathiness and popularity into one sweet fragarance
  let scent-ahead sniffin-around 0 destination
  let scent-right sniffin-around 45 destination
  let scent-left sniffin-around -45 destination

  ;; the ants model just turns the ant, we need to report a patch instead
  ;; see visible-patches above
  ifelse (scent-right > scent-ahead) or (scent-left > scent-ahead) [
    ifelse scent-right > scent-left
      [ report patch-at-heading-and-distance (heading + 45) 1 ]
      [ report patch-at-heading-and-distance (heading - 45) 1 ]
  ] [
    report patch-ahead 1
  ]
end

to-report sniffin-around [angle destination]
  let p patch-at-heading-and-distance (heading + angle) 1  ;; why is there not a patch-ahead(aheadness)

  ; Avoid runnels completely
  if p = nobody or [pcolor] of p = blue [ report -100 ]

  let base-pathularity 0

  ifelse [pcolor] of p = gray [
    set base-pathularity 100 + [popularity] of p
  ] [
    set base-pathularity [popularity] of p
  ]

  ; now we need to bring in the best-way-to approach since ants have no idea about distances
  let my-distance-to-goal distance destination
  let patch-distance-to-goal [distance destination] of p
  let direction 50 * (my-distance-to-goal - patch-distance-to-goal)

  ; itʻs pathularity with an angle
  report base-pathularity + direction
end

;; straight outta Ants
to wiggle  ;; turtle procedure
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
end

to-report popularity-scent-at-angle [angle]
  let p patch-at-heading-and-distance (heading + angle) 1  ;; donʻt just do right and ahead
  ifelse p = nobody or [pcolor] of p = blue   ;; slightly more complicated due to runnel
    [ report 0 ]  ;; return 0 for runnels or off-world
    [ report [popularity] of p ]
end

to-report pathiness-scent-at-angle [angle]
  let p patch-at-heading-and-distance (heading + angle) 1  ;; donʻt just do right and ahead
  if p = nobody or [pcolor] of p = blue [ report 0 ]

  ifelse [pcolor] of p = gray
    [ report 100 + [popularity] of p ] ;; better pathiness
    [
    ;; again we use the source model
      let distance-to-goal distance goal
      let patch-distance-to-goal [distance goal] of p
      let direction 50 * (distance-to-goal - patch-distance-to-goal)

     ;;output-print(word ([popularity] of p + direction)

      report [popularity] of p + direction
    ]
end


to-report check-curvilinearity
  ;; avoid zeroness
  ;; no references for this, I made it up. It doesnʻt work as well as I would like

  if pathness = 0 or count patches with [ on-line? ] = 0 [ report 0 ]

  let out-of-bounds 5 ;; if a path is farther than this from some line, it is probably not part of a curve, but rather just out "in the wild"

  let path-patches patches with [ pcolor = gray ]
  let sample-size min list pathness 90  ;; too high a sample-size causes a big slow-down
  let paths-sample n-of sample-size patches with [ pcolor = gray ]

  ;; have each patch that is path (gray) calculate its distance to the nearest line patch
  let sq-deviation 0  ;; initialize collector
  let patches-checked 0

  ask paths-sample [
    ;; find the nearest patch with on-line? true
    let nearest-line-patch min-one-of patches with [ on-line? ] [ distance myself ]
    ;; only add to absolute deviation if we are within bounds
    let deviation distance nearest-line-patch
    if deviation < out-of-bounds [
      ;; square the distance up to the OOB, closer we get to OOB we are, we are getting much curvier.
      set sq-deviation sq-deviation + (deviation * deviation)
      set patches-checked (patches-checked + 1)
    ]
  ]

  ; because lines are far more dense in complex shapes (more houses)
  ; we scale our curvilinearity with a factor of num-lines
  let curve-scaling-factor 1
  let num-lines length lines
  if num-lines > 1 [
    set curve-scaling-factor sqrt num-lines
  ]

  ;; calculate an average over pathness. we may need to update for runnelation

  ifelse patches-checked > 0 [   ; avoid div0
    report  (sq-deviation / patches-checked) * curve-scaling-factor
  ] [
    report 0
  ]
end

to recolor-patches
  ifelse show-popularity? [
    let max-value (minimum-route-popularity * 3)
    ask patches with [ pcolor != gray and pcolor != blue ] [
      set pcolor scale-color green popularity (- max-value) max-value
    ]
  ] [
    ask patches with [ pcolor != gray and pcolor != blue ] [
      set pcolor green
    ]
  ]
end


to add-lines [ this-house ]

  ;; we will assume, and this is more or less by the grace of the netlogo gods, that all prior houses are on the line network
  ;; speaking of by the grace of... letʻs just get this program fault out of the way

  if [ house-number ] of this-house <= 1 [ stop ] ; no work to do here

  ;; with that out of the way, we need to get this house xcor ycor

  let this-x [ xcor ] of this-house
  let this-y [ ycor ] of this-house

  ;; and then we need to build an iterable set of the other houses, through which we will loop
  let all-houses-but-this houses with [ self != this-house ]

  ask all-houses-but-this [
    let other-x [ xcor ] of self
    let other-y [ ycor ] of self
    ;; line name is that-house-number--this-house-number (here, we are dealing with that house)
    let line-name (word ([ house-number ] of self) "--" ([ house-number ] of this-house))

    ;; okay, we have our xes and ys...
    let line-details (list line-name other-x other-y this-x this-y)

    ;; lines.append(line-details)
    set lines lput line-details lines  ;; lput == list-put?

    set new-lines-buffer lput line-details new-lines-buffer   ;; have to do this for observer context. dumping the lines into a global buffer
                                                              ;; we cannot otherwise work with patches here
                                                              ;; a syntactical dealbreaker

    output-print(word "constructed line: " line-details)
  ]

end

to process-new-lines-buffer
  if length new-lines-buffer > 0 [
    foreach new-lines-buffer [ line-data ->
      add-line-to-patches line-data
    ]
    ;; Clear the buffer once processed
    set new-lines-buffer []
  ]
end

to add-line-to-patches [line-data]
  ;; wishing for unzip
  let line-name item 0 line-data
  let other-x item 1 line-data
  let other-y item 2 line-data
  let this-x item 3 line-data
  let this-y item 4 line-data

  ;; lets use a comment on an SO (https://stackoverflow.com/a/328193/13693304) ... see my comment?

  let distance-line sqrt((this-x - other-x) ^ 2 + (this-y - other-y) ^ 2)  ; # def distance(a, b)

  ask patches [   ;; in other words, for all patches for which this is true:
    let patch-x pxcor
    let patch-y pycor
    let zeta 0.1  ;; tolerance. eps was already taken!
    let distance-other-this ((distancexy other-x other-y) + (distancexy this-x this-y)) ;; distance to houses, really

    if (abs(distance-other-this - distance-line) < zeta) [  ;; patch is on the line
      set on-line? true
      set line line-name  ;; again, this could overwrite, but thatʻs fine
    ]
  ]

  ;; output-print(word "patches updated: number of patches with on-line? true is now: " count patches with [on-line?] " out of " count patches "." )
end

to update-globals
  set eps 1e-10   ;;; yet another epsilonish value
  ;; set up for dts and d2ts... basically going to try and find inflection points and
  ;; beep them out

  ;; we have to do math in the middle of all this, so we need to do
  ;; set buffer states (current state buffers)
  ;; deal with dts (velocity)
  ;; deal with d2ts (accelertation)
  ;; update previous from current
  ;; update real states


  ;; buffer states
  let buffer-avg-popularity mean [popularity] of patches
  let buffer-stdev-popularity standard-deviation [popularity] of patches
  let buffer-pathness count patches with [pcolor = gray]
  let buffer-runnelness count patches with [pcolor = blue]
  let buffer-grassness count patches with [pcolor = green]

  ;; main summaries needed for telltailing, is that a word
  set avg-popularity buffer-avg-popularity
  set stdev-popularity buffer-stdev-popularity
  set pathness buffer-pathness
  set runnelness buffer-runnelness
  set grassness buffer-grassness

  ;; note that d2ts need to go back 2 steps
  if ticks > 1 [  ;; donʻt remove
    set dt-pathness (buffer-pathness - pathness-prev)
    set dt-runnelness (buffer-runnelness - runnelness-prev)
    set dt-stdev-popularity (buffer-stdev-popularity - stdev-popularity-prev)

    if ticks > 2 [  ;; donʻt remove
      set d2t-pathness (dt-pathness - dt-pathness-prev)
      set d2t-runnelness (dt-runnelness - dt-runnelness-prev)
      set d2t-stdev-popularity (dt-stdev-popularity - dt-stdev-popularity-prev)

      ;output-print (word "d2t-pathness: " precision d2t-pathness 3 ", d2t-runnelness: " precision d2t-runnelness 3 ", d2t-stdev-popularity: " precision d2t-stdev-popularity 3)
      ;output-print (word "d2t-pathness-threshold: " d2t-pathness-threshold ", d2t-runnelness-threshold: " d2t-runnelness-threshold ", d2t-stdev-popularity-threshold: " d2t-stdev-popularity-threshold)

      ;; okay, absolute thresholds will not work, we need to convert each of our d2ts to a percentage of their current absolute values
      ;; with dividing by zero of course
      let d2t-pathness-pct 0
      let d2t-runnelness-pct 0
      let d2t-stdev-popularity-pct 0
      if buffer-pathness > 0 [
        set d2t-pathness-pct (abs(d2t-pathness) / buffer-pathness)
      ]
      if buffer-runnelness > 0 [
        set d2t-runnelness-pct (abs(d2t-runnelness) / buffer-runnelness)
      ]
      if buffer-stdev-popularity > 0 [
        set d2t-stdev-popularity-pct (abs(d2t-stdev-popularity) / buffer-stdev-popularity)
      ]

      ; output-print (word "d2t-pathness-pct: " precision d2t-pathness-pct 3 ", d2t-runnelness-pct: " precision d2t-runnelness-pct 3 ", d2t-stdev-popularity-pct: " precision d2t-stdev-popularity-pct 3)
      ; output-print(word d2t-pathness-last-inflection ticks inflection-cooldown) ;; carnage setting this all up
      if (d2t-pathness-pct > d2t-pathness-threshold) and (d2t-pathness-last-inflection < ticks - inflection-cooldown) [
        output-print (word "Inflection. (Pathness): tick=" ticks ", d2t=" precision d2t-pathness 3 " of current value " buffer-pathness)
        if sound-on? [ sound:play-note "TUBULAR BELLS" 60 64 .5 ]
        set d2t-pathness-last-inflection ticks
      ]
      if (d2t-runnelness-pct > d2t-runnelness-threshold) and (d2t-runnelness-last-inflection < ticks - inflection-cooldown) [
        output-print (word "Inflection. (Runnelness): tick=" ticks ", d2t=" precision d2t-runnelness 3 " of current value " buffer-runnelness)
        if sound-on? [ sound:play-note "TUBULAR BELLS" 64 64 .5 ]
        set d2t-runnelness-last-inflection ticks
      ]
      if (d2t-stdev-popularity-pct > d2t-stdev-popularity-threshold) and (d2t-stdev-popularity-last-inflection < ticks - inflection-cooldown) [
        output-print (word "Inflection. (Stdev Pop): tick=" ticks ", d2t=" precision d2t-stdev-popularity 3 " of current value " buffer-stdev-popularity)
        if sound-on? [ sound:play-note "TUBULAR BELLS" 55 64 .5 ]
        set d2t-stdev-popularity-last-inflection ticks

      ]
    ]

    set dt-pathness-prev dt-pathness
    set dt-runnelness-prev dt-runnelness
    set dt-stdev-popularity-prev dt-stdev-popularity
  ]

  set pathness-prev buffer-pathness
  set runnelness-prev buffer-runnelness
  set stdev-popularity-prev buffer-stdev-popularity

  ;; Calculate Entropy and Curvilinearity
  let total-patches (grassness + pathness + runnelness)
  let pathness-p pathness / total-patches
  let grassness-p grassness / total-patches
  ;; shannon entropy: -sum(p_i * log(p_i)) (proporitions)  PATH ONLY! todo update for runnelness
  ;; https://stackoverflow.com/a/50313657
  set entropy (- (
    (pathness-p * ln (pathness-p + eps)) +  ;; log^-2
    (grassness-p * ln (grassness-p + eps))
  ))

  ifelse ticks > 200
    [ set curvilinearity check-curvilinearity ]
    [ set curvilinearity 0 ]
end


;;;;;;;;;; Homework stuff ;;;;;;;;;;


to step-0-q0
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Base Question"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  set houses-to-setup 0
  set house-spacing 0
  set weirdness 0
  set runnelator 0
  set runnels? false
  set show-popularity? false
end

to question1-hi
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 1, High Param"
  set popularity-decay-rate 96
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    set show-popularity? false
    setup-with-houses
    set simulation-name "Question 1, High Param"
  ]

end

to question2-hi
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 2, High Param"
  set popularity-decay-rate 4
  set popularity-per-step 96
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    set show-popularity? false
    setup-with-houses
    set simulation-name "Question 2, High Param"
  ]
end

to question3-hi
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 3, High Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 96
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    set show-popularity? false
    setup-with-houses
    set simulation-name "Question 3, High Param"
  ]
end

to question4-hi
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 4, High Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 500
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 4, High Param"
  ]
end

to question5-hi
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 5, High Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 96

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 5, High Param"
  ]
end

to question1-lo
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 1, Low Param"
  set popularity-decay-rate 0
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 1, Low Param"
  ]
end

  to question2-lo
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 2, Low Param"
  set popularity-decay-rate 4
  set popularity-per-step 4
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 2, Low Param"
  ]
end

to question3-lo
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 3, Low Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 4
  set walker-count 250
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 3, Low Param"
  ]
end

to question4-lo
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 4, Low Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 25
  set walker-vision-dist 10

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 4, Low Param"
  ]
end

to question5-lo
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Question 5, Low Param"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 2

  ifelse step-3? = false [
    set houses-to-setup 0
    set house-spacing 0
    set weirdness 0
    set runnelator 0
    set runnels? false
    set show-popularity? false
  ] [
    set houses-to-setup 7
    set house-spacing 30
    set weirdness 0
    set runnelator 15
    set runnels? true
    setup-with-houses
    set simulation-name "Question 5, Low Param"
  ]
end

to step-2-q0
  set step-2? true
  output-print "=== INITIALIZING SIMULATION ==="
  setup
  set simulation-name "Step 2, Question 0"
  set popularity-decay-rate 4
  set popularity-per-step 20
  set minimum-route-popularity 80
  set walker-count 250
  set walker-vision-dist 10

  set houses-to-setup 2
  set house-spacing 30
  set weirdness 50
  set runnelator 0
  set runnels? false
  set show-popularity? false
  setup-with-houses
end

to print-run-start [ max-ticks ]
  output-print "=== SIMULATION PARAMETERS ==="
  ifelse step-2? = true [
     output-print ("Simulation name: ")
  ] [
    ifelse step-3? = true [
      output-print (word "Simulation name: Step 3, " simulation-name)
    ] [
      output-print (word "Simulation name: Step 1, " simulation-name)
    ]
  ]
  output-print (word "Run for ticks: " max-ticks)
  output-print (word "Houses to setup: " houses-to-setup)
  output-print (word "House spacing: " house-spacing)
  output-print (word "Weirdness: " weirdness)
  output-print (word "Runnels enabled: " runnels?)
  output-print (word "Runnelator: " runnelator)
  output-print (word "Popularity decay rate: " popularity-decay-rate "%")
  output-print (word "Popularity per step: " popularity-per-step)
  output-print (word "Minimum route popularity: " minimum-route-popularity)
  output-print (word "Walker count: " walker-count)
  output-print (word "Walker vision distance: " walker-vision-dist)
  output-print (word "Runnel durability: " runnel-durability)
  output-print "======================="
end

to print-run-stats
  output-print "=== SIMULATION STATISTICS ==="
  output-print (word "Ticks completed: " ticks)
  output-print (word "Final Average popularity: " precision avg-popularity 3)
  output-print (word "Final Pathness: " pathness)
  output-print (word "Final Runnelness: " runnelness)
  output-print (word "Final Grassness: " grassness)
  output-print (word "Final Entropy: " precision entropy 3)
  output-print (word "Final Curvilinearity (works only with houses): " precision curvilinearity 3)
  output-print "======================="
end


to run-with-report
  let max-ticks 1250

  print-run-start max-ticks
  reset-ticks
  repeat max-ticks [
    go
    if ticks > max-ticks [ stop ]
  ]

  print-run-stats


end


; Copyright 2015 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
275
15
887
628
-1
-1
4.0
1
10
1
1
1
0
1
1
1
-75
75
-75
75
1
1
1
ticks
25.0

BUTTON
30
355
105
388
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
30
300
240
345
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

SLIDER
30
475
240
508
minimum-route-popularity
minimum-route-popularity
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
30
515
240
548
walker-count
walker-count
0
1000
333.0
1
1
NIL
HORIZONTAL

SLIDER
30
555
240
588
walker-vision-dist
walker-vision-dist
0
30
6.0
1
1
NIL
HORIZONTAL

SLIDER
30
395
240
428
popularity-decay-rate
popularity-decay-rate
0
100
4.0
1
1
%
HORIZONTAL

SLIDER
30
435
240
468
popularity-per-step
popularity-per-step
0
100
20.0
1
1
NIL
HORIZONTAL

SWITCH
30
595
240
628
show-popularity?
show-popularity?
1
1
-1000

SLIDER
35
15
240
48
houses-to-setup
houses-to-setup
1
12
7.0
1
1
NIL
HORIZONTAL

BUTTON
75
215
200
248
NIL
setup-with-houses
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
35
95
240
128
weirdness
weirdness
0
100
32.0
1
1
NIL
HORIZONTAL

SLIDER
35
55
240
88
house-spacing
house-spacing
1
100
33.0
1
1
NIL
HORIZONTAL

PLOT
905
175
1305
330
popularity
ticks
avg / stdev
0.0
10.0
0.0
2.0
true
true
"" ""
PENS
"stdev popularity" 1.0 0 -5987164 true "" "plot stdev-popularity"
"avg popularity" 1.0 0 -13210332 true "" "plot avg-popularity"

PLOT
905
15
1305
165
pathness and runnelness
NIL
pathness
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"pathness" 1.0 0 -9276814 true "" "plot pathness"
"runnelness" 1.0 0 -13791810 true "" "plot runnelness"

PLOT
905
340
1305
490
entropy
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot entropy"

PLOT
905
500
1305
630
path curvilinearity (jitter due to sampling)
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"curvilinearity" 1.0 0 -2674135 true "" "plot curvilinearity"

SLIDER
35
135
240
168
runnelator
runnelator
0
100
15.0
1
1
NIL
HORIZONTAL

SWITCH
35
175
240
208
runnels?
runnels?
0
1
-1000

BUTTON
415
670
527
703
NIL
question1-hi
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
535
670
647
703
NIL
question2-hi
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
655
670
767
703
NIL
question3-hi
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
775
670
887
703
NIL
question4-hi
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
895
670
1007
703
NIL
question5-hi
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
45
250
240
316
 ^^^^^^^^^^^^^^^^^^^^^^^^^\n                    NEW STUFF\n  runnelator makes more runnels
11
15.0
1

BUTTON
415
710
527
743
NIL
question1-lo
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
535
710
647
743
NIL
question2-lo
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
655
710
767
743
NIL
question3-lo
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
775
710
887
743
NIL
question4-lo
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
895
710
1007
743
NIL
question5-lo
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
1130
670
1305
740
NIL
run-with-report
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

BUTTON
310
690
402
723
NIL
step-0-q0
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
1020
690
1112
723
NIL
step-2-q0
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
205
690
300
723
step-3?
step-3?
0
1
-1000

TEXTBOX
30
650
180
761
To use the assignment buttons: set up a simulation for any step / question using the buttons. Toggle step-3 for Step 3 verisions of Step 1 questions. Press run-with-report, and view the Command Center.
11
0.0
1

SWITCH
120
355
240
388
sound-on?
sound-on?
1
1
-1000

TEXTBOX
635
750
840
791
^^^^^^^^^^^^^^^^^^^^^^\n Assignment Setup Buttons
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is a model about how paths emerge along commonly traveled routes. People tend to take routes that other travelers before them have taken, making them more popular and causing other travelers to follow those same routes. This can be used to determine an ideal set of routes between a set of points of interest without needing a central planner. Paths emerge from routes that travelers share.

## HOW IT WORKS

Each of the turtles in the model starts somewhere in the world, and is trying to get to another random location. Turtles prefer to move along the gray patches, representing established paths, if those patches are on the way to their destination. But as each turtle moves, it makes the path that it takes more popular. Once a certain route becomes popular enough, it becomes an established route (shown in gray), which attracts yet more turtles en route to their destination.

On setup, each turtle chooses a destination at random. On each tick, a turtle looks to see if there is a gray patch on the way to its destination, and walks toward it if there is. If there no gray patch, it walks directly towards its destination instead. With each step, a turtle makes each patch it walks on more popular. If a turtle causes the patch to pass a certain popularity threshold, it turns gray to indicate the presence of an established route. On the other hand, if no turtle has stepped on a patch in quite a while, its popularity will decrease over time and it will eventually become green again.

You can interact with this model by placing points of interest for the turtles to travel between. While "go" runs, click on a patch in the model to turn that into a point of interest. Once you have placed two or more such points, turtles will travel only between those locations. To remove a location, click it a second time.

## HOW TO USE IT

- `popularity-decay-rate` controls the rate at which grass loses popularity in the absence of a turtle visiting it.
- `popularity-per-step` controls the amount of popularity a turtle contributes to a patch of grass by visiting it.
- `minimum-route-popularity` controls how popular a given patch must become to turn into an established route.
- `walker-count` controls the number of turtles in the world.
- `walker-vision-dist` controls how far from itself each turtle will look to find a patch with an established route to move it closer to its goal.
- `show-popularity?` allows you to color more popular patches in a lighter shade of green, reflecting the fact that lots of people have walked on them, and showing the paths as they form.

## THINGS TO TRY

Try increasing and decreasing `walker-vision-dist`? When you set it to smaller and larger values, how does the evolution of the model change?

`popularity-decay-rate` and `popularity-per-step` balance one another. What happens when the `popularity-decay-rate` is too high relative to `popularity-per-step`? What happens when it is too low?

Can you find a way to measure whether the route network is "finished"? Does that change between runs or does it stay relatively constant? How does changing the `walker-count` affect that?

How does changing the world-wrap effect the shape of the paths that the turtles make?

## EXTENDING THE MODEL

See what happens if you set up specific destinations for the turtles instead of having them move at random. You might have start off by moving to a particular patch, or have each turtle move in a unique loop.

Come up with a way of plotting how much of each journey a turtle spends on an established route. Try plotting that value against the distance a turtle goes out of its way on a given journey to stay on an established route. How do the two quantities relate to one another?

Modify turtles to sometimes remove established routes instead of just creating them. Which route patches are best to remove? Do the resulting shapes generated by the model change?

Turtles select a new patch to move toward each turn. This isn't a particularly efficient way for a turtle to move and sometimes leads to some awkward routes. Can you come up with a more realistic path-finding scheme?

## RELATED MODELS

* [CCL Cities](http://ccl.northwestern.edu/cities/) has some information on city simulation, including other models where "positive feedback" figures prominently.

## CREDITS AND REFERENCES

Inspired by [Let pedestrians define the walkways](https://sive.rs/walkways).

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Grider, R. and Wilensky, U. (2015).  NetLogo Paths model.  http://ccl.northwestern.edu/netlogo/models/Paths.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2015 Cite: Grider, R. -->
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
1
@#$#@#$#@
