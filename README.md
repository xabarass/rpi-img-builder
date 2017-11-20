rpi-img-builder 
===============

Script to build custom sd card image for Raspberry Pi.

## Building SCION image

Clone scionlab repo
```
./getscion 
```

Create template image
```
su scion    # need this for chroot
sudo make
```

Customize image
```
sudo ./packscion <img_name>.img user_directory
```

At the end, bz2 compressed image is created.

## Features:
* Debian repository (Tested with Jessie and Stretch so far)
* Ubuntu repository (Yakkety/Zesty only since no rpi support before that and currently rpi2 only)
* Raspbian repository (armhf ONLY)
* Custom RPi repository
* Custom repositories
* Architectures
* Login: pi/raspberry (Default)
* Auto size, make as compact as possible or set a size
* Plugins

## Plugins
* Host name: raspberrypi-MACADDRESS (e.g. raspberrypi-1a2b3c4d5e6f)
* SSH host keys are generated and saved permanently on first boot
* Run configdb-common scripts on first boot
* Automatic mounting of USB storage devices using usbmount
* Automatic resize on first boot (It will auto reboot once done)
* Automatically reruns dbconfig install scripts on boot (It will auto reboot once done)
* Many more added all the time, check the plugins directory for more

## Make Options
The build process has a few options you can set.
* **DIST**: Debian distribution [default stretch (yakkety for Ubuntu)]
* **DIST_ARCH**: image architecture [armel, armhf (default), arm64]
* **REPO**: upstream repositories based on repos dir [Bluefalls, Debian, Ubuntu, Raspbian, Foundation, "Raspbian Foundation" (default)]
* **ARCH**: used to determine the kernel name [[Debian - armmp (default), armmp-lpae], [Ubuntu - raspi2 (default)], [Raspbian - rpix (default)]]
* **IMAGE_MB**: size of the image, 128MB is for the fat boot, which is included in this option [-1 = auto (default), n = size in MB]
* **LOCALE**: system locale (en_US.UTF-8 default, Make sure you type this exactly like in /usr/share/i18n/SUPPORTED)
* **UNAME**: user account that gets created (pi default)
* **UPASS**: user account password (raspberry default)
* **RPASS**: root password (raspberry default)
* **INC_REC**: include recommends for apt-get install [1 = Yes, 0 = No (default)]
* **RPI**: sets the base RPi board version, ONLY used with U-Boot [ 2 (default, 3 ]

## Prerequisites:
On a x86 based Debian system, make sure the following packages are installed:
```
sudo apt-get install build-essential wget git lzop u-boot-tools binfmt-support \
                     qemu qemu-user-static multistrap parted dosfstools
```

## Example: Build a Debian U-Boot Testing image based on armmp:
Just use the make utility to build e.g. an Debian-testing-armmp.img.  Be sure to run this with sudo, as root privileges are required to mount the image.
```
sudo make DIST=testing REPO=Debian RPI=2
```

## Example: Build a Ubuntu U-Boot Yakkety image based on raspi2:
Just use the make utility to build e.g. an Ubuntu-xenial-raspi2.img.  Be sure to run this with sudo, as root privileges are required to mount the image.
```
mv plugins/tmpfs plugins/disabled/
mv plugins/fsckboot plugins/disabled/
sudo make REPO=Ubuntu
```

## Example: Build a Raspbian Jessie image:
Just use the make utility to build e.g. an Rasbian-stretch-rpix.img.  Be sure to run this with sudo, as root privileges are required to mount the image.
```
sudo make
```

## Plugins:
It should be fairly easy to customize your image for your own needs.  Building and adding plugins is easy.  Each plugin can contain:
* **packages**: file with one line containing debian packages to install
* **preinst**: script to run pre chroot
* **postinst**: script to run in chroot of the rootfs
* **files**: dir which contains files to be copied into the rootfs, perms and atts included
* **patches**: dir which contains patch files to apply to the rootfs
* **baseonly**: is a special file for repo plugins, if the file exists the plugin is only included if the repo is the base repo

Execute order is files -> preinst -> packages -> postinst -> patches, per plugin. For example if alsa runs before common, the files for common will not be available when alsa files/preinst run.  All files, preinst and patches scripts are run outside of the chroot.  All files and preinst are available when packages, postinst and patches are run.

This should allow you install extra packages (e.g. using apt-get) and modify configurations to your needs.  Of course, you can do all this manually after booting the device, but the goal of this project is to be able to generate re-usable images that can be deployed on any number of RaspberryPi devices (think of it as "firmware" of a consumer device).  The `extrapackages` plugin is an example of a plugin to just add new packages, you can modify it or create a new plugin of your own.

All plugins in the base of the plugins dir will be included, if you do not want a plugin included move it to the disabled directory within the plugins directory.  There are a few special cases, and subdirectory in the plugins directory that match an enable Reporitory (via REPO option or the defaults) or Distribution (vis DIST option or the default) could have a sub set of plugins without a directory that is named like it.

For example, if you set DIST to stretch and REPO to Raspbian, then all plugins in the base of the plugins dir will be include as well as the plugins in the stretch and Raspbian directories.  Also since Raspbian will auto add the Foundation repo, any plugins in the Foundation directory if it exists will be included as well.

## Repositories
So repositories require others, for example Raspbian will auto add Foundation.

You can easily add a custom repo by making a directory in the repos dir with the repo name and making a multistrap.list.in file (see the others in that directory for examples on the files contents) and then listing it in the REPO options.  ie: make an ubuntu repo, I could then use REPO="Raspbian ubuntu", this is just an example I'm not sure why you would do this, but as an example.

More information in repos/README.md

## Notes
There are lots of plugin examples included, you can add and remove to your needs.  There are only there to show how customizable these build scripts are.

## Credits
Some tweaks and info for this project was taken in whole or part from:
* https://github.com/RPi-Distro/pi-gen
* https://github.com/ShorTie8/my_pi_os
