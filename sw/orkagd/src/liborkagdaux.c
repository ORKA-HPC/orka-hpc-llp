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
#include <stdbool.h>
#include <inttypes.h>
#include <stdlib.h>

#include "mmgmt.h"
#include "random.h"

// test functions
static bool
ORKA_TestDevMemLinear()
{
    uint16_t i;
    ORKAMM_DevMemEntry_t TestVals[ ORKAMM_TEST_TEST_LOOPS ];
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "* ORKA_TestDevMemLinear\n" );

    ORKAMM_DBG_PRINTF( "  - ORKAMM_DevMalloc\n" );
    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS; ++i )
    {
        uint64_t z = ORKA_RND_Get();
        z %= ORKAMM_TEST_MAX_SIZE_MALLOC_BLOCK;
        TestVals[ i ].size = z;
        TestVals[ i ].start = ORKAMM_DevMalloc( z );
        ORKAMM_DBG_PRINTF( "    %3d: MallocAddr = 0x%16.16" PRIx64 ", Size = 0x%16.16" PRIx64 "(%" PRId64 ")\n", i, TestVals[ i ].start, TestVals[ i ].size, TestVals[ i ].size );
    }

    ORKAMM_DBG_PRINTF( "  - ORKAMM_DevFree\n" );
    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS; ++i )
    {
        ORKAMM_DBG_PRINTF( "    %3d: Free  Addr = 0x%16.16" PRIx64 ", Size = 0x%16.16" PRIx64 "(%" PRId64 ")\n", i, TestVals[ i ].start, TestVals[ i ].size, TestVals[ i ].size );
        ORKAMM_DevFree( TestVals[ i ].start );
    }
    return true;
}

