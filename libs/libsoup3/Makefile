#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsoup3
PKG_VERSION:=3.7.1
PKG_RELEASE:=7

PKG_SOURCE:=libsoup-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libsoup/$(basename $(PKG_VERSION))
PKG_HASH:=9c96e11bb91641fe21948013499ca716393c9e9336562f9ff849c41d4edab80e
PKG_BUILD_DIR:=$(BUILD_DIR)/libsoup-$(PKG_VERSION)

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnome:libsoup

PKG_BUILD_DEPENDS:=glib2/host

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

define Package/libsoup3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libsoup3
  URL:=https://wiki.gnome.org/Projects/libsoup
  DEPENDS:=+glib2 +libsqlite3 +libpsl +libnghttp2 +LIBSOUP3_ZSTD:libzstd
endef

define Package/libsoup3/config
  config LIBSOUP3_ZSTD
	bool "zstd Content-Encoding support"
	depends on PACKAGE_libsoup3
	default n
	help
	  Enable transparent decoding of zstd-compressed HTTP responses.
	  This pulls in libzstd. Leave disabled to keep the footprint small.
endef

MESON_ARGS += \
	-Dgssapi=disabled \
	-Dntlm=disabled \
	-Dbrotli=disabled \
	-Dzstd=$(if $(CONFIG_LIBSOUP3_ZSTD),enabled,disabled) \
	-Dtls_check=false \
	-Dintrospection=$(if $(CONFIG_PACKAGE_gtk4),enabled,disabled) \
	-Dvapi=disabled \
	-Dtests=false \
	-Dinstalled_tests=false \
	-Dsysprof=disabled

define package/libsoup3/description
Libsoup is an HTTP library implementation in C
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib/pkgconfig,include/libsoup-3.0/libsoup}

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-3.0.so* \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libsoup-3.0/libsoup/*.h \
		$(1)/usr/include/libsoup-3.0/libsoup/
ifneq ($(CONFIG_PACKAGE_gtk4),)
	$(INSTALL_DIR) $(1)/usr/share/gir-1.0 $(1)/usr/lib/girepository-1.0
	$(CP) $(PKG_INSTALL_DIR)/usr/share/gir-1.0/. $(1)/usr/share/gir-1.0/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/girepository-1.0/. $(1)/usr/lib/girepository-1.0/
endif
endef

define Package/libsoup3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-3.0.* \
		$(1)/usr/lib/
ifneq ($(CONFIG_PACKAGE_gtk4),)
	$(INSTALL_DIR) $(1)/usr/lib/girepository-1.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/girepository-1.0/. $(1)/usr/lib/girepository-1.0/
endif
endef

$(eval $(call BuildPackage,libsoup3))
