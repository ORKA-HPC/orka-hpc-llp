
 PARAMETER VERSION = 2.2.0


BEGIN OS
 PARAMETER OS_NAME = standalone
 PARAMETER OS_VER = 6.7
 PARAMETER PROC_INSTANCE = microblaze_0
 PARAMETER stdin = axi_uart
 PARAMETER stdout = axi_uart
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu
 PARAMETER DRIVER_VER = 2.7
 PARAMETER HW_INSTANCE = microblaze_0
 PARAMETER compiler_flags =  -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-mul -mcpu=v10.0
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = top
 PARAMETER DRIVER_VER = 1.0
 PARAMETER HW_INSTANCE = Ecki_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = emaclite
 PARAMETER DRIVER_VER = 4.3
 PARAMETER HW_INSTANCE = axi_ethernet_lite
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 4.3
 PARAMETER HW_INSTANCE = axi_gpio_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 4.3
 PARAMETER HW_INSTANCE = axi_gpio_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 4.3
 PARAMETER HW_INSTANCE = axi_gpio_2
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = intc
 PARAMETER DRIVER_VER = 3.7
 PARAMETER HW_INSTANCE = axi_intc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = tmrctr
 PARAMETER DRIVER_VER = 4.4
 PARAMETER HW_INSTANCE = axi_timer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER DRIVER_VER = 3.2
 PARAMETER HW_INSTANCE = axi_uart
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 4.2
 PARAMETER HW_INSTANCE = microblaze_0_local_memory_dlmb_bram_if_cntlr
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 4.2
 PARAMETER HW_INSTANCE = microblaze_0_local_memory_ilmb_bram_if_cntlr
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = mig_7series
 PARAMETER DRIVER_VER = 2.1
 PARAMETER HW_INSTANCE = mig_0
END


BEGIN LIBRARY
 PARAMETER LIBRARY_NAME = lwip202
 PARAMETER LIBRARY_VER = 1.1
 PARAMETER PROC_INSTANCE = microblaze_0
 PARAMETER dhcp_does_arp_check = true
 PARAMETER lwip_dhcp = true
 PARAMETER phy_link_speed = CONFIG_LINKSPEED100
END


