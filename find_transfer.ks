main().

local function main {

    // Creates a manoevure node for a transfer orbit from current body to the destination
    parameter destination.              // orbitable body
    parameter samplingTime.             // as a fraction of the orbital period
    parameter targetPeriapsis.          // periapsis of target orbit

    // Calculate when the next launch window is:
    set phaseAngle to transferAngle().
    set earliestDeparture to timeUntilPhaseAngle(phaseAngle).

    // RSVP Settings:
    local options is lexicon("create_maneuver_nodes", "first", 
                            "verbose", true,
                            "earliest_departure", earliestDeparture,
                            "search_duration", 3 * ship:orbit:period,
                            "search_interval", samplingTime * ship:orbit:period,
                            "final_orbit_periapsis", targetPeriapsis,
                            "final_orbit_type", "circular",
                            "final_orbit_orientation", "prograde").

    // Run RSVP:
    runoncepath("1:/rsvp/main.ksm").       
    rsvp:goto(destination, options).
}

local function transferAngle {
    // finds the phase angle between two bodies for a hochman transfer.
    parameter start.
    parameter end.

    set as to start:obt:semimajoraxis.
    set ae to end:obt:semimajoraxis.

    return ((0.5 + as/2/ae)^1.5 - 1)*180.
}

local function phaseAngleAt {
    parameter t.
    parameter targetBody.
    parameter parentBody.

    return vang(positionat(targetBody, t)-parentBody:position, positionat(body,t)-parentBody:position).
}


local function timeUntilPhaseAngle {
    parameter targetPhaseAngle.

    // do some looping to find time where phase angle at t is within tolerance of target phase angle.
    return phaseAngle.
}