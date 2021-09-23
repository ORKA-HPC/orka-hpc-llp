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

bool
TestMemSmall( void *pTargetFPGA )
{
    bool rv = false;
    // memcpy both directions
    printf( "Checking memory transfer\n" );
    static const char myTestString[]  = "Hello world 2019";
    uint64_t          myTestStringLen = ( uint64_t )( strlen( myTestString ) + 1 );
    uint64_t          myStringHandle1 = ORKAMM_DevMalloc( myTestStringLen );
    printf( " * Store '%s'\n", myTestString );
    static char myReceivedString[ 128 ];
    memset( ( void * ) myReceivedString, 0x42, ( int ) myTestStringLen );
    ORKAGD_MemcpyD2H( pTargetFPGA, myReceivedString, myStringHandle1, myTestStringLen );
    ORKAGD_MemcpyH2D( pTargetFPGA, myStringHandle1, myTestString, myTestStringLen );
    memset( ( void * ) myReceivedString, 0x42, ( int ) myTestStringLen );
    ORKAGD_MemcpyD2H( pTargetFPGA, myReceivedString, myStringHandle1, myTestStringLen );
    printf( " * Received: '%s'\n", myReceivedString );
    if ( 0 == memcmp( myTestString, myReceivedString, strlen( myTestString ) ) )
    {
        printf( "Success!! memory contents ok\n" );
        rv = true;
    }
    else
    {
        printf( "ERROR!!\n" );
        printf( "ERROR!! memcpy's not working correctly - it has NOT received correct memory contents\n" );
        printf( "ERROR!!\n" );
    }
    return rv;
}

void
PatternGen( void *dst, uint64_t size, uint32_t mode )
{
    uint64_t i;
    switch ( mode )
    {
        default:
        case 0:
        {
            uint32_t *p = ( uint32_t * ) dst;
            for ( i = 0; i < size; i += sizeof( uint32_t ) )
            {
                *p++ = ( uint32_t ) i;
            }
        }
        case 1:
        {
            uint16_t *p = ( uint16_t * ) dst;
            for ( i = 0; i < size; i += sizeof( uint16_t ) )
            {
                *p++ = ( uint16_t ) rand();
            }
        }
    }
}

bool
TestMemBig( void *pTargetFPGA )
{
    void *   MemSrcHostOrig = NULL;
    void *   MemSrcHostVeri = NULL;
    uint64_t MemDstDev      = 0ULL;
    bool     error          = false;
    bool     end            = false;
    uint32_t mode;
    uint32_t rc;

    uint64_t memSize    = 1024 * 256;
    uint64_t memSizeEnd = 1024 * 1024 * 128;
    do
    {
        printf( "TestMemBig(): memSize=0x%16.16" PRIx64 " (%" PRId64 ")\n", memSize, memSize );

        MemSrcHostOrig = malloc( ( size_t ) memSize );
        MemSrcHostVeri = malloc( ( size_t ) memSize );
        MemDstDev      = ORKAMM_DevMalloc( memSize );
        if ( MemDstDev && MemSrcHostOrig && MemSrcHostVeri )
        {
            for ( mode = 0; mode < 2; ++mode )
            {
                printf( "  PatternMode=%d\n", mode );
                PatternGen( MemSrcHostOrig, memSize, mode );

                rc = ORKAGD_MemcpyH2D( pTargetFPGA, MemDstDev, MemSrcHostOrig, memSize );
                if ( rc )
                {
                    rc = ORKAGD_MemcpyD2H( pTargetFPGA, MemSrcHostVeri, MemDstDev, memSize );
                    if ( rc )
                    {
                        int cmpval = 0;
#if 1
                        uint32_t i;
                        uint8_t *pO = MemSrcHostOrig;
                        uint8_t *pV = MemSrcHostVeri;
                        for ( i = 0; i < memSize; ++i )
                        {
                            if ( *pO != *pV )
                            {
                                cmpval = -1;
                                break;
                            }
                        }
                        pV++;
                        pO++;
#else
                        cmpval = memcmp( MemSrcHostOrig, MemSrcHostVeri, memSize );
#endif

                        if ( 0 == cmpval )
                        {
                            printf( "  Success!! memory contents ok\n" );
                        }
                        else
                        {
                            printf( "  ErRROR!!! memory contents different\n" );

                            error = true;
                            break;
                        }
                    }
                    else
                    {
                        printf( "  ERROR!! ORKAGD_MemcpyD2H()\n" );
                        error = true;
                        break;
                    }
                }
                else
                {
                    printf( "  ERROR!! ORKAGD_MemcpyH2D()\n" );
                    error = true;
                    break;
                }
            }
            if ( !error )
            {
                memSize *= 2;
            }
        }

        // check dev mem
        if ( MemDstDev )
        {
            ORKAMM_DevFree( MemDstDev );
            MemDstDev = 0ULL;
        }
        else
        {
            end = true;
        }
        if ( MemSrcHostOrig )
        {
            free( MemSrcHostOrig );
            MemSrcHostOrig = NULL;
        }
        else
        {
            error = true;
        }
        if ( MemSrcHostVeri )
        {
            free( MemSrcHostVeri );
            MemSrcHostVeri = NULL;
        }
        else
        {
            error = true;
        }
    } while ( ( !error ) && ( !end ) );

    return error;
}

