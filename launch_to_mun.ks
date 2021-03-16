run once lib_xman.
run once lib_maneuvers.
run once lib_rsvp.
run once lib_launch.
run once lib_land.
run once lib_utils.

main().

local function main {

    // Launch
    LaunchToOrbit(120_000, 90, 33_000, 1.15).

    // Deploy solar panels and antenna
    panels on.
    DeployRTAntenna().

    // Check if the orbit is stable
    if not IsOrbitStable() {
        print "Unstable orbit. Let's fix that ... #todo".
    }

    // Check if orbit is circular
    if not IsOrbitCircular() {
        print "Eccentric orbit after launch. Let's fix that ... ".
        CircularizeAtApo().
    }

    // Get the transfer orbit and make sure it's okay.
    until IsTransferOkay() {
        MunarTransfer().
    }
    ExecuteManeuver().

    if VerifyEncounter() {
        print "Successful transfer to Mun.".
    } else {
        print "We didn't get an encounter.".
    }
}

local function IsTransferOkay {
    if not hasNode {
        return false.
    }
    // Do we slam through the atmosphere?
    local isTransferStable to nextNode:orbit:periapsis > 80_000.
    return isTransferStable.
}

local function VerifyEncounter {
    // Is the next encounter really the Mun?
    local doesEncounterMun to false.

    if orbit:hasnextpatch {
        local nextBody to orbit:nextpatch:body.
        set doesEncounterMun to nextBody = mun.
    }

    return doesEncounterMun.
}