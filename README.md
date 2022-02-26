# schroot_tools
A simple linux development enviornment using `schroot` that can be rapidly re-provisioned for quick iteration.

# Intro
A chroot "jail" functions by setting something other than your file-system root (/) directory as your temporary root directory, and then executes a shell in that context. This is useful for isolating file-systems from your host system. Chroot are commonly used for compiling software, which avoids leaving build artifacts on the host system. Chroot are also useful for cross-compiling software, whether your compilation target is a differetn linux distribution, or a different CPU architecture (such as ARM.)

This respository documents how to use the `schroot` package to work with chroot "jails". The primary focus is on using chroot "jails" as a development enviornment that you can rapidly provision and re-provision. Schroot comes from Debian linux, but this repository focuses heavily on Ubuntu usage.

# Schroot configuration
Configuration files are found in the directory `/etc/schroot`.
* `schroot.conf` (file) is read by `schroot` to define chroots. A user may add chroots to this file.
* `chroot.d` (dir) supplements the `schroot.conf` file. Users may add files to this directory, with contents formatted the same as entries in  `schroot.conf`.
* `buildd default desktop minimal sbuild` (dir) Schroot "profiles". Each contains files that are invoked when a chroot is created.
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
Schroot can use several [types](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html#Plain_and_directory_chroots) of file-systems on the host. A `directory` file-system type is just a directory on the host that has been prepared with a linux file heirarchy, i.e. (`/bin`, `/dev`, `/etc`, `/usr`, etc.) A `file` file-system type is a whole Linux directory layout in a `.tar` archive (optionally compressed, such as with gzip.)

The full list of types are: `plain`, `directory`, `file`, `loopback`, `block-device`, `btrfs-snapshot`, , `lvm-snapshot`, `zfs-snapshot`, and `custom`. 

If empty or omitted, the default type is `plain`. Note that `plain` chroots do not run setup scripts and mount filesystems; type `directory` is recommended for ordinary use.

# Source schroots
[Source](https://manpages.debian.org/bullseye/schroot/schroot.conf.5.en.html#Plain_and_directory_chroots) schroots create a copy of themselves at runtime. When the chroot is exited, the copy is deleted. This is useful for having a customized chroot that can be launched, discarded, and repeatedly re-launched in a clean state.

Depending on the file-system type, these copies typically will use mechanisms that save space on your hard-disk, so you are not generating an entire new linux file heirarchy. 

Schroot that are `type: directory` 

Enabled if you set the `union-type` option, values may be aufs, overlayFS, overlay, unionfs. 
# Sessions



# Profile
Profiles do not have to hae the same name as the chroot. Although it is common. The pattern here is that you could make a chroot via `schroot.conf` or `chroot.d/` and have it invoke a common profile.



# Security

 
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