static bool
ORKA_TestDevMemFreeBlockAllCases()
{
    bool rv = false;
    uint64_t a0;
    uint64_t a1;
    uint64_t a2;
    uint64_t a3;
    uint64_t a4;
    uint64_t a5;

    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - start =====================================\n" );
    ORKAMM_DBG_PRINTF( "------------------------------------------------------------------------------\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - FFFFFFFFFFFFFFFFFFFFFFFF ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( 17 );
    a1 = ORKAMM_DevMalloc( 123 );
    a2 = ORKAMM_DevMalloc( 38 );

    // test - generate new entry at start
    ORKAMM_DevFree( a1 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - AAAAAAAAAAAAAAAAAAAAAAAA ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( 17 );
    a1 = ORKAMM_DevMalloc( 123 );
    a2 = ORKAMM_DevMalloc( 38 );
    ORKAMM_DevFree( a1 );

    // test - check whether block concatenates to this block in front
    ORKAMM_DevFree( a0 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - BBBBBBBBBBBBBBBBBBBBBBBB ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( 17 );
    a1 = ORKAMM_DevMalloc( 123 );
    a2 = ORKAMM_DevMalloc( 38 );
    a3 = ORKAMM_DevMalloc( 69 );

    ORKAMM_DevFree( a0 );
    // test - check whether block concatenates to this block in the back
    ORKAMM_DevFree( a1 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - CCCCCCCCCCCCCCCCCCCCCCCC ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( 17 );
    a1 = ORKAMM_DevMalloc( 123 );
    a2 = ORKAMM_DevMalloc( 38 );
    a3 = ORKAMM_DevMalloc( 69 );
    a4 = ORKAMM_DevMalloc( 57 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevFree( a1 );
    ORKAMM_DevFree( a3 );

    // test - check whether block concatenates current and next block
    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();
    ORKAMM_DevFree( a2 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - DDDDDDDDDDDDDDDDDDDDDDDD ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( 17 );
    a1 = ORKAMM_DevMalloc( 123 );
    a2 = ORKAMM_DevMalloc( 38 );
    a3 = ORKAMM_DevMalloc( 69 );
    a4 = ORKAMM_DevMalloc( 57 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevFree( a1 );
    // test - check to insert between two ordinary blocks
    ORKAMM_DevFree( a3 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - EEEEEEEEEEEEEEEEEEEEEEEE ==================\n" );
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    a0 = ORKAMM_DevMalloc( ORKAMM_TEST_POOL_MAX_SIZE / 2 );
    a1 = ORKAMM_DevMalloc( ORKAMM_TEST_POOL_MAX_SIZE / 4 );
    a2 = ORKAMM_DevMalloc( ORKAMM_TEST_POOL_MAX_SIZE / 4 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevFree( a0 );
    // test - check to insert between two ordinary blocks
    ORKAMM_DevFree( a2 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    ORKAMM_DevMemDeInit();

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_TestDevMemFreeBlockAllCases - end =======================================\n" );
    ORKAMM_DBG_PRINTF( "------------------------------------------------------------------------------\n" );
    ORKAMM_DBG_PRINTF( "\n" );

    return rv;
}

static bool
ORKA_TestDevMemFillFreeBlock()
{
    bool rv = false;

    uint64_t a0 = ORKAMM_DevMalloc( 17 );
    uint64_t a1 = ORKAMM_DevMalloc( 123 );
    uint64_t a2 = ORKAMM_DevMalloc( 38 );

    ORKAMM_DevFree( a1 );

    ORKAMM_DBG_DumpListAllocated();
    uint64_t a3 = ORKAMM_DevMalloc( 123 );
    ORKAMM_DBG_DumpListAllocated();

    ORKAMM_DevFree( a0 );
    ORKAMM_DevFree( a2 );
    ORKAMM_DevFree( a3 );

    ORKAMM_DBG_DumpListAllocated();
    ORKAMM_DBG_DumpListFree();

    return rv;
}

static uint64_t TestVals[ ORKAMM_TEST_TEST_LOOPS ];
static uint64_t Testindices[ ORKAMM_TEST_TEST_LOOPS ];

static bool
ORKA_TestDevMemFillRandomBlock()
{
    uint32_t i;

    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );

    // allocate
    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS; ++i )
    {
        if ( 0 == ( i & 0xfff )) printf( "Alloc: %ld%c", i, 13 );

        // prepare sorted list of indices for later scrambling
        Testindices[ i ] = i;

        // get random number of bytes to allocate
        uint64_t z;
        do
        {
            z = ORKA_RND_Get();
            z %= ORKAMM_TEST_MAX_SIZE_MALLOC_BLOCK;
        } while( 0 == z );
        ORKAMM_DBG_PRINTF( "%3d: ORKAMM_DevMalloc = 0x%16.16" PRIx64 "\n", i, z );
        uint64_t a = ORKAMM_DevMalloc( z );
        if ( 0 == a )
        {
            printf( "%6d: ORKAMM_DevMalloc (no memory): 0x%16.16" PRIx64 " (%" PRId64 ") - Free: %" PRId64 " Max: %" PRId64 "\n", i, z, z, ORKAMM_DevFreeBytes(), ORKAMM_DevFreeBiggestBlock());
            ORKAMM_DBG_DumpListAllocated();
        }
        TestVals[ i ] = a;
    }

    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS * 4; ++i )
    {
        uint32_t i1 = rand() % ORKAMM_TEST_TEST_LOOPS;
        uint32_t i2 = rand() % ORKAMM_TEST_TEST_LOOPS;
        ORKAMM_DBG_PRINTF( "%d <=> %d\n", i1, i2 );
        uint64_t tmp = Testindices[ i1 ];
        Testindices[ i1 ] = Testindices[ i2 ];
        Testindices[ i2 ] = tmp;
    }

    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS; ++i )
    {
        // prepare sorted list of indices for later scrambling
        ORKAMM_DBG_PRINTF( "%2d: %" PRId64 "\n", i, Testindices[ i ] );
    }

    // free
    for ( i = 0; i < ORKAMM_TEST_TEST_LOOPS; ++i )
    {
        if ( 0 == ( i & 0xfff ) ) printf( "Free : %ld%c", i, 13 );

        uint64_t idx = Testindices[ i ];
        ORKAMM_DBG_PRINTF( "%3" PRId64 ": ORKAMM_DevFree = 0x%16.16" PRIx64 "\n", idx, TestVals[ idx ] );
        ORKAMM_DevFree( TestVals[ idx ] );
        ORKAMM_DBG_PRINTF( "\n\n\n" );
    }

    uint64_t s = ORKAMM_DBG_DumpListFreeSize();
    if ( 1 == s )
    {
        printf( "Test SUCCESS !!\n" );
    }
    else
    {
        printf( "Test ERRROR: Num entries in FREE-List is %" PRId64 " (should be 1) !!\n", s );
        printf( "Need <Ctrl>+<c>\n" );
        for ( ;;);
    }

    ORKAMM_DevMemDeInit();
    return true;
}

int
main_testMem()
{
    ORKAMM_DBG_PRINTF( "This is me - Testing the memory functions\n" );
    ORKA_RND_Init( 32 );

    ORKA_TestDevMemFillRandomBlock();

    ORKA_TestDevMemFreeBlockAllCases();

#if 0
    uint16_t i;
    uint64_t TestVals[ ORKAMM_TEST_TEST_LOOPS ];


    ORKAMM_DevMemInit( ORKAMM_TEST_POOL_START_ADDRESS, ORKAMM_TEST_POOL_MAX_SIZE );
    ORKA_TestDevMemFillFreeBlock();

    uint64_t a0 = ORKAMM_DevMalloc( 17 );
    uint64_t a1 = ORKAMM_DevMalloc( 123 );
    uint64_t a2 = ORKAMM_DevMalloc( 38 );

    ORKAMM_DevFree( a1 );

    ORKAMM_DBG_DumpListAllocated();
    uint64_t a3 = ORKAMM_DevMalloc( 123 );
    ORKAMM_DBG_DumpListAllocated();
    uint64_t a4 = ORKAMM_DevMalloc( 50 );
    uint64_t a5 = ORKAMM_DevMalloc( 20 );

    ORKAMM_DevFree( a4 );
    ORKAMM_DevFree( a5 );

    ORKAMM_DevMemDeInit();
#endif
    return 0;
}
