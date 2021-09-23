// hls1.h
// Avalon interface w

#ifndef __HLS1_H__
#define __HLS1_H__

#ifndef __INTELFPGA_COMPILER__
#include "ref/ac_int.h"
#else
#include "HLS/ac_int.h"
#endif

#include <HLS/hls.h>
#include <HLS/stdio.h>

struct return_struct
{
	uint32_t	version;
	uint32_t	retval1;
	uint32_t	retval2;
	uint32_t	retval3;
};


using avm1_int  = ihc::mm_master<uint32_t, ihc::aspace<1>, ihc::awidth<32>, ihc::dwidth<512>, ihc::maxburst<16>, ihc::latency<0>, ihc::waitrequest<true>, ihc::align<64>>;
using avm1_flt  = ihc::mm_master<float, ihc::aspace<1>, ihc::awidth<32>, ihc::dwidth<512>, ihc::maxburst<16>, ihc::latency<0>, ihc::waitrequest<true>, ihc::align<64>>;

hls_avalon_slave_component
component return_struct slavereg_comp( 
		hls_avalon_slave_register_argument avm1_int 	&memdata1,
		hls_avalon_slave_register_argument avm1_int 	&memdata2,
		hls_avalon_slave_register_argument avm1_flt 	&memdata3,
		hls_avalon_slave_register_argument uint32_t 	index,
		hls_avalon_slave_register_argument uint32_t	value );

#endif // HLS1_H
