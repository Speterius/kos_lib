run once lib_maneuvers.

function LaunchToOrbit{
    // Launch to orbit: follow ascent profile, coast until apoapses and circularize.

    parameter targetAltitude is 100_000.
    parameter targetHeading is 90.
    parameter turnEndAltitude is 45_000.
    parameter turnExponent is 1.2. 

    DoCountdown().

    // Take control
    lock throttle to 1.
    lock steering to up.
    sas off.

    // Staging check and flow control
    lock shouldStage to (ship:maxthrust = 0 and stage:number <> 0).
    local raisingApoapsis to true.
    local done to false.
    when shouldStage then {
        DoSafeStage().
        preserve.
    }

    // Follow Ascent Profile
    when altitude < turnEndAltitude then {
        lock steering to heading(targetHeading, AscentProfile(turnEndAltitude, turnExponent)).
        preserve.
    }

    // Once we reach the profile's end we lock the steering to horizontal.
    when altitude > turnEndAltitude and raisingApoapsis then {
        print "Ascent profile finished.".
        lock steering to heading(targetHeading, 0.0).
    }

    // Once we hit apoapsis target start coasting.
    when apoapsis >= targetAltitude then {
        print "Target apoapsis reached.".
        lock throttle to 0.
        lock steering to velocity:orbit:normalized.
        set raisingApoapsis to false.
    }

    // Once we are in vacuum and have started coasting.
    when altitude > 70_000 and not raisingApoapsis then {
        print "Left the Atmosphere.".
        // DeployFairing().
        CircularizeAtApo().
        set done to true.
    }

    wait until done.
}

function DoSafeStage{
    print "Staging.".
    wait until stage:ready.
    stage.
}

local function DoCountdown{
    from {local COUNTDOWN is 3.} until COUNTDOWN = 0 step {set COUNTDOWN to COUNTDOWN - 1.} do {
        HUDTEXT(COUNTDOWN, 0.6, 2, 36, RED, true).
        wait 1.0.
    }
    HUDTEXT("Liftoff!", 1, 2, 20, GREEN, true).
}

local function AscentProfile {
    parameter turnEndAltitude.
    parameter turnExponent.

    return 90 * (1 - (altitude / turnEndAltitude) ^ turnExponent).
}

local function DeployFairing {
    print "Deploying fairing.".

    // todo: generalize for all fairings and make sure there is no error when there is no part like this 
    set p to ship:partsnamed("fairingSize2")[0].
    local decoupler is p:getmodule("moduleproceduralfairing"). 

    if decoupler:hasevent("deploy") {
            decoupler:doevent("deploy").
    }
}
