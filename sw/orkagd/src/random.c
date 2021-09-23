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
#include "random.h"

#include <stdbool.h>
#include <inttypes.h>
#include <stdlib.h>

static uint8_t ORKA_g_NumRnd = 1;
static uint8_t ORKA_g_NumBits = 15;
static uint64_t ORKA_g_RND_Mask = 1ULL;

void
ORKA_RND_Init( uint8_t maxBits )
{
    uint8_t i;
    uint8_t j;

    srand( 123 );
    uint64_t maxVal = 1ULL << maxBits;
    ORKA_g_RND_Mask = maxVal - 1;

    // generate a bismask representing all bits needed to randomizely set/reset until max value to achieve
    // check RAND_MAX num bits
    const uint64_t cr = ( uint64_t ) RAND_MAX;

    for ( i = 0; i < 64; ++i )
    {
        // const uint64_t cm = 1ULL << i;
        // printf( "0x%16.16" PRIx64 " & 0x%16.16" PRIx64 ": %c\n", cr, cm, ( cr & cm ) ? '1' : '0' );
        // continue;
        if ( 0 == ( ( ( uint64_t ) ( RAND_MAX ) ) & ( 1ULL << i ) ) )
        {
            break;
        }
    }
    ORKA_g_NumBits = i;

    for ( j = 0; j < 64; ++j )
    {
        if ( maxVal <= ( 1ULL << ( i * j ) ) )
        {
            break;
        }
    }
    ORKA_g_NumRnd = j;
}

uint64_t
ORKA_RND_Get()
{
    uint64_t value = ( uint64_t ) rand();
    for ( uint8_t i = 1; i < ORKA_g_NumRnd; ++i )
    {
        value <<= ORKA_g_NumBits;
        value |= ( uint64_t ) rand();
    }
    return value & ORKA_g_RND_Mask;
}

