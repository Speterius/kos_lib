// Manoeuvre node executor

xman().

local function xMan {

    // Check if we have a node in queue.
    if not hasNode {
        print "No Node to execute!".

    } else {
        print "Executing next node.".

        sas off.
        set mNode to nextNode.
        set v0 to mNode:deltav.

        // Parameters:
        set pointingTimeout to 15.              // seconds
        set pointingAngleTolerance to 2.5.      // degrees
        set warpExitTimeBuffer to 2.            // seconds
        set burnAngleTolerance to 2.            // degrees

        // Lock Steering to burn vector
        doInitialPointing(mNode, pointingTimeout, pointingAngleTolerance).

        // Warp to the burn start:
        set maxAcceleration to getMaxAcceleration().
        set burnDuration to mNode:deltav:mag / maxAcceleration.
        print "Waiting until burn start...".
        set burnStartTimeStamp to time:seconds + mNode:eta - (burnDuration / 2) - warpExitTimeBuffer.

        // Do the warping:
        kuniverse:timewarp:warpto(burnStartTimeStamp).

        // Wait out the buffer:
        wait until mNode:eta <= (burnDuration / 2).

        // Start burn:
        print "Starting burn".
        set throttleSetting to 1.
        lock throttle to throttleSetting.

        // Set throttle setting to max and a near linear cutoff at the end.
        until isManoeuvreComplete(mNode, v0, burnAngleTolerance) {
        
            set maxAcceleration to getMaxAcceleration().

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
        print "Finished burn with dv left: __ " + mNode:deltav:mag + "__ .".

        // Release control.
        unlock steering.
        unlock throttle.
        sas on.
        remove mNode.
    }
}

function lockSteering {
    parameter manoeuvreNode.
    lock steering to manoeuvreNode:burnvector.

    print "Locked steering to burn vector. ".
}

function doInitialPointing {
    parameter manoeuvreNode.
    parameter timeout.
    parameter angleTolerance.

    // Lock the steering towards node vector
    lockSteering(manoeuvreNode).

    // Add a timeout to pointing
    set steeringTimeOut to time:seconds + timeout.

    // Wait.
    wait until vang(v0, ship:facing:vector) < angleTolerance or time:seconds >= steeringTimeOut.
    if time:seconds >= steeringTimeOut {
        print "We have a steering time out.".
    }
}

function getMaxAcceleration {
    return ship:maxthrust / ship:mass.
}

function isManoeuvreComplete {
    parameter manoeuvreNode.
    parameter startVector.
    parameter toleranceAngle.

    set angleCheck to vAng(startvector, manoeuvreNode:burnvector) > toleranceAngle.
    set magnitudeCheck to manoeuvreNode:burnvector:mag < 0.2.

    return angleCheck and magnitudeCheck.
}

function estimateBurnTime {
    parameter manoeuvreNode.

    // Get the current engine info:
    set isp to getCurrentISP().
    set fuelFlow to getCurrentFuelFlow(). 

    // Remaining delta V:
    set dV to manoeuvreNode:burnvector:mag.
    
    // Rocket equation to get final mass:
    set M_end to mass / constant:e ^ (dV / (isp * constant:g0)).

    // Time left:
    set timeToBurn to constant:g0 * (mass - M_end) / fuelFlow.

    return timeToBurn.
}

function getCurrentFuelFlow {
    // Sum the fuel flow from all engines:
    list engines in engine_list.

    set fuel_flow to 0.

    for eng in engine_list {
        if eng:ignition {
            set fuel_flow to fuel_flow + eng:fuelflow.
        }
    }.
    return fuel_flow.
}

function getCurrentISP {
    // Calculate the average ISP for the vehicle:
    // ISP_avg = sum ( thrust_i for i in engines) / sum ( thrust_i / isp_i  for i in engines)
    list engines in engine_list.

    set sumThrust to 0.
    set sumThrust_divISP to 0.

    set nActiveEngines to 0.

    for eng in engine_list {
        if eng:ignition {
            set nActiveEngines to nActiveEngines + 1.
            set sumThrust to sumThrust + eng:AVAILABLETHRUSTAT.
            set sumThrust_divISP to sumThrust_divISP + eng:AVAILABLETHRUSTAT / eng:ISP.
        }
    }.

    // If we don't have active engines:
    if not nActiveEngines > 0{
        return -1.
    } else {

        // Return the average ISP:
        set ISP_avg to sumThrust / sumThrust_divISP.
        return ISP_avg.
    }   
}
