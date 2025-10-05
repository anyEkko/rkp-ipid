# 内核模块包必须包含的头文件（放在package/kernel/下）
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

# 包基础信息
PKG_NAME:=rkp-ipid
PKG_VERSION:=1.3
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

# 关键：明确源码路径（src目录下的rkp-ipid.c）
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# 内核模块包定义（SDK识别的核心，必须放在package/kernel/下）
define KernelPackage/rkp-ipid
  SUBMENU:=Other Kernel Modules  # 归类到内核模块的“其他模块”
  TITLE:=IPID Modification Module (6.1.x Kernel)
  DESCRIPTION:=Modifies IPv4 IPID to avoid NAT detection
  FILES:=$(PKG_BUILD_DIR)/rkp-ipid.ko  # 编译后的.ko路径
  AUTOLOAD:=$(call AutoLoad,99,rkp-ipid)  # 自动加载优先级
  DEPENDS:=+kmod-nf-iptables  # 依赖的内核模块（确保网络功能可用）
  KCONFIG:=  # 无额外Kconfig选项
endef

# 准备源码（确保src目录的代码被复制到编译目录）
define Build/Prepare
  # 创建编译目录
  mkdir -p $(PKG_BUILD_DIR)
  # 复制src目录的所有源码到编译目录
  $(CP) $(CURDIR)/src/* $(PKG_BUILD_DIR)/
endef

# 编译规则（适配aarch64交叉编译）
define Build/Compile
  $(MAKE) -C "$(LINUX_DIR)" \
    ARCH=$(LINUX_KARCH) \
    CROSS_COMPILE=$(TARGET_CROSS) \
    SUBDIRS="$(PKG_BUILD_DIR)" \
    EXTRA_CFLAGS="-I$(PKG_BUILD_DIR) -DLINUX_VERSION=$(LINUX_VERSION)" \
    modules  # 编译为内核模块
endef

# 注册包（SDK识别入口）
$(eval $(call KernelPackage,rkp-ipid))
