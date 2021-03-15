function MunarTransfer{
    parameter targetPeriapsis is 50_000.

    runoncepath("1:/rsvp/main.ksm").
    local options is lexicon("create_maneuver_nodes", "first", 
                            "verbose", true,
                            "search_interval", 0.05 * ship:orbit:period,
                            "search_duration", 1.2 * ship:orbit:period,
                            "final_orbit_periapsis", targetPeriapsis,
                            "final_orbit_orientation", "prograde",
                            "final_orbit_type", "circular").

    rsvp:goto(mun, options).
}

function DunaTransfer{
    parameter targetPeriapsis is 500_000.

    // todo: find time of alignment:
    local earliestDeparture is time + 200.

    runoncepath("1:/rsvp/main.ksm").
    local options is lexicon("create_maneuver_nodes", "first", 
                            "verbose", true,
                            "earliest_departure", earliestDeparture,
                            "search_interval", 0.01 * ship:orbit:period,
                            "search_duration", 1.2 * ship:orbit:period,
                            "final_orbit_periapsis", targetPeriapsis,
                            "final_orbit_orientation", "prograde",
                            "final_orbit_type", "circular").

    rsvp:goto(mun, options).
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