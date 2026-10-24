include $(TOPDIR)/rules.mk

PKG_NAME:=podman
PKG_VERSION:=6.1.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/podman-container-tools/podman/archive/v$(PKG_VERSION)
PKG_HASH:=a4b2b10bd560cf9b4c50c282bd04bb74486ff6c78bebd51427f779fe985fc1bb

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_CPE_ID:=cpe:/a:podman_project:podman

PKG_BUILD_DEPENDS:=golang/host protobuf/host btrfs-progs
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_INSTALL:=1
PKG_CONFIG_DEPENDS:=CONFIG_OPENWRT_SYSTEMD

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Download/default-policy
  URL:=https://raw.githubusercontent.com/containers/skopeo/362f70b056a1f5d2bd4184527a0ae0d20c4d35d3
  URL_FILE:=default-policy.json
  FILE:=default-policy.json-362f70b056
  HASH:=cddfaa8e6a7e5497b67cc0dd8e8517058d0c97de91bf46fff867528415f2d946
endef

define Package/podman
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Podman
  URL:=https://podman.io
  DEPENDS:=$(GO_ARCH_DEPENDS) +conmon +libgpgme +libseccomp +nsenter \
	+zoneinfo-simple +kmod-veth +passt +netavark +aardvark-dns \
	+catatonit +crun +OPENWRT_SYSTEMD:libsystemd +kmod-tun \
	+shadow-newuidmap +shadow-newgidmap \
	+PODMAN_SELINUX_SUPPORT:libselinux
endef

define Package/podman/description
  Podman: A tool for managing OCI containers and pods
endef

define Package/podman/config
  menu "Configuration"

    config PODMAN_SELINUX_SUPPORT
    bool "Enable SELinux support"
    default n

  endmenu
endef

define Package/podman/conffiles
/etc/containers/policy.json
/etc/containers/storage.conf
/etc/containers/registries.conf
/etc/containers/containers.conf
/etc/containers/networks/podman.json
endef

GO_PKG_TAGS:=seccomp exclude_graphdriver_devicemapper apparmor
ifeq ($(CONFIG_OPENWRT_SYSTEMD),y)
  GO_PKG_TAGS+= systemd
endif
ifdef CONFIG_PODMAN_SELINUX_SUPPORT
  GO_PKG_TAGS+= selinux
endif

MAKE_VARS += \
	$(GO_GENERAL_BUILD_CONFIG_VARS) \
	$(GO_PKG_BUILD_CONFIG_VARS) \
	$(GO_PKG_VARS) \
	GIT_COMMIT="" \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	PREFIX=/usr \
	LIBEXECDIR=/usr/lib \
	LIBEXECPODMAN=/usr/lib/podman \
	TMPFILESDIR=/usr/lib/tmpfiles.d \
	BUILDTAGS="$(GO_PKG_TAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(eval $(call Download,default-policy))
endef

define Build/Compile
	$(call Build/Compile/Default,binaries)
endef

define Build/Install
	$(call Build/Compile/Default,install.bin $(if $(CONFIG_OPENWRT_SYSTEMD),install.systemd))
endef

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/podman/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/podman $(1)/usr/bin/
	$(INSTALL_BIN) ./files/podman-remote.sh $(1)/usr/bin/podman-remote
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/podman/{rootlessport,quadlet} $(1)/usr/lib/podman/
	$(LN) podman $(1)/usr/bin/podmansh
	$(INSTALL_DIR) $(1)/etc/containers
	$(INSTALL_DATA) $(DL_DIR)/default-policy.json-362f70b056 $(1)/etc/containers/policy.json
	$(INSTALL_DATA) ./files/default-registries.conf $(1)/etc/containers/registries.conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/go.podman.io/storage/storage.conf $(1)/etc/containers/storage.conf
	$(INSTALL_DATA) ./files/containers.conf $(1)/etc/containers/containers.conf
ifeq ($(CONFIG_OPENWRT_SYSTEMD),y)
	$(SED) 's/default_rootless_network_cmd = "slirp4netns"/default_rootless_network_cmd = "pasta"/' $(1)/etc/containers/containers.conf
	$(INSTALL_DIR) $(1)/usr/lib/systemd/system $(1)/usr/lib/systemd/user
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman.socket \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman-restart.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman-auto-update.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman-auto-update.timer \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman-kube@.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/system/podman-clean-transient.service \
		$(1)/usr/lib/systemd/system/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman.socket \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-restart.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-auto-update.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-auto-update.timer \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-kube@.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-clean-transient.service \
		$(PKG_INSTALL_DIR)/usr/lib/systemd/user/podman-user-wait-network-online.service \
		$(1)/usr/lib/systemd/user/
	$(INSTALL_DIR) $(1)/usr/lib/systemd/system-generators \
		$(1)/usr/lib/systemd/user-generators $(1)/usr/lib/tmpfiles.d
	$(LN) ../../podman/quadlet \
		$(1)/usr/lib/systemd/system-generators/podman-system-generator
	$(LN) ../../podman/quadlet \
		$(1)/usr/lib/systemd/user-generators/podman-user-generator
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/tmpfiles.d/podman.conf \
		$(1)/usr/lib/tmpfiles.d/podman.conf
	$(INSTALL_DIR) $(1)/usr/lib/systemd/user/sockets.target.wants \
		$(1)/usr/lib/systemd/user/default.target.wants \
		$(1)/usr/lib/systemd/user/timers.target.wants
	$(LN) ../podman.socket \
		$(1)/usr/lib/systemd/user/sockets.target.wants/podman.socket
	$(LN) ../podman-restart.service \
		$(1)/usr/lib/systemd/user/default.target.wants/podman-restart.service
	$(LN) ../podman-auto-update.timer \
		$(1)/usr/lib/systemd/user/timers.target.wants/podman-auto-update.timer
endif
	$(INSTALL_DIR) $(1)/etc/containers/networks
	$(INSTALL_CONF) ./files/podman.json $(1)/etc/containers/networks
	$(INSTALL_DIR) $(1)/usr/share/containers
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/go.podman.io/common/pkg/seccomp/seccomp.json $(1)/usr/share/containers/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/podman.init $(1)/etc/init.d/podman
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/podman.defaults $(1)/etc/uci-defaults/90-podman
	$(SED) 's/driver = \"\"/driver = \"overlay\"/g' $(1)/etc/containers/storage.conf
endef

define Package/podman/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] && exit 0
[ "$${PKG_UPGRADE:-0}" = "1" ] || exit 0
conf=/etc/containers/containers.conf
[ -f "$$conf" ] || exit 0
# Drop only the values injected by older packages; Podman now selects the
# backend at runtime (systemd boot: systemd cgroups + journald; procd: cgroupfs
# + file events). User-added values with other formatting are left untouched.
sed -i -e '/^events_logger = "none"$$/d' \
	-e '/^cgroup_manager = "systemd"$$/d' \
	-e '/^cgroup_manager = "cgroupfs"$$/d' "$$conf"
$(if $(CONFIG_OPENWRT_SYSTEMD),sed -i -e 's/^default_rootless_network_cmd = "slirp4netns"$$/default_rootless_network_cmd = "pasta"/' -e '/^network_cmd_path = "\/usr\/bin\/slirp4netns"$$/d' "$$conf")
exit 0
endef

$(eval $(call BuildPackage,podman))
