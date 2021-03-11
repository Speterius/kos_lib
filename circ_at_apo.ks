main().

local function main {
    
    // Calculate circularization delta V.
    local timeOfNode to time: eta:apoapsis.
    local targetSpeed to sqrt(ship:body:mu / (apoapsis + ship:body:radius)).
    local apoapsisSpeed to velocityAt(ship, timeOfNode):orbit:mag.
    local deltaV to (targetSpeed - apoapsisSpeed).
    
    // Create node
    local nd to node(timeOfNode, 0, 0, deltaV).

    // Add man node
    add nd.

    // Exectue man node.
    run xman.
}
