run once lib_maneuvers.

function Land {

    // Lock retrogade steering
    lock steering to velocity:surface:normalized * (-1).

    // Calculate burn distance:
    local lock g to ship:sensors:grav:mag.
    local lock h to AltitudeRadar().
    local lock timeOfImpact to addons:tr:timetillimpact.
    local lock deltaV to abs(verticalSpeed) - timeOfImpact * g.
    local lock maxAcc to maxThrust / mass.
    local lock burnDuration to deltaV / maxAcc.
    local lock burnDistance to abs(0.5 * verticalSpeed * burnDuration).

    // Air brakes trigger
    when h < 5000 then {
        brakes on.
        print "Airbrakes on.".
    }

    // Landing gear trigger
    when h < 2000 then {
        gear on.
        print "Landing gear on.".
    }

    when (h - burnDistance) < 1.0 then {
        lock throttle to 1.
        print "Burn started at with estimated burn distance: " + round(burnDistance, 2).
    }

    wait until ship:status = "LANDED".
    lock throttle to 0.
    print "Landed.".
}

local function AltitudeRadar {
    return alt:radar.
}


