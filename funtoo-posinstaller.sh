#!/bin/bash

## A script to install Funtoo Linux on a computer.

####---------------------------------------------####
export PS1="(chroot) $PS1"
echo Downloading the portage tree...
ego sync
emerge --sync

echo Change Language.
echo 'pt_BR.UTF-8 UTF-8' > /etc/locale.gen
echo 'LANG=pt_BR.UTF-8' > /etc/env.d/02locale
echo 'pt_BR ISO-8859-1' >> /etc/locale.gen
echo 'KEYMAP=br-abnt2' > /etc/conf.d/keymaps
nano -w /etc/conf.d/keymaps
locale-gen
env-update && source /etc/profile

echo Time to configure the system.
#nano -w /etc/fstab
ln -sf /usr/share/zoneinfo/America/Bahia /etc/localtime
hwclock --systohc --localtime
#Make.conf
echo 'CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe"' > /etc/portage/make.conf
echo 'CXXFLAGS="${CFLAGS}"' >> /etc/portage/make.conf
echo 'CHOST="x86_64-pc-linux-gnu"' >> /etc/portage/make.conf
echo 'FEATURES="buildpkg candy -collision-protect compressdebug -getbinpkg network-sandbox parallel-fetch -protect-owned sandbox splitdebug usersandbox userfetch usersync"' >> /etc/portage/make.conf
echo 'AUTOCLEAN="yes"' >> /etc/portage/make.conf
echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf
echo 'L10N="pt-BR"' >> /etc/portage/make.conf
echo 'INPUT_DEVICES="evdev joystick keyboard libinput mouse synaptics vmmouse wacom"' >> /etc/portage/make.conf
echo 'ALSA_CARDS="hda-intel"' >> /etc/portage/make.conf
echo 'LLVM_TARGETS="AMDGPU BPF NVPTX"' >> /etc/portage/make.conf
echo 'EMERGE_DEFAULT_OPTS="--quiet-build=n --exclude plymouth"' >> /etc/portage/make.conf
echo 'CURL_SSL="openssl"' >> /etc/portage/make.conf
echo MAKEOPTS="-j$(nproc)" >> /etc/portage/make.conf
echo 'LINGUAS=pt_BR en_US' >> /etc/portage/make.conf
echo 'INTEL_VIDEO="intel dri3 i965 i915"' >> /etc/portage/make.conf
echo 'NVIDIA_VIDEO="nvidia"' >> /etc/portage/make.conf
echo 'AMDGPU_VIDEO="amdgpu radeon radeonsi"' >> /etc/portage/make.conf
echo 'VIDEO_ACCELERATORS="vaapi vdpau xa xvmc"' >> /etc/portage/make.conf
echo 'GALLIUM="gallium-r300 gallium-r600 gallium-radeonsi gallium-vmware"' >> /etc/portage/make.conf
echo 'VULKAN="vulkan-amdgpu vulkan-intel"' >> /etc/portage/make.conf
echo 'HYPERVISION="qxl virtualbox vmware"' >> /etc/portage/make.conf
echo 'MISC_VIDEO="fbdev osmesa swrast vesa"' >> /etc/portage/make.conf

echo 'VIDEO_CARDS="
  ${VIDEO_CARDS}
  ${INTEL_VIDEO}\
  ${NVIDIA_VIDEO}\
  ${AMDGPU_VIDEO}\
  ${GALLIUM}\
  ${VULKAN}\
  ${HYPERVISION}\
  ${MISC_VIDEO}
  ${VIDEO_ACCELERATORS}
"' >> /etc/portage/make.conf

