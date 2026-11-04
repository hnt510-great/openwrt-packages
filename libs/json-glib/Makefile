#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=json-glib
PKG_VERSION:=1.10.8
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/json-glib/$(basename $(PKG_VERSION))
PKG_HASH:=55c5c141a564245b8f8fbe7698663c87a45a7333c2a2c56f06f811ab73b212dd

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=glib2/host

OPENWRT_VERBOSE:=c

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk
PKG_CONFIG_DEPENDS+=CONFIG_PACKAGE_gtk4
# Metadata scans ignore .config, so declare the GIR build deps conditionally.
PKG_BUILD_DEPENDS += PACKAGE_gtk4:gobject-introspection/host PACKAGE_gtk4:gobject-introspection PACKAGE_gtk4:glib2-gir
ifneq ($(CONFIG_PACKAGE_gtk4),)
include $(INCLUDE_DIR)/gobject-introspection.mk
PKG_BUILD_DEPENDS+=glib2-gir
endif

define Package/json-glib
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=JSON GLib Library
  URL:=https://wiki.gnome.org/Projects/JsonGlib
  DEPENDS:=+glib2
  ABI_VERSION:=0
endef

define Package/json-glib/description
JSON-GLib is a library providing serialization and deserialization
support for the JavaScript Object Notation (JSON) format described by
RFC 4627.
endef

MESON_ARGS += \
	-Dgtk_doc=disabled \
	-Dintrospection=$(if $(CONFIG_PACKAGE_gtk4),enabled,disabled) \
	-Dtests=false

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(QUILT),)
	$(SED) '/error=format=2/d' $(PKG_BUILD_DIR)/meson.build
endif
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/json-glib-1.0/json-glib
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/json-glib-1.0/json-glib/*.h \
				$(1)/usr/include/json-glib-1.0/json-glib
	
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjson-glib-1.0.so* \
						$(1)/usr/lib
	
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/json-glib-1.0.pc \
					$(1)/usr/lib/pkgconfig
ifneq ($(CONFIG_PACKAGE_gtk4),)
	$(INSTALL_DIR) $(1)/usr/share/gir-1.0 $(1)/usr/lib/girepository-1.0
	$(CP) $(PKG_INSTALL_DIR)/usr/share/gir-1.0/. $(1)/usr/share/gir-1.0/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/girepository-1.0/. $(1)/usr/lib/girepository-1.0/
endif
endef

define Package/json-glib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjson-glib-1.0.so.$(ABI_VERSION)* \
						$(1)/usr/lib
ifneq ($(CONFIG_PACKAGE_gtk4),)
	$(INSTALL_DIR) $(1)/usr/lib/girepository-1.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/girepository-1.0/. $(1)/usr/lib/girepository-1.0/
endif
endef

$(eval $(call BuildPackage,json-glib))