int
main()
{
    ORKAGD_ConfigTarget_t targetConfig;
    printf( "TestProgram for LibORKAGD (FPGA GenericDriver)\n" );
    printf( "Version LibORKAGD: %s\n", ORKAGD_VersionString() );

    // just LASYNESS factor
#if _MSC_VER
    ORKAGD_EC_t rc = ORKAGD_Init(
        "src\\2021-03-03_arty-a7-100-debugging",   // Location of JSON-Files
        "src\\2021-03-03_arty-a7-100-debugging",   // Location of bitstreams
        "src\\2021-03-03_arty-a7-100-debugging" ); // Scratch area (writable)
#else
    ORKAGD_EC_t rc = ORKAGD_Init(
        "./2021-03-03_arty-a7-100-debugging",   // Location of JSON-Files
        "./2021-03-03_arty-a7-100-debugging",   // Location of bitstreams
        "./2021-03-03_arty-a7-100-debugging" ); // Scratch area (writable)
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
                    char regName0[] = "ORKAPARAM0";

                    uint64_t nReg  = ORKAGD_RegisterGetNumIndexOf( compEntry );
                    uint64_t offs  = ORKAGD_RegisterGetOffsetByName( compEntry, regName0 );
                    uint64_t width = ORKAGD_RegisterGetBitWidthByName( compEntry, regName0 );
                    uint64_t iReg  = ORKAGD_RegisterGetIndexOf( compEntry, regName0 );

                    printf( "found 'orkaip':\n" );
                    printf( "- nReg: %" PRId64 "\n", nReg );
                    printf( "- regName: %s\n", regName0 );
                    printf( "- offs: %" PRId64 "\n", offs );
                    printf( "- width: %" PRId64 "\n", width );
                    printf( "- iReg: %" PRId64 "\n", iReg );
                }
            }

            if ( 0 == strcmp( "gpio", compEntry->ipType ) )
            {
                if ( 0 == strcmp( "LEDsAndSwitches", compEntry->ipSubType ) )
                {
                    ledComponents[ NumLEDs ] = compEntry;
                    ledAddresses[ NumLEDs ]  = compEntry->ipOffset;
                    NumLEDs++;
                }
                continue;
            }
            if ( strncmp( "orkaip", compEntry->ipType, 9 ) )
            {
                continue;
            }
            if ( 0 == strcmp( "register", compEntry->ipAccess ) )
            {
                orkaIPHandle    = compEntry;
                static bool_t x = TRUE;
                if ( x )
                {
                    printf( "Registered ORKA component:\n" );
                    x = FALSE;
                }
                printf( "Name:          %s\n", orkaIPHandle->ipDesignComponentName );
                printf( "SubType:       %s\n", orkaIPHandle->ipSubType );
                printf( "RegisterSpace: 0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n", orkaIPHandle->ipOffset, orkaIPHandle->ipOffset + orkaIPHandle->ipRange );
            }
            else
            {
                printf( "MemorySpace:   0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n", compEntry->ipOffset, compEntry->ipOffset + compEntry->ipRange );

                // initialize MemoryManager
                ORKAMM_DevMemInit( compEntry->ipOffset + ORKAGD_EXAMPLE_FIRMWARE_SPACE, compEntry->ipRange - ORKAGD_EXAMPLE_FIRMWARE_SPACE );

                memoryManagerInitialized = true;
            }
        }
        else
        {
            if ( writeInfoAboutUndefinedJSonEntries )
            {
                printf( "Info (only problematic if needed and used):\n" );
                printf( " Analyse of JSON reveals: Entry cannot be mapped by 'ORKAInterpreter.json':\n" );
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
    ORKAGD_FPGAComponent_t orkaIPComponent;

    if ( !orkaIPHandle )
    {
#if 0
        exit( 10 );
#else
        // only for debug purposes
        printf( "* Using DEBUG-VALUES for ORKA\n" );
        orkaIPComponent.fpgaHandle                    = pTargetFPGA;
        orkaIPComponent.ipDesignComponentName         = "dummyName";
        orkaIPComponent.ipType                        = NULL;
        orkaIPComponent.ipSubType                     = NULL;
        orkaIPComponent.ipAccess                      = NULL;
        orkaIPComponent.ipDesignComponentTemplateName = NULL;
        orkaIPComponent.ipBitstream                   = NULL;
        orkaIPComponent.ipOffset                      = 0x70000000ULL;
        orkaIPComponent.ipRange                       = 0x10000ULL;

        orkaIPHandle = &orkaIPComponent;
#endif
    }

    if ( ORKAGD_FPGAOpen( pTargetFPGA ) )
    {
        printf( "FPGAOpen failed ...\n" );
        exit( 11 );
    }

    // memcpyXXX Test
    // JSC 2021-03-10
    if ( 0 )
    {
#define NUM_VALS 1000
        int    buffOP0_Snd[ NUM_VALS ];
        int    buffOP0_Rcv[ NUM_VALS ];
        double buffOP1[ NUM_VALS ];
        buffOP0_Snd[ 3 ] = 23;
        uint64_t varOP0  = ORKAMM_DevMalloc( NUM_VALS * sizeof( int ) );
        uint64_t varOP1  = ORKAMM_DevMalloc( NUM_VALS * sizeof( double ) );
        ORKAGD_MemcpyH2D( pTargetFPGA, varOP0, ( void * ) buffOP0_Snd, NUM_VALS * sizeof( int ) );
        ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) buffOP0_Rcv, varOP0, NUM_VALS * sizeof( int ) );

        ORKAGD_FPGAClose( pTargetFPGA );
        ORKAGD_FPGAHandleDestroy( pTargetFPGA );
        ORKAGD_Deinit();
        ORKAMM_DevMemDeInit();
        return 0;
    }

    // ARTY Test - start ============================================
    // NumLEDs = 0;
    if ( NumLEDs )
    {
        printf( "* LED-Test\n" );
#define ORKA_LED_STATUS_BLACK   ( 0x00 )
#define ORKA_LED_STATUS_BLUE    ( 0x01 )
#define ORKA_LED_STATUS_GREEN   ( 0x02 )
#define ORKA_LED_STATUS_RED     ( 0x04 )
#define ORKA_LED_STATUS_MASK    ( 0x07 )
#define ORKA_LED_STATUS_CYAN    ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_GREEN )
#define ORKA_LED_STATUS_MAGENTA ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_RED )
#define ORKA_LED_STATUS_YELLOW  ( ORKA_LED_STATUS_GREEN | ORKA_LED_STATUS_RED )
#define ORKA_LED_STATUS_WHITE   ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_GREEN | ORKA_LED_STATUS_RED )

        uint32_t led0       = ORKA_LED_STATUS_RED;
        uint32_t led1       = ORKA_LED_STATUS_GREEN;
        uint32_t led2       = ORKA_LED_STATUS_YELLOW;
        uint32_t led3       = ORKA_LED_STATUS_BLUE;
        uint32_t ledMaskALL = ( ORKA_LED_STATUS_MASK << ( 3 * 3 ) ) | ( ORKA_LED_STATUS_MASK << ( 3 * 2 ) ) | ( ORKA_LED_STATUS_MASK << ( 3 * 1 ) ) | ( ORKA_LED_STATUS_MASK << ( 3 * 0 ) );

        // separate LED access (register)
        uint32_t led = led0 | ( led1 << 3 ) | ( led2 << 6 ) | ( led3 << 9 );
        printf( "write = 0x%8.8x\n", led );

#define REGISTER_BY_NAME
#ifdef REGISTER_BY_NAME
        ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_TRI", 0x00000000 );
        ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_DATA", led );
        uint32_t value = ORKAGD_RegisterReadByNameU32( ledComponents[ 1 ], "GPIO_DATA" );
#else
        ORKAGD_RegisterU32Write( ledComponents[ 1 ], 0x00000004, 0x00000000 );
        ORKAGD_RegisterU32Write( ledComponents[ 1 ], 0x00000000, led );
        uint32_t value = ORKAGD_RegisterU32Read( ledComponents[ 1 ], 0x00000000 );
#endif
        printf( "read  = 0x%8.8x\n", value );

        // massive register usage
        uint32_t      numLoops = 10;
        static bool_t massive  = FALSE;
        if ( massive )
        {
            numLoops = 1000000;

            uint32_t ledMask = 0;
            bool_t   rv      = TRUE;
            do
            {
                ledMask++;
                ledMask &= ledMaskALL;
#ifdef REGISTER_BY_NAME
                rv = ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_DATA", ledMask );
#else
                rv = ORKAGD_RegisterU32Write( ledComponents[ 1 ], 0x00000000, ledMask );
#endif
            } while ( ( rv ) && ( --numLoops ) );
        }
        else
        {
            uint32_t ledMask = 0;
            bool_t   rv      = TRUE;
            do
            {
                ledMask = ledMask & ledMaskALL ? ledMask : ORKA_LED_STATUS_YELLOW;
#ifdef REGISTER_BY_NAME
                rv = ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_DATA", ledMask );
#else
                rv = ORKAGD_RegisterU32Write( ledComponents[ 1 ], 0x00000000, ledMask );
#endif
                ledMask <<= 3;
            } while ( ( rv ) && ( --numLoops ) );
        }

#if 0
        numLoops = 10000000;
        uint64_t myVariableHandle = ledComponents[ 0 ]->ipOffset;

        do
        {
            ORKAGD_Axi4LiteBlockMasterPortAddressSetAndStart( orkaIPHandle, myVariableHandle );
            uint32_t test = 0xffddccbb;
            ORKAGD_MemcpyD2H( pTargetFPGA, &test, myVariableHandle, sizeof( test ) );
        } while ( --numLoops );
#endif
        ORKAGD_RegisterU32Write( ledComponents[ 1 ], 0x00000000, 0 );
    }

    bool testRv;
    // testRv = TestMemSmall( pTargetFPGA );
    // printf( "TestMemSmall() = %s\n", testRv ? "Success" : "fail!" );
    testRv = TestMemBig( pTargetFPGA );
    printf( "TestMemBig() = %s\n", testRv ? "Success" : "fail!" );

    // memcpy to device and AXI4 IP start
    printf( "* Testing memory transfer and ORKA Block start\n" );
    uint32_t myTestVar          = 0x00004711;
    uint32_t myStorageOfTestVar = myTestVar;
    //    uint64_t myVariableHandle   = ORKAMM_DevMalloc( sizeof( myTestVar ) );
    //    printf( "VariableHandle(Addr)=0x%" PRIx64 "\n", myVariableHandle );
    //    printf( "myTestVar(before)=0x%8.8x\n", myTestVar );
    //    ORKAGD_MemcpyH2D( pTargetFPGA, myVariableHandle, ( void * ) &myTestVar, sizeof( myTestVar ) );
    //    ORKAGD_Axi4LiteBlockMasterPortAddressSetAndStart( orkaIPHandle, myVariableHandle );

