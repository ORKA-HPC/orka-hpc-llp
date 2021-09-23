// hls1.cpp
// Avalon interface 

#include "hls1.h"


#define BUFFER_SIZE 4096
#define SEED 64

// Take an integer array and swap between
// big and little endianness at each element

hls_avalon_slave_component
component uint32_t slavereg_comp( 
		hls_avalon_slave_register_argument avm1 &memdata,
		hls_avalon_slave_register_argument uint32_t index,
		hls_avalon_slave_register_argument uint32_t value )
{

	memdata[0] = index;
	memdata[1] = value;
	memdata[2] = index * value;
	memdata[3] = index * index;
	return(index * value);

}

