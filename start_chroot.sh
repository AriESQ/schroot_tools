#!/bin/bash
shout() { echo "$0: $*" >&2; }
die() { shout "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

session_name="$(date +"%Y_%m_%d_%H%M")-focal_chroot"
session="$(schroot -b -n ${session_name} -d / -c focal_chroot)"

echo "Doing schroot operations"
schroot -r -d / -c "$session" -u root -- mkdir -p /home/ubuntu/
schroot -r -d / -c "$session" -u root -- chown ubuntu:ubuntu /home/ubuntu
schroot -r -d / -c "$session" -u root -- apt update
schroot -r -d / -c "$session" -u root -- apt install -y sudo
#This is a terrible way to get passwordless sudoers, but this script is only run once, so shouldn't multiple
#Overwrite.
schroot -r -d / -c "$session" -u root -- sh -c "echo \"ubuntu ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"

#Test for location of overlay fs
overlay_loc="/run/schroot/mount/${session_name}"
#This works to mount an exteranal dir into the chroot, but then you can't write in that dir, such as for
#compiling, so it's not the colution here.
#sudo mount --bind -o ro /home/ubuntu/work/ffmpeg/ffmpeg ${overlay_loc}/home/ubuntu/ffmpeg

sudo cp ./chroot_files/cuda* ${overlay_loc}/home/ubuntu/
sudo cp ./ffmpeg/compile-ffmpeg.sh ${overlay_loc}/home/ubuntu/

sudo cp ./chroot_files/proxy ${overlay_loc}/etc/apt/apt.conf.d/

schroot -r -d /home/ubuntu -c ${session}


#close the schroot session.
#schroot -e -c "$session"
