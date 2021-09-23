FPGA_DEVICE  := 10AX115N2F40E2LG
#FPGA_DEVICE  := 1SG085HN3F43E2VG
QUARTUS_SEED := 1138
TARGETS      := x86-64 \
               fpga \
               qii

SOURCE       := src/main.cpp src/hls1.cpp
HEADERS		 := src/hls1.h
CXX          := i++
DEBUG_FLAGS  = --time $@_time.log -v -ghdl
FPGA_FLAGS   := --simulator none

x86-64: DEVICE   := x86-64
fpga:   DEVICE   := $(FPGA_DEVICE) 
fpga:   CXXFLAGS := $(CXXFLAGS) $(FPGA_FLAGS)
qii:    DEVICE   := $(FPGA_DEVICE)
qii:    CXXFLAGS := $(CXXFLAGS) $(FPGA_FLAGS) --quartus-compile --quartus-seed $(QUARTUS_SEED)

CXXFLAGS    := $(USERCXXFLAGS)
RM          := rm -rf

.PHONY: test
test: $(TARGETS)
	@$(foreach t,$(TARGETS),echo ./$(t); ./$(t); echo "";)

.PHONY: test-fpga
test-fpga : fpga		# output "fpga" compile it
	sed -i 's/INTERNAL true/INTERNAL false/g' fpga.prj/components/slavereg_comp/slavereg_comp_internal_hw.tcl
#	./fpga				# run it 

.PHONY: test-x86-64
test-x86-64 : x86-64
	./x86-64

.PHONY: test-windows
test-windows : CXX := CL
test-windows : x86-64
	x86-64.exe

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-$(RM) $(TARGETS) $(foreach t,$(TARGETS),$(t).prj)

$(TARGETS) : $(SOURCE) $(HEADERS)
	$(CXX) -march=$(DEVICE) $(CXXFLAGS) $(DEBUG_FLAGS) $(SOURCE) -o $@
