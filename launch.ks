launch().

local function launch {

    lock throttle to 1.
    lock steering to up.
    sas off.

    lock shouldStage to (ship:maxthrust = 0 and stage:number <> 0).
    set raisingApoapsis to true.
    set done to false.

    when shouldStage then {
        doSafeStage().
        preserve.
    }

    when altitude < turnEndAltitude then {
        lock steering to heading(targetHeading, ascentProfile()).
        preserve.
    }

    // Once we reach the profile's end we lock the steering to horizontal.
    when altitude > turnEndAltitude and raisingApoapsis then {
        print "Ascent profile finished.".
        lock steering to heading(targetHeading, 0.0).
    }

    when apoapsis >= targetAltitude then {
        print "Target apoapsis reached.".
        lock throttle to 0.
        lock steering to velocity:orbit:normalized.
        set raisingApoapsis to false.
    }

    when altitude > 70_000 and not raisingApoapsis then {
        
        print "Left the Atmosphere. Deploy fairings.".
        set p to ship:partsnamed("fairingSize2")[0].
        local decoupler is p:getmodule("moduleproceduralfairing"). 
        if decoupler:hasevent("deploy") {
                decoupler:doevent("deploy").
            }

        print "Left the Atmosphere. Adding manoeuvre node.".

        run circ_at_apo.

        set done to true.
    }

    wait until done.
}
