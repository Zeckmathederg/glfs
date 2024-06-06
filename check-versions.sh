#!/bin/sh

echo " "
echo "Make sure BLFS is updated or else the check"
echo "involving BLFS will be pointless!"
echo " "

if [[ $BLFS_DIR == "" ]]; then
	echo 'BLFS_DIR not set, defaulting to "blfs"'
	BLFS_DIR="blfs"
fi
if [[ $GLFS_DIR == "" ]]; then
	echo 'GLFS_DIR not set, defaulting to "glfs"'
	GLFS_DIR="glfs"
fi

ls $BLFS_DIR >> findbooks.log
if [[ "$?" != 0 ]]; then
	cat findbooks.log
	rm findbooks.log
	echo " "
	echo "This script depends on BLFS""'" 'files.'
	echo 'If the directories "blfs" and "glfs" aren'"'"'t'
	echo 'in your current working directory, please set'
	echo 'BLFS_DIR and GLFS_DIR that contain the paths to'
	echo 'these books.'
	exit 1
fi
ls $GLFS_DIR >> findbooks.log
if [[ "$?" != 0 ]]; then
	cat findbooks.log
	rm findbooks.log
	echo " "
	echo "This script depends on GLFS""'" '"packages.ent"'
	echo 'If the directories "glfs" and "blfs" aren'"'"'t'
	echo 'in your current working directory, please set'
	echo 'GLFS_DIR and BLFS_DIR that contain the paths to'
	echo 'these books.'
	exit 1
fi
rm findbooks.log

BLFS_SIMPLE_PACKAGES="
libtasn1
nspr
nss-dir
nss-minor
nss-micro
nss-version
p11-kit
make-ca
libunistring
libidn2
libpsl
curl
wget
git
libogg
libvorbis
vorbistools
flac
opus
libsndfile
pulseaudio
xorg-version
util-macros
xorgproto
libXau
libXdmcp
which
libpng
freetype2
harfbuzz
fontconfig
libxcvt
libunwind
nettle
gnutls
pixman
vulkan
spirv
glslang
pciutils
hwdata
rust-version
cbindgen
mako
libdrm
mesa
xbitmaps
luit
xcursor
xkeyboard
epoxy
xorg-server
mtdev
xinit
icu
libxml2
xdg-user-dirs
libgpg-error
lynx-version
links-version
gdb-version
valgrind-version
gcc
libxkbcommon
sdl2-version
"

BLFS_COMPLEX_PACKAGES="
alsa
python3
cmake
dbus
llvm
xcb
wayland
"

BLFS_ONLY_PACKAGES="
xfce4
balsa
dbus-glib
xdg-dbus
dbus-python
dbusmock
libdbusmenu
plasma
"

GLFS_PACKAGES="
libglvnd
nvidia
rust-bindgen
seatd
steam
binutils
wine
"

check_blfs_simple_packages() {
	for package in $BLFS_SIMPLE_PACKAGES; do
		diff -Naur <(grep $package $GLFS_DIR/packages.ent) \
			<(grep $package $BLFS_DIR/packages.ent)  | \
			grep -v fd | grep -v '^@' | grep ENTITY  | \
     			grep '^\(+\|-\)'                         | \
			grep -v xfce4 | grep -v balsa            | \
			grep -v dbus-glib | grep -v xdg-dbus     | \
			grep -v dbus-python | grep -v dbusmock   | \
			grep -v libdbusmenu | grep -v plasma
		if [[ "$?" = 0 ]]; then
			echo " "
		fi
	done
}
check_blfs_complex_packages() {
	for package in $BLFS_COMPLEX_PACKAGES; do
		diff -Naur <(grep $package $GLFS_DIR/packages.ent) \
			<(grep $package $BLFS_DIR/packages.ent)  | \
			grep -v fd | grep -v '^@' | grep ENTITY  | \
     			grep '^\(+\|-\)'                         | \
			grep -v xfce4 | grep -v balsa            | \
			grep -v dbus-glib | grep -v xdg-dbus     | \
			grep -v dbus-python | grep -v dbusmock   | \
			grep -v libdbusmenu | grep -v plasma
		if [[ "$?" = 0 ]]; then
			echo " "
		fi
	done
}
check_glfs_packages() {
	for package in $GLFS_PACKAGES; do
		echo "$package on GLFS:"
		grep $package $GLFS_DIR/packages.ent
		echo "$package on Arch:"
		curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/$package/-/raw/main/PKGBUILD" | grep "pkgver=" | sed 's/pkgver=//'
		echo " "
	done
}

