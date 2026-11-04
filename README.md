# OpenWrt 通用软件包 feed

本仓库是 [hnt510-great/openwrt](https://github.com/hnt510-great/openwrt) 定制主树使用的私有源码 feed。
项目面向 x86_64/glibc、APK、原生 systemd 和 GNOME 桌面；软件选择以主树
保存的完整配置为准。

| 项目 | 值 |
| --- | --- |
| Feed 名称 | `packages` |
| 本仓库分支 | `master` |
| 原始上游 | [https://github.com/openwrt/packages](https://github.com/openwrt/packages)（`master`） |

本 feed 基于 OpenWrt packages，提供通用应用、系统库、编译工具、容器及
虚拟化组件的构建配方，并保存本项目的本地集成提交。

## 本项目的主要集成

| 方向 | 本 feed 的职责与主树文档 |
| --- | --- |
| GNOME 与 Python GI | GLib、JSON-GLib、libgudev、libsoup 等库的目标运行时元数据及 GIR 构建依赖，配合主树的 GNOME 自定义配方 |
| 虚拟化 | QEMU、SPICE 相关配方及控制台修复；libvirt、virt-manager 的自定义配方位于主树 `package/custom` |
| 容器 | Podman、conmon、crun 等配方的 systemd、journald、Quadlet 和 rootless 集成 |
| 服务与共享 | PAM OpenSSH、D-Bus、Samba；Samba 保留 UCI/procd 管理，守护进程的进程组行为与 systemd 监督匹配 |
| Web 终端 | ttyd 复用 LuCI/uhttpd 证书、配置变更和证书续期时的重载逻辑 |
| 桌面应用兼容 | Flatpak 所需的 GnuPG、FUSE 等依赖与本机开发工具链配套 |

当前桌面配置使用 GNOME。早期 Weston 文档记录的是历史实现与当时的验证，
不应据此覆盖当前配置。GNOME 会话、libvirt 管理、APK ABI 检查和发布编排
还依赖主树，单独 clone 本 feed 不会得到完整可构建固件。

## 获取与构建

先在构建机登录有权访问全部私有仓库的 GitHub 账号，再获取完整主树：

```sh
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
git clone https://github.com/hnt510-great/openwrt.git
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
```

主树 `feeds.conf.default` 已包含：

```text
src-git packages https://github.com/hnt510-great/openwrt-packages.git;master
```

在现有主树中只更新本 feed，可执行：

```sh
./scripts/feeds update packages
./scripts/feeds install -a -p packages
```

先在主树配置中选择所需包并运行 `make defconfig`。单包构建示例：

```sh
make package/feeds/packages/ttyd/compile V=s
```

以上命令均从主树根目录运行。保留已有 `.config`；新 checkout 的配置恢复
步骤见 [本地构建指南](https://github.com/hnt510-great/openwrt/blob/main/docs/local-build.md)。`install` 安装的是构建配方链接，
不会在设备上安装软件。完整 `update -a` 还会检查并可能修改主树的 custom 配方。

## 维护与验证

`origin` 指向本私有仓库。新 clone 需要合并原始上游时，先添加一次 `upstream`：

```sh
git -C feeds/packages remote add upstream https://github.com/openwrt/packages.git
git -C feeds/packages fetch upstream
git -C feeds/packages merge upstream/master
# 审阅、解决冲突并完成相关验证后推送
git -C feeds/packages push origin master
```

已有 `upstream` 时跳过添加命令。`scripts/feeds update` 拉取本私有分支，
不会自动合并原始上游。本地集成修改与主树的提交分别管理，保留现有提交、
stash 和未提交文件。主树的 `patches/feeds/` 和功能清单是历史备份，
不要向已经包含修改的 feed 重复应用补丁。

涉及已发布 APK 内容的修改必须产生新包版本，不能覆盖同一包身份。源码
检查、包构建、VM 与物理设备验证应分别记录；本文汇总已有设计和验证记录，
不新增构建或设备验证结论。私有源码托管说明见
[GitHub 源码托管](https://github.com/hnt510-great/openwrt/blob/main/docs/github-source-hosting.md)。

## 设计与验证文档

- [GNOME 桌面](https://github.com/hnt510-great/openwrt/blob/main/docs/gnome-desktop.md)
- [Podman 原生 systemd 集成](https://github.com/hnt510-great/openwrt/blob/main/docs/podman-systemd.md)
- [Rootless Podman](https://github.com/hnt510-great/openwrt/blob/main/docs/podman-rootless.md)
- [Libvirt](https://github.com/hnt510-great/openwrt/blob/main/docs/libvirt.md)
- [SPICE 崩溃修复与验证](https://github.com/hnt510-great/openwrt/blob/main/docs/spice-crash-fix.md)
- [Samba](https://github.com/hnt510-great/openwrt/blob/main/docs/samba4.md)
- [ttyd HTTPS](https://github.com/hnt510-great/openwrt/blob/main/docs/ttyd-https.md)
- [原生开发环境](https://github.com/hnt510-great/openwrt/blob/main/docs/native-development.md)

## 许可与上游

保留上游版权和许可。各软件包源码的许可按其配方 `PKG_LICENSE` 及源码声明执行。
仓库许可声明见 [LICENSE](LICENSE)。
通用配方约定见 [CONTRIBUTING.md](CONTRIBUTING.md)；本项目集成还需遵循主树规范。
