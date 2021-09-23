FIRMWARE := firmware.elf

RM := rm -rf

LIBS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group -Wl,--start-group,-lxil,-llwip4,-lgcc,-lc,--end-group

C_SRCS := \
./src/i2c_access.c \
./src/iic_phyreset.c \
./src/main.c \
./src/platform.c \
./src/platform_mb.c \
./src/platform_ppc.c \
./src/platform_zynq.c \
./src/platform_zynqmp.c \
./src/server.c \
./src/jesko.cpp \
./src/sfp.c \
./src/si5324.c 

OBJS := \
./src/i2c_access.o \
./src/iic_phyreset.o \
./src/main.o \
./src/platform.o \
./src/platform_mb.o \
./src/platform_ppc.o \
./src/platform_zynq.o \
./src/platform_zynqmp.o \
./src/server.o \
./src/jesko.o \
./src/sfp.o \
./src/si5324.o 

C_DEPS := \
./src/i2c_access.d \
./src/iic_phyreset.d \
./src/main.d \
./src/platform.d \
./src/platform_mb.d \
./src/platform_ppc.d \
./src/platform_zynq.d \
./src/platform_zynqmp.d \
./src/server.d \
./src/jesko.d \
./src/sfp.d \
./src/si5324.d 


all: bsp $(FIRMWARE)

jesko: buildversion copytarget_local inject copytarget_remote outputversion

buildversion:
	#@BuildVersion src/BuildVersion.txt

inject:
	cd genbit && ./inject_microblaze_elf.sh && cd ..

outputversion:
	@cat src/BuildVersion.txt
	@echo .

copytarget_local: genbit/$(FIRMWARE)

copytarget_remote: ~/work/110_Exchange/2021-04-05_arty-a7-100-debugging/bitstream_injected.bit
	cp "genbit/bitstream_injected.bit" ~/work/110_Exchange/2021-04-05_arty-a7-100-debugging

genbit/$(FIRMWARE): $(FIRMWARE)
	cp $(FIRMWARE) 'genbit'

bsp:
	@echo 'Building libs'
	(cd bsp && make all)

$(FIRMWARE): $(OBJS) lscript.ld
	@echo 'Building target: $@'
	@echo 'Invoking: MicroBlaze gcc linker'
	mb-gcc -Wl,-T -Wl,lscript.ld -Lbsp/microblaze_0/lib -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mcpu=v10.0 -mno-xl-soft-mul -Wl,--no-relax -Wl,--gc-sections -o $(FIRMWARE) $(OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

src/%.o: src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -Os -c -fmessage-length=0 -MT"$@" -Ibsp/microblaze_0/include -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mcpu=v10.0 -mno-xl-soft-mul -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: src/%.cpp
	@echo 'Building (cpp) file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -Os -c -fmessage-length=0 -MT"$@" -Ibsp/microblaze_0/include -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mcpu=v10.0 -mno-xl-soft-mul -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS) $(FIRMWARE)
	(cd bsp && make clean)
	-@echo ' '

.PHONY: all bsp clean
