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