echo 'CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"' >> /etc/portage/make.conf
echo 'CORE="cryptsetup udev dbus X sqlite icu device-mapper consolekit introspection lvm python plymouth qt5 symlink threads xcb xkb"' >> /etc/portage/make.conf
echo 'COMPRESSOR="lzma lzo zstd"' >> /etc/portage/make.conf
echo 'GRAPHICS="cairo corefonts egl glamor gtk nvenc vaapi vdpau xa xinerama xvmc"' >> /etc/portage/make.conf
echo 'DEVELOPMENT=" source"' >> /etc/portage/make.conf
echo 'FILESYSTEM="ext4"' >> /etc/portage/make.conf
echo 'IMAGE="openimageio raw"' >> /etc/portage/make.conf
echo 'AUDIO="pulseaudio sdl"' >> /etc/portage/make.conf
echo 'NETWORK="wifi networkmanager"' >> /etc/portage/make.conf
echo 'DEVICES="gphoto2 lm_sensors usb"' >> /etc/portage/make.conf
echo 'SECURITY="gnome-keyring nss seccomp"' >> /etc/portage/make.conf
echo 'DESKTOPS="kde xfce gnome"' >> /etc/portage/make.conf
echo 'REMOVED="-elogind -systemd -wayland -handbook -qt3support -qt4 -webkit -cuda"' >> /etc/portage/make.conf

echo 'USE="
 ${CORE}\
 ${COMPRESSOR}\
 ${GRAPHICS}\
 ${DEVELOPMENT}\
 ${FILESYSTEM}\
 ${IMAGE}\
 ${AUDIO}\
 ${NETWORK}\
 ${DEVICES}\
 ${SECURITY}\
 ${DESKTOPS}\
 ${REMOVED}
"' >> /etc/portage/make.conf
echo 'DISTDIR="/var/cache/portage/distfiles"' >> /etc/portage/make.conf
echo 'PORTAGE_TMPDIR="/var/tmp"' >> /etc/portage/make.conf
echo 'GRUB_PLATFORMS="efi-64 pc qemu"' >> /etc/portage/make.conf
echo 'QEMU_USER_TARGETS="aarch64 arm i386 x86_64"' >> /etc/portage/make.conf
echo 'PYTHON_ABIS="2.7 3.7"' >> /etc/portage/make.conf
echo 'PYTHON_SINGLE_TARGET="python3_7"' >> /etc/portage/make.conf
echo 'PYTHON_TARGETS="python2_7 python3_7"' >> /etc/portage/make.conf
echo 'RUBY_TARGETS="ruby26"' >> /etc/portage/make.conf
echo 'PHP_TARGETS="php7-3"' >> /etc/portage/make.conf
echo 'SANE_BACKENDS="*"' >> /etc/portage/make.conf
nano -w /etc/portage/make.conf 
nano -w /etc/conf.d/hwclock
nano -w /etc/conf.d/hostname

echo Time to install the kernel.
echo "sys-kernel/debian-sources binary" >> /etc/portage/package.use
emerge --ask --newuse --deep --with-bdeps=y @world
emerge -v linux-firmware
emerge -v debian-sources

echo Installing a bootloader...
emerge -v grub
grub-install --target=i386-pc --no-floppy /dev/sda
ego boot update

echo Configure the network...
emerge -v dhcpcd
rc-update add dhcpcd default

emerge -v networkmanager

echo Time to set the root password.
passwd

echo Time to update the system.
emerge --sync
emerge -auDNV world

echo We will now install useful apps.
emerge metalog
rc-update add metalog default
emerge fcron
rc-update add fcron default
emerge sudo
emerge htop

echo Time to add a normal user.
echo Enter your username.
read username
useradd -m -g users -G audio,video,cdrom,wheel $username
echo Enter your password.
passwd $username
visudo

echo We will now install a graphical environment.
epro flavor desktop
emerge -v xorg-x11

echo 'What desktop environment do you want to install? Enter [KDE/XFCE].'
read deanswer

if [[ $deanswer == "KDE" || $deanswer == "kde" ]]
then 
	echo 'Installing KDE Plasma.'
	epro mix-in kde-plasma-5
	emerge -auvDN --with-bdeps=y @world
else
	echo 'Installing XFCE.'
	epro mix-ins +xfce
	emerge -auvDN --with-bdeps=y @world
	emerge xfce4-meta
fi

echo Done! Great Work.
exit