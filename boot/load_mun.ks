wait until ship:unpacked.
clearscreen.
switch to 1.

// Copy files
copypath("0:/to_mun.ks", "").
copypath("0:/xman.ks", "").
copypath("0:/hoverslam.ks", "").
copypath("0:/launch.ks", "").
copypath("0:/circ_at_apo.ks", "").
copypath("0:/circ_at_peri.ks", "").
copypath("0:/lower_peri.ks", "").

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
