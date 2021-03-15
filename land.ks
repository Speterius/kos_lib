// Kill almost all velocity:
print "killing 60% of orbital vel".
local nd2 to node(time + 30, 0, 0, -0.6 * ship:velocity:orbit:mag).
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

set boundingBox to ship:bounds.
lock h to boundingBox:bottomaltradar.

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