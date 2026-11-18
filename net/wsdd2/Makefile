include $(TOPDIR)/rules.mk

PKG_NAME:=wsdd2
PKG_RELEASE:=6

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Netgear/wsdd2.git
PKG_SOURCE_DATE:=2023-12-21
PKG_SOURCE_VERSION:=b676d8ac8f1aef792cb0761fb68a0a589ded3207
PKG_MIRROR_HASH:=f91c011746cab42dbc638f2c049d4be2e882b220adca7ba88c6d14fd2d0c3e7e

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

PKG_CONFIG_DEPENDS:=CONFIG_OPENWRT_SYSTEMD

define Package/wsdd2
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Web Services for Devices (WSD) daemon
  URL:=https://github.com/Netgear/wsdd2
endef

define Package/wsdd2/description
  Web Services for Devices or Web Services on Devices (WSD),
  is a Microsoft API to simplify programming connections to web service
  enabled devices, such as printers, scanners and file shares.

  This daemon advertises and responds to probe requests from Windows clients looking for file shares.
  It also implements LLMNR multicast name lookup services.
endef

define Build/Compile
  $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/{wsdd2.c,wsd.c,llmnr.c} -o $(PKG_BUILD_DIR)/wsdd2
endef

define Package/wsdd2/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/libexec $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsdd2 $(1)/usr/bin/
	$(INSTALL_DATA) ./files/wsdd2-config.sh $(1)/usr/libexec/wsdd2-config.sh
	$(INSTALL_BIN) ./files/wsdd2.init $(1)/etc/init.d/wsdd2
	$(if $(CONFIG_OPENWRT_SYSTEMD),$(call Package/wsdd2/install-systemd,$(1)))
endef

define Package/wsdd2/install-systemd
	$(INSTALL_DIR) $(1)/usr/lib/systemd/system $(1)/usr/libexec $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/wsdd2.service ./files/wsdd2-config.path \
		./files/wsdd2-reconfigure.service $(1)/usr/lib/systemd/system/
	$(INSTALL_BIN) ./files/wsdd2-systemd ./files/wsdd2-package $(1)/usr/libexec/
	$(INSTALL_DATA) ./files/wsdd2.hotplug $(1)/etc/hotplug.d/iface/65-wsdd2
endef

define Package/wsdd2/postinst
#!/bin/sh
[ ! -x "$${IPKG_INSTROOT}/usr/libexec/wsdd2-package" ] || "$${IPKG_INSTROOT}/usr/libexec/wsdd2-package" postinst
endef

define Package/wsdd2/prerm
#!/bin/sh
[ ! -x "$${IPKG_INSTROOT}/usr/libexec/wsdd2-package" ] || "$${IPKG_INSTROOT}/usr/libexec/wsdd2-package" prerm
endef

$(eval $(call BuildPackage,wsdd2))
