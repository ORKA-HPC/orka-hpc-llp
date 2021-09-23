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
#ifndef MM_H__
#define MM_H__

#include "types.h"
#include <stdint.h>

#ifdef __SYNTHESIS__
#define ORKA_VOLATILE volatile
#define ORKA_DBG_PRINTF( ... )
#else
#define ORKA_VOLATILE
#define ORKA_DBG_PRINTF( ... ) printf(" - " __VA_ARGS__ )
#endif


#define MEMORY_ALIGN               ( 0x0010 )
#define MEMORY_ALIGNED_SIZE( x )   ((( x ) + MEMORY_ALIGN - 1 ) & ( ~( MEMORY_ALIGN - 1 )))

typedef float32_t                  MatType_t;

#endif
