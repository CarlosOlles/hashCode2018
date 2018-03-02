// R – numberofrowsofthegrid (1≤R≤10000)
// C – number of columns of the grid (1 ≤ C ≤ 10000)
// F – number of coches in the fleet (1 ≤ F ≤ 1000)
// N – numberofrides (1≤N ≤10000)
// B – per-ride bonus for starting the ride on time (1 ≤ B ≤ 10000)
// T – number of steps in the simulation (1 ≤ T ≤ 109)
//
 
Function.prototype.clone = function() {
    var that = this;
    var temp = function temporary() { return that.apply(this, arguments); };
    for(var key in this) {
        if (this.hasOwnProperty(key)) {
            temp[key] = this[key];
        }
    }
    return temp;
};
 
 
var Utils = {
    distance: function(p1, p2) {
        return Math.abs(p1.x-p2.x) + Math.abs(p1.y-p2.y)
    }
}
 
var fs = require("fs")
 
// var fn = "a_example.in"
// var fn = "b_should_be_easy.in"
// var fn = "c_no_hurry.in"
// var fn = "d_metropolis.in"
var fn = "e_high_bonus.in"
 
var lines = []
fs.readFileSync(fn).toString().split('\n').forEach(function (line) {
    lines.push(line)
})
 
// Globals
var step = 0
var rides = []
var coches = []
var rows
var cols
var nvehicles
var nrides
var bonus
var nsteps
var results = {}
 
for (var i = 0; i < lines.length; i++) {
   
    var splitted = lines[i].split(" ")
   
    // first line
    if (i == 0) {
        rows      = splitted[0]
        cols      = splitted[1]
        nvehicles = splitted[2]
        nrides    = splitted[3]
        bonus     = splitted[4]
        nsteps    = splitted[5]
    }
   
    // parse rides
    else {
        rides.push(new Ride(
            i,
            splitted[0],
            splitted[1],
            splitted[2],
            splitted[3],
            splitted[4],
            splitted[5]
        ))
    }
   
}
 
function Ride(idx, si, sj, fi, fj, es, lf) {
    this.idx = idx
    this.si = si
    this.sj = sj
    this.fi = fi
    this.fj = fj
    this.es = es
    this.posStart = new Point(si,sj)
    this.posFinish = new Point(fi,fj)
    this.distance = Utils.distance(this.posStart, this.posFinish)
    this.available = true
}
 
Ride.prototype.length = function() {
    return Math.abs(this.si-this.fi) + Math.abs(this.sj-this.fj)
}
 
function Coche(idx, i,j) {
    this.idx = idx
    this.i = i
    this.j = j
    this.pos = new Point(i,j)
    this.busy = false
    this.rideStepsLeft = 0
    results[this.idx] = []
   
    this.takeRide = function(ride) {
        this.busy = true
        this.ride = ride
        this.rideStepsLeft = ride.distance + Utils.distance(this.pos, ride.posStart)
        this.ride.available = false
        // console.log("coche", this.idx, "taking ride", ride.idx)
        results[this.idx].push(ride.idx)
    }
}
 
function Point(x,y) {
    this.x = x
    this.y = y
}
 
// Init coches at start
for (var i = 0; i < nvehicles; i++)
    coches.push(new Coche(i,0,0))
 
// ------------------------------------
 
// console.log(rides)
// console.log(coches)
 
// distancia toda lista de coches a cada rides
//
// para cada coche (disponible), encontrar el viaje mas cercano
// Utils.distance(coches[0])
 
Utils.findViajeMasCercanoParaCoche = function(coche) {
    var currentMin = Number.MAX_SAFE_INTEGER
    var currentMinI = -1
    for (var i = 0; i < rides.length; i++) {
        if (!rides[i].available) continue
        var d = Utils.distance(coche.pos, rides[i].posStart)
        if (d < currentMin) {
            currentMin = d
            currentMinI = i
        }
    }
   
    if (currentMinI == -1) return null
   
    return rides[currentMinI]
}
 
function intentarAssignarCocheVacio(coche) {
    var ride = Utils.findViajeMasCercanoParaCoche(coche)
    if (ride == null) return
    coche.takeRide(ride)
}
 
var currentStep = 0
while (nsteps > 0) {
   
    // console.log("STEP --------------------", currentStep)
   
    coches.forEach(function(coche) {
       
        // Verifica se el viaje se ha terminado
        if (coche.busy) {
            // console.log("coche", coche.idx, "busy")
            if (coche.rideStepsLeft == 0) {
                // console.log("coche", coche.idx, "ha dejado de estar busy!")
                coche.busy = false
                coche.ride = null
                intentarAssignarCocheVacio(coche)
            }
        }
 
        else {
            intentarAssignarCocheVacio(coche)
        }
       
        coche.rideStepsLeft--
 
    })
   
    nsteps--
    currentStep++
}
 
function printResults() {
    var keys = Object.keys(results)
    for (var key in keys) {
        var n = results[key].length
        process.stdout.write(""+n)
        // process.stdout.write(n)
        for (var iride = 0; iride < n; iride++) {
            process.stdout.write(" " + (results[key][iride]-1))
        }
        process.stdout.write("\n")
    }
    // results.forEach(function(res) {
    //     console.log(res)
    // })
}
 
printResults()
