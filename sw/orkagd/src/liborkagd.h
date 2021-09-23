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
#ifndef LIB_ORKAGD_GD_H__
#define LIB_ORKAGD_GD_H__

#include "types.h"

#include <stdint.h>

// Xilinx ...
// AXILiteS
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x10 : Data signal of axi
//        bit 31~0 - axi[31:0] (Read/Write)
// 0x14 : Data signal of axi
//        bit 31~0 - axi[63:32] (Read/Write)
// 0x18 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)
//#define ORKAGD_AXILITES_ADDR_AP_CTRL  ( 0x00 )
//#define ORKAGD_AXILITES_ADDR_GIE      ( 0x04 )
//#define ORKAGD_AXILITES_ADDR_IER      ( 0x08 )
//#define ORKAGD_AXILITES_ADDR_ISR      ( 0x0c )
//#define ORKAGD_AXILITES_ADDR_AXI_DATA ( 0x10 )
//#define ORKAGD_AXILITES_BITS_AXI_DATA ( 64   )
typedef enum
{
    // offsets from base address
    ORKAGD_AXILITES_AP_CTRL    = 0x00,
    ORKAGD_AXILITES_GIE        = 0x04,
    ORKAGD_AXILITES_IER        = 0x08,
    ORKAGD_AXILITES_ISR        = 0x0c,
    ORKAGD_AXILITES_AXI_DATA   = 0x10,
    ORKAGD_AXILITES_AXI_DATA_L = 0x10,
    ORKAGD_AXILITES_AXI_DATA_H = 0x14,

    // data bus width
    ORKAGD_AXILITES_AXI_DATA_BITS = 64,

    // bit values
    ORKA_AXILITES_BIT_AP_START     = 0,
    ORKA_AXILITES_BIT_AP_DONE      = 1,
    ORKA_AXILITES_BIT_AP_IDLE      = 2,
    ORKA_AXILITES_BIT_AP_READY     = 3,
    ORKA_AXILITES_BIT_AUTO_RESTART = 7,
    ORKA_AXILITES_BIT_GIE          = 0,
    ORKA_AXILITES_BIT_IE_AP_DONE   = 0,
    ORKA_AXILITES_BIT_IE_AP_READY  = 1,
    ORKA_AXILITES_BIT_IS_AP_DONE   = 0,
    ORKA_AXILITES_BIT_IS_AP_READY  = 1,
} ORKA_AXILITE;

typedef enum
{
    // error codes
    ORKAGD_EC_SUCCESS         = 0,
    ORKAGD_EC_OUT_OF_MEMORY   = 1,
    ORKAGD_EC_WRONG_PARAMETER = 2
} ORKAGD_EC_t;

// human readable value (fixed)
#define ORKAGD_HRVF( x, e ) ( x >> e )
#define ORKAGD_HRUF( x, e ) ( e == 1 ? "B" : ( e == 10 ? "kB" : ( e == 20 ? "MB" : ( e == 30 ? "GB" : ( e == 40 ? "TB" : ( e == 50 ? "PB" : "EB" ) ) ) ) ) )
// human readable value
#define ORKAGD_HRV( x ) ( x < 1024 ? x : x / ( 1024 ) < 1024 ? x / ( 1024 ) : x / ( 1024 * 1024 ) < 1023 ? x / ( 1024 * 1024 ) : x / ( 1024 * 1024 * 1024 ) )
#define ORKAGD_HRU( x ) ( x < 1024 ? "B" : x / ( 1024 ) < 1024 ? "kB" : x / ( 1024 * 1024 ) < 1024 ? "MB" : "GB" )

#define ORKAGD_MBYTE ( 1024 * 1024 )

#define ORKA_RegRead32( address, register ) ( *( ( uint32_t * ) ( ( ( uint8_t * ) address ) + register ) ) )

#define ORKA_RegBitRead32( address, register, bitNum ) ( ( *( ( uint32_t * ) ( ( ( uint8_t * ) address ) + register ) ) ) & ( 1 << ( bitNum ) ) )