echo " "
echo "Checking BLFS package differences..."
echo "------------------------------------"
check_blfs_simple_packages

echo " "
echo " "
echo 'Checking versions in files other than "packages.ent"'
echo "----------------------------------------------------"

echo "In glfs/shareddeps/dps/basicx/x/x7lib.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/basicx/x/x7lib.xml \
     $BLFS_DIR/x/installing/x7lib.xml |                \
     grep version                     |                \
     grep ENTITY                      |                \
     grep -v download                 |                \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7app.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7app.xml \
     $BLFS_DIR/x/installing/x7app.xml |         \
     grep version                     |         \
     grep ENTITY                      |         \
     grep -v download                 |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7font.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7font.xml \
     $BLFS_DIR/x/installing/x7font.xml |         \
     grep version                      |         \
     grep ENTITY                       |         \
     grep -v download                  |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/libevdev.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/libevdev.xml \
     $BLFS_DIR/x/installing/libevdev.xml |         \
     grep version                        |         \
     grep ENTITY                         |         \
     grep -v download                    |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7driver-evdev.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7driver-evdev.xml \
     $BLFS_DIR/x/installing/x7driver-evdev.xml |         \
     grep version                              |         \
     grep ENTITY                               |         \
     grep -v download                          |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/libinput.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/libinput.xml \
     $BLFS_DIR/x/installing/libinput.xml |         \
     grep version                        |         \
     grep ENTITY                         |         \
     grep -v download                    |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7driver-libinput.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7driver-libinput.xml \
     $BLFS_DIR/x/installing/x7driver-libinput.xml |         \
     grep version                                 |         \
     grep ENTITY                                  |         \
     grep -v download                             |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7driver-synaptics.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7driver-synaptics.xml \
     $BLFS_DIR/x/installing/x7driver-synaptics.xml |         \
     grep version                                  |         \
     grep ENTITY                                   |         \
     grep -v download                              |         \
     grep '^\(+\|-\) '
echo " "

echo "In glfs/shareddeps/dps/x/x7driver-wacom.xml:"
diff -Naur $GLFS_DIR/shareddeps/dps/x/x7driver-wacom.xml \
     $BLFS_DIR/x/installing/x7driver-wacom.xml |         \
     grep version                              |         \
     grep ENTITY                               |         \
     grep -v download                          |         \
     grep '^\(+\|-\) '
echo " "


echo " "
echo "The next section will likely have a lot of diffs."
echo "This is normal and you might not have to do anything."
echo "-----------------------------------------------------"
check_blfs_complex_packages

echo " "
echo " "
echo "Lastly, GLFS packages not in BLFS. The method of finding"
echo "new package versions is pulling from Arch PKGBUILD files."
echo "Arch is notorious for having out of date packages so be"
echo "warned that this info may not be up to date."
echo "--------------------------------------------------------"
check_glfs_packages
echo "mingw-w64 on GLFS:"
grep mingw-w64 $GLFS_DIR/packages.ent
echo "mingw-w64 on Arch:"
curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-crt/-/raw/main/PKGBUILD" | grep "pkgver=" | sed 's/pkgver=//'

echo " "
echo "Done! If there were no diffs, then nothing needs to be done :)"
