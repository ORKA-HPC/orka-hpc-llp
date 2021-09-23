#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
.PHONY: all
all: sw-dep hw-dep


.PHONY: hw-dep
hw-dep: orka-hw-configurator

.PHONY: orka-hw-configurator
orka-hw-configurator:
	$(MAKE) -C hw/orka_hw_configurator

.PHONY: sw-dep
sw-dep:
	$(MAKE) -C sw/orkagd/src

.PHONY: xdma
xdma:
	$(MAKE) -C 3rdparty/xilinx_dma_drivers/XDMA/linux-kernel/xdma

.PHONY: intel
intel:
	$(MAKE) build -C 3rdparty/intel_drivers/fpga_pcie

.PHONY: clean
clean: clean-hw-dep clean-sw-dep

.PHONY: clean-sw-dep
clean-sw-dep:
	$(MAKE) clean -C sw/orkagd/src

.PHONY: clean-hw-dep
clean-hw-dep:
	$(MAKE) clean -C hw/orka_hw_configurator

.PHONY: clean-xdma
clean-xdma:
	$(MAKE) clean -C 3rdparty/xilinx_dma_drivers/XDMA/linux-kernel/xdma

.PHONY: clean-intel
clean-intel:
	$(MAKE) clean -C 3rdparty/intel_drivers/fpga_pcie


.PHONY: clean-xilinx-microblaze-firmware
clean-xilinx-microblaze-firmware:
	$(MAKE) clean -C sw/orkafw/arty

.PHONY: xilinx-microblaze-firmware
xilinx-microblaze-firmware:
	$(MAKE) -C sw/orkafw/arty