#define ORKA_RegWrite32( address, register, value )                                   \
    do                                                                                \
    {                                                                                 \
        uint32_t *virtAddr = ( uint32_t * ) ( ( ( uint8_t * ) address ) + register ); \
        *virtAddr          = value;                                                   \
    } while ( 0 )

#define ORKA_RegBitSet32( address, register, bitNum )                                         \
    do                                                                                        \
    {                                                                                         \
        uint32_t *virtAddr = ( uint32_t * ) ( ( ( uint8_t * ) ( address ) ) + ( register ) ); \
        *virtAddr |= 1 << ( bitNum );                                                         \
    } while ( 0 )

#define ORKA_RegBitClr32( address, register, bitNum )                                         \
    do                                                                                        \
    {                                                                                         \
        uint32_t *virtAddr = ( uint32_t * ) ( ( ( uint8_t * ) ( address ) ) + ( register ) ); \
        *virtAddr &= ~( 1 << ( bitNum ) );                                                    \
    } while ( 0 )

#define ORKA_ILLEGAL_VALUE ( ( uint64_t )( ( int64_t )( -1 ) ) )

// external known datastructs
typedef struct
{
    char *m_InfrastructureFilename;
} ORKAGD_ConfigTarget_t;

struct ORKAGD_FPGAComponentRegisterTag_t
{
    char *                            name;
    uint64_t                          offset; // 2nd offset added to base offset (of component) to get effective address
    uint64_t                          bitwidth;
    uint64_t                          absoluteOffset; // offset of component + individual registerOffset
    struct ORKAGD_FPGAComponentTag_t *component;      // back-pointer to get access to belonging IP
};

struct ORKAGD_FPGAComponentTag_t
{
    void *                                    fpgaHandle;                    // handle to access (internal data struct)
    char *                                    ipDesignComponentName;         // name of IP from config
    char *                                    ipType;                        // type name from config
    char *                                    ipSubType;                     // subtype name from config
    char *                                    ipAccess;                      // access type (register/memcpy)
    char *                                    ipDesignComponentTemplateName; // pathname of ip within design
    char *                                    ipBitstream;                   // <GUID.json> filename of bitstream
    struct ORKAGD_FPGAComponentRegisterTag_t *ipRegisterArray;               // here we provide a structured access to registers give with the IP
    uint64_t                                  ipRegisterArraySize;           // number of elements in ipRegisterArray
    uint64_t                                  ipOffset;                      // memory address (or register base address)
    uint64_t                                  ipRange;                       // size of memory block in bytes
};

typedef struct ORKAGD_FPGAComponentTag_t         ORKAGD_FPGAComponent_t;
typedef struct ORKAGD_FPGAComponentRegisterTag_t ORKAGD_FPGAComponentRegister_t;

typedef uint32_t ( *ORKAGD_CallbackOnFinish )( void *pParameterBlackBox );

// initialization/deinitialization
const char *
ORKAGD_VersionString();
const uint64_t
ORKAGD_VersionNumber();
ORKAGD_EC_t
ORKAGD_Init( const char *configFileSearchPath, const char *bitstreamSearchPath, const char *pathnameTempWrite );
void
ORKAGD_Deinit();

// discovering of targets and boards
void *
ORKAGD_BoardListOpen( void *targetConfig );
void
ORKAGD_BoardListClose( void *boardControlHandle );
bool_t
ORKAGD_BoardListRead( void *boardControlHandle );
char *
ORKAGD_BoardGetName( void *boardControlHandle );
char *
ORKAGD_BoardGetComment( void *boardControlHandle );
char *
ORKAGD_BoardGetInfrastructureName( void *boardControlHandle );
char *
ORKAGD_BoardGetManufacturerName( void *boardControlHandle );
uint64_t
ORKAGD_BoardGetNumDrivers( void *boardControlHandle );
uint64_t
ORKAGD_BoardGetNumFPGAs( void *boardControlHandle );

