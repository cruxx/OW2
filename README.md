OW2 Project
===

A step by step guide for building an OpenWRT firmware, installing and configuring it for TP-LINK MR3020 or MR3040 devices
---

Our objective is to obtain fully configured small device based on TP-LINK MR3020 or MR3040 router hardware with OpenWRT as firmware. It can be used for:
* Compact router with 3G/4G modem support
* Video surveillance (by USB web cam) device with ethernet, wifi or 3G/4G connectivity
* Remote, internet control of lighting, heating, automating etc. (need hardware hacks and additional components)
* Remote measure of temperature, air humidity, pressure and/or some other sensor reading (again need hw works)
* A lot of other things that can be powered by 400 MHz MCU and linux inside

### Below are steps to build and configure OpenWRT:

0)  If you start from scratch, first you need to install all required packets on your host. Check http://wiki.openwrt.org/doc/howto/buildroot.exigence for prerequisites for your exact system. Below is Ubuntu-1404LTS-64bit example:

`sudo apt-get install git-core build-essential subversion libncurses5-dev zlib1g-dev gawk intltool gcc-multilib flex`

1)  Download the latest OpenWRT repo snapshot and all feeds by following commands:

`git clone git://git.openwrt.org/openwrt.git`  
`cd openwrt`  
`./scripts/feeds update -a`  
`./scripts/feeds install -a` 

2)  Perform `make menuconfig` and go to "Target Profile" in the main menu. Select "TP-LINK TL-MR3020" or "-3040", according to your hardware. Exit by pressing ESC ESC two time and confirm saving the config.

3)  Perform `make defconfig` (that creates general configuration of the build system including a check of dependencies and prerequisites for your selected system

4)  Now you can already build your system with default settings/environment (it can take from 1 to 3 hours depend on your host performance, internet connection speed and other factors...

`time make`

5)  `make menuconfig` and select:
- Base System -> block-mount (\*)
- Boot Loaders -> uboot ( )   *<--  remove selection*
- Kernel Modules -> Filesystems -> kmod-fs-ext4 (\*)
- Kernel Modules -> USB Support -> kmod-usb-storage-extras (\*), kmod-usb-uhci (\*)

Also you can select a lot of additional items depend of what you need for your exact system. Below are some examples:
- Kernel Modules -> USB Support -> kmod-usb-serial ->  (M)
- Kernel Modules -> I2C support -> (M)   *<--  if you need i2c support - put (M) on required items*
- Kernel Modules -> W1 support ->  (M)   *<--  if you need 1-wire support - put (M) on required items*
- Multimedia -> mjpg-streamer (M)
- Multimedia -> motion (M)
- Network -> File Transfer -> curl (M)
- Network -> File Transfer -> wget (M)
- Network -> IP Addresses and Names -> ddns-scripts (M)
- Network -> Web Servers/Proxies  -> lighttpd (M) -> lighttpd-mod-\* (M)  *<--  put (M) on all lighttpd modules that you need*
- Network -> wpad (\*) *if you need full IEEE 802.1x Authenticator/Supplicant for enterprise Wi-Fi networks, otherwise select*   wpad-mini (\*)
- Utilities -> filemanager -> mc (M)  *(? - no in latest OpenWRT, need to check ?)*
- Utilities -> comgt (M)  *<--  for 3G modems*
- Utilities -> digitemp (M)  *(? - no in latest OpenWRT, need to check ?)*
- Utilities -> haserl (M)
- Utilities -> oww (M) *(? - no in latest OpenWRT, need to check ?)*
- Utilities -> usb-modeswitch (M) *<--  for 3G modems*

`time make V=s > build.log 2>errors.log`  *it will create also build log and errors log in corresponding files*

6)  (optional) Create file ` ~openwrt/files/etc/config/fstab` and ...(will be updated soon)... in order to have overlay filesystem (pivot overlay) on USB flash drive

7)  `time make V=s > build.log 2>errors.log`  *it will create also build log and errors log in corresponding files* 
If build process aborts with error (of course not related with unavailable downloads) - sometimes it helps full rebuild: `make dirclean` and then `make` again

8)  After the build process completed successfully - you can install OpenWrt "\*-squashfs-factory.bin" firmware from `~/youpathtoprojects/OW2/openwrt/bin/ar71xx/` using manufacturer's WebGUI like a regular firmware update. Wait for the progress bar to finish twice (the device will reset itself in the process).  
If your device is already on OpenWrt - just copy the firmware .bin file to `/tmp` and perform `mtd -r write /tmp/your_firmware_file.bin firmware`

9)  Connect ethernet directly to you device and perform `telnet 192.168.1.1`. After that use `passwd` command to set a password to be able to connect through `ssh` and to copy files by using `scp`

10) Copy all files from `files/` directory to corresponding places on your device. Check all shell scripts have execution permission, perform `chmod +x scriptname` if not. If your device is MR3040 v1 (without slider) - need to correct script in `/etc/init.d/` with only one option and also no need to copy to `/etc/hotplug.d/button`

11) Copy all packages from `~/youpathtoprojects/OW2/openwrt/bin/ar71xx/packages` to ext4-formatted USB flash, insert it to your device, mount it and install all package you need by `opkg update; opkg install thepackageswhatyouneed` (remember to check free space on device's flash or use overlay filesystem on USB flash as in step #6). The file `/etc/opkg.conf` should be corrected properly to point to your USB flash.

12) to be continued...
