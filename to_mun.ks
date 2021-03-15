// "Import" libraries:
run lib_maneuvers.

main().

local function main {

    // 1) Launch
    run launch(120_000, 90, 33_000, 1.15).

    // 2) Deploy Solar panels and antennas
    print "Activating solar panels and antennas".

    panels on.
    set p to ship:partsnamed("mediumDishAntenna")[0].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("activate").
    m:setfield("target", kerbin).

    // 3) Check if our orbit is good.
    set isOrbitStable to periapsis > 75_000 and apoapsis > 75_000.
    set isOrbitCircular to ship:orbit:eccentricity < 0.1.

    print " Stable orbit: " + isOrbitStable.
    print " Circular orbit " + isOrbitCircular.

    // Raise perisapsis if we are not stable:
    if not isOrbitStable {
        print "Unstable orbit. Let's fix that ... #todo".
    }

    // Circularize at apoapsis if we are too eccentric.
    if not isOrbitCircular {
        print "Eccentric orbit after launch. Let's fix that ... #todo".
        run circ_at_apo.
    }

    // Get the transfer orbit
    set munTargetPeri to 500_000.
    findMunarTransfer(0.005, 500_000).
    run xman.

    // confirm burn accuracy:
    set orbitTolerance to 5_000.
    print "Mun encounter periapsis: " + orbit:nextpatch:periapsis.
    print "Is within tolerance: " + abs(orbit:nextpatch:periapsis - munTargetPeri) < orbitTolerance.

    // todo: fine tune closest approach to a close encounter.

    // warp to SOI change.
    warpTo(time:seconds + orbit:nextpatcheta + 10).

    // Circularize at the periapsis.
    run circ_at_peri.
}

function pointToRadialOut {
    lock steering to vxcl(prograde:vector, up:vector).
}

local function findMunarTransfer {
    parameter samplingTime.         // Scalar: percentage of orbital period.
    parameter targetPeriapsis.       // Scalar.

    runoncepath("1:/rsvp/main.ksm").
    local options is lexicon("create_maneuver_nodes", "first", 
                            "verbose", true,
                            "search_interval", samplingTime * ship:orbit:period,
                            "search_duration", 3 * ship:orbit:period,
                            "final_orbit_periapsis", targetPeriapsis,
                            "final_orbit_orientation", "prograde",
                            "final_orbit_type", "circular").

    rsvp:goto(mun, options).
}