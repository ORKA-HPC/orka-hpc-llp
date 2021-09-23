// hls1.cpp
// Avalon interface 

#include "hls1.h"


#define BUFFER_SIZE 4096
#define SEED 64

// Take an integer array and swap between
// big and little endianness at each element

hls_avalon_slave_component
//component return_struct slavereg_comp(
component return_struct slavereg_comp(  
		hls_avalon_slave_register_argument avm1_int 	&memdata1,
		hls_avalon_slave_register_argument avm1_int 	&memdata2,
		hls_avalon_slave_register_argument avm1_flt 	&memdata3,
		hls_avalon_slave_register_argument uint32_t 	index,
		hls_avalon_slave_register_argument uint32_t	value )
{
return_struct	rv;
	rv.version = 0x20210416;
	rv.retval1 = index;
	rv.retval2 = memdata1[1];
	rv.retval3 = value;

//	memdata1[10] = index;
//	memdata1[11] = value;
//	memdata1[12] = index * value;
//	memdata1[13] = index * index;
	for (uint32_t i = 0;i<index;i++)
	{
		memdata2[i] = (memdata1[i] * value);
		memdata3[i] = float (memdata1[i]) * 3.5f;
	}
	return(rv);

}

