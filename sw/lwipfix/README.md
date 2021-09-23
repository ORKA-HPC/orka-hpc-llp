Vivado 2018.2 lwip lib is broken and xsdk won't build the BSP.
Fix your installation by copying/overwriting xadapter.c to your Vivado 2018.2 installation:

Xilinx/SDK/2018.2/data/embeddedsw/ThirdParty/sw_services/lwip202_v1_1/src/contrib/ports/xilinx/netif/xadapter.c

sudo cp xadapter.c /opt/Xilinx/SDK/2018.2/data/embeddedsw/ThirdParty/sw_services/lwip202_v1_1/src/contrib/ports/xilinx/netif/xadapter.c
