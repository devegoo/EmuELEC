# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="batocera-emulationstation"
PKG_VERSION="e8395405cfbf3513e6ce6049dd92ef76a638459b"
PKG_GIT_CLONE_BRANCH="EmuELEC"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/shantigilbert/batocera-emulationstation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git freetype curl freeimage vlc bash rapidjson ${OPENGLES} SDL2_mixer boost_locale fping pyyaml"
PKG_SECTION="emuelec"
PKG_NEED_UNPACK="busybox"
PKG_SHORTDESC="Emulationstation emulator frontend"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"


if [[ ${EMUELEC_ADDON} ]]; then
PKG_VERSION="ec03d18e74d77efe14aa4cefc81e01b9455486a0"
PKG_GIT_CLONE_BRANCH="EmuELEC_Addon"
fi

# themes for Emulationstation
PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET es-theme-ComicBook"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_EMUELEC=1 -DDISABLE_KODI=1"

makeinstall_target() {
	mkdir -p $INSTALL/usr/share/locale
	cp -rf $PKG_BUILD/locale/lang/* $INSTALL/usr/share/locale
	
	mkdir -p $INSTALL/usr/config/emulationstation/resources
    cp -rf $PKG_BUILD/resources/* $INSTALL/usr/config/emulationstation/resources/
    
	mkdir -p $INSTALL/usr/lib/python2.7
	cp -rf $PKG_DIR/bluez/* $INSTALL/usr/lib/python2.7
	
	mkdir -p $INSTALL/usr/config/emuelec/
	cp -rf $PKG_DIR/emuelec/* $INSTALL/usr/config/emuelec
	chmod +x $INSTALL/usr/config/emuelec/scripts/batocera/*
	
    mkdir -p $INSTALL/usr/bin
    ln -sf /storage/.config/emulationstation/resources $INSTALL/usr/bin/resources
    cp -rf $PKG_BUILD/emulationstation $INSTALL/usr/bin

	mkdir -p $INSTALL/etc/emulationstation/
	ln -sf /storage/.config/emulationstation/themes $INSTALL/etc/emulationstation/
   
	mkdir -p $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/scripts $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/*.cfg $INSTALL/usr/config/emulationstation

# Remove systems that are not compatible with S905
	if [ ${PROJECT} = "Amlogic" ]; then 	
	xmlstarlet ed -L -P -d "/systemList/system[name='3do']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	xmlstarlet ed -L -P -d "/systemList/system[name='segasaturn']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	fi 
	
	chmod +x $INSTALL/usr/config/emulationstation/scripts/*
	chmod +x $INSTALL/usr/config/emulationstation/scripts/configscripts/*
	find $INSTALL/usr/config/emulationstation/scripts/ -type f -exec chmod o+x {} \; 
	
	if [ ${PROJECT} = "Amlogic-ng" ]; then    
	sed -i "s|Libretro_mba_mini|Libretro_mba_mini,Libretro_mame2016|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	sed -i "s|Libretro_snes9x2005_plus|Libretro_snes9x2005_plus,Libretro_mesen-s|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	fi
}

post_install() {  
  enable_service emustation.service
}
