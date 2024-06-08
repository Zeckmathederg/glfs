#!/bin/sh

echo " "
if [[ $UPDATE_BLFS != "y" ]]; then
	echo 'UPDATE_BLFS is not set to "y"; Not updating BLFS.'
	echo "Make sure BLFS is updated or else the check"
	echo "involving BLFS will be pointless!"
	echo "You can update BLFS automatically by setting"
	echo "UPDATE_BLFS=y"
	echo " "
fi

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

if [[ $UPDATE_BLFS == "y" ]]; then
	pushd $BLFS_DIR
	echo "Assuming BLFS_DIR is a git repository..."
	echo "Updating BLFS..."
	git pull
	echo "Done."
	popd
fi

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
spirv-headers
spirv-tools
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

XORG_XML="
x7lib
x7app
x7font
libevdev
x7driver-evdev
libinput
x7driver-libinput
x7driver-synaptics
x7driver-wacom
"

GLFS_PACKAGES="
libglvnd
spirv-llvm-translator
nvidia
rust-bindgen
libclc
ply
seatd
steam
binutils
mingw-w64
wine
"

check_blfs_simple_packages() {
	for package in $BLFS_SIMPLE_PACKAGES; do
		diff -Naur <(grep $package $GLFS_DIR/packages.ent) \
			<(grep $package $BLFS_DIR/packages.ent)  | \
			grep -v fd | grep -v '^@' | grep ENTITY  | \
     			grep '^\(+\|-\)'                         | \
			grep -v xfce4       | grep -v balsa      | \
			grep -v dbus-glib   | grep -v xdg-dbus   | \
			grep -v dbus-python | grep -v dbusmock   | \
			grep -v libdbusmenu | grep -v plasma     | \
			grep -v mingw-w64   | grep -v spirv-llvm
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
			grep -v xfce4       | grep -v balsa      | \
			grep -v dbus-glib   | grep -v xdg-dbus   | \
			grep -v dbus-python | grep -v dbusmock   | \
			grep -v libdbusmenu | grep -v plasma     | \
			grep -v mingw-w64   | grep -v spirv-llvm
		if [[ "$?" = 0 ]]; then
			echo " "
		fi
	done
}
check_xorg_xml() {
	for xml in $XORG_XML; do
		if [[ $xml == "x7lib" ]]; then
			diff -Naur $GLFS_DIR/shareddeps/dps/basicx/x/$xml.xml   \
				$BLFS_DIR/x/installing/$xml.xml               | \
				grep version | grep ENTITY | grep -v download | \
				grep '^\(+\|-\) ' > check-versions-xml.log
			if [[ "$?" != 0 ]]; then
				rm check-versions-xml.log
			else
				echo "In glfs/shareddeps/dps/basicx/x/$xml.xml:"
				cat check-versions-xml.log
				rm check-versions-xml.log
				echo " "
			fi
		else
			diff -Naur $GLFS_DIR/shareddeps/dps/x/$xml.xml          \
				$BLFS_DIR/x/installing/$xml.xml               | \
				grep version | grep ENTITY | grep -v download | \
				grep '^\(+\|-\) ' > check-versions-xml.log
			if [[ "$?" != 0 ]]; then
				rm check-versions-xml.log
			else
				echo "In glfs/shareddeps/dps/x/$xml.xml:"
				cat check-versions-xml.log
				rm check-versions-xml.log
				echo " "
			fi
		fi
	done
}
check_glfs_packages() {
	for package in $GLFS_PACKAGES; do
		if [[ $package == "mingw-w64" ]]; then
			diff -Naur <(grep mingw-w64 $GLFS_DIR/packages.ent | \
				grep -v gcc | awk -F'"' '{print $2}')        \
				<(curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/mingw-w64-crt/-/raw/main/PKGBUILD" | \
				grep "pkgver=" | sed 's/pkgver=//')        | \
				grep -v fd | grep -v '^@' > glfsvarch-version.log
			if [[ "$?" != 0 ]]; then
				rm glfsvarch-version.log
			else
				echo "$package:"
				cat glfsvarch-version.log
				rm glfsvarch-version.log
				echo " "
			fi
		elif [[ $package == "spirv-llvm-translator" ]]; then
			diff -Naur <(grep spirv-llvm-trans $GLFS_DIR/packages.ent | \
				awk -F'"' '{print $2}')                             \
				<(curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/$package/-/raw/main/PKGBUILD" | \
				grep "pkgver=" | sed 's/pkgver=//')               | \
				grep -v fd | grep -v '^@' > glfsvarch-version.log
			if [[ "$?" != 0 ]]; then
				rm glfsvarch-version.log
			else
				echo "$package:"
				cat glfsvarch-version.log
				rm glfsvarch-version.log
				echo " "
			fi
		elif [[ $package == "ply" ]]; then
			diff -Naur <(grep $package $GLFS_DIR/packages.ent | \
				awk -F'"' '{print $2}')                             \
				<(curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/python-$package/-/raw/main/PKGBUILD" | \
				grep "pkgver=" | sed 's/pkgver=//')               | \
				grep -v fd | grep -v '^@' > glfsvarch-version.log
			if [[ "$?" != 0 ]]; then
				rm glfsvarch-version.log
			else
				echo "$package:"
				cat glfsvarch-version.log
				rm glfsvarch-version.log
				echo " "
			fi
		else
			diff -Naur <(grep $package $GLFS_DIR/packages.ent | \
				grep -v wine-major                        | \
				awk -F'"' '{print $2}')                     \
				<(curl --silent "https://gitlab.archlinux.org/archlinux/packaging/packages/$package/-/raw/main/PKGBUILD" | \
				grep "pkgver=" | sed 's/pkgver=//')       | \
				grep -v fd | grep -v '^@' > glfsvarch-version.log
			if [[ "$?" != 0 ]]; then
				rm glfsvarch-version.log
			else
				echo "$package:"
				cat glfsvarch-version.log
				rm glfsvarch-version.log
				echo " "
			fi
		fi
	done
}

echo " "
echo "Checking BLFS package differences..."
echo "------------------------------------"
check_blfs_simple_packages

echo " "
echo " "
echo "The next section will likely have a lot of diffs."
echo "This is normal and you might not have to do anything."
echo "-----------------------------------------------------"
check_blfs_complex_packages

echo " "
echo " "
echo 'Checking versions in Xorg XML files...'
echo "----------------------------------------------------"
check_xorg_xml

echo " "
echo " "
echo "Lastly, GLFS packages not in BLFS. The method of finding"
echo "new package versions is pulling from Arch PKGBUILD files."
echo "Arch is notorious for having out of date packages so be"
echo "warned that this info may not be up to date."
echo "NOTE: This might take a while..."
echo "--------------------------------------------------------"
check_glfs_packages

echo " "
echo "Done! If there were no diffs, then nothing needs to be done :)"
