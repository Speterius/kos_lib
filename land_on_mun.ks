run once lib_maneuvers.
run once lib_land.
run once lib_utils.

print "fine tuning periapsis.".
FineTunePeriapsis().

wait 3.

// Warp until close to the periapsis and halt CPU
set t to time:seconds + eta:periapsis - 30.
warpTo(t).
wait until time:seconds > t + 3.

// Point retrogade
lock steering to srfRetrograde.

// Periapsis velocity at the start of the burn
set v0 to velocityAt(ship, time + eta:periapsis):surface:mag.
wait until time:seconds > time:seconds + eta:periapsis - 3.

print "starting retrogade burn".
lock throttle to 1.
wait until ship:velocity:surface:mag < 0.05 * v0.
lock throttle to 0.

print "Starting land sequence.".
Land().

print "yee boiii.".


local function FineTunePeriapsis {

    parameter periapsisTarget is 10_000.
    parameter periapsisMargin is 500.

    if periapsis > periapsisTarget + periapsisMargin {
        pointToRadialIn().
        lock throttle to 0.1.
        wait until periapsis <= periapsisTarget + periapsisMargin.
        lock throttle to 0.
    }

    if periapsis < periapsisTarget - periapsisMargin {
        pointToRadialOut().
        lock throttle to 0.1.
        wait until periapsis >= periapsisTarget - periapsisMargin.
        lock throttle to 0.
    }
}