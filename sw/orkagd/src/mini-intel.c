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
#include "mmgmt.h"
#include "tcpipclient.h"
#include "types.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>

int
main()
{
    ORKAGD_ConfigTarget_t targetConfig;
    printf( "TestProgram for LibORKAGD (FPGA GenericDriver)\n" );
    printf( "Version LibORKAGD: %s\n", ORKAGD_VersionString() );

// just LASYNESS factor
#if _MSC_VER
    ORKAGD_EC_t rc = ORKAGD_Init(
        ".\\src\\vcu118",   // Location of JSON-Files
        ".\\src\\vcu118",   // Location of bitstreams
        ".\\src\\vcu118" ); // Scratch area (writable)
#else
    ORKAGD_EC_t rc = ORKAGD_Init(
        "./vcu118",   // Location of JSON-Files
        "./vcu118",   // Location of bitstreams
        "./vcu118" ); // Scratch area (writable)
#endif
    if ( rc )
    {
        exit( 1 );
    }
    targetConfig.m_InfrastructureFilename = "bitstream.json";

    void *target = ORKAGD_BoardListOpen( &targetConfig );
    if ( !ORKAGD_BoardListRead( target ) )
    {
        exit( 2 );
    }

    if ( 1 != ORKAGD_BoardGetNumFPGAs( target ) )
    {
        exit( 3 );
    }

    void *pTargetFPGA = ORKAGD_FPGAHandleCreate( target, 0 );
    if ( !pTargetFPGA )
    {
        exit( 4 );
    }

    ORKAGD_BoardListClose( target );

// default init (can be overridden by ORKA module)
#define ORKAGD_EXAMPLE_FIRMWARE_SPACE ( 16ULL * ORKAGD_MBYTE )
    bool memoryManagerInitialized = false;

    const ORKAGD_FPGAComponent_t *orkaIPHandle  = NULL;
    const ORKAGD_FPGAComponent_t *orkaPRHandle  = NULL;
    const ORKAGD_FPGAComponent_t *orkaDDRHandle = NULL;
    uint64_t                      numComponents = ORKAGD_FPGAComponentsGetNumOf( pTargetFPGA );
    const ORKAGD_FPGAComponent_t *ledComponents[ 3 ];
    uint64_t                      ledAddresses[ 3 ];
    uint64_t                      NumLEDs = 0;
    printf( "%-10s, %-15s, %-18s [%-18s] was '%-60s'\n", "ipType", "ipSubType", "  ipOffset", "  ipRange", "ipDesignComponentName" );

    bool writeInfoAboutUndefinedJSonEntries = false;

    for ( uint64_t i = 0; i < numComponents; ++i )
    {
        const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( pTargetFPGA, i );
        if ( !compEntry )
        {
            exit( 5 );
        }
        char ipTypeDummy[] = "---", *ipType = ipTypeDummy;
        char ipSubTypeDummy[] = "---", *ipSubType = ipSubTypeDummy;
        if ( compEntry->ipType )
        {
            ipType = compEntry->ipType;
        }
        if ( compEntry->ipSubType )
        {
            ipSubType = compEntry->ipSubType;
        }

        printf( "%-10s, %-15s, 0x%16.16" PRIx64 " [0x%16.16" PRIx64 "] was '%-60s'\n", ipType, ipSubType, compEntry->ipOffset, compEntry->ipRange, compEntry->ipDesignComponentName );

        if ( compEntry->ipType )
        {
            if ( 0 == strcmp( "orkaip", compEntry->ipType ) )
            {
                if ( 0 == strcmp( "register", compEntry->ipAccess ) )
                {
                    if ( 0 == strcmp( compEntry->ipDesignComponentName, "PR" ) )
                    {
                        orkaPRHandle = compEntry;
                    }
                    else
                    {
                        orkaIPHandle = compEntry;
                    }
                    printf( "Name:          %s\n", compEntry->ipDesignComponentName );
                    printf( "SubType:       %s\n", compEntry->ipSubType );
                    printf( "RegisterSpace: 0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n", compEntry->ipOffset, compEntry->ipOffset + compEntry->ipRange );
                }
                else
                {
                    if ( 0 == strcmp( "memcpy", compEntry->ipAccess ) )
                    {
                        orkaDDRHandle   = compEntry;
                        static bool_t x = true;
                        if ( x )
                        {
                            ORKAMM_DevMemInit( compEntry->ipOffset /*+ ORKAGD_EXAMPLE_FIRMWARE_SPACE*/, compEntry->ipRange /*- ORKAGD_EXAMPLE_FIRMWARE_SPACE*/ );
                            memoryManagerInitialized = true;
                            x                        = false;
                        }
                    }
                }
            }
        }
        else
        {
            if ( writeInfoAboutUndefinedJSonEntries )
            {
                printf( "Info (only problematic if needed and used):\n" );
                printf( " Analyse of JSON reveals: Entry cannot be mapped by "
                        "'ORKAInterpreter.json':\n" );
                printf( " - ipDesignComponentName: '%s'\n", compEntry->ipDesignComponentName );
                printf( " - ipOffset:              0x%16.16" PRIx64 "\n", compEntry->ipOffset );
                printf( " - ipRange:               0x%16.16" PRIx64 "\n", compEntry->ipRange );
            }
        }
    }

    if ( !memoryManagerInitialized )
    {
        printf( "Error: Device-Memory is not initialized - No ORKA IP found ...\n" );
        exit( 6 );
    }

    if ( ORKAGD_FPGAOpen( pTargetFPGA ) )
    {
        printf( "FPGAOpen failed ...\n" );
        exit( 11 );
    }

    // Read Persona ID
    printf( "Reading Persona ID\n" );
    uint32_t persona_id = ( uint32_t ) ORKAGD_RegisterReadByName( orkaPRHandle, "PR_PERSONA_ID" );
    printf( "PersonaID = 0x%8.8x\n", persona_id );
    printf( "Reading PR Static ID\n" );
    uint32_t static_id = ( uint32_t ) ORKAGD_RegisterReadByName( orkaPRHandle, "PR_STATIC_ID" );
    printf( "StaticID = 0x%8.8x\n", static_id );

    uint32_t x_snd = 23;
    ORKAGD_RegisterU32Write( orkaDDRHandle, 0x0, x_snd );
    uint32_t x_rcv = ORKAGD_RegisterU32Read( orkaDDRHandle, 0x0 );
    printf( "sent %i, received %i\n", x_snd, x_rcv );

#if 0
#    define TESTBUF_NUMELEM ( 128 )
    uint64_t transferSize = TESTBUF_NUMELEM * sizeof( uint32_t );
    uint64_t pdev         = ORKAMM_DevMalloc( transferSize );
    uint32_t phst1[ TESTBUF_NUMELEM ];
    uint32_t phst2[ TESTBUF_NUMELEM ];
    uint32_t idx;
    uint32_t err = 0;
    for ( idx = 0; idx < TESTBUF_NUMELEM; ++idx )
    {
        phst1[ idx ] = idx;
    }
    ORKAGD_MemcpyH2D( pTargetFPGA, pdev, ( void * ) phst1, transferSize );
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) phst2, pdev, transferSize );
    for ( idx = 0; idx < TESTBUF_NUMELEM; ++idx )
    {
        printf("Mem at 0x%"PRIx64" [%u] = %u\n", pdev, idx, phst2[idx]);
        if ( phst1[ idx ] != phst2[ idx ] )
        {
            printf( "Error in ORKAGD_MemcpyXXX: %d: %d [0x%8.8x] <> %d [0x%8.8x]\n", idx, phst1[ idx ], phst1[ idx ], phst2[ idx ], phst2[ idx ] );
            err++;
        }
    }
    if ( err )
    {
        printf( "Memcpy failed: %d errors occurred!\n", err );
    }
    else
    {
        printf( "Memcpy success!!!\n" );
    }
