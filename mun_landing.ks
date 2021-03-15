// Circularize at periapsis.
print "circ at peri.".
run circ_at_peri.

// Lower periapsis to 10_000
print "lowering peri".
local targetPeriapsis is 10_000.
local timeOfNode is time + eta:apoapsis.
local distAtApoapsis is apoapsis + ship:body:radius.
local targetSemiMajorAxis is (apoapsis + targetPeriapsis + 2 * ship:body:radius) / 2.
local targetSpeed is VisVisaEquation(ship:body:mu, distAtApoapsis, targetSemiMajorAxis).
local apoapsisSpeed is velocityAt(ship, timeOfNode):orbit:mag.
local deltaV is (targetSpeed - apoapsisSpeed).
local nd to node(timeOfNode, 0, 0, deltaV).
add nd.

// Exectue man node.
run xman.

// Circularize at 10_000
print "circ at peri".
run circ_at_peri.

// Kill almost all velocity:
print "killing 80% of orbital vel".
local nd2 to node(time + 30, 0, 0, -0.8 * ship:velocity:orbit:mag.v).
add nd2.
run xman.

// Do Hoverslam:
print "hoverslam start".

lock steering to velocity:surface:normalized * (-1).
lock g to ship:sensors:grav:mag.
lock t_impact to addons:tr:timetillimpact. 
lock dV to abs(verticalspeed) + t_impact * g.
lock maxAcc to maxThrust / mass.
lock burnDuration to dV / maxAcc.
lock burnDistance to abs(0.5 * verticalSpeed * burnDuration).

lock h to correctAltitudeRadar(alt:radar).

// Landing gear trigger
when h < 2000 then {
    gear on.
    print "Landing gear on.".
}

when h - burnDistance < 1.0 then {
    lock throttle to 1.
    print "Burn started.".
}

wait until ship:status = "LANDED".
lock throttle to 0.
print "yee boi.".

function correctAltitudeRadar{
    parameter altRadar.
    
    local boundingBox is ship:bounds.
    local bkv is -ship:FACING:VECTOR.
    local altCorrection is (boundingBox:FURTHESTCORNER(bkv)-SHIP:ROOTPART:POSITION)*bkv.
    local cosA is up:vector*facing:vector.
    return (altRadar - altCorrection) / cosA.
}

function VisVisaEquation {

    parameter mu.   // standard grav parameter
    parameter r.    // distance between ship and body
    parameter a.    // semi-major axis

    return sqrt(mu * (2/r - 1/a)).

}
