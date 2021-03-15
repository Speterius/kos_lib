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

function ExecuteManeuver {

    // Check if we have a node in queue.
    if not hasNode {
        print "No Node to execute!".

    } else {
        print "Executing next node.".

        sas off.
        local mNode to nextNode.
        local v0 to mNode:deltav.

        // Parameters:
        local pointingTimeout to 15.              // seconds
        local pointingAngleTolerance to 2.5.      // degrees
        local warpExitTimeBuffer to 2.            // seconds
        local burnAngleTolerance to 2.            // degrees

        // Lock Steering to burn vector
        doInitialPointing(mNode, pointingTimeout, pointingAngleTolerance, v0).

        // Warp to the burn start:
        local maxAcceleration to getMaxAcceleration().
        local burnDuration to mNode:deltav:mag / maxAcceleration.
        print "Waiting until burn start...".
        local burnStartTimeStamp to time:seconds + mNode:eta - (burnDuration / 2) - warpExitTimeBuffer.

        // Do the warping:
        kuniverse:timewarp:warpto(burnStartTimeStamp).

        // Wait out the buffer:
        wait until mNode:eta <= (burnDuration / 2).

        // Start burn:
        print "Starting burn".
        local throttleSetting to 1.
        lock throttle to throttleSetting.

        // Set throttle setting to max and a near linear cutoff at the end.
        until IsManeuverComplete(mNode, v0, burnAngleTolerance) {
        
            set maxAcceleration to getMaxAcceleration().

            // Stage when we run out:
            if maxAcceleration <= 0.0 {
                wait until stage:ready.
                stage.
            } else {
                set throttleSetting to min(mNode:deltav:mag/maxAcceleration, 1).
            }

            if mNode:deltav:mag < 0.01 {
                    break.
                }

            if mNode:deltav:mag < 0.1 {
                print "finalizing burn...".
                wait until vdot(v0, mNode:deltav) < 0.5.
                break.
            }
        }

        // Finish burn
        lock throttle to 0.
        print "Finished burn with dv left: " + round(mNode:deltav:mag, 4).

        // Release control.
        unlock steering.
        unlock throttle.
        sas on.
        remove mNode.
    }
}

local function IsManeuverComplete {
    parameter maneuverNode.
    parameter startVector.
    parameter toleranceAngle.

    set angleCheck to vAng(startvector, maneuverNode:burnvector) > toleranceAngle.
    set magnitudeCheck to maneuverNode:burnvector:mag < 0.2.

    return angleCheck and magnitudeCheck.
}

local function getMaxAcceleration {
    return ship:maxthrust / ship:mass.
}

local function lockSteeringToMan {
    parameter maneuverNode.
    lock steering to maneuverNode:burnvector.
    print "Locked steering to maneuver burn vector. ".
}

local function doInitialPointing {
    parameter maneuverNode.
    parameter timeout.
    parameter angleTolerance.
    parameter initialVector.

    // Lock the steering towards node vector
    lockSteeringToMan(maneuverNode).

    // Add a timeout to pointing
    local steeringTimeOut to time:seconds + timeout.

    // Wait.
    wait until vang(initialVector, ship:facing:vector) < angleTolerance or time:seconds >= steeringTimeOut.
    if time:seconds >= steeringTimeOut {
        print "We have a steering time out.".
    }
}
