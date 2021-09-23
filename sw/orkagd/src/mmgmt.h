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
#ifndef MMGMT_H__
#define MMGMT_H__

// unused so far
#define ORKAMM_MEMPOOLS_USE ( 0 )

#include <stdbool.h>
#include "vector.h"

#if 1
#define ORKAMM_DBG_PRINTF( ... )
#define ORKAMM_DBG_OUTPUT_LEVEL 0
#else
#define ORKAMM_DBG_PRINTF( ... ) printf( " ORKAGD_MMGMT: " __VA_ARGS__ )
#define ORKAMM_DBG_OUTPUT_LEVEL 1
#endif

#ifdef ORKAMM_EXT_MMGMT
#define ORKAMM_FREE( addr )         ( ORKAMM_EXT_MMGMT_FREE( addr ))
#define ORKAMM_MALLOC( size )       ( ORKAMM_EXT_MMGMT_MALLOC( size ))
#define ORKAMM_CALLOC( num, size )  ( ORKAMM_EXT_MMGMT_CALLOC( num, size ))
#else
#define ORKAMM_FREE( addr )         ( free( addr ))
#define ORKAMM_MALLOC( size )       ( malloc( size ))
#define ORKAMM_CALLOC( num, size )  ( calloc( num, size ))
#endif

#define ORKAGD_KB ( 1024ULL )
#define ORKAGD_MB ( ORKAGD_KB * ORKAGD_KB )
#define ORKAGD_GB ( ORKAGD_MB * ORKAGD_KB )
#define ORKAGD_TB ( ORKAGD_GB * ORKAGD_KB )
#define ORKAGD_PB ( ORKAGD_TB * ORKAGD_KB )
#define ORKAGD_EB ( ORKAGD_PB * ORKAGD_KB )

typedef struct
{
    uint64_t start;
    uint64_t size;
} ORKAMM_DevMemEntry_t;

enum
{
    ORKAGD_MEM_ALIGNMENT = ( 1ULL << 4 ),
    ORKAGD_MEM_POOL_MINSIZE = ( 1ULL << 8 ),
};

typedef ORKAVEC_Vector_t *ORKAMM_DevMemList_t;

typedef struct
{
    ORKAMM_DevMemList_t memVecFree;

    uint64_t poolSizeMember;
} ORKAMM_DevMemPool_t;

typedef struct
{
    ORKAVEC_Vector_t *memPools;
    ORKAMM_DevMemList_t memVecAlloced;
} ORKAMM_DevMemPools_t;


// Test data - start ================================
#define ORKAMM_TEST_TEST_LOOPS ( 100000 )
#define ORKAMM_TEST_MAX_SIZE_MALLOC_BLOCK ( 256 * ORKAGD_KB )
#define ORKAMM_TEST_POOL_START_ADDRESS ( 0x0000000080000000ULL )
#define ORKAMM_TEST_POOL_MAX_SIZE ( 16 * ORKAGD_GB )
// Test data - end ==================================

bool ORKAMM_DevMemInit( uint64_t blockStartAddress, uint64_t blockSize );
void ORKAMM_DevMemDeInit();
uint64_t ORKAMM_DevMalloc( const uint64_t size );
void ORKAMM_DevFree( const uint64_t address );
uint64_t ORKAMM_DevFreeBytes();
uint64_t ORKAMM_DevFreeBiggestBlock();

// locally needed debug functions
uint64_t ORKAMM_DBG_DumpListFreeSize();
uint64_t ORKAMM_DBG_DumpListAllocatedSize();
void ORKAMM_DBG_DumpListAllocated();
void ORKAMM_DBG_DumpListFree();

#endif
