
set altradar_offset to alt:radar.

main().

function main {
    launch_up_to_apoapsis(8_000).

    hoverslam().

    unlock throttle.
    unlock steering.
    sas on.
}

function launch_up_to_apoapsis{
    parameter targetApoapsis.

    lock throttle to 1.
    lock steering to heading(180, 88).
    stage.
    print "Launching up to: " + targetApoapsis.
    wait until apoapsis >= targetApoapsis.
    lock throttle to 0.
}

function hoverslam {
    // Wait until the ship starts falling
    wait until VERTICALSPEED < 0.
    wait 2.

    // Lock to retrogade steering
    lock steering to velocity:surface:normalized * (-1).

    // Altitude above ground:
    lock g to ship:sensors:grav:mag.
    lock h to altitude - geoPosition:terrainheight.

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

    lock g to ship:sensors:grav:mag.
    lock t_impact to addons:tr:timetillimpact. 
    lock dV to abs(verticalspeed) + t_impact * g.
    lock maxAcc to maxThrust / mass.
    lock burnDuration to dV / maxAcc.
    lock burnDistance to abs(0.5 * verticalSpeed * burnDuration).

    lock h to correctAltitudeRadar(alt:radar).

    when h - burnDistance < 2.0 then {
        lock throttle to 1.
        print "Burn started.".
    }
    
    wait until ship:status = "LANDED".
    lock throttle to 0.
    print "yee boi.".
}

function correctAltitudeRadar{
    parameter altRadar.
    
    local boundingBox is ship:bounds.
    local bkv is -ship:FACING:VECTOR.
    local altCorrection is (boundingBox:FURTHESTCORNER(bkv)-SHIP:ROOTPART:POSITION)*bkv.
    local cosA is up:vector*facing:vector.
    return (altRadar - altCorrection) / cosA.
}