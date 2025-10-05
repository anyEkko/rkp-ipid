# 必须包含的内核包依赖头文件
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

# 包基础信息（需与源码目录匹配）
PKG_NAME:=rkp-ipid
PKG_VERSION:=1.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

# 内核模块包配置（SDK识别的关键）
define KernelPackage/rkp-ipid
  SUBMENU:=Other modules  # 归类到“其他模块”菜单
  TITLE:=IPID Modification Module (for 6.1.x kernel)  # 包描述
  DESCRIPTION:=Modify IPID in IPv4 headers to avoid NAT detection
  FILES:=$(PKG_BUILD_DIR)/rkp-ipid.ko  # 编译后的.ko文件路径（必须正确）
  AUTOLOAD:=$(call AutoLoad,99,rkp-ipid)  # 自动加载优先级（99为较晚加载）
  KCONFIG:=  # 无额外Kconfig依赖，留空
endef

# 编译参数配置（适配aarch64和6.1.x内核）
define Build/Compile
  $(MAKE) -C "$(LINUX_DIR)" \
    ARCH=$(LINUX_KARCH) \
    CROSS_COMPILE=$(TARGET_CROSS) \
    SUBDIRS="$(PKG_BUILD_DIR)" \
    EXTRA_CFLAGS="-DCONFIG_RKP_IPID -DLINUX_VERSION_CODE=$(LINUX_VERSION_CODE)" \
    modules
endef

# 注册包（SDK识别的入口）
$(eval $(call KernelPackage,rkp-ipid))
