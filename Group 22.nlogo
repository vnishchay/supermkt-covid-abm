globals [
  fileList max-cutomers shope_close total-customers-with-deaths time whitecustomers orangecustomers initialwhite initialorange totalcountcustomer
  total-exposure
  transmission-rate-local
  infectious-radius-local
  exposure-time-limit-local
  number
  arriving-rate
  countdeaths
]
breed [customers customer]
customers-own[infection time-in-store sick-time infected? ]


to setup
  clear-all
  file-open "shelves.csv"
  set-default-shape customers "person"
  ask patches[ set pcolor white ]
  border
  while [not file-at-end?][
    shelf
  ]
  add-customer
  entrygate
  file-close-all
  reset-ticks
  set countdeaths 0
end



to go
  if ticks >= nb-hours-before-stop * 1000 [ stop ]
  move
  rate_of_customer
  tick
end


to shelf
  let csv file-read-line
  set csv word csv ","
  let mylist []
  while [not empty? csv]
  [
    let $sep position "," csv
    let $item substring csv 0 $sep
    carefully [set $item read-from-string $item][]
    set mylist lput $item mylist
    set csv substring csv ($sep + 1) length csv
  ]
  let x item 0 mylist * 1.75
  let y item 1 mylist * 1.75
    ask patch x ( y - 20 ) [
  let ent item 6 mylist
    (ifelse
    ent = "Entrance" [
      set pcolor green]
    ent = "StandardShelf" [
      set pcolor pink]
    ent = "SlantedShelf" [
      set pcolor blue]
   ent = "Refridgerator" [
      set pcolor yellow]
   ent = "Checkout" [
      set pcolor yellow]
   ent = "CircularStand" [
      set pcolor grey]
    [set pcolor red])
  ]
end




to border
    ask patches[
    if pxcor = 32 and pycor = -25 [set pcolor yellow ]
    if  (pxcor >= -14 and pxcor <= 33 ) and pycor = -26 [set pcolor grey ]
    if  (pxcor >= 14 and pxcor <= 33 ) and pycor = -5 [set pcolor grey ]
    if  (pxcor >= -13 and pxcor <= 13 ) and pycor = -14 [set pcolor grey ]
    if  (pycor >= -26 and pycor <= -14) and pxcor = -14 [set pcolor grey ]
    if  (pycor >= -26 and pycor <= -6) and pxcor = 33 [set pcolor grey ]
    if  (pycor >= -14 and pycor <= -6) and pxcor = 14 [set pcolor grey ]
    if (pxcor >= -11 and pxcor <= -8) and (pycor >= 2 and pycor <= 4 )[set pcolor yellow ]
     if (pxcor >= 26 and pxcor <= 33) and (pycor >= -5 and pycor <= 8 )
    [set pcolor orange]
    if (pxcor >= -14 and pxcor <= 13) and (pycor >= -13 and pycor <= 8 )
    [set pcolor brown ]
    if (pxcor >= 14 and pxcor <= 25) and (pycor >= -4 and pycor <= 8 )
    [set pcolor brown ]
     if (pxcor >= -13  and pxcor <= 32 ) and (pycor >= -25 and pycor <= -15 )
     [set pcolor black ]
    if (pxcor >= 15  and pxcor <= 32 ) and (pycor >= -14 and pycor <= -6 )
     [set pcolor black ]
     if (pxcor >= 28 and pxcor <= 31) and (pycor >= -13 and pycor <= -6 )
    [set pcolor red ]
  ]
end


to entrygate
  ask patches[
    if  (pxcor >= -13 and pxcor <= -11) and pycor = -14 [set pcolor green ]
    if  (pxcor >= 15 and pxcor <= 17 ) and pycor = -5 [set pcolor gray ]
    if  (pxcor >= 23 and pxcor <= 24 ) and pycor = -5 [set pcolor gray ]
  ]
end

to add-customer
   create-customers max-customers
   [
      customer-setting
   ]
  set totalcountcustomer count customers

  set initialwhite count customers with [color = white]
  set initialorange count customers with [color = orange]
  set time closing_time * 100
  set number 0
  rate_of_customer
end


to customer-setting
  let p one-of patches with [pcolor = brown]
  let x [ pxcor ] of p
  let y [ pycor ] of p
  setxy  x  y
  set sick-time 0
  set color white
  set size 1
  set infected? false
  set time-in-store random  500
  set infection random 100
  if infection > 100 - percentage_of_infected
  [
     set color orange
     set infected? true
  ]
