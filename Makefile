obj-m += sharp-drm.o
sharp-drm-objs += src/main.o src/drm_iface.o src/params_iface.o src/ioctl_iface.o
ccflags-y := -g -Wno-declaration-after-statement

.PHONY: all clean install uninstall install_modules install_aux

ifeq ($(KERNELRELEASE),)
KERNELRELEASE := $(shell uname -r)
endif

ifeq ($(LINUX_DIR),)
LINUX_DIR := /lib/modules/$(KERNELRELEASE)/build
endif

DTB_DEFINE :=
ifeq ($(BOARD),BLEPIS_V2)
DTB_DEFINE := -DBLEPIS_V2
endif

all: sharp-drm.dtbo
	$(MAKE) -C '$(LINUX_DIR)' M='$(shell pwd)' modules

# see https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/136904764/Creating+Devicetree+from+Devicetree+Generator+for+Zynq+Ultrascale+and+Zynq+7000#Compiling-the-DTS-using-DTC%3A
sharp-drm.dtbo: sharp-drm.dts
	cc -I dts $(DTB_DEFINE) -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o - $< | dtc -@ -I dts -O dtb -W no-unit_address_vs_reg -o $@

install_modules:
	$(MAKE) -C '$(LINUX_DIR)' M='$(shell pwd)' modules_install
	depmod -a

install: install_modules install_aux

install_aux:
	@grep -qxF 'sharp-drm' /etc/modules || echo 'sharp-drm' >> /etc/modules

uninstall:
	@sed -i.save '/sharp-drm/d' /etc/modules

clean:
	rm sharp-drm.dtbo || true
	$(MAKE) -C '$(LINUX_DIR)' M='$(shell pwd)' clean
