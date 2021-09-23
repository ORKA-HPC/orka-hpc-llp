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
// matrixMul header
#include "mm.h"
#include "mm.cpp"

// Generic driver header
#include "liborkagd.h"

// Project specific types
#include "types.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <inttypes.h>

#define ORKA_DBG_PRINTF( ... ) printf(" - " __VA_ARGS__ )

#define MEMORY_ALIGN               ( 0x0010 )
#define MEMORY_ALIGNED_SIZE( x )   ((( x ) + MEMORY_ALIGN - 1 ) & ( ~( MEMORY_ALIGN - 1 )))

typedef float32_t                  MatType_t;
#define MAT_MEMORY_SIZE            ( MEMORY_ALIGNED_SIZE( MAT_SIZE_N * MAT_SIZE_N * sizeof( MatType_t )))
#define MAT_MEMORY_SIZE_ALL        ( 3 * MAT_MEMORY_SIZE )
#define MAT_MEMORY_SIZE_INPUT      ( 2 * MAT_MEMORY_SIZE )
#define MAT_MEMORY_SIZE_OUTPUT     MAT_MEMORY_SIZE_ALL

#define MAT_MEMORY_ADDR_A          ( 0 * MAT_MEMORY_SIZE )
#define MAT_MEMORY_ADDR_B          ( 1 * MAT_MEMORY_SIZE )
#define MAT_MEMORY_ADDR_C          ( 2 * MAT_MEMORY_SIZE )

#define OUTPUT_CLEAR_PATTERN       ( 0x00 )


int8_t g_FailureMatrix = -1;
float32_t *g_FailureAddressG = NULL;
float32_t *g_FailureAddressF = NULL;
uint32_t g_FailureAddressX = 0;
uint32_t g_FailureAddressY = 0;
float32_t g_FailureValueG = 0.0f;
float32_t g_FailureValueF = 0.0f;

// destinction
#ifdef _MSC_VER
#include <Windows.h>

#define CLOCK_MONOTONIC (0)
LARGE_INTEGER
getFILETIMEoffset()
{
    SYSTEMTIME s;
    FILETIME f;
    LARGE_INTEGER t;

    s.wYear = 1970;
    s.wMonth = 1;
    s.wDay = 1;
    s.wHour = 0;
    s.wMinute = 0;
    s.wSecond = 0;
    s.wMilliseconds = 0;
    SystemTimeToFileTime( &s, &f );
    t.QuadPart = f.dwHighDateTime;
    t.QuadPart <<= 32;
    t.QuadPart |= f.dwLowDateTime;
    return ( t );
}

int
clock_gettime( int X, struct timespec *ts )
{
    LARGE_INTEGER           t;
    FILETIME                f;
    double                  microseconds;
    static LARGE_INTEGER    offset;
    static double           frequencyToMicroseconds;
    static int              initialized = 0;
    static BOOL             usePerformanceCounter = 0;
    struct timeval          *tv = ( struct timeval * )ts;

    if ( !initialized )
    {
        LARGE_INTEGER performanceFrequency;
        initialized = 1;
        usePerformanceCounter = QueryPerformanceFrequency( &performanceFrequency );
        if ( usePerformanceCounter )
        {
            QueryPerformanceCounter( &offset );
            frequencyToMicroseconds = ( double ) performanceFrequency.QuadPart / 1000000.;
        }
        else
        {
            offset = getFILETIMEoffset();
            frequencyToMicroseconds = 10.;
        }
    }
    if ( usePerformanceCounter ) QueryPerformanceCounter( &t );
    else
    {
        GetSystemTimeAsFileTime( &f );
        t.QuadPart = f.dwHighDateTime;
        t.QuadPart <<= 32;
        t.QuadPart |= f.dwLowDateTime;
    }

    t.QuadPart -= offset.QuadPart;
    microseconds = ( double ) t.QuadPart / frequencyToMicroseconds;
    t.QuadPart = (LONGLONG) microseconds;
    tv->tv_sec = ( long )( t.QuadPart / 1000000 );
    tv->tv_usec = t.QuadPart % 1000000;
    return ( 0 );
}
#endif

