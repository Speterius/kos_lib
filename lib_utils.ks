// Short utility functions so I don't have to remember syntax.

function pointToRadialOut {
    lock steering to vxcl(prograde:vector, up:vector).
}

function pointToRadialIn {
    lock steering to (-1) * vxcl(prograde:vector, up:vector).
}

function IsOrbitStable {
    return periapsis > 75_000 and apoapsis > 75_000.
}

function IsOrbitCircular {
    return ship:orbit:eccentricity < 0.1.
}

function DeployRTAntenna {
    // Deploys the first Remote Tech dish antenna and points it at Kerbin.

    set p to ship:partsnamed("mediumDishAntenna")[0].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("activate").
    m:setfield("target", kerbin).
}

