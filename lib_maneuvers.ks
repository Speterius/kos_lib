// Run xman to get access to ExecuteManeuver().
run once lib_xman.

function CircularizeAtPeri {
    // Circularize the orbit at the next periapsis.

    // Calculate circularization delta V.
    local timeOfNode to time + eta:periapsis.
    local targetSpeed to sqrt(ship:body:mu / (periapsis + ship:body:radius)).
    local periapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.
    local deltaV to (targetSpeed - periapsisSpeed).
    
    // Create node and execute
    local nd to node(timeOfNode, 0, 0, deltaV).
    add nd.
    ExecuteManeuver().
}

function CircularizeAtApo {
    // Circularize the orbit at the next apoapsis.
    
    // Calculate circularization delta V.
    local timeOfNode to time + eta:apoapsis.
    local targetSpeed to sqrt(ship:body:mu / (apoapsis + ship:body:radius)).
    local apoapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.
    local deltaV to (targetSpeed - apoapsisSpeed).
    
    // Create node and execute
    local nd to node(timeOfNode, 0, 0, deltaV).
    add nd.
    ExecuteManeuver().
}

function ChangePeriapsisAtApo {
    // Change the perisapsis to the target at the next apoapsis.
    parameter targetPeriapsis.

    // The maneuver is done at the apoapsis.
    local timeOfNode to time + eta:apoapsis.
    local apoapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.

    local pe is targetPeriapsis + ship:body:radius.
    local ap is apoapsis + ship:body:radius.

    local a is (ap + pe) / 2.

    local targetSpeed to sqrt(ship:body:mu * (2 / ap - 1 / a)).
    local deltaV to (targetSpeed - apoapsisSpeed).
    
    // Create node and execute
    local nd to node(timeOfNode, 0, 0, deltaV).
    add nd.
    ExecuteManeuver().
}

function ChangeApoapsisAtPeri {
    // Change the apoapsis to the target at the next apoapsis.
    parameter targetApoapsis.

    // The maneuver is done at the apoapsis.
    local timeOfNode to time + eta:periapsis.
    local periapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.

    local pe is periapsis + ship:body:radius.
    local ap is targetApoapsis + ship:body:radius.

    local a is (ap + pe) / 2.

    local targetSpeed to sqrt(ship:body:mu * (2 / ap - 1 / a)).
    local deltaV to (targetSpeed - periapsisSpeed).
    
    // Create node and execute
    local nd to node(timeOfNode, 0, 0, deltaV).
    add nd.
    ExecuteManeuver().
}

function KillSurfaceVelocity {
    // Kill a percentage of the surface velocity.
    parameter percentage is 0.99.
    parameter secondsDelay is 5.0.

    local nd to node(time + secondsDelay, 0, 0, -percentage * ship:velocity:surface:mag).
    add nd.
    ExecuteManeuver().
}

local function VisVisaEquation {

    parameter mu.   // standard grav parameter
    parameter r.    // distance between ship and body
    parameter a.    // semi-major axis

    return sqrt(mu * (2/r - 1/a)).

}
