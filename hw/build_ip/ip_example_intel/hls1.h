/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
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



using avm1  = ihc::mm_master<uint32_t, ihc::aspace<1>, ihc::awidth<32>, ihc::dwidth<512>, ihc::maxburst<16>, ihc::latency<0>, ihc::waitrequest<true>, ihc::align<64>>;

hls_avalon_slave_component
component uint32_t slavereg_comp( 
		hls_avalon_slave_register_argument avm1 &memdata,
		hls_avalon_slave_register_argument uint32_t index,
		hls_avalon_slave_register_argument float value );

#endif // HLS1_H
