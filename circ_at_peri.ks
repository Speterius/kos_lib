main().

local function main {
    
    // Calculate circularization delta V.
    local timeOfNode to time + eta:periapsis.
    local targetSpeed to sqrt(ship:body:mu / (periapsis + ship:body:radius)).
    local periapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.
    local deltaV to (targetSpeed - periapsisSpeed).
    
    // Create node
    local nd to node(timeOfNode, 0, 0, deltaV).

    // Add man node
    add nd.

    // Exectue man node.
    run xman.
}