void *
ORKAGD_FPGAHandleCreate( void *boardControlHandle, uint64_t indexFPGA );
void
ORKAGD_FPGAHandleDestroy( void *fpgaHandle );
uint64_t
ORKAGD_FPGAOpen( void *pTargetFPGA );
void
ORKAGD_FPGAClose( void *pTargetFPGA );
char *
ORKAGD_FPGAGetFullNameQualifier( void *fpgaHandle );
char *
ORKAGD_FPGAGetManufacturer( void *fpgaHandle );
char *
ORKAGD_FPGAGetCategory( void *fpgaHandle );
char *
ORKAGD_FPGAGetFamily( void *fpgaHandle );
char *
ORKAGD_FPGAGetPackage( void *fpgaHandle );
char *
ORKAGD_FPGAGetSpeed( void *fpgaHandle );
char *
ORKAGD_FPGAGetTemperature( void *fpgaHandle );
uint64_t
ORKAGD_FPGAGetMMIOSize( void *fpgaHandle );
uint64_t
ORKAGD_FPGAGetComponentCount( void *fpgaHandle, char *identifier );
uint64_t
ORKAGD_FPGAGetMemoryRegionAddress( void *fpgaHandle, const char *identifierMemory, const uint64_t indexMemoryRegion );
uint64_t
ORKAGD_FPGAGetMemoryRegionSize( void *fpgaHandle, const char *identifierMemory, const uint64_t indexMemoryRegion );
uint64_t
ORKAGD_FPGAGetBitstreamRegionCount( void *fpgaHandle );
uint64_t
ORKAGD_FPGAComponentsGetNumOf( void *fpgaHandle );
const ORKAGD_FPGAComponent_t *
ORKAGD_FPGAComponentsGetEntry( void *fpgaHandle, uint64_t index );
char *
ORKAGD_FPGAGetInfrastructureName( void *fpgaHandle );
void
ORKAGD_FPGABitstreamUploadInfrastructure( void *fpgaHandle );

// region 0 is always the infrastructure
// subsequent regions are partial configuration areas
// uint32_t ORKAGD_GetNumRegions( ORKAGD_TargetFPGA_t *target );
// void ORKAGD_BitstreamClean( ORKAGD_TargetFPGA_t *target, uint32_t bitstreamRegionID );
// bool_t ORKAGD_BitstreamUpload( ORKAGD_TargetFPGA_t *target, uint32_t bitstreamRegionID, void *bitstreamData, uint64_t bistreamSize );

// memory copy operations
bool_t
ORKAGD_MemcpyH2D( void *target, const uint64_t dstDevice, const void *srcHost, const uint64_t byteSize );
bool_t
ORKAGD_MemcpyD2H( void *target, void *dstHost, const uint64_t srcDevice, const uint64_t byteSize );

// acceleration block control
bool_t
ORKAGD_Axi4LiteBlockStart( const ORKAGD_FPGAComponent_t *component );

bool_t
ORKAGD_Axi4LiteBlockWait( const ORKAGD_FPGAComponent_t *component );
// uint32_t ORKAGD_AcceleratorBlockWaitWithTimeout( ORKAGD_TargetFPGA_t *target, uint32_t bitstreamRegionID, uint64_t waitUSec );
// void ORKAGD_AcceleratorBlockSetCallbackOnFinish( ORKAGD_TargetFPGA_t *target, uint32_t bitstreamRegionID, ORKAGD_CallbackOnFinish pCallbackFunction, void *pParameterBlackBox );

// DBG
void *
ORKAGD_TcpIPData();

