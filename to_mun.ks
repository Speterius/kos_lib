// Separate the two phases for testing.s


// Launch
run launch_to_mun.

// Warp through Transfer
local timeSOICHange to time:seconds + orbit:nextpatcheta + 300.
warpTo(timeSOICHange).
wait until time:seconds > timeSOICHange + 5.

// Run landing sequence.
run land_on_mun.
