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
#ifndef LIB_ORKAGD_GD_INTERNAL_H__
#define LIB_ORKAGD_GD_INTERNAL_H__

#include "printf.h"
#include "database.h"
#include "vector.h"
#include "types.h"
#include <stdint.h>

#ifdef _MSC_VER
#    define ORKAGD_DIR_SEPERATOR       ( '\\' )
#    define ORKAGD_DIRECTORY_CURRENT   ( ".\\" )
#    define ORKAGD_DIR_SEPERATOR_OTHER ( '/' )
#else
#    define ORKAGD_DIR_SEPERATOR       ( '/' )
#    define ORKAGD_DIRECTORY_CURRENT   ( "./" )
#    define ORKAGD_DIR_SEPERATOR_OTHER ( '\\' )
#    include <linux/ioctl.h>
#endif

#if 0
// human readable value (fixed)
#    define ORKAGD_HRVF( x, e ) ( x >> e )
#    define ORKAGD_HRUF( x, e ) ( e == 1 ? "B" : ( e == 10 ? "kB" : ( e == 20 ? "MB" : ( e == 30 ? "GB" : ( e == 40 ? "TB" : ( e == 50 ? "PB" : "EB" ) ) ) ) ) )
// human readable value
#    define ORKAGD_HRV( x )     ( x < 1024 ? x : x / ( 1024 ) < 1024 ? x / ( 1024 ) : x / ( 1024 * 1024 ) < 1023 ? x / ( 1024 * 1024 ) : x / ( 1024 * 1024 * 1024 ) )
#    define ORKAGD_HRU( x )     ( x < 1024 ? "B" : x / ( 1024 ) < 1024 ? "kB" : x / ( 1024 * 1024 ) < 1024 ? "MB" : "GB" )
#endif

/* ltoh: little to host */
/* htol: little to host */
#if __BYTE_ORDER == __LITTLE_ENDIAN
#    define ltohl( x ) ( x )
#    define ltohs( x ) ( x )
#    define htoll( x ) ( x )
#    define htols( x ) ( x )
#elif __BYTE_ORDER == __BIG_ENDIAN
#    define ltohl( x ) __bswap_32( x )
#    define ltohs( x ) __bswap_16( x )
#    define htoll( x ) __bswap_32( x )
#    define htols( x ) __bswap_16( x )
#endif

#define ORKAGD_COMPONENT_REGISTER_HANDLE_MAGIC ( 0x6f73e4dd )

//#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

// Intel IOCTL
#define ORKAGD_FPGA_DEBUG_PRINT_ROM                     _IO( 'q', 1 )
#define ORKAGD_FPGA_DISABLE_UPSTREAM_AER                _IO( 'q', 2 )
#define ORKAGD_FPGA_ENABLE_UPSTREAM_AER                 _IO( 'q', 3 )
#define ORKAGD_FPGA_INITIATE_PR                         _IOW( 'q', 4, pr_arg_t * )
#define ORKAGD_FPGA_PR_REGION_CONTROLLER_FREEZE_ENABLE  _IOW( 'q', 5, int * )
#define ORKAGD_FPGA_PR_REGION_CONTROLLER_FREEZE_DISABLE _IOW( 'q', 6, int * )
#define ORKAGD_FPGA_PR_REGION_READ                      _IOR( 'q', 7, ORKAGD_IntelIOCtl_t * )
#define ORKAGD_FPGA_PR_REGION_WRITE                     _IOW( 'q', 8, ORKAGD_IntelIOCtl_t * )

typedef enum
{
    ORKAGD_ACCESSTYPE_UNDEFINED = 0,
    ORKAGD_ACCESSTYPE_XDMA,
    ORKAGD_ACCESSTYPE_IPV4,
    ORKAGD_ACCESSTYPE_INTEL_IOCTL,
} ORKAGD_AccessTypes_t;

typedef struct
{
    char *   name;
    uint64_t typeID;
} ORKAGD_AccessType_t;

typedef struct
{
    char *name;

    // supports XDMA from Xilinx
    ORKAGD_AccessTypes_t accessType;

    char *controlAccess;
    char *memcpyd2h;
    char *memcpyh2d;
    char *registerAccess;
} ORKAGD_TranslatorDriver_t;

typedef struct
{
    char *ipType;
    char *ipAddress;
    char *ipSubType;
    char *ipAccess;
} ORKAGD_TranslatorComponent_t;

typedef struct
{
    char *            manufacturer;
    ORKAVEC_Vector_t *drivers;    // ORKAGD_TranslatorDriver_t
    ORKAVEC_Vector_t *components; // ORKAGD_TranslatorComponent_t
} ORKAGD_TranslatorManufacturerBoard_t;

typedef struct
{
    char *   manufacturerName;
    uint64_t manufacturerID;
    char *   fullNameQualifier;
    char *   shortName;
    char *   category;
    char *   family;
    char *   package;
    char *   speedgrade;
    char *   temperature;
} ORKAGD_FPGADescription_t;

typedef struct
{
    uint64_t m_MemoryStartAddress;
    uint64_t m_MemorySize;
} ORKAGD_MemoryRegion_t;

typedef struct
{
    void *   m_BistreamData;
    uint64_t m_BitstreamSize;
} ORKAGD_BitstreamRegion_t;

typedef enum
{
    ORKAGD_INTERFACE_TYPE_UNDEFINED = 0,
    ORKAGD_INTERFACE_TYPE_PCIE,
    ORKAGD_INTERFACE_TYPE_IPV4,
    ORKAGD_INTERFACE_TYPE_IPV6,
    ORKAGD_INTERFACE_TYPE_UART,
    ORKAGD_INTERFACE_TYPE_USB,
} ORKAGD_InterfaceType_t;