// ===========================================================================================================
// new 2021-01, JSC
// Registers revisited 2021-01-16.
//
// Short abstract (Motivation):
// ----------------------------
//
// Registers are now "named" ...
//
// They are still accessible by their offsets relative to the component IP, but you have to have previous
// knowledge about offsets and bit-width of them. At least with Xilinx they tend to move if IP ports are
// somehow changed (added or removed), so naming them makes the software independent on that.
//
// Realization:
// ------------
//
// The names are provided with the configuration-JSON and may be used here wth the "...ByName" functions.
// To increase usability and performance (string comparisons in string arrays are expensive!) there are
// different accesses in addition possible:
// By name   - Slow method "...ByName" functions.
// By index  - Each register has an internal index which can be read out [ORKAGD_RegisterGetIndexOf()].
//             With this index each register can be accessed by the "...ByIndex" functions.
// By handle - We provide a handle per individual register (over all provided configuration registers).
//             This handle can be gathered with either ORKAGD_RegisterGetHandleByName() or
//             ORKAGD_RegisterGetHandleByIndex() function.
//             Fastest access is given with the "...ByHandle" functions as they have all build in which is
//             needed to do the job. Simply store the handle somewhere and access is possible wherever used.
// ===========================================================================================================

// purly checks existance of name
bool
ORKAGD_RegisterNameExist( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterGetOffsetByName( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterGetOffsetByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx );
uint64_t
ORKAGD_RegisterGetOffsetByHandle( const uint64_t handle );
uint64_t
ORKAGD_RegisterGetBitWidthByName( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterGetBitWidthByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx );
uint64_t
ORKAGD_RegisterGetBitWidthByHandle( const uint64_t handle );
uint64_t
ORKAGD_RegisterGetHandleByName( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterGetHandleByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx );

uint64_t
ORKAGD_RegisterGetNumIndexOf( const ORKAGD_FPGAComponent_t *component );
uint64_t
ORKAGD_RegisterGetIndexOf( const ORKAGD_FPGAComponent_t *component, const char *registerName );

bool
ORKAGD_RegisterWriteByName( const ORKAGD_FPGAComponent_t *component, const char *registerName, const void *value );
bool
ORKAGD_RegisterWriteByNameU32( const ORKAGD_FPGAComponent_t *component, const char *registerName, const uint32_t value );
bool
ORKAGD_RegisterWriteByNameU64( const ORKAGD_FPGAComponent_t *component, const char *registerName, const uint64_t value );
bool
ORKAGD_RegisterWriteByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const void *value );
bool
ORKAGD_RegisterWriteByIndexU32( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint32_t value );
bool
ORKAGD_RegisterWriteByIndexU64( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint64_t value );
bool
ORKAGD_RegisterWriteByHandle( const uint64_t handle, const void *value );
bool
ORKAGD_RegisterWriteByHandleU32( const uint64_t handle, const uint32_t *value );
bool
ORKAGD_RegisterWriteByHandleU64( const uint64_t handle, const uint64_t *value );

uint64_t
ORKAGD_RegisterReadByName( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint32_t
ORKAGD_RegisterReadByNameU32( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterReadByNameU64( const ORKAGD_FPGAComponent_t *component, const char *registerName );
uint64_t
ORKAGD_RegisterReadByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex );
uint32_t
ORKAGD_RegisterReadByIndexU32( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint32_t value );
uint64_t
ORKAGD_RegisterReadByIndexU64( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex );
uint64_t
ORKAGD_RegisterReadByHandle( const uint64_t handle );
uint32_t
ORKAGD_RegisterReadByHandleU32( const uint64_t handle );
uint64_t
ORKAGD_RegisterReadByHandleU64( const uint64_t handle );
// the "..Ex" functions return the value with a pointer ...

// ===========================================================================================
// Attention: gives back a value to the memory location where the pointer points to (*pvalue).
// This can be (dependent on the bitwidth of the register) 4 bytes OR 8 bytes (yet, so far) !
// ===========================================================================================
void
ORKAGD_RegisterReadByHandleEx( const uint64_t handle, void *pValue );
void
ORKAGD_RegisterReadByHandleU32Ex( const uint64_t handle, uint32_t *pValue );
void
ORKAGD_RegisterReadByHandleU64Ex( const uint64_t handle, uint64_t *pValue );

// dedicated register control
bool_t
ORKAGD_RegisterU32Write( const ORKAGD_FPGAComponent_t *component, const uint64_t registerAddress, const uint32_t value );
uint32_t
ORKAGD_RegisterU32Read( const ORKAGD_FPGAComponent_t *component, const uint64_t registerAddress );

#endif
