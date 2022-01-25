#!/bin/bash
shout() { echo "$0: $*" >&2; }
die() { shout "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

session_name="$(date +"%Y_%m_%d_%H%M")-focal_chroot"
session="$(schroot -b -n ${session_name} -d / -c focal_chroot)"
user=$(whoami)

echo "Doing schroot operations"
schroot -r -d / -c "$session" -u root -- mkdir -p /home/${user}/
schroot -r -d / -c "$session" -u root -- chown ${user}:${user} /home/${user}
schroot -r -d / -c "$session" -u root -- apt update
schroot -r -d / -c "$session" -u root -- apt install -y sudo
#This is a terrible way to get passwordless sudoers, but this script is only run once, so shouldn't multiple
#Overwrite.
schroot -r -d / -c "$session" -u root -- sh -c "echo \"${user} ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/user-${user}"

#Add Test for location of overlay fs 
overlay_loc="/run/schroot/mount/${session_name}"
#sudo cp ./chroot_files/proxy ${overlay_loc}/etc/apt/apt.conf.d/

schroot -r -d /home/${user} -c ${session}

#close the schroot session.
#schroot -e -c "$session"
