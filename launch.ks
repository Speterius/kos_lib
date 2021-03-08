print "running __launch__.ks__ script".

parameter targetAltitude.
parameter targetHeading.
parameter turnEndAltitude is 55_000.
parameter turnExponent is 1.3.

// Count down from 3:
from {local COUNTDOWN is 3.} until COUNTDOWN = 0 step {set COUNTDOWN to COUNTDOWN - 1.} do {
    HUDTEXT(COUNTDOWN, 0.6, 2, 36, RED, true).
    wait 1.0.
}
HUDTEXT("Liftoff!", 1, 2, 20, GREEN, true).

// Do not let go of control until we are done with our launch
set done to false.
set ascending to true.
set executing_node to false.

// Keep staging logic preserved:
function doSafeStage{
    wait until stage:ready.
    stage.
}

lock should_stage to (ship:maxthrust = 0 and stage:number <> 0).
when should_stage then {
    print "Staging".
    doSafeStage().
    preserve.
}.

// Ascent profile flight phase:
// set turnEndAltitude to 55_000.
// set turnExponent to 1.3.
lock ascentPitch to (90 * (1 - (altitude / turnEndAltitude) ^ turnExponent)).
when altitude <= turnEndAltitude and ascending then {
    lock steering to heading(targetHeading, ascentPitch).
    preserve.
}.

when altitude > turnEndAltitude and not executing_node and ascending then {
    lock steering to heading(targetHeading, 0.0).
    preserve.
}

// Coast flight phase:
// set targetAltitude to 100_000.
when apoapsis >= targetAltitude then {
    print "Target apoapsis reached.".
    set current_heading to ship:prograde.
    lock throttle to 0.
    lock steering to current_heading.
    set ascending to false.
}.

// Node creation:
when altitude >= 75_000 and not ascending then {
    print "Left the Atmosphere.".
    lock steering to ship:velocity:orbit.
    set target_speed to sqrt(ship:body:mu / (targetAltitude + ship:body:radius)).
    print "Target speed is :" + round(target_speed).

    // Node at the apopasis:
    set time_nd to time + eta:apoapsis.
    set speed_at_apoapsis to velocityAt(ship, time_nd):orbit:mag.
    set dv to (target_speed - speed_at_apoapsis).

    set nd to node(time_nd, 0, 0, dv).
    add nd.

    set executing_node to true.
    set v0 to nd:deltav.
}

// Node execution:
when executing_node then {
    set nd to nextNode.
    set np to nd:deltav.
    lock steering to np.

    // Quick estimate of burn time
    set max_acc to ship:maxthrust/ship:mass.
    set burn_duration to nd:deltav:mag / max_acc.
    wait until vang(np, ship:facing:vector) < 5.
    wait until nd:eta <= (burn_duration / 2).

    // Do the burn:
    set throttle_setting to min(nd:deltav:mag/max_acc, 1).
    lock throttle to throttle_setting.

    // Check for burn end:
    if vdot(v0, nd:deltav) < 0 {
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(v0, nd:deltav), 1).
        lock throttle to 0.
        set executing_node to false.
        set done to true.
        remove nd.
        sas on.
        unlock steering.
        unlock throttle.
    }

    preserve.
}


lock throttle to 1.
wait until done.