void *
ORKAAUX_StartCode(
    const char *infrastructureGUID,
    const char *configFileSearchPath,
    const char *bitstreamSearchPath,
    const char *pathnameTempWrite )
{
    void *TargetFPGA = NULL;
    srand( 123 );

    ORKAGD_EC_t rc = ORKAGD_Init( configFileSearchPath, bitstreamSearchPath, pathnameTempWrite );    // expensive call
    if ( !rc )  // success?
    {
        ORKAGD_ConfigTarget_t targetConfig;
        memset( &targetConfig, 0x00, sizeof( ORKAGD_ConfigTarget_t ) );
        targetConfig.m_InfrastructureFilename = ( char * )infrastructureGUID;
        ORKA_DBG_PRINTF( "TargetList about to open\n" );
        void *target = ORKAGD_BoardListOpen( &targetConfig ); // expensive call

        size_t targetCounter = 0;
        while (( ORKAGD_BoardListRead( target )))
        {
            ORKA_DBG_PRINTF( "Target#%zd:\n", targetCounter );
            ORKA_DBG_PRINTF( "Board: Name: %s\n", ORKAGD_BoardGetName( target ) );
            ORKA_DBG_PRINTF( "Board: Comment: %s\n", ORKAGD_BoardGetComment( target ) );
            ORKA_DBG_PRINTF( "Board: Manufacturer: %s\n", ORKAGD_BoardGetManufacturerName( target ));
            size_t numFPGAs = ORKAGD_BoardGetNumFPGAs( target );
            ORKA_DBG_PRINTF( "Board: NumFPGAs: %zd\n", numFPGAs );
            size_t i;
            size_t j;
            // all FPGAs of the board
            for ( i = 0; i < numFPGAs; ++i )
            {
                void *pTargetFPGA = ORKAGD_FPGAHandleCreate( target, i ); // expensive call
                ORKA_DBG_PRINTF( "FPGA#%3zd\n", i );
                ORKA_DBG_PRINTF( "FPGA#%3zd: FullNameQualifier: %s\n", i, ORKAGD_FPGAGetFullNameQualifier( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Manufacturer: %s\n", i, ORKAGD_FPGAGetManufacturer( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Category: %s\n", i, ORKAGD_FPGAGetCategory( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Family: %s\n", i, ORKAGD_FPGAGetFamily( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Package: %s\n", i, ORKAGD_FPGAGetPackage( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Speed: %s\n", i, ORKAGD_FPGAGetSpeed( pTargetFPGA ) );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Temperature: %s\n", i, ORKAGD_FPGAGetTemperature( pTargetFPGA ) );
                size_t numFPGAMemoryRegions = ORKAGD_FPGAGetComponentCount( pTargetFPGA, "memory" );
                ORKA_DBG_PRINTF( "FPGA#%3zd: MemoryRegionCount: %zd\n", i, numFPGAMemoryRegions );
                for ( j = 0; j < numFPGAMemoryRegions; ++j )
                {
                    uint64_t addr = ORKAGD_FPGAGetMemoryRegionAddress( pTargetFPGA, "memory", j );
                    uint64_t size = ORKAGD_FPGAGetMemoryRegionSize( pTargetFPGA, "memory", j );
                    ORKA_DBG_PRINTF( "FPGA#%3zd: MemoryRegion#%2zd: 0x%16.16llx [ %lld%s ]\n",
                        i,
                        j,
                        ( long long unsigned int ) addr,
                        ( long long unsigned int ) ORKAGD_HRV( size ),
                        ORKAGD_HRU( size ) );
                }
                ORKA_DBG_PRINTF( "FPGA#%3zd: BitstreamRegionCount: %zd\n", i, ORKAGD_FPGAGetBitstreamRegionCount( pTargetFPGA ));
                char *infrastructure = ORKAGD_FPGAGetInfrastructureName( pTargetFPGA );
                ORKA_DBG_PRINTF( "FPGA#%3zd: Infrastructure: %s\n", i, infrastructure );
                if ( 0 == strcmp( infrastructureGUID, infrastructure ) )
                {
                    ORKA_DBG_PRINTF( "FPGA#%3zd: used target!!!\n", i );
                    TargetFPGA = pTargetFPGA;
                }
                else
                {
                    // clean up if not used
                    ORKAGD_FPGAHandleDestroy( target );
                }
            }
            targetCounter++;
        }
        ORKAGD_BoardListClose( target );
    }
    return TargetFPGA;
}

void
ORKAAUX_EndCode()
{
    ORKAGD_Deinit( );
}

#if 0
void ORKAAUX_GetBitstreamForTarget(
    ORKAGD_TargetFPGA_t *pTargetFPGA, // unused here, demo
    void **ppBitstream,
    uint64_t *pBitstreamSize )
{
    pTargetFPGA = pTargetFPGA;  // dummy, remove compiler warning
    // fill up some memory to simulate bitstream from HLS
    if ( ppBitstream )
    {
        *pBitstreamSize = ( uint64_t ) rand( ) * 10 + 1000000;
        *ppBitstream = malloc( ( size_t )*pBitstreamSize );
    }
}

void ORKAAUX_SetBitstreamForTarget(
    ORKAGD_TargetFPGA_t *pTargetFPGA,
    uint32_t region )
{
    void *ppBitstream;
    uint64_t pBitstreamSize;

    ORKAAUX_GetBitstreamForTarget(
        pTargetFPGA,
        &ppBitstream,
        &pBitstreamSize );

    if ( pTargetFPGA )
    {
        if ( region < pTargetFPGA->m_BitstreamRegionCount )
        {
            if ( pTargetFPGA->m_BitstreamRegions[ region ].m_BistreamData )
            {
                // already occupied
                free( pTargetFPGA->m_BitstreamRegions[ region ].m_BistreamData );
            }
            pTargetFPGA->m_BitstreamRegions[ region ].m_BitstreamSize = pBitstreamSize;
            pTargetFPGA->m_BitstreamRegions[ region ].m_BistreamData = ppBitstream;
        }
    }
}
#endif

#if 0
// Compiler-Internal- and ORKAGD-Lib-Calls

#define ORKAGD_PRAGMA_OMP_INIT( board )   \
    ORKAAUX_StartCode( board, &CompilerTargetFPGA );
#define ORKAGD_PRAGMA_OMP_DEINIT          \
    ORKAAUX_EndCode();
#define ORKAGD_PRAGMA_OMP_ACCELERATOR_LOAD( region )   \
    ORKAAUX_SetBitstreamForTarget( CompilerTargetFPGA, region );

ORKAGD_PRAGMA_OMP_INIT( "Xilinx VCU118 Board" )
ORKAGD_PRAGMA_OMP_ACCELERATOR_LOAD( 0 );
ORKAGD_PRAGMA_OMP_ACCELERATOR_LOAD( 1 );
ORKAGD_PRAGMA_OMP_ACCELERATOR_LOAD( 0 );
ORKAGD_PRAGMA_OMP_DEINIT
#endif

float32_t
RandFloat32(
    float32_t min,
    float32_t max )
{
    const int r = rand();
    const float32_t rand = ( float32_t ) r;
    const float32_t diff = max - min;
    const float32_t randMax = ( float32_t ) RAND_MAX;
    const float32_t diffRandMax = diff / randMax;
    const float32_t result = min + rand * diffRandMax;
    return result;
}

#if 0


float32_t cacheRow[ MAT_SIZE_N ];
float32_t matrixBCache[ MAT_SIZE_N * MAT_SIZE_N ];

void
MatrixMul( float32_t *matrix )
{
    float32_t *matrixA = &matrix[ 0 * MAT_SIZE_N * MAT_SIZE_N ];
    float32_t *matrixB = &matrix[ 1 * MAT_SIZE_N * MAT_SIZE_N ];
    float32_t *matrixC = &matrix[ 2 * MAT_SIZE_N * MAT_SIZE_N ];

    printf( "MatrixMul: MatrixA: 0x%p\n", matrixA );
    printf( "MatrixMul: MatrixB: 0x%p\n", matrixB );
    printf( "MatrixMul: MatrixC: 0x%p\n", matrixC );

Row:
    for ( uint16_t i = 0; i < MAT_SIZE_N; ++i )
    {
Col:
        for ( uint16_t j = 0; j < MAT_SIZE_N; ++j )
        {
            float32_t akku = 0.0f;
            if ( 0 == j )
            {
RowCache:
                for ( uint16_t k = 0; k < MAT_SIZE_N; ++k )
                {
                    cacheRow[ k ] = matrixA[ i * MAT_SIZE_N + k ];
                }
            }

            if ( 0 == i )
            {
ColCache:
                for ( uint16_t k = 0; k < MAT_SIZE_N; ++k )
                {
                    matrixBCache[ k * MAT_SIZE_N + j ] = matrixB[ k * MAT_SIZE_N + j ];
                }
            }

MatMul:
            for ( uint16_t k = 0; k < MAT_SIZE_N; ++k )
            {
                akku += cacheRow[ k ] * matrixBCache[ k * MAT_SIZE_N + j ];
            }
            matrixC[ i * MAT_SIZE_N + j ] = akku;
        }
    }
}
#endif

void
DataCreateGoldenSample(
    void *pInputDataMem,
    uint64_t sizeMat )
{
    uint8_t *matAddrAByte = ( uint8_t * ) pInputDataMem;
    float32_t *component = NULL;

    // InputMatrixA
    component = ( float32_t * ) ( &matAddrAByte[ MAT_MEMORY_ADDR_A ] );
    printf( "MatrixA: 0x%p\n", component );
    for ( uint32_t y = 0; y < sizeMat; ++y )
    {
        for ( uint32_t x = 0; x < sizeMat; ++x )
        {
            *component++ = RandFloat32( 0.0f, 1.0f );
        }
    }

    // InputMatrixB
    component = ( float32_t * ) ( &matAddrAByte[ MAT_MEMORY_ADDR_B ] );
    printf( "MatrixB: 0x%p\n", component );
    for ( uint32_t y = 0; y < sizeMat; ++y )
    {
        for ( uint32_t x = 0; x < sizeMat; ++x )
        {
            *component++ = RandFloat32( 0.0f, 1.0f );
        }
    }

    // ResultMatrix
    component = ( float32_t * ) ( &matAddrAByte[ MAT_MEMORY_ADDR_C ] );
    printf( "MatrixC: 0x%p\n", component );
    for ( uint32_t y = 0; y < sizeMat; ++y )
    {
        for ( uint32_t x = 0; x < sizeMat; ++x )
        {
            *component++ = 0.0f;
        }
    }

    float32_t *matrices = ( float32_t * ) ( pInputDataMem );
    struct timespec tstart={0,0}, tend={0,0};
    clock_gettime( CLOCK_MONOTONIC, &tstart);
    MatrixMul( matrices );
    clock_gettime(CLOCK_MONOTONIC, &tend);
    printf("==> CPU-Calculation took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
}

bool_t
DataCompareFloat32(
    const float32_t a,
    const float32_t b,
    const float32_t eps )
{
    bool_t rv = FALSE;
    const float32_t d = fabsf( a - b );
    if ( d <= eps )
    {
        rv = TRUE;
    }
    return rv;
}

bool_t
DataCompareResults(
    float32_t *goldenSampleData,
    float32_t *fpgaData,
    uint64_t sizeMat,
    float32_t eps )
{
    bool_t rv = TRUE;
    uint8_t *matAddrAByteG = ( uint8_t * ) goldenSampleData;
    uint8_t *matAddrAByteF = ( uint8_t * ) fpgaData;
    float32_t *componentG = NULL;
    float32_t *componentF = NULL;

    printf( "DataCompareResults: eps = %0.7f\n", eps );

    do
    {
        // InputMatrix
        componentG = ( float32_t * ) ( &matAddrAByteG[ MAT_MEMORY_ADDR_A ] );
        componentF = ( float32_t * ) ( &matAddrAByteF[ MAT_MEMORY_ADDR_A ] );
        printf( "DataCompareResults: MatrixA(G): 0x%p\n", componentG );
        printf( "DataCompareResults: MatrixA(F): 0x%p\n", componentF );
        for ( uint32_t y = 0; rv && ( y < sizeMat ); ++y )
        {
            for ( uint32_t x = 0; rv && ( x < sizeMat ); ++x )
            {
                if ( !DataCompareFloat32( *componentG, *componentF, eps ) )
                {
                    if ( rv )
                    {
                        rv = FALSE;
                        g_FailureAddressX = x;
                        g_FailureAddressY = y;
                        g_FailureAddressG = componentG;
                        g_FailureAddressF = componentF;
                        g_FailureValueG = *componentG;
                        g_FailureValueF = *componentF;
                        g_FailureMatrix = 0;
                    }
                }
                componentG++;
                componentF++;
            }
        }

        if ( !rv )
        {
            break;
        }

        // OutputMatrix
        componentG = ( float32_t * ) ( &matAddrAByteG[ MAT_MEMORY_ADDR_B ] );
        componentF = ( float32_t * ) ( &matAddrAByteF[ MAT_MEMORY_ADDR_B ] );
        printf( "DataCompareResults: MatrixB(G): 0x%p\n", componentG );
        printf( "DataCompareResults: MatrixB(F): 0x%p\n", componentF );
        for ( uint32_t y = 0; rv && ( y < sizeMat ); ++y )
        {
            for ( uint32_t x = 0; rv && ( x < sizeMat ); ++x )
            {
                if ( !DataCompareFloat32( *componentG, *componentF, eps ) )
                {
                    if ( rv )
                    {
                        rv = FALSE;
                        g_FailureAddressX = x;
                        g_FailureAddressY = y;
                        g_FailureAddressG = componentG;
                        g_FailureAddressF = componentF;
                        g_FailureValueG = *componentG;
                        g_FailureValueF = *componentF;
                        g_FailureMatrix = 1;
                    }
                }
                componentG++;
                componentF++;
            }
        }

        if ( !rv )
        {
            break;
        }

        // ResultMatrix
        componentG = ( float32_t * ) ( &matAddrAByteG[ MAT_MEMORY_ADDR_C ] );
        componentF = ( float32_t * ) ( &matAddrAByteF[ MAT_MEMORY_ADDR_C ] );
        printf( "DataCompareResults: MatrixC(G): 0x%p\n", componentG );
        printf( "DataCompareResults: MatrixC(F): 0x%p\n", componentF );
        for ( uint32_t y = 0; rv && ( y < sizeMat ); ++y )
        {
            for ( uint32_t x = 0; rv && ( x < sizeMat ); ++x )
            {
                if ( !DataCompareFloat32( *componentG, *componentF, eps ) )
                {
                    if ( rv )
                    {
                        rv = FALSE;
                        g_FailureAddressX = x;
                        g_FailureAddressY = y;
                        g_FailureAddressG = componentG;
                        g_FailureAddressF = componentF;
                        g_FailureValueG = *componentG;
                        g_FailureValueF = *componentF;
                        g_FailureMatrix = 2;
                    }
                }
                componentG++;
                componentF++;
            }
        }
    } while ( 0 );

    return rv;
}

void
DumpMemX32(
    uint32_t *p,
    uint64_t size,
    uint16_t width )
{
    uint32_t *a = p;
    for ( uint16_t i = 0; i < size; i += width )
    {
        ORKA_DBG_PRINTF( "0x%p: ", a );
        for ( uint16_t j = i; ( j < i + width ) && ( j < size ); ++j )
        {
            printf( "%8.8x ", *a++ );
        }
        printf( "\n" );
    }
}

void
DumpMemF32(
    float32_t *p,
    uint64_t size,
    uint16_t width )
{
    float32_t *a = p;
    for ( uint16_t i = 0; i < size; i += width )
    {
        ORKA_DBG_PRINTF( "0x%p: ", a );
        for ( uint16_t j = i; ( j < i + width ) && ( j < size ); ++j )
        {
            printf( "%+.8f ", *a++ );
        }
        printf( "\n" );
    }
}


int
main( int argc, char **argv )
{
    // Sample code to communicate with FPGAs
    struct timespec tstart = { 0,0 }, tend = { 0,0 };
    char *configFilename = "92305916-5c48-4c87-9343-d2c91fad97e1.json";
    char *configFileSearchPath = "./";
    char *bitstreamSearchPath = configFileSearchPath;
    void *pTargetFPGA;
    bool_t CopyToFPGA = TRUE;
    bool_t uploadBitstreamTrigger = FALSE;

    const uint64_t version = ORKAGD_VersionNumber();
    printf( "ORKAGD Version: %s (%d.%2.2d.%5.5d)\n",
            ORKAGD_VersionString(),
            ( ( uint32_t ) ( ( version >> 32 ) & 0x0000000000000fffULL ) ),
            ( ( uint32_t ) ( ( version >> 16 ) & 0x000000000000ffffULL ) ),
            ( ( uint32_t ) ( ( version >> 0 ) & 0x000000000000ffffULL ) ) );

    switch ( argc )
    {
        case 0:
        case 1:
            break;
        default:
            for ( int i = 1; i < argc; ++i )
            {
                printf( "Parameter given: %s\n", argv[ i ] );
                if ( ( '-' == argv[ i ][ 0 ] ) ||
                    ( '/' == argv[ i ][ 0 ] ) )
                {
                    switch ( argv[ i ][ 1 ] )
                    {
                        case 'h':
                            printf( "Help:\n" );
                            printf( "-h: this text\n " );
                            printf( "-n: omit clearing memory\n" );
                            printf( "-c: provide configuration filename (without path)\n" );
                            printf( "-p: provide root of search tree for configurations and bitstreams\n" );
                            printf( "-u: trigger upload of infrastructure bitstream\n" );
                            break;

                        case 'n':
                            printf( "* no initial memcopy ...\n" );
                            CopyToFPGA = FALSE;
                            break;

                        case 'c':
                            if ( ( i + 1 ) < argc )
                            {
                                configFilename = argv[ i + 1 ];
                                printf( "* target bitstream config: %s\n", configFilename );
                                i++;
                            }
                            break;

                        case 'p':
                            if ( ( i + 1 ) < argc )
                            {
                                configFileSearchPath = argv[ i + 1 ];
                                printf( "* config file search path: %s\n", configFileSearchPath );
                                i++;
                            }
                            break;

                        case 'u':
                            printf( "* Bitstream upload triggered\n" );
                            uploadBitstreamTrigger = TRUE;
                            break;

                        default:
                            printf( "Unsupported paramter: %s\n", argv[ i ] );
                            break;
                    }
                }

            }
            break;
    }
    if ( !configFilename )
    {
        printf( "Error: No config file mentioned: Use '-c <ConfigFileName>.json'\n" );
        printf( "Exiting ...\n" );
        exit( 1 );
    }


    // =====================================================
    //
    // initialize
    //
    // =====================================================
    // get target

    printf( "Stage0 - Find board/fpga: %s [%s, %s]\n",
            configFilename,
            configFileSearchPath,
            bitstreamSearchPath );
    pTargetFPGA = ORKAAUX_StartCode(
        configFilename,
        configFileSearchPath,
        bitstreamSearchPath,
        "/tmp" );

    if ( !pTargetFPGA )
    {
        printf( "Error: Cannot find target board or FPGA! Are paths to config files valid?\n" );
        exit( -999 );
    }

    const char *componentTypes [] =
    {
        "memory",
        "gpio",
        "sysmgmt",
        "intc",
        "orkaip",
    };

    uint64_t memoryFPGAStart = 0ULL;
    uint64_t memoryFPGASize = 0ULL;
    uint64_t orkaBaseMemoryWorkingAddresses[ 16 ];
    size_t orkaBaseMemoryWorkingAddressesCount = 0;
    const ORKAGD_FPGAComponent_t *orkaIPHandle = NULL;
    uint64_t numComponents = ORKAGD_FPGAComponentsGetNumOf( pTargetFPGA );
    printf( "Examine %" PRId64 " components:\n", numComponents );
    for ( uint64_t i = 0; i < numComponents; ++i )
    {
        const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( pTargetFPGA, i );
        if ( !compEntry )
        {
            printf( "ERROR! Something internal wrong !!!\n" );
            break;
        }
        printf( "Component#%" PRId64 ": %s\n", i, compEntry->ipType );
        size_t j;
        bool_t found = FALSE;
        for ( j = 0; j < sizeof( componentTypes ); ++j )
        {
            if ( compEntry->ipType )
            {
                if ( 0 == strcmp( componentTypes[ j ], compEntry->ipType ) )
                {
                    found = TRUE;
                    break;
                }
            }
            else
            {
                printf( "Error: Something went wrong: ipType not set. Check %s file!\n", configFilename );
                break;
            }
        }
        if ( found )
        {
            printf( " - ipDesignComponentName:         %s\n", compEntry->ipDesignComponentName );
            printf( " - ipType:                        %s\n", compEntry->ipType );
            printf( " - ipSubType:                     %s\n", compEntry->ipSubType );
            printf( " - ipAccess:                      %s\n", compEntry->ipAccess );
            printf( " - ipDesignComponentTemplateName: %s\n", compEntry->ipDesignComponentTemplateName );
            printf( " - ipBitstream:                   %s\n", compEntry->ipBitstream );
            printf( " - ipOffset:                      0x%16.16" PRIx64 "\n", compEntry->ipOffset );
            printf( " - ipRange:                       0x%16.16" PRIx64 "\n", compEntry->ipRange );
            switch ( j )
            {
                default:
                    printf( "Component not used: %s\n", compEntry->ipDesignComponentName );
                    printf( "Error: Component not defined\n" );
                    break;
                case 0:
                {
                    static bool_t init = FALSE;
                    if ( !init )
                    {
                        init = TRUE;

                        memoryFPGAStart = compEntry->ipOffset;
                        memoryFPGASize = compEntry->ipRange;
                    }
                }
                break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    if ( 0 == strcmp( "memcpy", compEntry->ipAccess ) )
                    {
                        printf( " - IPBlockMemoryStartAddress: 0x%" PRIx64 " (offset)\n", compEntry->ipOffset );
                        static bool_t init = FALSE;
                        if ( !init )
                        {
                            orkaBaseMemoryWorkingAddresses[ orkaBaseMemoryWorkingAddressesCount++ ] = compEntry->ipOffset;
                            init = TRUE;
                        }
            }
                    else
                    {
                        if ( 0 == strcmp( "register", compEntry->ipAccess ) )
                        {
                            static bool_t init = FALSE;
                            if ( !init )
                            {
                                printf( " - IPBlockRegisterStartAddress: 0x%p\n", compEntry );
                                orkaIPHandle = compEntry;
                                init = TRUE;
                            }
                        }
                    }
                    break;
        }
    }
}

    ORKA_DBG_PRINTF( "FPGA Memory usage (max values)\n" );
    ORKA_DBG_PRINTF( "Address: 0x%16.16llx-0x%16.16llx [0x%16.16llx Bytes]\n",
        ( long long unsigned int )( memoryFPGAStart ),
        ( long long unsigned int )( memoryFPGAStart + memoryFPGASize - 1 ),
        ( long long unsigned int )( memoryFPGASize ) );

    // generate 'clear' memory
    uint64_t clearDataSize = MAT_MEMORY_SIZE_ALL;
    void *pClearDataMem = malloc(( uint32_t ) clearDataSize );
	
    // generate FPGA input data
    uint64_t inputDataSize = MAT_MEMORY_SIZE_ALL;
    void *pInputDataMem = malloc(( uint32_t ) inputDataSize );
	
    // prepare storage for FPGA output
    uint64_t outputDataSize = MAT_MEMORY_SIZE_ALL;
    void *pOutputDataMem = malloc(( uint32_t ) outputDataSize );
        
    if ( //pBitstream &&
         pInputDataMem &&
         pOutputDataMem &&
         pClearDataMem )
    {
        printf( "Stage1 - Prepare Testcase\n" );
        memset( pClearDataMem, OUTPUT_CLEAR_PATTERN, clearDataSize );
        memset( pInputDataMem, 0x00, inputDataSize );
        memset( pOutputDataMem, 0x00, outputDataSize );
        DataCreateGoldenSample( pInputDataMem, MAT_SIZE_N );

        printf( "Stage2 - OpenFPGA\n" );
        // =====================================================
        //
        // open FPGA
        //
        // =====================================================
        uint32_t rv = ORKAGD_FPGAOpen( pTargetFPGA );
        if ( 0 == rv )
        {
            // =====================================================
            //
            // operate on FPGA
            //
            // =====================================================
            if ( uploadBitstreamTrigger )
            {
                printf( "Stage3 - Upload infrastructure bitstream\n" );
                ORKAGD_FPGABitstreamUploadInfrastructure( pTargetFPGA );
            }
            else
            {
                printf( "Stage3 - No infrastructure bitstream upload desired\n" );
            }

            if ( CopyToFPGA )
            {
                printf( "Stage4 - Clear memory on FPGA\n" );
                // copy input to FPGA
                ORKAGD_MemcpyH2D(
                    pTargetFPGA,                // void *target,
                    memoryFPGAStart,            // uint64_t destDevice,
                    pClearDataMem,              // void *srcHost,
                    clearDataSize );            // uint64_t byteSize );
            }
            else
            {
                printf( "Stage4 - No clear of FPGA memory (switched off by parameter '-n')\n" );
            }

            printf( "Stage5 - Upload input data\n" );
            // copy input to FPGA
            ORKAGD_MemcpyH2D(
                pTargetFPGA,                    // void *target,
                memoryFPGAStart,                // uint64_t destDevice,
                pInputDataMem,                  // void *srcHost,
                MAT_MEMORY_SIZE_INPUT );        // uint64_t byteSize );

            printf( "Stage6 - Downoload input data back from FPGA and dump\n" );
            ORKAGD_MemcpyD2H(
                pTargetFPGA,                    // void *target,
                pOutputDataMem,                 // void *destHost,
                memoryFPGAStart,                // uint64_t srcDevice,
                MAT_MEMORY_SIZE_ALL );          // uint64_t byteSize );

            ORKA_DBG_PRINTF("Memory Dump (after FPGA input data upload) *************\n");
            ORKA_DBG_PRINTF("Dump as 32-bit uint\n" );
            ORKA_DBG_PRINTF("InputMem (MatrixA):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixB):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixC):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixA):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixB):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixC):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("Dump as 32-bit float\n" );
            ORKA_DBG_PRINTF("InputMem (MatrixA):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixB):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixC):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixA):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixB):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixC):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("Check output clear pattern (0x%2.2x)\n", OUTPUT_CLEAR_PATTERN );
            for (int i = MAT_MEMORY_ADDR_C; i < MAT_MEMORY_SIZE_ALL; ++i )
            {
                if ( 0 == ( i & 0xfff))
                {
                    printf(".");
                }
                if ( OUTPUT_CLEAR_PATTERN != (((uint8_t *)pOutputDataMem)[i]))
                {
                    ORKA_DBG_PRINTF("\nFound! Addr=0x%p (%d)\n", &(((uint8_t *)pOutputDataMem)[i]), i);
                    break;
                }
            }
            printf("\n");

#if 1
            printf( "Stage7 - Start IP\n" );
            // start FPGA-Acceleration
            ORKAGD_Axi4LiteBlockStart(
                orkaIPHandle,
                orkaBaseMemoryWorkingAddresses[ 0 ]);

            printf( "Stage8 - Wait for IP\n" );
            // start FPGA-Acceleration
            clock_gettime( CLOCK_MONOTONIC, &tstart);
            ORKAGD_Axi4LiteBlockWait(
                orkaIPHandle );
            clock_gettime(CLOCK_MONOTONIC, &tend);
            ORKA_DBG_PRINTF("==> FPGA-Calculation took about %.5f seconds\n",
                ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
                ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

            printf( "Stage9 - Copy back memory from FPGA\n" );
            // get back output from FPGA
            ORKAGD_MemcpyD2H(
                pTargetFPGA,                    // void *target,
                pOutputDataMem,                 // void *destHost,
                memoryFPGAStart,                // uint64_t srcDevice,
                MAT_MEMORY_SIZE_OUTPUT );       // uint64_t byteSize );

            ORKA_DBG_PRINTF( "First 4 bytes of OutputMem: 0x%8.8x\n", *((uint32_t *)pOutputDataMem ) );
            printf( "\n" );

            ORKA_DBG_PRINTF("Memory Dump (after FPGA IP run) *************\n");
            ORKA_DBG_PRINTF("Dump as 32-bit uint\n" );
            ORKA_DBG_PRINTF("InputMem (MatrixA):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixB):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixC):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixA):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixB):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixC):\n");
            DumpMemX32(( uint32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("Dump as 32-bit float\n" );
            ORKA_DBG_PRINTF("InputMem (MatrixA):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixB):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("InputMem (MatrixC):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pInputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixA):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_A]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixB):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_B]), 32, 8 );
            ORKA_DBG_PRINTF("OutputMem (MatrixC):\n");
            DumpMemF32(( float32_t * ) &(((uint8_t *)pOutputDataMem)[MAT_MEMORY_ADDR_C]), 32, 8 );
            ORKA_DBG_PRINTF("Check output clear pattern (0x%2.2x)\n", OUTPUT_CLEAR_PATTERN );
            for (int i = MAT_MEMORY_ADDR_C; i < MAT_MEMORY_SIZE_ALL; ++i )
            {
                if ( 0 == ( i & 0xfff))
                {
                    printf(".");
                }
                if ( OUTPUT_CLEAR_PATTERN != (((uint8_t *)pOutputDataMem)[i]))
                {
                    ORKA_DBG_PRINTF("\nFound! Addr=0x%p (%d)\n", &(((uint8_t *)pOutputDataMem)[i]), i);
                    break;
                }
            }
            printf("\n");

            printf("======= Comparison GoldenSample against FPGA calculation =========================================\n");

            bool_t compResult = DataCompareResults(
                ( float32_t * ) pInputDataMem,
                ( float32_t * ) pOutputDataMem,
                MAT_SIZE_N,
                0.000001f );
            printf( "Calculation: %s\n", compResult ? "OK" : "Something went wrong!!!!!" );
            if ( !compResult )
            {
                printf( "g_FailureAddressX = %d\n", g_FailureAddressX );
                printf( "g_FailureAddressY = %d\n", g_FailureAddressY );
                printf( "g_FailureAddressG = 0x%p\n", g_FailureAddressG );
                printf( "g_FailureAddressF = 0x%p\n", g_FailureAddressF );
                printf( "g_FailureValueG = %0.7f\n", g_FailureValueG );
                printf( "g_FailureValueF = %0.7f\n", g_FailureValueF );
                printf( "g_FailureMatrix = %d\n", g_FailureMatrix );
                
                printf( "Input:\n" );
                DumpMemX32(( uint32_t * ) g_FailureAddressG, 32, 8 );
                printf( "Output:\n" );
                DumpMemX32(( uint32_t * ) g_FailureAddressF, 32, 8 );
printf("Check output clear pattern\n");
for (int i = MAT_MEMORY_ADDR_C; i < MAT_MEMORY_SIZE_ALL; ++i )
{
if ( 0 == ( i & 0xfff))    printf(".");
    if ( OUTPUT_CLEAR_PATTERN != (((uint8_t *)pOutputDataMem)[i]))
    {
        printf("\nFound difference! Addr=0x%p (%d): 0x%8.8x insted of 0x%8.8x\n", &(((uint8_t *)pOutputDataMem)[i]), i, (((uint8_t *)pOutputDataMem)[i]), OUTPUT_CLEAR_PATTERN );
        break;
    }
}
printf("\n");
            }
#endif
            printf( "Stage9 - Close FPGA\n" );
            ORKAGD_FPGAClose( pTargetFPGA );
        }
    }
    // =====================================================
    //
    // deinitialize
    //
    // =====================================================

    // free up the mem
    printf( "StageX - free mem\n" );
    if ( pClearDataMem )
    {
        printf( "- 1. clear\n" );
        free( pClearDataMem );
    }
    if ( pInputDataMem )
    {
        printf( "- 2. input\n" );
        free( pInputDataMem );
    }
    if ( pOutputDataMem )
    {
        printf( "- 3. output\n" );
        free( pOutputDataMem );
    }
#if 0
    if ( pBitstream )
    {
        printf( "- 4. bitstream\n" );
        free( pBitstream );
    }
#endif
    // deinitialize
    printf( "Stage8 - Close Board\n" );
    ORKAAUX_EndCode();
    return 0;
}