typedef struct
{
    ORKAGD_InterfaceType_t m_type;

    void *m_RegisterMapBase;
    char *m_DeviceDMAReadName;
    char *m_DeviceDMAWriteName;
    char *m_DevicePCIConfigName;
    char *m_DeviceMemoryMappedIOName;
    int   m_DeviceDMAReadHandle;
    int   m_DeviceDMAWriteHandle;
    int   m_DevicePCIConfigHandle;
    int   m_DeviceMemoryMappedIOHandle;

    uint64_t m_mmioSize;
} ORKAGD_BOARD_Interface_PCIE_t;

typedef struct
{
    ORKAGD_InterfaceType_t m_type;

    char *   m_ipv4Address;
    uint64_t m_ipv4Port;
    uint64_t m_ipv4Speed;

} ORKAGD_BOARD_Interface_IPV4_t;

typedef union
{
    ORKAGD_BOARD_Interface_PCIE_t m_PCIe;
} ORKAGD_BOARD_FPGA_InterfaceHandle_t;

typedef struct ORKAGD_TargetFPGA_tag  ORKAGD_TargetFPGA_t;
typedef struct ORKAGD_TargetsList_tag ORKAGD_TargetsList_t;

typedef struct
{
    char *                               m_Comment;
    char *                               m_InfrastructureName;
    char *                               m_BoardName;
    char *                               m_BlockDesignName;
    char *                               m_ManufacturerBoard;
    ORKADB_TableHandle_t *               m_TableDrivers;
    ORKAGD_BOARD_FPGA_InterfaceHandle_t *m_InterfaceHandle;
    uint32_t                             m_FPGACount;
    ORKAGD_TargetFPGA_t *                m_TargetFPGAs;
} ORKAGD_DBG_TargetBoard_t;

struct ORKAGD_TargetsList_tag
{
    ORKAGD_DBG_TargetBoard_t *m_TargetBoard;
    ORKAGD_TargetsList_t *    m_TargetsList;
};

typedef struct
{
    ORKADB_DBHandle_t *   dataBase;
    ORKADB_TableHandle_t *tableBoard;
    ORKADB_FieldHandle_t *fieldComment;
    ORKADB_FieldHandle_t *fieldInfrastructureName;
    ORKADB_FieldHandle_t *fieldBoardName;
    ORKADB_FieldHandle_t *fieldBlockDesignName;
    ORKADB_FieldHandle_t *fieldManufacturerBoard;
    ORKADB_FieldHandle_t *fieldManufacturerDrivers;
    ORKADB_FieldHandle_t *fieldManufacturerFPGAs;
    ORKADB_FieldHandle_t *fieldPCIeBars;
    ORKADB_TableHandle_t *tableFPGAs;
    ORKADB_TableHandle_t *tableDrivers;
    ORKADB_TableHandle_t *tablePCIeBars;
    ORKADB_FieldHandle_t *fieldPCIeBarType;
    ORKADB_FieldHandle_t *fieldPCIeBarSize;
    ORKAVEC_Vector_t *    recordList;
    ORKAVEC_Iter_t *      iter;
    void *                recordCurrent;
    void *                recordNext;
} ORKAGD_TargetBoardList;

#include "liborkagd.h"

typedef struct
{
    ORKADB_RecordHandle_t * recordFPGA;
    ORKAGD_TargetBoardList *board;
    ORKADB_FieldHandle_t *  fieldDriverParamsDriverName;
    ORKADB_FieldHandle_t *  fieldDriverParamsInstance;
    ORKADB_FieldHandle_t *  fieldDriverParamsPort;
    ORKADB_FieldHandle_t *  fieldDriverParamsSpeed;
    ORKADB_FieldHandle_t *  fieldDriverParamsAddress;

    ORKADB_TableHandle_t *tableFPGAs;
    ORKADB_FieldHandle_t *fieldFullNameQualifier;
    ORKADB_FieldHandle_t *fieldDriver;
    ORKADB_FieldHandle_t *fieldComponents;
    ORKADB_FieldHandle_t *fieldMemoryRegions;

    ORKADB_TableHandle_t *tableComponents;
    ORKADB_FieldHandle_t *fieldComponentsName;
    ORKADB_FieldHandle_t *fieldComponentsOffset;
    ORKADB_FieldHandle_t *fieldComponentsRange;
    ORKADB_FieldHandle_t *fieldComponentsType;
    ORKADB_FieldHandle_t *fieldComponentsIpAddress;
    ORKADB_FieldHandle_t *fieldComponentsSubType;
    ORKADB_FieldHandle_t *fieldComponentsIpAccess;
    ORKADB_FieldHandle_t *fieldComponentsRegisters;

    ORKADB_TableHandle_t *tableMemoryRegions;
    ORKADB_FieldHandle_t *fieldMemoryRegionsOffset;

    ORKAGD_FPGADescription_t * fpgaDescriprion;
    uint64_t                   driverIndex;
    ORKAGD_TranslatorDriver_t *fpgaDriver;

    //    ORKAVEC_Vector_t *interfaces;
    ORKAGD_AccessTypes_t          interfaceAccessType;
    ORKAGD_BOARD_Interface_PCIE_t interfacePCIe;
    ORKAGD_BOARD_Interface_IPV4_t interfaceIPv4;

    uint64_t mmioSize;
    uint64_t memcpyOffset;

    uint64_t                componentArrayNumEntries;
    ORKAGD_FPGAComponent_t *componentArrayData; // external definition
    char *                  infrastructureName;
} ORKAGD_FPGAHandle_t;

typedef struct
{
    int32_t offset;
    int32_t data;
} ORKAGD_IntelIOCtl_t;
#endif
