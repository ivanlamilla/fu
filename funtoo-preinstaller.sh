#!/bin/bash

## A script to install Funtoo Linux on a computer.

####---------------------------------------------####
echo We will now start installing Funtoo Linux on this computer!

echo We will start by partitioning the hard disk.
cfdisk

echo Now, we will create the filesystems.
echo Please enter the root partition. Eg. /dev/sda?
read rootdev
mkfs.ext4 $rootdev
echo Please enter the boot partition. Eg. /dev/sda?
read bootdev
mkfs.ext4 $bootdev
echo Please enter the swap partition. Eg. /dev/sda?
read swapdev
mkswap $swapdev
echo Please enter the home partition. Eg. /dev/sda?
read homedev
mkfs.ext4 $homedev

echo 'It is time to mount the filesystems.'
  echo "mount ${rootdev} /mnt/funtoo"
  mkdir /mnt/funtoo
  mount ${rootdev} /mnt/funtoo
  echo "mkdir /mnt/funtoo/{boot,home}"
  mkdir /mnt/funtoo/{boot,home} 2>/dev/null
  if [ ! "${bootdev}" = "" ]; then
    echo "mount ${bootdev} /mnt/funtoo/boot"
    mount ${bootdev} /mnt/funtoo/boot
  fi
  if [ ! "${swapdev}" = "" ]; then
    echo "swapon ${swapdev}"
    swapon ${swapdev}
  fi
  if [ ! "${homedev}" = "" ]; then
    echo "mount ${homedev} /mnt/funtoo/home"
    mount ${homedev} /mnt/funtoo/home
  fi

cd /mnt/funtoo
echo Now, we will download the stage 3 file.
wget -nc https://build.funtoo.org/1.4-release-std/x86-64bit/generic_64/stage3-latest.tar.xz

echo We will extract the downloaded file.
tar xJpfv stage3-latest.tar.xz

echo It is time to chroot into Funtoo linux.
cd
mount -t proc /proc /mnt/funtoo/proc
mount --rbind /sys /mnt/funtoo/sys
mount --rbind /dev /mnt/funtoo/dev
cp /etc/resolv.conf /mnt/funtoo/etc
cd /mnt/funtoo
genfstab -p /mnt/funtoo >> /mnt/funtoo/etc/fstab
wget -nc https://gist.githubusercontent.com/kassane/b7199fb3a8c5cd2ca445a3fe08aa1eaa/raw/25004d45fc8fe1aa651090bf5417fefdb7eaf60a/funtoo-posinstaller.sh -O root/funtoo-pos.sh
chmod +x root/funtoo-pos.sh
echo Please run /root/funtoo-pos.sh
env -i HOME=/root TERM=$TERM chroot . bash -l