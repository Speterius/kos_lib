// Launch to altitude and heading.
print "Running < launch2.ks > ".

parameter targetAltitude is 90_000.
parameter targetHeading is 90.
parameter turnEndAltitude is 55_000.
parameter turnExponent is 1.3.

doCountdown().
launch().

local function doCountdown {
    from {local COUNTDOWN is 3.} until COUNTDOWN = 0 step {set COUNTDOWN to COUNTDOWN - 1.} do {
        HUDTEXT(COUNTDOWN, 0.6, 2, 36, RED, true).
        wait 1.0.
    }
    HUDTEXT("Liftoff!", 1, 2, 20, GREEN, true).
}

function doSafeStage{
    print "Staging.".
    wait until stage:ready.
    stage.
}

function ascentProfile {
    return 90 * (1 - (altitude / turnEndAltitude) ^ turnExponent).
}

local function launch {

    lock throttle to 1.
    lock steering to up.
    sas off.

    lock shouldStage to (ship:maxthrust = 0 and stage:number <> 0).
    set raisingApoapsis to true.
    set done to false.

    when shouldStage then {
        doSafeStage().
        preserve.
    }

    when altitude < turnEndAltitude then {
        lock steering to heading(targetHeading, ascentProfile()).
        preserve.
    }

    // Once we reach the profile's end we lock the steering to horizontal.
    when altitude > turnEndAltitude and raisingApoapsis then {
        print "Ascent profile finished.".
        lock steering to heading(targetHeading, 0.0).
    }

    when apoapsis >= targetAltitude then {
        print "Target apoapsis reached.".
        lock throttle to 0.
        lock steering to velocity:orbit:normalized.
        set raisingApoapsis to false.
    }

    when altitude > 70_000 and not raisingApoapsis then {
        print "Left the Atmosphere. Adding manoeuvre node.".

        run circ_at_apo.

        set done to true.
    }

    wait until done.
}
