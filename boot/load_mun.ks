wait until ship:unpacked.
clearscreen.
switch to 1.

// Copy lib files
copypath("0:/lib_launch.ks", "").
copypath("0:/lib_xman.ks", "").
copypath("0:/lib_maneuvers.ks", "").
copypath("0:/lib_rsvp.ks", "").
copypath("0:/lib_land.ks", "").
copypath("0:/lib_utils.ks", "").

// Copy main script
copypath("0:/launch_to_mun.ks", "").
copypath("0:/land_on_mun.ks", "").
copypath("0:/to_mun.ks", "").

// Copy and compile RSVP files from the archive:
if not exists("1:/rsvp") {
    runoncepath("0:/rsvp/main").
    createdir("1:/rsvp").
    rsvp:compile_to("1:/rsvp").
}

// Show terminal
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// List all the files on 1:
print "Boot successful, copied specified files to 1:/:".
list files.

// Set IPU config to high:apoapsis
set config:ipu to 2000.
