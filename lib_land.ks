run once lib_maneuvers.

function Land {
    wait until verticalSpeed < 0.

    // Calculate burn distance:
    // local lock g to ship:sensors:grav:mag.
    // local lock timeOfImpact to addons:tr:timetillimpact.
    // local lock deltaV to abs(verticalSpeed) - timeOfImpact * g.
    // local lock maxAcc to maxThrust / mass.
    // local lock burnDuration to deltaV / maxAcc.
    // local lock burnDistance to 0.5 * abs(verticalSpeed) * burnDuration.

    lock steering to srfRetrograde.
    local lock h to DistanceToGround().
    lock pct to StoppingDistance() / h.

    // Landing gear trigger
    when h < 2000 then {
        gear on.
        print "Landing gear on.".
    }

    wait until pct > 1.

    lock throttle to pct.
    print "Burn started.".

    wait until ship:verticalspeed > 0.
    lock throttle to 0.
    lock steering to GroundSlope().
    wait 15.
    print "Landed.".
    
    unlock steering.
    unlock throttle.
}

local function DistanceToGround {
    return altitude - body:geopositionOf(ship:position):terrainHeight - 4.
    // return ship:bounds:bottomaltradar.
}

local function StoppingDistance {
  local grav is constant():g * (body:mass / body:radius^2).
  local maxDeceleration is (ship:availableThrust / ship:mass) - grav.
  return ship:verticalSpeed^2 / (2 * maxDeceleration).
}

local function GroundSlope {

  local east is vectorCrossProduct(north:vector, up:vector).

  local center is ship:position.

  local a is body:geopositionOf(center + 5 * north:vector).
  local b is body:geopositionOf(center - 3 * north:vector + 4 * east).
  local c is body:geopositionOf(center - 3 * north:vector - 4 * east).

  local a_vec is a:altitudePosition(a:terrainHeight).
  local b_vec is b:altitudePosition(b:terrainHeight).
  local c_vec is c:altitudePosition(c:terrainHeight).

  return vectorCrossProduct(c_vec - a_vec, b_vec - a_vec):normalized.
}
