local targetPeriapsis is 50_000.

runoncepath("1:/rsvp/main.ksm").
local options is lexicon("create_maneuver_nodes", "first", 
                        "verbose", true,
                        "search_interval", 0.05 * ship:orbit:period,
                        "search_duration", 1.2 * ship:orbit:period,
                        "final_orbit_periapsis", targetPeriapsis,
                        "final_orbit_orientation", "prograde",
                        "final_orbit_type", "circular").

rsvp:goto(mun, options).
