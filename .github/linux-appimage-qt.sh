# SPDX-FileCopyrightText: 2024 shadPS4 Emulator Project
# SPDX-License-Identifier: GPL-2.0-or-later

#!/bin/bash

if [[ -z $GITHUB_WORKSPACE ]]; then
	GITHUB_WORKSPACE="${PWD%/*}"
fi

export Qt6_DIR="/usr/lib/qt6"
export PATH="$Qt6_DIR/bin:$PATH"
export EXTRA_QT_PLUGINS="waylandcompositor"
export EXTRA_PLATFORM_PLUGINS="libqwayland-egl.so;libqwayland-generic.so"

# Prepare Tools for building the AppImage
wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget -q https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
wget -q https://github.com/linuxdeploy/linuxdeploy-plugin-checkrt/releases/download/continuous/linuxdeploy-plugin-checkrt-x86_64.sh
wget -q https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-x86_64

chmod a+x linuxdeploy-x86_64.AppImage
chmod a+x linuxdeploy-plugin-qt-x86_64.AppImage
chmod a+x linuxdeploy-plugin-checkrt-x86_64.sh
chmod a+x uruntime-appimage-dwarfs-x86_64

# Build AppImage
./linuxdeploy-x86_64.AppImage --appdir AppDir
./linuxdeploy-plugin-checkrt-x86_64.sh --appdir AppDir

cp -a "$GITHUB_WORKSPACE/build/translations" AppDir/usr/bin

./linuxdeploy-x86_64.AppImage --appdir AppDir -d "$GITHUB_WORKSPACE"/dist/net.shadps4.shadPS4.desktop  -e "$GITHUB_WORKSPACE"/build/shadps4 -i "$GITHUB_WORKSPACE"/src/images/net.shadps4.shadPS4.svg --plugin qt
rm AppDir/usr/plugins/multimedia/libgstreamermediaplugin.so
./uruntime-appimage-dwarfs-x86_64 --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B32 --header uruntime-appimage-dwarfs-x86_64 -i AppDir -o Shadps4-qt.AppImage