end

to-report customercounter[num addnum]
  set num num + addnum
  report num
end




to rate_of_customer
  ifelse (number = 20 and time > 0) [
    set arriving-rate  random max-arrival-rate
    if change-arrival-rate? [
      set arriving-rate modified-arrival-rate
    ]
   create-customers  arriving-rate [
      customer-setting
    ]
    set totalcountcustomer totalcountcustomer + arriving-rate
    set number 0
  ]
  [
    set number number + 1;
  ]
end


to move
  ask customers [
;    move-to one-of patches with [pcolor = green]
    let s count customers
    set time-in-store time-in-store - 1
    ifelse ( ( pcolor = brown or pcolor = green or pcolor = black or  pcolor = grey or pcolor = white or pcolor = yellow or pcolor = red or pcolor = orange) and time-in-store > 0)  [
    if pcolor = brown [
;     let x one-of [pxcor] of patches with [pcolor = green]
;     let y one-of [pycor] of patches with [pcolor = green]
;     facexy x y
;        fd 1
     ;face [one-of  patches with [pcolor = green]]
        set heading towards one-of patches with [pcolor = green]
        fd 5
      ]
      if(pcolor = gray)
      [
        set heading 180
        fd 1
      ]
     if ( pcolor = green )[
        set heading 180
        fd 2
      ]
     if ( pcolor = black  )[
       set heading random 360
       fd 1
      ]
     if( pcolor = grey or pcolor = white or pcolor = yellow )
       [ bk 2 ]
;     if ([pcolor] of patch-ahead 1 != grey and [pcolor] of patch-ahead 1 !=  white and [pcolor] of patch-ahead 1 != yellow)[
;        bk 5
;      ]
    if pcolor = red [
        let x one-of [pxcor] of patches with [pcolor = orange]
        let y one-of [pycor] of patches with [pcolor = orange]
        facexy x y
        fd 1
    ]
    if pcolor = orange [
        if color = white [set whitecustomers whitecustomers + 1]
        if color = orange [set orangecustomers orangecustomers + 1]
        set total-customers-with-deaths total-customers-with-deaths + 1
        die
;       set countdeaths countdeaths + 1
;        print countdeaths
      ]
;    if s < max-customers and time > 0
;         [
;            hatch max-customers - s [
;              set totalcountcustomer totalcountcustomer + max-customers - s
;              let p one-of patches with [pcolor = brown]
;              let x4 [ pxcor ] of p
;              let y4 [ pycor ] of p
;              setxy  x4  y4
;              set color white
;              set size 1
;              set time-in-store random  500
;              set infection random 100
;                if infection > 100 - percentage_of_infected
;                [
;                  set color orange
;                ]
;                ;customer-setting
;            ]
;          ]
    ]
    [
      ifelse ( time-in-store <= 0 and ( pcolor = black or pcolor  = 135 or pcolor = 105 or pcolor = red or pcolor = 45 or pcolor = 5 or pcolor = gray))
      [
         let x one-of [pxcor] of patches with [pcolor = red]
         let y one-of [pycor] of patches with [pcolor = red]
         facexy x y
         fd 1
        if (pcolor = red )
        [let x2 one-of [pxcor] of patches with [pcolor = orange]
         let y2 one-of [pycor] of patches with [pcolor = orange]
        facexy x2 y2
          fd 1
          ]
        if (pcolor = orange) [
;          fd random 10
;          stop
          if color = white [set whitecustomers whitecustomers + 1]
          if color = orange [set orangecustomers orangecustomers + 1]
          set total-customers-with-deaths total-customers-with-deaths + 1
          die
        ]
      ]
      [
        ifelse( time-in-store <= 0 and ( pcolor = brown or pcolor  = green  ))
        [ set time-in-store 10]
       [set heading 90 fd 1]
      ]
    ]
 ]
  infect-others
  shop_closeing_time
  remove-bug
end


to infect-others
  ask customers with [color = white ] [
    if (pcolor = black or pcolor  = 135 or pcolor = 105 or pcolor = red or pcolor = 45 or pcolor = 5 or pcolor = gray) [
      check-mask
      if any? other customers in-radius infectious-radius-local with [color = orange] [
        ;exposure time
        set sick-time sick-time + 0.1   ;; make it in minutes   divide with 60 consider 15 min max exposure time  ;; maths
;        set infection infection + rate-of-increment-if-in-contact
        set total-exposure total-exposure + sick-time
        if  sick-time > exposure-time-limit-local  [
            if random 100 < transmission-rate-local [
            set infected? true
            set color orange
          ]
        ]
      ]
    ]
  ]