#endif

#if 0 // 2021-04-27-intel
    // Handle IP
    uint32_t param0    = 23;
    uint32_t param1    = 42;
    uint32_t start     = 0x1;
    uint32_t returnval = ( uint32_t ) -1;
    uint64_t memaddr  = ORKAMM_DevMalloc( 4 * sizeof( int ) );

    ORKAGD_RegisterWriteByName( orkaIPHandle, "INDEX", &param0 );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "VALUE", &param1 );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "MEMDATA", &memaddr );

    printf("...starting IP...\n");
    ORKAGD_Axi4LiteBlockStart( orkaIPHandle );

    printf("...waiting for IP to finish...\n");
    ORKAGD_Axi4LiteBlockWait( orkaIPHandle );

    uint32_t result[4];
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) result, memaddr, sizeof(result) );

    printf("result[0]=%u (was expecting %u)\n", result[0], param0);
    printf("result[1]=%u (was expecting %u)\n", result[1], param1);
    printf("result[2]=%u (was expecting %u)\n", result[2], param0 * param1);
    printf("result[3]=%u (was expecting %u)\n", result[3], param0 * param0);

    returnval = ORKAGD_RegisterReadByName( orkaIPHandle, "RETURNDATA" );
    printf("return value = %u (was expecting %u)\n", returnval, param0 * param1);
#endif
#if 1 // 2021-06-08-intel
    uint32_t param1      = 25;
    uint32_t param2      = 26;
    uint32_t returnval   = ( uint32_t ) -1;
    uint64_t memaddr     = ORKAMM_DevMalloc( 100 * sizeof( int ) );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "ORKAPARAM0", &memaddr );
    uint64_t memaddr_rb = ORKAGD_RegisterReadByName( orkaIPHandle, "ORKAPARAM0" );
    printf( "ORKAPARAM0=0x%" PRIx64 "\n", memaddr_rb );
    printf( "should be 0x%" PRIx64 "\n", memaddr );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "ORKAPARAM1", &param1 );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "ORKAPARAM2", &param2 );
    printf( "...starting IP...\n" );
    ORKAGD_Axi4LiteBlockStart( orkaIPHandle );
    printf( "...waiting for IP to finish...\n" );
    ORKAGD_Axi4LiteBlockWait( orkaIPHandle );
    uint32_t result[ 100 ];
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) result, memaddr, sizeof( result ) );
    printf( "result[0]=%u (was expecting %u)\n", result[ 0 ], param1 );
    printf( "result[1]=%u (was expecting %u)\n", result[ 1 ], param2 );
    printf( "result[3]=%u (was expecting %u)\n", result[ 3 ], 42 );
    returnval = ORKAGD_RegisterReadByName( orkaIPHandle, "RETURNDATA" );
    printf( "return value = %u (was expecting %u)\n", returnval, param1 );
#endif

    ORKAGD_FPGAClose( pTargetFPGA );
    ORKAGD_FPGAHandleDestroy( pTargetFPGA );
    ORKAGD_Deinit();
    ORKAMM_DevMemDeInit();
    return 0;
}
