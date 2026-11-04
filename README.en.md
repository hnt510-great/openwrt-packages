# OpenWrt general packages feed

[简体中文](README.md) | **English**

This private source feed is used by the customized
[hnt510-great/openwrt](https://github.com/hnt510-great/openwrt) main tree.
The project targets x86_64/glibc, APK, native systemd and GNOME. Package
selection follows the main tree's saved configuration.

| Item | Value |
| --- | --- |
| Feed name | `packages` |
| Repository branch | `master` |
| Original upstream | [https://github.com/openwrt/packages](https://github.com/openwrt/packages) (`master`) |

Based on OpenWrt packages, this feed provides recipes for applications,
system libraries, development tools, containers and virtualization, while
preserving this project's local integration commits.

## Main integrations

| Area | Feed responsibility |
| --- | --- |
| GNOME and Python GI | Target metadata and GIR build dependencies for GLib, JSON-GLib, libgudev, libsoup and other libraries used by the main tree's GNOME recipes |
| Virtualization | QEMU/SPICE recipes and console fixes; custom libvirt and virt-manager recipes live in the main tree's `package/custom` |
| Containers | systemd, journald, Quadlet and rootless integration in Podman, conmon, crun and related recipes |
| Services and sharing | PAM OpenSSH, D-Bus and Samba; Samba retains UCI/procd management with process-group behavior matching systemd supervision |
| Web terminal | ttyd certificate reuse from LuCI/uhttpd and reloads on configuration or certificate renewal |
| Desktop compatibility | GnuPG/FUSE dependencies for Flatpak and support for native development tools |

The current desktop uses GNOME. GNOME sessions, libvirt management, APK ABI
checks and publication orchestration also depend on the main tree; cloning
this feed alone does not supply complete buildable firmware.

## Get the source and build

Authenticate on the build machine with an account that can read every private
repository, then obtain the complete main tree:

```sh
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
git clone https://github.com/hnt510-great/openwrt.git
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
```

The main tree's `feeds.conf.default` already contains:

```text
src-git packages https://github.com/hnt510-great/openwrt-packages.git;master
```

To update only this feed in an existing main tree:

```sh
./scripts/feeds update packages
./scripts/feeds install -a -p packages
```

Select the desired package in the main configuration and run `make defconfig`.
Example individual package build:

```sh
make package/feeds/packages/ttyd/compile V=s
```

Run these commands from the main-tree root. Preserve an existing `.config`;
see [local build](https://github.com/hnt510-great/openwrt/blob/main/docs/local-build.md) for setup in a new checkout.
`install` creates build-recipe links rather than installing software on a
device. The full `update -a` also checks and can modify main-tree custom recipes.

## Maintenance and validation

`origin` points to this private repository. To merge original upstream changes
in a new clone, add `upstream` once:

```sh
git -C feeds/packages remote add upstream https://github.com/openwrt/packages.git
git -C feeds/packages fetch upstream
git -C feeds/packages merge upstream/master
# Review, resolve conflicts and validate before pushing
git -C feeds/packages push origin master
```

Skip the add command if `upstream` already exists. `scripts/feeds update` pulls
the private branch; it does not merge original upstream automatically. Feed
integration and main-tree commits are separate. Preserve existing commits,
stashes and uncommitted work. Main-tree `patches/feeds/` files and feature
manifests are historical backups; do not reapply changes already present.

Changes to published APK contents require a new package version, preserving
immutable package identities. Record source checks, package builds, VM tests
and physical-device validation separately. This page summarizes existing
design and evidence without claiming new build or device results. See
[private GitHub hosting](https://github.com/hnt510-great/openwrt/blob/main/docs/github-source-hosting.md).

## Design and validation documents

- [GNOME desktop](https://github.com/hnt510-great/openwrt/blob/main/docs/gnome-desktop.md)
- [Native systemd Podman](https://github.com/hnt510-great/openwrt/blob/main/docs/podman-systemd.md)
- [Rootless Podman](https://github.com/hnt510-great/openwrt/blob/main/docs/podman-rootless.md)
- [Libvirt](https://github.com/hnt510-great/openwrt/blob/main/docs/libvirt.md)
- [SPICE crash fixes and validation](https://github.com/hnt510-great/openwrt/blob/main/docs/spice-crash-fix.md)
- [Samba](https://github.com/hnt510-great/openwrt/blob/main/docs/samba4.md)
- [ttyd HTTPS](https://github.com/hnt510-great/openwrt/blob/main/docs/ttyd-https.md)
- [Native development](https://github.com/hnt510-great/openwrt/blob/main/docs/native-development.md)

## License and upstream

Retain upstream copyrights and licenses. Each package's source follows its
recipe's `PKG_LICENSE` and source declarations.
See the repository [LICENSE](LICENSE).
See [CONTRIBUTING.md](CONTRIBUTING.md) for general recipe conventions; project integration also follows the main-tree guidelines.
