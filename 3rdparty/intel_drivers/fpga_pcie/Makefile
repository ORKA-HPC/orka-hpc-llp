# Configured Linux kernel source.
KDIR ?= /lib/modules/`uname -r`/build/


EXTRA_CFLAGS=-I$(M) -I$(M)/libfdt -DCONFIG_FPGA_MGR_DEBUG_FS -DWAIT_TIME=$(WAIT_TIME)

DEVICE=a10

VERBOSE=true

DEBUG=true

WAIT_TIME=5

all:
	$(MAKE) -C $(KDIR) M=`pwd` modules
	gcc fpga-configure.c -o fpga-configure
	sudo cp fpga-pcie-mod.ko /usr/lib/modules/3.10.0-1062.4.1.el7.x86_64/extra

build:
	$(MAKE) -C $(KDIR) M=`pwd` modules
	gcc fpga-configure.c -o fpga-configure

install:
	$(MAKE) -C $(KDIR) M=`pwd` modules_install

load:
	-sudo rmmod fpga-pcie-mod
	-sudo modprobe fpga-pcie-mod

# Final modules
obj-m := fpga-pcie-mod.o

ifeq ($(DEVICE), s10)
	fpga-pcie-mod-objs := fpga-pcie.o altera-pr-ip-core-s10.o fpga-region-controller.o
else
	fpga-pcie-mod-objs := fpga-pcie.o altera-pr-ip-core-a10.o fpga-region-controller.o
endif

ifeq ($(VERBOSE), true)
	EXTRA_CFLAGS += -DVERBOSE_TRUE
endif

ifeq ($(DEBUG), true)
	EXTRA_CFLAGS += -DDEBUG
endif

clean : clean-intermediates clean-module

clean-module :
	rm -f *.ko

clean-intermediates:
	rm -f $(obj-m)
	rm -f *.o libfdt/*.o
	rm -f *.mod.*
	rm -f *.symvers
	rm -f *.order
	rm -f ./.*cmd
	rm -rf .tmp_versions
	rm -rf fpga_region_controller

.PHONY: all clean clean-intermediates clean-module
