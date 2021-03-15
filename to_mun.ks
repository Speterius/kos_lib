run once lib_xman.
run once lib_maneuvers.
run once lib_rsvp.
run once lib_launch.
run once lib_land.

main().

local function main {

    // Launch
    LaunchToOrbit(120_000, 90, 33_000, 1.15).

    // Deploy solar panels and antenna
    panels on.
    DeployRTAntenna().

    // Check if the orbit is stable
    if not IsOrbitStable() {
        print "Unstable orbit. Let's fix that ... #todo".
    }

    // Check if orbit is circular
    if not IsOrbitCircular() {
        print "Eccentric orbit after launch. Let's fix that ... ".
        CircularizeAtApo().
    }

    // Get the transfer orbit and make sure it's okay.
    until IsTransferOkay() {
        MunarTransfer().
    }
    ExecuteManeuver().

    // Warp to the SOI change.
    warpTo(time:seconds + orbit:nextpatcheta + 10).

    // Circularize
    CircularizeAtPeri().

    // Lower orbit to 8_500.
    ChangePeriapsisAtApo(8_500).
    CircularizeAtPeri().

    // Do the landing
    KillSurfaceVelocity(0.9).

    // Suicide burn
    Land().
}

local function DeployRTAntenna {
    // Deploys the first dish antenna and points it at Kerbin.

    set p to ship:partsnamed("mediumDishAntenna")[0].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("activate").
    m:setfield("target", kerbin).
}

local function IsTransferOkay {
    if not hasNode {
        return false.
    }
    
    local transferOrbit to nextNode:orbit.
    print "checking transfer orbit with peri: " + transferOrbit:periapsis.
    return transferOrbit:periapsis > 80_000.
}

local function IsOrbitStable {
    return periapsis > 75_000 and apoapsis > 75_000.
}

local function IsOrbitCircular {
    return ship:orbit:eccentricity < 0.1.
}