// wie wird in ap2_llp speicher alloziert?
#define NUM_VALS 1000
    int    buffOP0_Snd[ NUM_VALS ];
    int    buffOP0_Rcv[ NUM_VALS ];
    double buffOP1[ NUM_VALS ];
    buffOP0_Snd[ 3 ] = 23;
    uint64_t varOP0  = ORKAMM_DevMalloc( NUM_VALS * sizeof( int ) );
    uint64_t varOP1  = ORKAMM_DevMalloc( NUM_VALS * sizeof( double ) );
    ORKAGD_MemcpyH2D( pTargetFPGA, varOP0, ( void * ) buffOP0_Snd, NUM_VALS * sizeof( int ) );
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) buffOP0_Rcv, varOP0, NUM_VALS * sizeof( int ) );

    ORKAGD_RegisterWriteByName( orkaIPHandle, "ORKAPARAM0", &varOP0 );
    ORKAGD_RegisterWriteByName( orkaIPHandle, "ORKAPARAM1", &varOP1 );
    //    ORKAGD_MemcpyH2D( pTargetFPGA, varOP1, ( void * ) buffOP1, NUM_VALS * sizeof( double ) );
    //    bool_t res_start = ORKAGD_Axi4LiteBlockStart(orkaIPHandle);
    //    bool rv = ORKAGD_Axi4LiteBlockWait( orkaIPHandle );
    //    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) buffOP0, varOP0, NUM_VALS * sizeof( int ) );
    //    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) buffOP1, varOP1, NUM_VALS * sizeof( double ) );
    //    printf( "buffOP0[3]=%i\n", buffOP0[ 3 ] );

    //    bool rv = ORKAGD_Axi4LiteBlockWait( orkaIPHandle );
    //    myTestVar = 0x12345678;
    //    printf( "myTestVar(overwritten)=0x%8.8x\n", myTestVar );
    //    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) &myTestVar, myVariableHandle, sizeof( myTestVar ) );
    //    printf( "myTestVar(after)=0x%8.8x\n", myTestVar );
    //    if ( ( myStorageOfTestVar + 1 ) == myTestVar )
    //    {
    //        printf( "Success!! IP has incremented memory of variable\n" );
    //    }
    //    else
    //    {
    //        printf( "ERROR!!\n" );
    //        printf( "ERROR!! IP's not working correctly - it has NOT incremented memory of variable\n" );
    //        printf( "ERROR!!\n" );
    //    }

    // ARTY Test - end ==============================================
