#!/bin/bash
shout() { echo "$0: $*" >&2; }
die() { shout "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

#Check if the directory exists, and prompt if we want to overwrite it.
if [ -d /var/chroot/focal_chroot ]; then
    read -p 'Chroot exists, do you want to overwrite it? (y/n) ' overwriteVar
    if [ "$overwriteVar" = 'n' ]; then
        echo 'Exiting, user did not want to overwrite.'
        exit 0
    elif [ "$overwriteVar" = 'y' ]; then
        echo 'Chroot directory will be overwritten'
    else
        echo "$overwriteVar is not valid input"
        exit 1 
    fi
fi
#If you have not exited, user agreed to continue.

echo "Deleting old chroot"
sudo rm -rf '/var/chroot/focal_chroot'

echo "Building new chroot"
sudo debootstrap --verbose --variant=buildd focal /var/chroot/focal_chroot//

session="$(schroot -b -c focal_chroot)"

echo "Doing schroot operations"
schroot -r -d / -c "$session" -u root -- mkdir /home/ubuntu/
schroot -r -d / -c "$session" -u root -- chown ubuntu:ubuntu /home/ubuntu
schroot -r -d / -c "$session" -u root -- apt install -y sudo
schroot -r -d / -c "$session" -u root -- sh -c "echo \"ubuntu ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"

#close the schroot session.
#schroot -e -c "$session"
