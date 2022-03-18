# schroot_tools
A simple linux development enviornment using `schroot` that can be rapidly re-provisioned for quick iteration. Runs on Debian based distributions (Kali Linux, Ubuntu)

# Intro
A chroot "jail" functions by setting something other than your file-system root (/) directory as your temporary root directory, and then executes a shell in that context. This is useful for isolating file-systems from your host system. Chroot are commonly used for compiling software, which avoids leaving build artifacts on the host system. Chroot are also useful for cross-compiling software, whether your compilation target is a differetn linux distribution, or a different CPU architecture (such as ARM.)

This respository documents how to use the `schroot` package to work with chroot "jails". The primary focus is on using chroot "jails" as a development enviornment that you can rapidly provision and re-provision. Schroot comes from Debian linux, but this repository focuses heavily on Ubuntu usage.

# Getting started quickly
* apt install `schroot` and `debootstrap`
* Define a schroot with `type=directory` in /etc/schroot/chroot.d/<chroot name>.conf
* Create a Linux root filesystem with `debootstrap`  
  * `sudo debootstrap --verbose --variant=<minbase | buildd> <bullseye | focal> /var/chroot/<chroot name>`  
* Enter the schroot with `schroot -c <schroot name>`  

# Schroot configuration
Configuration files are found in the directory `/etc/schroot`.
* `schroot.conf` (file) is read by `schroot` to define chroots. A user may add chroots to this file.
* `chroot.d` (dir) supplements the `schroot.conf` file. Users may add files to this directory, with contents formatted the same as entries in  `schroot.conf`.
* `buildd default desktop minimal sbuild` (dir) are Schroot "profiles". Each contains files that are invoked when a chroot is created.
  * `copyfiles` - Files to be copied into the chroot
  * `fstab` - Mounts for the chroot. `/proc /sys /dev` and others are neccesary for your chroot to run.
  * `nssdatabases` - System configuraton files to copy into the chroot. `/etc/passwd /etc/group` for example.
  * `config` - A shell script that will be run when the chroot is created. (Note, this is documented as the `script-config` value of `schroot.conf`, but it appears to throw an error if invoked that way.  
* `setup.d` (dir) contains the scripts `schroot` uses to start and stop chroots. User configuration does not go here.

The chroot definitions in `schroot.conf` or `chroot.d/` are comprised of key=value pairs, as specified in [man schroot.conf(5)](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html)

Example `schroot.conf` entry:
```ini
[sid]                             
description=Debian sid (unstable) 
directory=/srv/chroot/sid         
users=rleigh                      
groups=sbuild                     
root-groups=root                  
aliases=unstable,default
```

# Schroot file-system types
Schroot can use several [types](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html#Plain_and_directory_chroots) of file-systems on the host. A `directory` file-system type is just a directory on the host that has been prepared with a Linux root filesystem, i.e. (`/bin`, `/dev`, `/etc`, `/usr`, etc.) A `file` file-system type is a whole Linux root filesystem in a `.tar` archive (optionally compressed, such as with gzip.)

The full list of types are: `plain`, `directory`, `file`, `loopback`, `block-device`, `btrfs-snapshot`, , `lvm-snapshot`, `zfs-snapshot`, and `custom`. 

If empty or omitted, the default type is `plain`. Note that `plain` chroots do not run setup scripts or mount filesystems; type `directory` is recommended for ordinary use.

# Source schroots
Typically a chroot is just a Linux root filesystem, and if you make changes while the chroot is active, you are making changes to the files directly. Schroot offers [Source](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html#Plain_and_directory_chroots) schroots which are persistant, and are the basis for `sessions`, which are meant to be temporary.  

This is useful for having a customized chroot that can be used and discarded, then re-run in the original state. Source schroots typically will use mechanisms that save space on your hard-disk, such as file-system snapshots, or overlay file-systems. 

Source schroots are enabled for `type: directory` by setting the `union-type` setting to one of the supported options: `aufs, overlayFS, overlay, unionfs`. 

# Sessions
Schroot [sessions](https://manpages.debian.org/bullseye/schroot/schroot.1.en.html#Session_actions) are an instance created from a `source`. This is useful for making a clean linux install, doing some customization; and then freezing that state. You can then base one or more sessions off of that `source`.

# Profile
Profiles are a collection of files that are used by the schroot creation scripts in `setup.d`. The `default` profile is applied silenty under ordinary circumstances. It specifies which special directorys to mount, and copies files from the host into the chroot. `resolv.conf` and `/etc/passwd` are two files that are copied into the chroot. These files setup networking and copy your users into the chroot.

If you need control over this setup, you can copy one of the provided directories and modify it for your needs. Then specify a `profile=<directory>` paramater in your schroot definition.

# Creating a Debian or Ubuntu Linux Root Filesystem
The [debootstrap](https://manpages.debian.org/bullseye/debootstrap/debootstrap.8.en.html) tool is used to create a Linux root filesystem for your chroot.
Basic syntax  
`sudo debootstrap --verbose --variant=<minbase|buildd|fakechroot> <suite> /var/chroot/<chroot name>`

Ubuntu 20.04 LTS Focal Fossa  
`sudo debootstrap --verbose --variant=minbase focal /var/chroot/focal_chroot`

# Finding filesystem types
Check `/sys/fs` to see which filesystems are supported on your version of linux.

# Security
Chroot should not be considered a security mechanism. A chroot provides an isolated filesystem, except for utility directorys which are typically mounted into the chroot (`/proc /sys /dev`). A shell executed inside the chroot   
 
# Man Pages
[Schroot(1)](https://manpages.debian.org/bullseye/schroot/schroot.1.en.html)  
[Schroot.conf(5)](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html)  
[Schroot-setup(5)](https://manpages.debian.org/bullseye/schroot/schroot-setup.5.en.html)  
[Schroot-script-config(5)](https://manpages.debian.org/bullseye/schroot/schroot-script-config.5.en.html)  
[Schroot-faq(7)](https://manpages.debian.org/bullseye/schroot/schroot-faq.7.en.html)  
[Debootstrap(8)](https://manpages.debian.org/bullseye/debootstrap/debootstrap.8.en.html)

# See Also
[http://logan.tw/posts/2018/02/24/manage-chroot-environments-with-schroot/](http://logan.tw/posts/2018/02/24/manage-chroot-environments-with-schroot/)  
[https://wiki.ubuntu.com/DebootstrapChroot](https://wiki.ubuntu.com/DebootstrapChroot)
