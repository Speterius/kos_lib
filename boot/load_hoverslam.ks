wait until ship:unpacked.
clearscreen.
switch to 1.

// Copy files
copypath("0:/hoverslam.ks", "").

// Show terminal
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

// List all the files on 1:
print "Boot successful, copied specified files to 1:/:".
list files.