#if 0
    // test varaible 1
    uint32_t myTestVar1        = 0x00001234;
    uint64_t myVariableHandle1 = ORKAMM_DevMalloc( sizeof( myTestVar1 ) );
    printf( "VariableHandle(Addr)=0x%" PRIx64 "\n", myVariableHandle1 );
    printf( "myTestVar(before)=0x%8.8x\n", myTestVar1 );
    ORKAGD_MemcpyH2D( pTargetFPGA, myVariableHandle1, ( void * ) &myTestVar1, sizeof( myTestVar1 ) );
    ORKAGD_Axi4LiteBlockMasterPortAddressSetAndStart( orkaIPHandle, myVariableHandle1 );

    ORKAGD_Axi4LiteBlockWait( orkaIPHandle );
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) &myTestVar1, myVariableHandle1, sizeof( myTestVar1 ) );
    printf( "myTestVar(after)=0x%8.8x\n", myTestVar1 );

    // test varaible 2
    uint32_t myTestVar2 = 0x0000fffe;
    //    uint64_t myVariableHandleDummy = ORKA_DevMalloc( 256 - 4 );
    uint64_t myVariableHandle2 = ORKAMM_DevMalloc( sizeof( myTestVar2 ) );
    printf( "VariableHandle1(Addr)=0x%" PRIx64 "\n", myVariableHandle2 );
    printf( "myTestVar2(before)=0x%8.8x\n", myTestVar2 );
    ORKAGD_MemcpyH2D( pTargetFPGA, myVariableHandle2, ( void * ) &myTestVar2, sizeof( myTestVar2 ) );
    ORKAGD_Axi4LiteBlockMasterPortAddressSetAndStart( orkaIPHandle, myVariableHandle2 );
    ORKAGD_Axi4LiteBlockWait( orkaIPHandle );
    ORKAGD_MemcpyD2H( pTargetFPGA, ( void * ) &myTestVar2, myVariableHandle2, sizeof( myTestVar2 ) );
    printf( "myTestVar2(after)=0x%8.8x\n", myTestVar2 );
#endif
    ORKAGD_FPGAClose( pTargetFPGA );
    ORKAGD_FPGAHandleDestroy( pTargetFPGA );
    ORKAGD_Deinit();
    ORKAMM_DevMemDeInit();
    return 0;
}
