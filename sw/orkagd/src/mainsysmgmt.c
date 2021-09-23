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
#include "liborkagd.h"
#include "types.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>

typedef enum
{
    SYSMGMT_REG_FRMT_RAW = 0,
    SYSMGMT_REG_FRMT_32_0 = 1,
    SYSMGMT_REG_FRMT_16_16 = 2,
} SysMgmtRegNumberFormat_t;

typedef struct
{
    const char *subComponentName;
    const uint64_t regOffset;
    const SysMgmtRegNumberFormat_t regFrmt;
    const float32_t preOffset;
    const float32_t scale;
    const float32_t postOffset;
} SysMgmtHelper_t;

const SysMgmtHelper_t subComponents [] =
{
    { "temperature", 0x0000000000000400ULL, SYSMGMT_REG_FRMT_16_16, 0.0f, 1.0f / 0.00198421639f, -273.15f },
    { "vccint",      0x0000000000000404ULL, SYSMGMT_REG_FRMT_16_16, 0.0f, 3.0f                 ,    0.0f  },
    { "vccaux",      0x0000000000000408ULL, SYSMGMT_REG_FRMT_16_16, 0.0f, 3.0f                 ,    0.0f  },
    { "vccbram",     0x0000000000000418ULL, SYSMGMT_REG_FRMT_16_16, 0.0f, 3.0f                 ,    0.0f  },
};

float32_t SysMgmtValueGetF32(
    const ORKAGD_FPGAComponent_t *sysmgmtIPHandle,
    const char *subComponentName,
    const uint32_t index )
{
    float32_t rv = 0.0f;
    if ( sysmgmtIPHandle &&
         subComponentName &&
         ( 0 == index ))
    {
        for ( uint32_t i = 0; i < sizeof( subComponents ) / sizeof( SysMgmtHelper_t ); ++i )
        {
            if ( strcmp( subComponentName, subComponents[ i ].subComponentName ) )
            {
                // not found
                continue;
            }
            uint32_t raw = ORKAGD_RegisterU32Read( sysmgmtIPHandle, subComponents[ i ].regOffset );
            switch ( ( int ) subComponents[ i ].regFrmt )
            {
				default:
                case SYSMGMT_REG_FRMT_RAW:
                case SYSMGMT_REG_FRMT_32_0:
                    rv = ( float32_t ) raw;
                    break;
                case SYSMGMT_REG_FRMT_16_16:
                    rv = (( float32_t ) raw ) * ( 1.0f / 65536.0f );
                    break;
            }
            rv = ( ( rv - subComponents[ i ].preOffset ) * subComponents[ i ].scale ) + subComponents[ i ].postOffset;
            break;
        }
    }
    return rv;
}

int main()
{
    ORKAGD_ConfigTarget_t targetConfig;
    ORKAGD_EC_t rc = ORKAGD_Init( "./", "./", "./" );
    if ( rc ) exit( 1 );

    targetConfig.m_InfrastructureFilename = "c7253b34-165a-47a6-b7ae-274dd963eed4.json";
    void *target = ORKAGD_BoardListOpen( &targetConfig );
    if ( !ORKAGD_BoardListRead( target )) exit( 2 );

    if ( 1 != ORKAGD_BoardGetNumFPGAs( target )) exit( 3 );

    void *pTargetFPGA = ORKAGD_FPGAHandleCreate( target, 0 );
    if ( !pTargetFPGA ) exit( 4 );

    ORKAGD_BoardListClose( target );

    const ORKAGD_FPGAComponent_t *sysmgmtIPHandle = NULL;
    uint64_t numComponents = ORKAGD_FPGAComponentsGetNumOf( pTargetFPGA );

    for ( uint64_t i = 0; i < numComponents; ++i )
    {
        const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( pTargetFPGA, i );
        if ( !compEntry ) exit( 5 );
        if ( 0 == strcmp( "sysmgmt", compEntry->ipType ))
        {
            if ( 0 == strcmp( "register", compEntry->ipAccess )) sysmgmtIPHandle = compEntry;
            continue;
        }
    }
    if ( !sysmgmtIPHandle ) exit( 6 );

    if ( ORKAGD_FPGAOpen( pTargetFPGA )) exit( 7 );

    printf( "Temperature: %-3.4f°C\n", SysMgmtValueGetF32( sysmgmtIPHandle, "temperature", 0 ));
    printf( "VCCINT:       %1.4fV\n",  SysMgmtValueGetF32( sysmgmtIPHandle, "vccint",      0 ));
    printf( "VCCAUX:       %1.4fV\n",  SysMgmtValueGetF32( sysmgmtIPHandle, "vccaux",      0 ));
    printf( "VCCBRAM:      %1.4fV\n",  SysMgmtValueGetF32( sysmgmtIPHandle, "vccbram",     0 ));

    ORKAGD_FPGAClose( pTargetFPGA );
    ORKAGD_FPGAHandleDestroy( pTargetFPGA );
    ORKAGD_Deinit();
    return 0;
}