end



to check-mask
  ifelse mask? [
    set transmission-rate-local transmission-when-mask
    set infectious-radius-local infectiousradius-when-mask
    set exposure-time-limit-local exposure-time-limit-when-mask
  ][
    set transmission-rate-local transmission-rate
    set infectious-radius-local infectious-radius
    set exposure-time-limit-local exposure-time-limit
  ]
end


to shop_closeing_time
  set time time - 1
  if time < 0[
    ask customers [
    if pcolor != brown and pcolor != green[
         let x one-of [pxcor] of patches with [pcolor = red]
         let y one-of [pycor] of patches with [pcolor = red]
         facexy x y
         fd 1
      ]
    ]
  ]
end



to remove-bug
  ask customers [
  if pcolor = white
  [    die
   set countdeaths countdeaths + 1
      print countdeaths
    ]
  ]
  if (count customers = 0) [
    stop
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
382
15
806
336
-1
-1
8.0
1
10
1
1
1
0
0
0
1
-16
35
-28
10
1
1
1
ticks
30.0

BUTTON
45
12
140
45
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

SLIDER
175
14
347
47
max-customers
max-customers
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
40
60
148
93
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
1

MONITOR
250
159
355
204
No of Customers in Store
count customers with \n[pcolor != brown and pcolor != green]
17
1
11

SLIDER
191
103
363
136
nb-hours-before-stop
nb-hours-before-stop
0
24
14.0
1
1
NIL
HORIZONTAL

SLIDER
840
14
1024
47
percentage_of_infected
percentage_of_infected
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
845
58
1017
91
infectious-radius
infectious-radius
0
5
2.0
0.5
1
NIL
HORIZONTAL

PLOT
652
351
1029
613
Customers in Shop
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Infected Customer" 1.0 0 -955883 true "" "plot count customers with [color = orange]"
"Susceptible Customer" 1.0 0 -5825686 true "" "plot count customers with [color = white]"
"Total customers " 1.0 0 -7500403 true "" "plot count customers"

SLIDER
847
143
1019
176
exposure-time-limit
exposure-time-limit
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
845
99
1017
132
transmission-rate
transmission-rate
0
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
179
60
351
93
closing_time
closing_time
0
24
13.0
1
1
NIL
HORIZONTAL

PLOT
1059
189
1385
427
Customers after they leave the store
NIL
No. of Customers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Susceptible" 1.0 0 -13791810 true "" "plot whitecustomers"
"Total" 1.0 0 -1184463 true "" "plot orangecustomers + whitecustomers"
"Infected" 1.0 0 -2674135 true "" "plot orangecustomers"

SLIDER
1061
100
1246
133
transmission-when-mask
transmission-when-mask
0
5
1.0
1
1
NIL
HORIZONTAL

SWITCH
1050
10
1153
43
mask?
mask?
1
1
-1000

SLIDER
1051
58
1259
91
infectiousradius-when-mask
infectiousradius-when-mask
0
5
0.5
0.5
1
NIL
HORIZONTAL

SLIDER
1047
144
1262
177
exposure-time-limit-when-mask
exposure-time-limit-when-mask
0
10
10.0
1
1
NIL
HORIZONTAL

PLOT
12
151
245
344
Total exposure time
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-exposure / 10"

PLOT
15
362
300
585
Customer Arrivial Rate
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot arriving-rate"

PLOT
316
350
639
614
Infection Rate
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot orangecustomers / ( 1 + orangecustomers + whitecustomers)"

SLIDER
851
246
1023
279
modified-arrival-rate
modified-arrival-rate
0
10
1.0
1
1
NIL
HORIZONTAL

SWITCH
849
202
1018
235
change-arrival-rate?
change-arrival-rate?
1
1
-1000

SLIDER
7
105
179
138
max-arrival-rate
max-arrival-rate
0
10
7.0
1
1
NIL
HORIZONTAL

PLOT
1058
435
1384
630
Infection per customer
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "set-plot-x-range 0 totalcountcustomer"
PENS
"default" 1.0 1 -16777216 true "" "histogram [ infection ] of customers "

@#$#@#$#@
# ABMS Project

## RESEARCH PAPER PROPOSAL: [Modelling COVID-19 transmission in supermarkets using an agent-based model](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0249821)

---

GROUP MEMEBERS

- Dishant Tayade
- Hardik Sharma
- Satyam Kumar Singh
- Nishchay Verma

---

## PURPOSE AND PATTERNS

As the main provider of food and essential goods, supermarkets remained open in many countries throughout the COVID-19 pandemic in 2020, while the majority of other businesses (such as general retail stores) shut down during periods of government-mandated lockdowns . Supermarkets represent one of the main hubs where a large number of people mix indoors throughout the pandemic and COVID-19, may be transmitted. It is therefore vital to find safe ways for customers to shop and minimize virus transmission. Models for customer dynamics and virus transmission are useful towards that goal, as they can be used to estimate the infection risk and assess how different interventions affect the risk.

Thus, we propose an agent-based model for customer dynamics which we use to estimate the total amount of exposure time, which we define as the total amount of time that customers are in close proximity to infected customers. Using a simple virus transmission model, we estimate the number of infections from exposure time. We apply this model to synthetic data and how to model the following interventions:

- Restricting the maximum number of customers in the store (MOBILITY MODEL),
We aim to find the rate of customer entering the store and at max how many customers can be present inside store at-a-time, and its dependency on the spread of virus.
- Reducing the rate at which customers enter the store (TRANSMISSION MODEL),
We focus on
- Implementing face mask policy, and
- One-way aisle store layout.

## ENTITY, STATE VARIABLES AND SCALES

### Agents

We have customers that enter the store , until store remains open.
The customers goes inside the store from entry gate, do their shopping for some time, checkout at billing area and exit from the exit door.
Initially some of the customers may/may not be infected with COVID 19 virus.
The customers randomly shop inside the shopping store going from shop to shop.

### Store graph

We represent a store as a network (called a store graph), in which nodes represent zones and edges connect contiguous zones. We create a store graph from a synthetic store layout following a similar procedure. Zones are approximately 2m by 2m and we specify a number of entrance, till, and exit nodes. We choose a network representation of a store for ease of simulation, as it significantly reduces the complexity of the model.

![abms2.png](abms2.png)

![Untitled](Untitled.png)

The coordinates of the store map are imported from " shelves.csv " file.
We added some border , entry and exit area with different colors so it is easy to simulate the customer movement and virus transmission.

### Patch

The patch coordinates are altered so that the imported coordinates of map can be easily managed within the patch size and it is visually good.

### Environment

**ENTRY AREA [ BROWN ]**
The customers spawn in the entry area. From there they move towards the store.

**ENTRY GATE [ GREEN  ]**
The customers move inside the store from the entry gate.

**SHOPPING GALLERY [ BLACK ]**
The customers roam freely and randomly in every directions and do their shopping. The path is the shopping gallery.

**SHOPS [ PINK , BLUE , GREY , YELLOW ]**
The shops are of different colors. Each color specify zones (like children section, ladies section, grocery, sports area, kitchen items etc. ).

**CHECKOUT AREA [ RED ]**
The checkout area is the billing area. After shopping their items , customers do the billing at checkout area.

**STORE BORDER [ GREY ]**
The border is the boundary of the store, so that customers roam freely inside the store and do not move out of store while shopping.

**EXIT AREA [ ORANGE ]**
Exit area is the place from where people move out of the store after shopping.

### Collectives

There may be two groups of customers, one of them non-infected and other be infected.
Non-infected one are of *white color* and infected one are of *orange color*.

## PROCESS, OVERVIEW AND SCHEDULING

Our agent-based model has four major components: a customer mobility model, a virus transmission model, face mask policy and one-way aisle layout.
The first component is the customer mobility model for how customers arrive at the store and move.
The second component is a model for how the virus transmits in the supermarket.
The third component shows the effect of using masks on the transmission of virus.
The last component shows if customers move only in one direction , then how it will affect the transmission.

### CUSTOMER - MOBILITY MODEL

In our agent-based model, customers arrive the store according to a Poisson process with constant rate "customer/min" . Each customer starts at a random entrance node (chosen uniformly at random from all entrance nodes) and follows a random shopping path.  Each shopping path is a path in the store graph, representing the route that a customer takes in the store. Two consecutive nodes in the shopping path may be identical. This case occurs when a customer picks up one or more items in the zone. A customer traverses the store graph according to its assigned shopping path. At the beginning of each simulation, the store is empty and customers arrive in the store over a period of H hours (corresponding to length of the opening hours of the store). After H hours, no new customers arrive and the simulation stops once the last customer leaves the store.

### **TRANSMISSION MODEL**

 In our model, Customer are either susceptible or infectious when they enter the store. Each customer that arrives to the store is infectious with independent probability "percentage_of_infected" (corresponding to the proportion of infectious customers) and is otherwise susceptible. In our infection mechanism, we assume susceptible customers become infected proportional to the time they spent with infectious customers. We assume that the main mode of transmission is direct transmission via respiratory droplets and neglect airborne transmission and fomite transmission. More formally, we define the *exposure time  ( sick-time )* for each susceptible customer . 

 as the total time that customer was in the same radius as an infectious customer during the shopping trip . If they have positive exposure time. Each exposed customer becomes infected after the shopping trip with probability of  "transmission-rate"  for some transmission rate . In other words, we model the infection probability of an exposed customer as a linear function of the exposure time with infectious customers. In reality, the infection probability function may take some other form (e.g., a logistic function), but for simplicity and due to lack of validated alternative models, we choose a linear function.

## DESIGN CONCEPTS

### BASIC

- The coordinates of map are imported and patch size and min, max patch coordinates are also altered so that the store map is manageable inside the patch area.
- Custom borders are made of grey color to avoid customer from moving out of the store. As initially, we had only coordinates of the shops .
    
    We used "border" function for the same by providing custom coordinates of the patches and then changing the colors of the patches to grey.
    
- Entry gates are made by changing the colors of patches to green. Function "entrygate" is used for the same.

### **CUSTOMER MOBILITY MODEL**

- **Create Customer**

We made the "add-customer" named function, that creates new customers. The customers are randomly created over the entry area. The customers have shape of "person" and have "white" color and size 1.

- **Move Customer**

After creation of the customers , the customers move towards any of the nearest entry gate. The customers stay inside the  store for atmax "time-in-store" time. 

The customer leave the store if either their shopping is done or the stay time exceeds that value , the customers move towards the exit. 

- **Restricting the maximum number of customers in store**

We restrict the maximum number *C*max of customers in a store. We can add this restriction to our model by simulating a queue outside of the store, where customers queue up if we have *C*max or more customers in the store. Customers from the queue only enter the store when the number of customers in the store is below *C*max. In our model, the estimated chance of infection and number of infections also decreases significantly when decreasing the maximum number of customers in the store. We also note that the mean number of infections plateaus as we increase the *C*max beyond 20, as the number of customers typically does not exceed 20 in our simulations

We made a variable "max-customer" for the same.

- **Reducing customer arrival rate**

Another way of reducing the number of customers in the store is to restrict the rate at which customers enter the store. We can incorporate this in our model by varying the arrival rate λ. We see that the chance of infection increases linearly with λ while the number of infections increases quadratically . The linear and quadratic scaling are not unsurprising: The number of customers (both infectious customers and susceptible customers) in the store increases linearly with the arrival rate. Therefore, we expect the exposure time (and hence the chance of infection) for each susceptible customer to increase linearly with the arrival rate λ. 

We made a variable "customer/min" for the same. After every tick new "customer/minutes" new customer will enter the store. 

- **Total store open time**

The store will remain open for "closing-time" hours and until then new customers will continuously spawn over the entry area.

### TRANSMISSION MODEL

- **Infecting others**

If a customer is infected and if a non infected customer comes in contact ( certain radius ) with him then the non infected customer's is now exposed. When a susceptible customer is exposed or positive exposure time he can get infected with a probability of "transmission-rate".  

### FACE MASK MODEL

Masks can be implemented to stop/ decrease the spread of virus as masks will avoid direct contact to virus resulting in decreasing the spread of virus.  

# INPUT DATA

We are using synthetically created store layout and shopping path. The store is a small store with around 80 shelves, 4 tiles and 3 entrances and 1 exit. which we are taking from "shelves.csv" file. Other inputs such as Customer customer/min , transmission rate, percentage of infected customers, radius of infection/exposure etc. are taken using sliders. .

# INITIALIZATION

In the initial state of the model world, we use a synthetically-created store layout. The store is small and has around 80 shelves, 4 tills, 2 entrances and one exit. There are not any customers in supermarket. Customers are eighter susceptible of infectious when they enter the store and the customers initially are infected by  a probability of "percentage-of-infected". Customer customer/min is defined, which is the number of customer entering the store per minute. "percentage-of-infected-customers" is defined, which is the percentage infected initially. Opening time of store is defined and virus  transmission rate is defined. Option to turn on masks and turn off masks can be done.
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
NetLogo 6.2.0
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
