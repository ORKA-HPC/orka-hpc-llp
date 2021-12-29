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
/**
 *
 *         \file         :     liborkagd.c
 *         \description  :     File contains functions to manage .json config files and
 *                             is responsible for managing access to different FPGA drivers
 *                             for several supported boards.
 *         \author       :     Jesko Schwarzer (initial)
 *         \version      :     V1.12
 *
 * Last changes:
 *                       *     + changed driver section in JSON of board/fpga to support xdma as well as ipv4
 *                             + added ipv4 support in ORKAInterpreter.json
 * todo:
 *                       *     + IRQ support
 *
 */

// =======================================================================================================
//
// 64-bits-Registers-Rule:
// =======================
//
// All functions rely on the assumption that 64-bit registers span two 32-bit
// registers starting with lower 32 of 64 bits at lower address.
// The upper 32 bits of the 64-bit registers are contained at an increment of 4 in the address.
//
// +---------+------------------+
// | address | containment      |
// +---------+------------------+
// |  x      | low  bits  0..31 |
// +---------+------------------+
// |  x + 4  | high bits 32..63 |
// +---------+------------------+
//
// =======================================================================================================

#define ORKAGD_VERSION_MAJOR    2     // always 1-digit
#define ORKAGD_VERSION_MINOR    00    // always 2-digits
#define ORKAGD_VERSION_BUILDNUM 00000 // always 5-digits

#define ORKAGD_STR_HELPER( x ) #x
#define ORKAGD_STR( x )        ORKAGD_STR_HELPER( x )

#define ORKAGD_VERSION_STRING ( "V" ORKAGD_STR( ORKAGD_VERSION_MAJOR ) "." ORKAGD_STR( ORKAGD_VERSION_MINOR ) "." ORKAGD_STR( ORKAGD_VERSION_BUILDNUM ) )
// 1.11.00000" )

// local includes
#include "database.h"
#include "vector.h"
#include "liborkagdint.h"
#include "printf.h"
#include "tiny-json.h"
#include "stringhelper.h"
#include "tcpipclient.h"

// global includes
#define _FILE_OFFSET_BITS 64
#include <sys/types.h>
#include <sys/stat.h>
#include <inttypes.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <memory.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>

ORKADB_DBHandle_t *ORKAGD_g_DataBase                = NULL;
ORKAVEC_Vector_t * ORKAGD_g_TranslatorManufacturers = NULL;
ORKAVEC_Vector_t * ORKAGD_g_FPGADescriptions        = NULL; // ORKAGD_FPGADescription_t

// Board table
ORKADB_FieldHandle_t *ORKAGD_g_BoardField1 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField2 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField3 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField4 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField5 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField6 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField7 = NULL;
ORKADB_FieldHandle_t *ORKAGD_g_BoardField8 = NULL;

// global variables
// ================
static bool_t                     ORKAGD_g_Intern_Initialized  = FALSE;
static const char *               ORKAGD_g_PathnameTempWrite   = NULL;
static const char *               ORKAGD_g_DebugOutputFile     = "output.log";
static const char *               ORKAGD_g_BitstreamSearchPath = NULL;
static json_t                     ORKAGD_g_configFileJsonBuffer[ 1024 * 1024 ];
static ORKAGD_TcpIPControlBlock_t ORKAGD_g_TcpIPControlBlock;
// static uint64_t                   ORKAGD_g_ipRegisterHandle    = ORKAGD_COMPONENT_REGISTER_HANDLE_MAGIC; // some magic number
// static ORKAVEC_Vector_t *         ORKAGD_g_ipRegisterHandleMap = NULL;

void *
ORKAGD_TcpIPData()
{
    return ( void * ) &ORKAGD_g_TcpIPControlBlock;
}
// destinction
#ifdef _MSC_VER

// Microsoft version will not fully work,
// implementation is (currently) only for simulation and development.

#    include "dirent.h"

#    define O_NONBLOCK        ( 0 )
#    define O_SYNC            ( 0 )
#    define ORKAGD_FILEFUNC64 ( 0 )
#    include <io.h>
#    include <share.h>
#    define lseek64    _lseeki64
#    define PROT_READ  ( 0 )
#    define PROT_WRITE ( 0 )
#    define MAP_SHARED ( 0 )

#    define PRIp "0x%16.16p"

void *
mmap( int a, size_t b, int c, int d, int e, int f )
{
    a = a;
    c = c;
    d = d;
    e = e;
    f = f;
    return calloc( 1, b );
}
int
munmap( void *addr, size_t len )
{
    free( addr );
    len = len;
    return 0;
}
FILE *
popen( const char *command, const char *mode )
{
    return _popen( command, mode );
}

int
pclose( FILE *stream )
{
    return _pclose( stream );
}

const char *
ORKAGD_GetHostName()
{
#    define INFO_BUFFER_SIZE 32767
    static TCHAR infoBuf[ INFO_BUFFER_SIZE ];
    DWORD        bufCharCount = INFO_BUFFER_SIZE;

    // get computer/host name
    GetComputerName( infoBuf, &bufCharCount );
    return infoBuf;
}

int
ioctl( int fd, unsigned long request, ... )
{
    return -999; // error - not implemented
}

#else
#    ifndef __USE_BSD
#        define __USE_BSD ( 1 )
#    endif
#    include <dirent.h>

#    define ORKAGD_FILEFUNC64 ( 1 )
#    include <sys/mman.h>
#    include <sys/ioctl.h>
#    include <byteswap.h>
#    include <unistd.h>
#    include <termios.h>

#    define PRIp "%p"

// #include <stddef.h>
// #include <unistd.h>

// execl( "myprog", "myprog", "ARG1", "ARG2", NULL );
FILE *
popen( const char *command, const char *mode )
{
#    if 0
    char buf[ 40 ];
    FILE *fp = popen( command, "r" );

    while ( fgets( buf, sizeof( buf ), fp ) )
    {
        ORKAGD_DBG_PRINTF_INT( "%s", buf );
    }
#    endif
    char *newCommand = StringCreate( "echo ============================================ " );
    char *outputFile = StringCreate( ">>" );
    outputFile       = StringAddExt( outputFile, ORKAGD_g_PathnameTempWrite );
    outputFile       = StringAddFilenameToPath( outputFile, ORKAGD_g_DebugOutputFile );
    newCommand       = StringAddExt( newCommand, outputFile );
    ORKAGD_DBG_PRINTF_INT( "system( '%s' )\n", newCommand );
    system( newCommand );
    char *commandWithOutput = StringAdd( command, " " );
    commandWithOutput       = StringAdd( commandWithOutput, outputFile );
    system( commandWithOutput );
    ORKAGD_DBG_PRINTF_INT( "system( '%s' )\n", commandWithOutput );
    StringDestroy( commandWithOutput );
    StringDestroy( outputFile );
    StringDestroy( newCommand );
    return ( FILE * ) -1;
}

int
pclose( FILE *stream )
{
    return 0;
}

#    include <limits.h>

const char *
ORKAGD_GetHostName()
{
    static char hostname[] = "mydummyhostname";
    return hostname;
}

#endif

const char *
ORKAGD_VersionString()
{
    return ORKAGD_VERSION_STRING;
}

const uint64_t
ORKAGD_VersionNumber()
{
    const uint64_t version = ( ( ( uint64_t ) ORKAGD_VERSION_MAJOR ) << 32 ) | ( ( ( uint64_t ) ORKAGD_VERSION_MINOR ) << 16 ) | ( ( ( uint64_t ) ORKAGD_VERSION_BUILDNUM ) << 0 );
    return version;
}

int
ORKAGD_Execute( const char *command )
{
    FILE *pipe;

    ORKAGD_DBG_PRINTF( "Process: Start: %s\n", command );
    pipe = popen( command, "rt" );
    if ( NULL == pipe )
    {
        ORKAGD_DBG_PRINTF( "Process: Error\n" );
        return 1;
    }
    ORKAGD_DBG_PRINTF( "Process: End: returned = %d\n", pclose( pipe ) );
    return 0;
}

void
ORKAGD_PathnameConvertLinuxWindows( char *pathnameDst, const char *pathnameSrc )
{
    size_t len = strlen( pathnameSrc );
    // copy including trailling
    for ( size_t i = 0; i <= len; ++i )
    {
        if ( ORKAGD_DIR_SEPERATOR_OTHER == pathnameSrc[ i ] )
        {
            pathnameDst[ i ] = ORKAGD_DIR_SEPERATOR;
        }
        else
        {
            pathnameDst[ i ] = pathnameSrc[ i ];
        }
    }
}

static uint64_t
ORKAGD_GetFromJsonU64WithDefault( json_t const *json, const char *jsonProperty, ORKADB_RecordHandle_t *dbRecord, ORKADB_FieldHandle_t *dbField, uint64_t defVal )
{
    uint64_t      rv       = defVal;
    json_t const *property = json_getProperty( json, jsonProperty );
    if ( property && ( JSON_INTEGER == json_getType( property ) ) )
    {
        rv = json_getInteger( property );
        // ORKAGD_DBG_PRINTF( "Property: %s [%" PRId64 "]", jsonProperty, rv );
    }
    ORKADB_EntryFieldValueSetCopy( dbRecord, dbField, ( void * ) &rv );
    return rv;
}

static uint64_t
ORKAGD_GetFromJsonU64( json_t const *json, const char *jsonProperty, ORKADB_RecordHandle_t *dbRecord, ORKADB_FieldHandle_t *dbField )
{
    uint64_t rv = ORKAGD_GetFromJsonU64WithDefault( json, jsonProperty, dbRecord, dbField, 0ULL );
    return rv;
}

static const uint64_t
ORKAGD_GetFromJsonU64HexOrDecWithDefault( json_t const *json, const char *jsonProperty, ORKADB_RecordHandle_t *dbRecord, ORKADB_FieldHandle_t *dbField, uint64_t defVal )
{
    uint64_t      rv       = defVal;
    json_t const *property = json_getProperty( json, jsonProperty );
    if ( property && ( JSON_TEXT == json_getType( property ) ) )
    {
        // ORKAGD_DBG_PRINTF( "Property: %s [", jsonProperty );
        char const *value = json_getValue( property );
        if ( value )
        {
            // ORKAGD_DBG_PRINTF( "Value: %s]\n", value );
            uint64_t valueNumber = 0;
            size_t   l           = strlen( value );
            if ( l > 2 )
            {
                if ( ( '0' == value[ 0 ] ) && ( 'x' == value[ 1 ] ) )
                {
                    sscanf( value, "%" PRIx64, &valueNumber );
                }
                else
                {
                    valueNumber = strtoull( value, NULL, 10 );
                }
                char a = value[ l - 1 ];
                char b = value[ l - 2 ];
                if ( ( 'b' == a ) || ( 'B' == a ) )
                {
                    switch ( b )
                    {
                        case 't':
                        case 'T':
                            valueNumber *= 1024ULL * 1024ULL * 1024ULL * 1024ULL;
                            break;
                        case 'g':
                        case 'G':
                            valueNumber *= 1024ULL * 1024ULL * 1024ULL;
                            break;
                        case 'm':
                        case 'M':
                            valueNumber *= 1024ULL * 1024ULL;
                            break;
                        case 'k':
                        case 'K':
                            valueNumber *= 1024ULL;
                            break;
                        default:
                            break;
                    }
                }
            }
            else
            {
                valueNumber = strtoull( value, NULL, 10 );
            }

            rv = valueNumber;
        }
    }
    ORKADB_EntryFieldValueSetCopy( dbRecord, dbField, ( void * ) &rv );
    return rv;
}

static const uint64_t
ORKAGD_GetFromJsonU64HexOrDec( json_t const *json, const char *jsonProperty, ORKADB_RecordHandle_t *dbRecord, ORKADB_FieldHandle_t *dbField )
{
    uint64_t rv = ORKAGD_GetFromJsonU64HexOrDecWithDefault( json, jsonProperty, dbRecord, dbField, 0ULL );
    return rv;
}

static const char *
ORKAGD_GetFromJsonText( json_t const *json, const char *jsonProperty, ORKADB_RecordHandle_t *dbRecord, ORKADB_FieldHandle_t *dbField )
{
    const char *  rv       = NULL;
    json_t const *property = json_getProperty( json, jsonProperty );
    if ( property && ( JSON_TEXT == json_getType( property ) ) )
    {
        char const *value = json_getValue( property );
        if ( value )
        {
            // ORKAGD_DBG_PRINTF( "%s: %s\n", jsonProperty, value );
            ORKADB_EntryFieldValueSetCopy( dbRecord, dbField, ( void * ) value );
            rv = value;
        }
    }
    return rv;
}

#if 1
static void
ORKAGD_DBG_JsonDump( json_t const *json )
{
    jsonType_t const type = json_getType( json );
    if ( type != JSON_OBJ && type != JSON_ARRAY )
    {
        puts( "error" );
        return;
    }

    ORKAGD_DBG_PRINTF_INT( "%s\n", type == JSON_OBJ ? " {" : " [" );

    json_t const *child;
    for ( child = json_getChild( json ); child != 0; child = json_getSibling( child ) )
    {

        jsonType_t  propertyType = json_getType( child );
        char const *name         = json_getName( child );
        if ( name )
            ORKAGD_DBG_PRINTF_INT( " \"%s\": ", name );

        if ( propertyType == JSON_OBJ || propertyType == JSON_ARRAY )
            ORKAGD_DBG_JsonDump( child );

        else
        {
            char const *value = json_getValue( child );
            if ( value )
            {
                bool const  text = JSON_TEXT == json_getType( child );
                char const *fmt  = text ? " \"%s\"" : " %s";
                ORKAGD_DBG_PRINTF_INT( fmt, value );
                bool const last = !json_getSibling( child );
                if ( !last )
                {
                    putchar( ',' );
                    ORKAGD_DBG_PRINTF_INT( "\n" );
                }
            }
        }
    }

    ORKAGD_DBG_PRINTF_INT( "%s\n", type == JSON_OBJ ? " }" : " ]" );
}
#endif

ORKAGD_FPGADescription_t *
GetFPGADescriptor( const char *fpgaFullNameQualifier )
{
    ORKAGD_FPGADescription_t *rv = NULL;
    if ( fpgaFullNameQualifier )
    {
        // ORKAGD_DBG_PRINTF( "ORKAGD_FPGAFileRead: %s\n", fpgaFullNameQualifier );
        ORKAVEC_Iter_t *iter = ORKAVEC_IterCreate( ORKAGD_g_FPGADescriptions );
        for ( void *i = ORKAVEC_IterBegin( iter ); ORKAVEC_IterEnd( iter ); i = ORKAVEC_IterNext( iter ) )
        {
            ORKAGD_FPGADescription_t *fpgaDescription = ( ( ORKAGD_FPGADescription_t * ) i );
            // ORKAGD_DBG_PRINTF( "%s: %s\n", fpgaDescription->manufacturerName, fpgaDescription->fullNameQualifier );
            if ( 0 == StringCompareIgnoreCase( fpgaFullNameQualifier, fpgaDescription->fullNameQualifier ) )
            {
                rv = i;
                break;
            }
        }
        ORKAVEC_IterDestroy( iter );
    }
    return rv;
}

ORKAGD_TranslatorComponent_t *
GetTranslationRecord( const char *fpgaFullNameQualifier, const char *name )
{
    // ORKAGD_DBG_PRINTF( "GetTranslationRecord: %s, %s\n", fpgaFullNameQualifier, name );
    ORKAGD_TranslatorComponent_t *rv = NULL;
    if ( name )
    {
        ORKAGD_FPGADescription_t *fpgaDescription = GetFPGADescriptor( fpgaFullNameQualifier );
        if ( fpgaDescription )
        {
            ORKAVEC_Iter_t *iter = ORKAVEC_IterCreate( ORKAGD_g_TranslatorManufacturers );
            for ( void *i = ORKAVEC_IterBegin( iter ); ORKAVEC_IterEnd( iter ); i = ORKAVEC_IterNext( iter ) )
            {
                ORKAGD_TranslatorManufacturerBoard_t *translatorManufacturer = ( ( ORKAGD_TranslatorManufacturerBoard_t * ) i );
                // ORKAGD_DBG_PRINTF( "ManufacturerFPGA for Component: %s\n", translatorManufacturer->manufacturer );
                // ORKAGD_DBG_PRINTF( "%s: %s\n", fpgaDescription->manufacturerName, fpgaDescription->fullNameQualifier );
                if ( 0 == StringCompareIgnoreCase( fpgaDescription->manufacturerName, translatorManufacturer->manufacturer ) )
                {
                    ORKAVEC_Iter_t *iter2 = ORKAVEC_IterCreate( translatorManufacturer->components );
                    for ( void *j = ORKAVEC_IterBegin( iter2 ); ORKAVEC_IterEnd( iter2 ); j = ORKAVEC_IterNext( iter2 ) )
                    {
                        ORKAGD_TranslatorComponent_t *translatorComponent = ( ( ORKAGD_TranslatorComponent_t * ) j );
                        // ORKAGD_DBG_PRINTF( "==========================\n" );
                        // ORKAGD_DBG_PRINTF( "ipType: %s\n", translatorComponent->ipType );
                        // ORKAGD_DBG_PRINTF( "ipAddress: %s\n", translatorComponent->ipAddress );
                        // ORKAGD_DBG_PRINTF( "ipSubType: %s\n", translatorComponent->ipSubType );
                        // ORKAGD_DBG_PRINTF( "ipAccess: %s\n", translatorComponent->ipAccess );
                        if ( 0 == StringCompareTemplate( name, translatorComponent->ipAddress ) )
                        {
                            rv = j;
                            break;
                        }
                    }
                    ORKAVEC_IterDestroy( iter2 );
                    break;
                }
            }
            ORKAVEC_IterDestroy( iter );
        }
    }
    return rv;
}

static bool_t
ORKAGD_InterpreterFileInterprete( void *interpreterFileBuffer, size_t interpreterFileSize )
{
    bool_t rv           = FALSE;
    interpreterFileSize = interpreterFileSize; // keep compiler calm
    json_t const *json  = json_create( interpreterFileBuffer, ORKAGD_g_configFileJsonBuffer, sizeof ORKAGD_g_configFileJsonBuffer / sizeof *ORKAGD_g_configFileJsonBuffer );

    do
    {
        if ( !json )
        {
            break;
        }

        // ORKAGD_DBG_JsonDump( json );

        const char    fileType[] = "FileType";
        json_t const *property   = json_getProperty( json, fileType );
        if ( !property || ( JSON_TEXT != json_getType( property ) ) )
        {
            break;
        }
        char const *value = json_getValue( property );
        if ( !value )
        {
            break;
        }
        // ORKAGD_DBG_PRINTF( "%s: %s\n", fileType, value );

        if ( 0 != StringCompareIgnoreCase( "boardsupportpackageconfig", value ) )
        {
            break;
        }
        json_t const *manufacturers = json_getProperty( json, "ManufacturersBoard" );
        if ( !manufacturers || JSON_ARRAY != json_getType( manufacturers ) )
        {
            break;
        }

        ORKAGD_g_TranslatorManufacturers = ORKAVEC_Create( sizeof( ORKAGD_TranslatorManufacturerBoard_t ) );
        if ( !ORKAGD_g_TranslatorManufacturers )
        {
            break;
        }

        json_t const *manufacturer;
        for ( manufacturer = json_getChild( manufacturers ); manufacturer != 0; manufacturer = json_getSibling( manufacturer ) )
        {
            char const *manufacturerName = json_getPropertyValue( manufacturer, "ManufacturerName" );
            if ( manufacturerName )
            {
                // ORKAGD_DBG_PRINTF( "Name: %s\n", manufacturerName );

                json_t const *boards = json_getProperty( manufacturer, "Boards" );
                if ( !boards || JSON_ARRAY != json_getType( boards ) )
                {
                    break;
                }

                json_t const *board;
                for ( board = json_getChild( boards ); board != 0; board = json_getSibling( board ) )
                {
                    ORKAGD_TranslatorManufacturerBoard_t transLator;

                    json_t const *jsonObject;
                    json_t const *jsonSubObject;
                    transLator.manufacturer = StringCreate( manufacturerName );

                    // =========================================================================================
                    // this section reads the "Drivers" part out of "Boards" from "ORKAInterpreter.json" - start
                    // =========================================================================================

                    // Drivers options
                    // ===============
                    json_t const *drivers = json_getProperty( board, "Drivers" );
                    if ( !drivers || JSON_ARRAY != json_getType( drivers ) )
                    {
                        break;
                    }
                    transLator.drivers = ORKAVEC_Create( sizeof( ORKAGD_TranslatorDriver_t ) );
                    for ( jsonObject = json_getChild( drivers ); jsonObject != 0; jsonObject = json_getSibling( jsonObject ) )
                    {
                        if ( !jsonObject || JSON_OBJ != json_getType( jsonObject ) )
                        {
                            break;
                        }
                        jsonSubObject          = json_getChild( jsonObject );
                        const char *driverName = json_getName( jsonSubObject );

                        jsonType_t const type = json_getType( jsonSubObject );
                        if ( type != JSON_OBJ && type != JSON_ARRAY )
                        {
                            break;
                        }

                        ORKAGD_TranslatorDriver_t translatorDriver;
                        memset( &translatorDriver, 0x00, sizeof( ORKAGD_TranslatorDriver_t ) );

                        // store driver name
                        translatorDriver.name = StringCreate( driverName );

                        json_t const *child;
                        for ( child = json_getChild( jsonSubObject ); child != 0; child = json_getSibling( child ) )
                        {
                            char const *subvalue = json_getValue( child );
                            char const *name     = json_getName( child );
                            if ( 0 == StringCompareIgnoreCase( "control", name ) )
                            {
                                translatorDriver.controlAccess = StringCreate( subvalue );
                                continue;
                            }
                            if ( 0 == StringCompareIgnoreCase( "memcpyd2h", name ) )
                            {
                                translatorDriver.memcpyd2h = StringCreate( subvalue );
                                continue;
                            }
                            if ( 0 == StringCompareIgnoreCase( "memcpyh2d", name ) )
                            {
                                translatorDriver.memcpyh2d = StringCreate( subvalue );
                                continue;
                            }
                            if ( 0 == StringCompareIgnoreCase( "register", name ) )
                            {
                                translatorDriver.registerAccess = StringCreate( subvalue );
                                continue;
                            }
                        }

                        // configure access-type
                        //
                        // 0 - not defined
                        // 1 - access xdma-like linux (4 separate drivers for control, register, memcpyd2h and memcpyh2d)
                        // 2 - access via TCP/IP
                        // 3 ... to be extended
                        ORKAGD_AccessType_t driverAccessTypes[] = {
                            { "not-defined", ORKAGD_ACCESSTYPE_UNDEFINED },
                            { "xdma", ORKAGD_ACCESSTYPE_XDMA },              // access xdma-like linux (4 separate drivers for control, register, memcpyd2h and memcpyh2d)
                            { "ipv4", ORKAGD_ACCESSTYPE_IPV4 },              // access via tcpip v4 network
                            { "intel_pcie", ORKAGD_ACCESSTYPE_INTEL_IOCTL }, // TODO
                        };

                        uint64_t i;
                        translatorDriver.accessType = ORKAGD_ACCESSTYPE_UNDEFINED;
                        for ( i = 1; i < sizeof( driverAccessTypes ) / sizeof( driverAccessTypes[ 0 ] ); ++i )
                        {
                            if ( 0 == strcmp( driverAccessTypes[ i ].name, driverName ) )
                            {
                                translatorDriver.accessType = driverAccessTypes[ i ].typeID;
                                break;
                            }
                        }
                        ORKAGD_DBG_PRINTF( "==========================================\n" );
                        ORKAGD_DBG_PRINTF( "Driver: %s\n", driverName );
                        ORKAGD_DBG_PRINTF( "* accessType: %" PRId64 "\n", ( uint64_t ) translatorDriver.accessType );
                        switch ( translatorDriver.accessType )
                        {
                            default:
                            case ORKAGD_ACCESSTYPE_UNDEFINED:
                                break;
                            case ORKAGD_ACCESSTYPE_XDMA:
                                // Xilinx DMA
                                ORKAGD_DBG_PRINTF( "* control:    %s\n", translatorDriver.controlAccess );
                                ORKAGD_DBG_PRINTF( "* memcpyd2h:  %s\n", translatorDriver.memcpyd2h );
                                ORKAGD_DBG_PRINTF( "* memcpyh2d:  %s\n", translatorDriver.memcpyh2d );
                                ORKAGD_DBG_PRINTF( "* register:   %s\n", translatorDriver.registerAccess );
                                break;
                            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
                                // INTEL_MMIO
                                ORKAGD_DBG_PRINTF( "* control:    %s\n", translatorDriver.controlAccess );
                                ORKAGD_DBG_PRINTF( "* memcpyd2h:  %s\n", translatorDriver.memcpyd2h );
                                ORKAGD_DBG_PRINTF( "* memcpyh2d:  %s\n", translatorDriver.memcpyh2d );
                                ORKAGD_DBG_PRINTF( "* register:   %s\n", translatorDriver.registerAccess );
                                break;
                            case ORKAGD_ACCESSTYPE_IPV4:
                                // accesss with TCP/IP custom protocol
                                ORKAGD_DBG_PRINTF( "* TCP/IP access\n" );
                                break;
                        }

                        ORKAVEC_PushBack( transLator.drivers, ( void * ) &translatorDriver );
                    }
                    // =========================================================================================
                    // this section reads the "Drivers" part out of "Boards" from "ORKAInterpreter.json" - end
                    // =========================================================================================

                    // Components translator
                    // =====================
                    json_t const *components = json_getProperty( board, "Components" );
                    if ( !components || JSON_ARRAY != json_getType( components ) )
                    {
                        break;
                    }
                    transLator.components = ORKAVEC_Create( sizeof( ORKAGD_TranslatorComponent_t ) );
                    for ( jsonObject = json_getChild( components ); jsonObject != 0; jsonObject = json_getSibling( jsonObject ) )
                    {
                        if ( !jsonObject || JSON_OBJ != json_getType( jsonObject ) )
                        {
                            break;
                        }
                        const char *ipType    = json_getPropertyValue( jsonObject, "type" );
                        const char *ipAddress = json_getPropertyValue( jsonObject, "address" );
                        const char *ipSubType = json_getPropertyValue( jsonObject, "subtype" );
                        const char *ipAccess  = json_getPropertyValue( jsonObject, "access" );
                        if ( ipType && ipAddress && ipSubType && ipAccess )
                        {
                            // ORKAGD_DBG_PRINTF( "ipType:    %s\n", ipType );
                            // ORKAGD_DBG_PRINTF( "ipAddress: %s\n", ipAddress );
                            // ORKAGD_DBG_PRINTF( "ipSubType: %s\n", ipSubType );
                            // ORKAGD_DBG_PRINTF( "ipAccess:  %s\n", ipAccess );

                            ORKAGD_TranslatorComponent_t translatorComponent;
                            translatorComponent.ipType    = StringCreate( ipType );
                            translatorComponent.ipAddress = StringCreate( ipAddress );
                            translatorComponent.ipSubType = StringCreate( ipSubType );
                            translatorComponent.ipAccess  = StringCreate( ipAccess );
                            ORKAVEC_PushBack( transLator.components, ( void * ) &translatorComponent );
                        }
                    }
                    ORKAVEC_PushBack( ORKAGD_g_TranslatorManufacturers, ( void * ) &transLator );
                } // for ( board = json_getChild( boards ); board != 0; board = json_getSibling( board ) )
            }
        } // for ( manufacturer = json_getChild( manufacturers ); manufacturer != 0; manufacturer = json_getSibling( manufacturer ) )
        rv = true;
    } while ( 0 );
    return rv;
}

static bool_t
ORKAGD_InterpreterFileRead( char *interpreterFilenameWithPath )
{
    bool_t rv = FALSE;

    ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
    ORKAGD_DBG_PRINTF( "ORKAGD_InterpreterFileRead: interpreterFilenameWithPath: %s\n", interpreterFilenameWithPath );
    // filename has to be longer than 5 letters as extension alone needs 5 (".json")
    size_t len = strlen( interpreterFilenameWithPath );
    if ( 5 < len )
    {
        if ( 0 == strcmp( &interpreterFilenameWithPath[ len - 5 ], ".json" ) )
        {
            FILE *fd = fopen( interpreterFilenameWithPath, "r+b" );
            if ( fd )
            {
                fseek( fd, 0, SEEK_END );
                long interpreterFileSize = ftell( fd );
                if ( interpreterFileSize )
                {
                    fseek( fd, 0, SEEK_SET );
                    // needs to have a trailling ZERO to be a valid C-string
                    void *interpreterFileBuffer = calloc( 1, ( size_t ) interpreterFileSize + 1 );
                    if ( interpreterFileBuffer )
                    {
                        size_t numElements = fread( interpreterFileBuffer, interpreterFileSize, 1, fd );
                        if ( 1 == numElements )
                        {
                            rv = ORKAGD_InterpreterFileInterprete( interpreterFileBuffer, interpreterFileSize );
                        }
                        free( interpreterFileBuffer );
                    }
                }
                fclose( fd );
            }
            else
            {
                ORKAGD_DBG_PRINTF( "ORKAGD_InterpreterFileRead: File not found !\n" );
            }
        }
    }
    ORKAGD_DBG_PRINTF( "ORKAGD_InterpreterFileRead: exit=%s\n", rv ? "(ok)" : "(Nok)" );
    ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
    return rv;
}

static bool_t
ORKAGD_FPGAFileInterprete( void *fpgaFileBuffer, size_t fpgaFileSize )
{
    bool_t rv          = FALSE;
    fpgaFileSize       = fpgaFileSize; // keep compiler calm
    json_t const *json = json_create( fpgaFileBuffer, ORKAGD_g_configFileJsonBuffer, sizeof ORKAGD_g_configFileJsonBuffer / sizeof *ORKAGD_g_configFileJsonBuffer );

    do
    {
        if ( !json )
        {
            break;
        }

        //        ORKAGD_DBG_JsonDump( json );

        const char    fileType[] = "FileType";
        json_t const *property   = json_getProperty( json, fileType );
        if ( !property || ( JSON_TEXT != json_getType( property ) ) )
        {
            break;
        }
        char const *value = json_getValue( property );
        if ( !value )
        {
            break;
        }
        // ORKAGD_DBG_PRINTF( "%s: %s\n", fileType, value );

        if ( 0 != StringCompareIgnoreCase( "BoardSupportPackageFPGAConfig", value ) )
        {
            break;
        }
        json_t const *manufacturers = json_getProperty( json, "ManufacturerFPGA" );
        if ( !manufacturers || JSON_ARRAY != json_getType( manufacturers ) )
        {
            break;
        }

        ORKAGD_g_FPGADescriptions = ORKAVEC_Create( sizeof( ORKAGD_FPGADescription_t ) );
        if ( !ORKAGD_g_FPGADescriptions )
        {
            break;
        }

        // we presume, that everything is "allright"
        rv = TRUE;

        json_t const *manufacturer;
        for ( manufacturer = json_getChild( manufacturers ); manufacturer != 0; manufacturer = json_getSibling( manufacturer ) )
        {
            ORKAGD_FPGADescription_t fpgaDescription;
            const char *             manufacturerName = json_getPropertyValue( manufacturer, "ManufacturerName" );
            if ( !manufacturerName )
            {
                continue;
            }

            json_t const *manufacturerIDProperty = json_getProperty( manufacturer, "ManufacturerID" );
            if ( !manufacturerIDProperty )
            {
                continue;
            }

            json_t const *fpgas = json_getProperty( manufacturer, "FPGAType" );
            if ( !fpgas || JSON_ARRAY != json_getType( fpgas ) )
            {
                break;
            }

            json_t const *fpga;
            for ( fpga = json_getChild( fpgas ); fpga != 0; fpga = json_getSibling( fpga ) )
            {
                // clear contents of datastruct
                memset( &fpgaDescription, 0x00, sizeof( ORKAGD_FPGADescription_t ) );

                // retrieve contents from JSON and store in container record
                fpgaDescription.manufacturerName  = StringCreate( manufacturerName );
                fpgaDescription.manufacturerID    = json_getInteger( manufacturerIDProperty );
                fpgaDescription.category          = StringCreate( json_getPropertyValue( fpga, "Category" ) );
                fpgaDescription.family            = StringCreate( json_getPropertyValue( fpga, "Family" ) );
                fpgaDescription.package           = StringCreate( json_getPropertyValue( fpga, "Package" ) );
                fpgaDescription.speedgrade        = StringCreate( json_getPropertyValue( fpga, "Speedgrade" ) );
                fpgaDescription.temperature       = StringCreate( json_getPropertyValue( fpga, "Temperature" ) );
                fpgaDescription.fullNameQualifier = StringCreate( json_getPropertyValue( fpga, "FullNameQualifier" ) );
                fpgaDescription.shortName         = StringCreate( json_getPropertyValue( fpga, "ShortName" ) );

                // ORKAGD_DBG_PRINTF( "ManufacturerName: %s\n", fpgaDescription.manufacturerName );
                // ORKAGD_DBG_PRINTF( "ManufacturerID: %" PRIu64 "\n", fpgaDescription.manufacturerID );
                if ( fpgaDescription.fullNameQualifier )
                {
                    // store record in vector
                    ORKAVEC_PushBack( ORKAGD_g_FPGADescriptions, &fpgaDescription );
                }
                else
                {
                    // we need the FullNameQualifier as a search criteria
                    ORKAGD_DBG_PRINTF( "Error! FullNameQualifier missing ...\n" );

                    // presumption was wrong  :-(
                    rv = FALSE;
                }
            }
        }
    } while ( 0 );
    return rv;
}

static bool_t
ORKAGD_FPGAFileRead( char *fpgaFilenameWithPath )
{
    bool_t rv = FALSE;
    ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
    ORKAGD_DBG_PRINTF( "ORKAGD_FPGAFileRead: fpgaFilenameWithPath: %s\n", fpgaFilenameWithPath );

    // filename has to be longer than 5 letters as extension alone needs 5 (".json")
    size_t len = strlen( fpgaFilenameWithPath );
    if ( 5 < len )
    {
        if ( 0 == strcmp( &fpgaFilenameWithPath[ len - 5 ], ".json" ) )
        {
            FILE *fd = fopen( fpgaFilenameWithPath, "r+b" );
            if ( fd )
            {
                fseek( fd, 0, SEEK_END );
                long fpgaFileSize = ftell( fd );
                if ( fpgaFileSize )
                {
                    fseek( fd, 0, SEEK_SET );
                    // needs to have a trailling ZERO to be a valid C-string
                    void *fpgaFileBuffer = calloc( 1, ( size_t ) fpgaFileSize + 1 );
                    if ( fpgaFileBuffer )
                    {
                        size_t numElements = fread( fpgaFileBuffer, fpgaFileSize, 1, fd );
                        if ( 1 == numElements )
                        {
                            rv = ORKAGD_FPGAFileInterprete( fpgaFileBuffer, fpgaFileSize + 1 );
                        }
                        free( fpgaFileBuffer );
                    }
                }
                fclose( fd );
            }
            else
            {
                ORKAGD_DBG_PRINTF( "ORKAGD_FPGAFileRead: File not found !\n" );
            }
        }
    }
    ORKAGD_DBG_PRINTF( "ORKAGD_FPGAFileRead: exit=%s\n", rv ? "(ok)" : "(Nok)" );
    ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
    return rv;
}

static bool_t
ORKAGD_ConfigFileInterprete( char *configFilename, void *configFileBuffer, size_t configFileSize )
{
    bool_t rv                            = FALSE;
    configFileSize                       = configFileSize; // keep compiler calm
    char *                 comment       = NULL;
    ORKADB_RecordHandle_t *record        = NULL;
    ORKADB_TableHandle_t * tableFPGAs    = NULL;
    ORKADB_FieldHandle_t * fpgaField1    = NULL;
    ORKADB_FieldHandle_t * fpgaField2    = NULL;
    ORKADB_FieldHandle_t * fpgaField3    = NULL; // components table
    ORKADB_FieldHandle_t * fpgaField4    = NULL; // memory regions table
    ORKADB_TableHandle_t * tablePCIeBars = NULL;
    ORKADB_FieldHandle_t * PCIeBarField1 = NULL;
    ORKADB_FieldHandle_t * PCIeBarField2 = NULL;
    ORKADB_TableHandle_t * boardsTable   = ORKADB_TableHandleGet( ORKAGD_g_DataBase, "Boards" );

    do
    {
        json_t const *json = json_create( configFileBuffer, ORKAGD_g_configFileJsonBuffer, sizeof ORKAGD_g_configFileJsonBuffer / sizeof *ORKAGD_g_configFileJsonBuffer );

        if ( !json )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: No JSON recognized\n" );
            break;
        }

        const char    fileType[] = "FileType";
        json_t const *property   = json_getProperty( json, fileType );
        if ( !property || ( JSON_TEXT != json_getType( property ) ) )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: FileType not found within JSON\n" );
            break;
        }

        char const *value = json_getValue( property );
        if ( !value )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: FileType value improper\n" );
            break;
        }
        if ( 0 != StringCompareIgnoreCase( "boardsupportpackage", value ) )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: string 'boardsupportpackage' as FileType not recognized\n" );
            break;
        }

        record = ORKADB_RecordCreate( boardsTable );

        // Comment ====================================================

        comment = ( char * ) ORKAGD_GetFromJsonText( json, "Comment", record, ORKAGD_g_BoardField1 );
        ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Comment: '%s'\n", comment );

        // InfrastructureName =========================================

        ORKADB_EntryFieldValueSetCopy( record, ORKAGD_g_BoardField2, ( void * ) configFilename );

        // BoardName ==================================================

        ORKAGD_GetFromJsonText( json, "BoardName", record, ORKAGD_g_BoardField3 );

        // BlockDesignName ============================================

        ORKAGD_GetFromJsonText( json, "BlockDesignName", record, ORKAGD_g_BoardField4 );

        // ManufacturerBoard ==========================================

        ORKAGD_GetFromJsonText( json, "ManufacturerBoard", record, ORKAGD_g_BoardField5 );

        // Drivers ====================================================

        // Create Table with drivers
        json_t const *drivers = json_getProperty( json, "Drivers" );
        if ( !drivers || JSON_ARRAY != json_getType( drivers ) )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: contains no 'Drivers' array\n" );
            break;
        }

        ORKADB_TableHandle_t *tableDrivers = ORKADB_TableCreate( ORKAGD_g_DataBase, "Drivers" );

        // Create fields of the table
        ORKADB_FieldHandle_t *DriverField1 = ORKADB_FieldCreate( tableDrivers, "DriverName", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKADB_FieldHandle_t *DriverField2 = ORKADB_FieldCreate( tableDrivers, "Instance", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
        ORKADB_FieldHandle_t *DriverField3 = ORKADB_FieldCreate( tableDrivers, "Port", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
        ORKADB_FieldHandle_t *DriverField4 = ORKADB_FieldCreate( tableDrivers, "Speed", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
        ORKADB_FieldHandle_t *DriverField5 = ORKADB_FieldCreate( tableDrivers, "Address", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );

        json_t const *driver;
        for ( driver = json_getChild( drivers ); driver != 0; driver = json_getSibling( driver ) )
        {
            if ( JSON_OBJ == json_getType( driver ) )
            {
                ORKADB_RecordHandle_t *recordCompontent = ORKADB_RecordCreate( tableDrivers );

                ORKAGD_GetFromJsonText( driver, "DriverName", recordCompontent, DriverField1 );
                ORKAGD_GetFromJsonU64( driver, "Instance", recordCompontent, DriverField2 );
                ORKAGD_GetFromJsonU64( driver, "Port", recordCompontent, DriverField3 );
                ORKAGD_GetFromJsonU64( driver, "Speed", recordCompontent, DriverField4 );
                ORKAGD_GetFromJsonText( driver, "Address", recordCompontent, DriverField5 );
            }
        }
        ORKADB_EntryFieldValueSetCopy( record, ORKAGD_g_BoardField6, ( void * ) tableDrivers );

        // FPGAs ======================================================

        // Create Table with FPGAs
        tableFPGAs = ORKADB_TableCreate( ORKAGD_g_DataBase, "FPGAs" );

        // Create fields of the table
        fpgaField1 = ORKADB_FieldCreate( tableFPGAs, "FullNameQualifier", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        fpgaField2 = ORKADB_FieldCreate( tableFPGAs, "Driver", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
        fpgaField3 = ORKADB_FieldCreate( tableFPGAs, "Components", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing );
        fpgaField4 = ORKADB_FieldCreate( tableFPGAs, "MemoryRegions", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing );

        json_t const *fpgas = json_getProperty( json, "FPGAs" );
        if ( !fpgas || JSON_ARRAY != json_getType( fpgas ) )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: contains no 'FPGAs' array\n" );
            break;
        }

        json_t const *fpga;
        for ( fpga = json_getChild( fpgas ); fpga != 0; fpga = json_getSibling( fpga ) )
        {
            if ( JSON_OBJ == json_getType( fpga ) )
            {
                ORKADB_RecordHandle_t *recordFPGA = ORKADB_RecordCreate( tableFPGAs );

                const char *fpgaFullnameQualifier = ORKAGD_GetFromJsonText( fpga, "FullNameQualifier", recordFPGA, fpgaField1 );
                // ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: FPGA-FullnameQualifier: %s\n", fpgaFullnameQualifier );

                ORKAGD_GetFromJsonU64( fpga, "Driver", recordFPGA, fpgaField2 );

                // Components =================================================

                json_t const *components = json_getProperty( fpga, "Components" );
                if ( !components || JSON_ARRAY != json_getType( components ) )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Error: contains no 'Components' array\n" );
                    break;
                }

                // Create Table with components
                // ============================
                ORKADB_TableHandle_t *TableComponents = ORKADB_TableCreate( ORKAGD_g_DataBase, "Components" );

                // Create fields of the table
                ORKADB_FieldHandle_t *ComponentField1 = ORKADB_FieldCreate( TableComponents, "name", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField2 = ORKADB_FieldCreate( TableComponents, "offset", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField3 = ORKADB_FieldCreate( TableComponents, "range", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField4 = ORKADB_FieldCreate( TableComponents, "type", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField5 = ORKADB_FieldCreate( TableComponents, "ipAddress", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField6 = ORKADB_FieldCreate( TableComponents, "subtype", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField7 = ORKADB_FieldCreate( TableComponents, "ipAccess", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
                ORKADB_FieldHandle_t *ComponentField8 = ORKADB_FieldCreate( TableComponents, "Registers", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing ); // here a full "new" table is store in the record (only a pointer to it)

                json_t const *component;
                for ( component = json_getChild( components ); component != 0; component = json_getSibling( component ) )
                {
                    if ( JSON_OBJ == json_getType( component ) )
                    {
                        ORKADB_RecordHandle_t *recordCompontent = ORKADB_RecordCreate( TableComponents );

                        const char *componentName = ORKAGD_GetFromJsonText( component, "name", recordCompontent, ComponentField1 );
                        ORKAGD_GetFromJsonU64HexOrDec( component, "offset", recordCompontent, ComponentField2 );
                        ORKAGD_GetFromJsonU64HexOrDec( component, "range", recordCompontent, ComponentField3 );

                        // now get the valid translation for identification and correct management of block.
                        // This depends on manufacturer of FPGA ...
                        ORKAGD_TranslatorComponent_t *translatorComponent = GetTranslationRecord( fpgaFullnameQualifier, componentName );

                        // here we get back the translation data and handling information as well as identification strings (type/subtype)
                        if ( translatorComponent )
                        {
                            // ORKAGD_DBG_PRINTF( "ipType: %s\n", translatorComponent->ipType );
                            // ORKAGD_DBG_PRINTF( "ipAddress: %s\n", translatorComponent->ipAddress );
                            // ORKAGD_DBG_PRINTF( "ipSubType: %s\n", translatorComponent->ipSubType );
                            // ORKAGD_DBG_PRINTF( "ipAccess: %s\n", translatorComponent->ipAccess );

                            // fill in fields of record
                            ORKADB_EntryFieldValueSetCopy( recordCompontent, ComponentField4, ( void * ) ( translatorComponent->ipType ) );
                            ORKADB_EntryFieldValueSetCopy( recordCompontent, ComponentField5, ( void * ) ( translatorComponent->ipAddress ) );
                            ORKADB_EntryFieldValueSetCopy( recordCompontent, ComponentField6, ( void * ) ( translatorComponent->ipSubType ) );
                            ORKADB_EntryFieldValueSetCopy( recordCompontent, ComponentField7, ( void * ) ( translatorComponent->ipAccess ) );
                        }

                        // *********************************
                        // JSC 2021-01-10
                        // new for ORKA-Demo
                        // add a new table with register map
                        //
                        // Reason was to be able to give the IP more ports than only the planned two.
                        // Thus we need to address them but didn't know at what offset the lay around.
                        // Vivado (which we used at first) gives a deviation of the names and so
                        // we try to drive with it.
                        // *********************************
                        do
                        {
                            // now we check for the "new" (2021-01-10) register section
                            json_t const *registerEntries = json_getProperty( component, "registers" );
                            if ( !registerEntries || JSON_ARRAY != json_getType( registerEntries ) )
                            {
                                ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Info: component '%s' contains no 'registers' array\n", componentName );
                                break;
                            }

                            // Create Table with registers (only the layout is generated here)
                            // ===============================================================
                            ORKADB_TableHandle_t *TableComponentRegisters = ORKADB_TableCreate( ORKAGD_g_DataBase, "ComponentRegisterTable" );

                            // Create fields of the table-record
                            ORKADB_FieldHandle_t *ComponentRegisterField1 = ORKADB_FieldCreate( TableComponentRegisters, "name", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );  // the "name" field for ease of access or recognition
                            ORKADB_FieldHandle_t *ComponentRegisterField2 = ORKADB_FieldCreate( TableComponentRegisters, "addr", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing ); // the "address" - or better "offset from base"
                            ORKADB_FieldHandle_t *ComponentRegisterField3 = ORKADB_FieldCreate( TableComponentRegisters, "bits", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing ); // number of bits belonging to register: the width

                            uint32_t registerCount = 0;
                            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Info: component '%s' contains 'registers' entry:\n", componentName );
                            json_t const *registerEntry;
                            for ( registerEntry = json_getChild( registerEntries ); registerEntry != 0; registerEntry = json_getSibling( registerEntry ) )
                            {
                                if ( JSON_OBJ == json_getType( registerEntry ) )
                                {
                                    ORKADB_RecordHandle_t *recordRegister = ORKADB_RecordCreate( TableComponentRegisters );

                                    const char *registerName = ORKAGD_GetFromJsonText( registerEntry, "name", recordRegister, ComponentRegisterField1 );
                                    ORKAGD_GetFromJsonU64HexOrDec( registerEntry, "addr", recordRegister, ComponentRegisterField2 );
                                    ORKAGD_GetFromJsonU64HexOrDecWithDefault( registerEntry, "bits", recordRegister, ComponentRegisterField3, 32 );
                                    ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Info: register#%2d: %s\n", registerCount, registerName );
                                    registerCount++;
                                }
                            }
                            // transfer table of registers into component record-entry
                            ORKADB_EntryFieldValueSetCopy( recordCompontent, ComponentField8, ( void * ) TableComponentRegisters );
                            ORKAGD_DBG_PRINTF( "Pointer to register table: " PRIp "\n", ( void * ) TableComponentRegisters );
                        } while ( 0 ); // pseudo loop to be able to exit easily
                    }
                }
                ORKADB_EntryFieldValueSetCopy( recordFPGA, fpgaField3, ( void * ) TableComponents );

                ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: 'Components' processed (OK)\n" );

                // MemoryRegions ==============================================

                // Create Table with MemoryRegions
                // ===============================
                ORKADB_TableHandle_t *TableMemoryRegions = ORKADB_TableCreate( ORKAGD_g_DataBase, "MemoryRegions" );

                // Create fields of the table
                ORKADB_FieldHandle_t *memoryRegionField1 = ORKADB_FieldCreate( TableMemoryRegions, "memcpyOffset", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );

                json_t const *memoryRegions = json_getProperty( fpga, "MemoryRegions" );
                if ( !memoryRegions || JSON_ARRAY != json_getType( memoryRegions ) )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: Info: contains no 'MemoryRegions' array\n" );

                    ORKADB_RecordHandle_t *recordMemoryRegion = ORKADB_RecordCreate( TableMemoryRegions );
                    uint64_t               dummyMemoryOffset  = 0ull;
                    ORKADB_EntryFieldValueSetCopy( recordMemoryRegion, memoryRegionField1, ( void * ) &dummyMemoryOffset );
                }
                else
                {
                    json_t const *memoryRegion;
                    for ( memoryRegion = json_getChild( memoryRegions ); memoryRegion != 0; memoryRegion = json_getSibling( memoryRegion ) )
                    {
                        //                    ORKAGD_DBG_JsonDump( memoryRegion );
                        if ( JSON_OBJ == json_getType( memoryRegion ) )
                        {
                            ORKADB_RecordHandle_t *recordMemoryRegion = ORKADB_RecordCreate( TableMemoryRegions );

                            ORKAGD_GetFromJsonU64HexOrDec( memoryRegion, "memcpyOffset", recordMemoryRegion, memoryRegionField1 );
                        }
                    }
                }
                ORKADB_EntryFieldValueSetCopy( recordFPGA, fpgaField4, ( void * ) TableMemoryRegions );
                ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: 'MemoryRegions' processed (OK)\n" );
            }
        }
        ORKADB_EntryFieldValueSetCopy( record, ORKAGD_g_BoardField7, ( void * ) tableFPGAs );

        // PCIeBars ===================================================

        // PCIe BARs are now optional as we could communicate over TCPIP/UARTS/USB etc. as well
        json_t const *pciebars = json_getProperty( json, "pciebars" );
        if ( pciebars && ( JSON_ARRAY == json_getType( pciebars ) ) )
        {
            // Create Table with PCIeBars
            tablePCIeBars = ORKADB_TableCreate( ORKAGD_g_DataBase, "PCIeBars" );

            // Create fields of the table
            PCIeBarField1 = ORKADB_FieldCreate( tablePCIeBars, "type", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
            PCIeBarField2 = ORKADB_FieldCreate( tablePCIeBars, "size", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );

            json_t const *pciebar;
            for ( pciebar = json_getChild( pciebars ); pciebar != 0; pciebar = json_getSibling( pciebar ) )
            {
                if ( JSON_OBJ == json_getType( pciebar ) )
                {
                    ORKADB_RecordHandle_t *recordPCIeBar = ORKADB_RecordCreate( tablePCIeBars );

                    ORKAGD_GetFromJsonText( pciebar, "type", recordPCIeBar, PCIeBarField1 );
                    ORKAGD_GetFromJsonU64HexOrDec( pciebar, "size", recordPCIeBar, PCIeBarField2 );
                }
            }
            ORKADB_EntryFieldValueSetCopy( record, ORKAGD_g_BoardField8, ( void * ) tablePCIeBars );
        }

        rv = TRUE;
        // exit pseudo-loop
    } while ( 0 );

    ORKAGD_DBG_PRINTF( "ORKAGD_ConfigFileInterprete: processed (%s)\n", ( FALSE == rv ) ? "NOK" : "OK" );
    return rv;
}

static bool_t
ORKAGD_ConfigFileRead( const char *configFilenameWithPath, const char *configFilepath, const char *configFilename )
{
    bool_t rv = FALSE;

    // filename has to be longer than 5 letters as extension alone needs 5 (".json")
    uint64_t len = ( uint64_t ) strlen( configFilename );
    // ORKAGD_DBG_PRINTF("\nlen=%" PRId64 "\n",len);
    if ( 5 < len )
    {
        if ( 0 == strcmp( &configFilename[ len - 5 ], ".json" ) )
        {
            // ORKAGD_DBG_PRINTF(".json\n");
            FILE *fd = fopen( configFilenameWithPath, "r+b" );
            if ( fd )
            {
                // ORKAGD_DBG_PRINTF(PRIp"\n", fd);
                fseek( fd, 0, SEEK_END );
                long configFileSize = ftell( fd );
                if ( configFileSize )
                {
                    // ORKAGD_DBG_PRINTF("Size=%ld\n", configFileSize);
                    fseek( fd, 0, SEEK_SET );
                    // needs to have a trailling ZERO to be a valid C-string
                    void *configFileBuffer = calloc( 1, ( size_t ) configFileSize + 1 );
                    if ( configFileBuffer )
                    {
                        // ORKAGD_DBG_PRINTF("Buffer="PRIp"\n", configFileBuffer);
                        uint64_t numElements = ( uint64_t ) fread( configFileBuffer, configFileSize, 1, fd );
                        if ( 1 == numElements )
                        {
                            // ORKAGD_DBG_PRINTF("NumEl=%" PRId64 "\n", numElements);
                            rv = ORKAGD_ConfigFileInterprete( StringGetFilenameFromPath( configFilenameWithPath ), configFileBuffer, configFileSize );
                            // ORKAGD_DBG_PRINTF("rv=%d\n", rv );
                        }
                        free( configFileBuffer );
                    }
                }
                fclose( fd );
            }
        }
    }
    return rv;
}

static bool_t alreadyShown = FALSE;
static bool_t
ORKAGD_ConfigProcess( const char *configDirname )
{
    bool_t          rv             = FALSE;
    static uint64_t recursionCount = 0;
    struct dirent * ent;

    if ( !alreadyShown )
    {
        ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
        alreadyShown = TRUE;
    }
    // ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: configDirname: %s\n", configDirname );

    DIR *m_Dir = opendir( configDirname );
    if ( m_Dir )
    {
        ent = readdir( m_Dir );
        while ( ent )
        {
            if ( ( 0 == strncmp( "..", ent->d_name, 3 ) ) || ( 0 == strncmp( ".", ent->d_name, 2 ) ) )
            {
                // skip it
            }
            else
            {
                size_t l1 = strlen( configDirname );
                size_t l2 = strlen( ent->d_name );

                // calculate in l1: length of configDirname + separator + length of d_name + trailling zero.
                // in case we already have a terminating backslash/slash omit separator.
                size_t lenNew = l1 + ( ( ORKAGD_DIR_SEPERATOR == configDirname[ l1 - 1 ] ) ? l2 + 1 : ( l2 + 2 ) );

                // get memory for new prolonged path
                char *newPath = ( char * ) malloc( lenNew );

                // on success
                if ( newPath )
                {
                    // first 'character' of empty string
                    *newPath = 0;

                    // fill up
                    ORKAGD_PathnameConvertLinuxWindows( newPath, configDirname );
                    if ( ORKAGD_DIR_SEPERATOR == configDirname[ l1 - 1 ] )
                    {
                        strcat( newPath, ent->d_name );
                    }
                    else
                    {
                        newPath[ l1 ]     = ORKAGD_DIR_SEPERATOR;
                        newPath[ l1 + 1 ] = 0;
                        strcat( newPath, ent->d_name );
                    }

                    if ( DT_DIR & ent->d_type )
                    {
                        // ORKAGD_DBG_PRINTF( "NameDir: %s\n", ent->d_name );
                        // recursively call itself to parse whole dir structure
                        recursionCount++;
                        rv |= ORKAGD_ConfigProcess( newPath );
                        recursionCount--;
                    }
                    else
                    {
                        // ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: Check file: %s\n", ent->d_name );
                        bool_t   rv2 = false;
                        uint64_t len = ( uint64_t ) strlen( ent->d_name );
                        if ( len > 5 )
                        {
                            if ( 0 == strcmp( &( ent->d_name[ len - 5 ] ), ".json" ) )
                            {
                                ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: enter: %s ...\n", ent->d_name );
                                rv2 = ORKAGD_ConfigFileRead( newPath, configDirname, ent->d_name );
                                ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: leave: %s (%s)\n\n", ent->d_name, rv2 ? "OK" : "NOK" );
                                rv |= rv2;
                                // ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: general rv = %s\n", rv ? "OK" : "NOK" );
                            }
                            // ORKAGD_DBG_PRINTF( "NameFile: %s %s\n", ent->d_name, (( rv2 ) ? "(ok)" : "(nok)" ));
                        }
                    }
                    // ORKAGD_DBG_PRINTF("about to free: "PRIp"\n", newPath );
                    free( newPath );
                }
            }
            // ORKAGD_DBG_PRINTF("readdir ... "PRIp"\n", m_Dir );
            ent = readdir( m_Dir );
        }
        closedir( m_Dir );
    }
    else
    {
        // single file
        //        ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: (single)\n" );
        rv = ORKAGD_ConfigFileRead( configDirname, ORKAGD_DIRECTORY_CURRENT, configDirname );
        //        ORKAGD_DBG_PRINTF( "%s\n", ( rv ) ? "(ok)" : "(nok)" );
        if ( rv )
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: %s (OK, single)\n", configDirname );
        }
    }

    if ( !recursionCount )
    {
        ORKAGD_DBG_PRINTF( "ORKAGD_ConfigProcess: exit=%s\n", rv ? "(ok)" : "(Nok)" );
        ORKAGD_DBG_PRINTF( "**********************************************************************************************\n" );
    }
    return rv;
}

static void
ORKAGD_CleanUp()
{
}

static void
ORKAGD_ComponentTableCreate()
{
    // Create fields of the table
    //    ORKAGD_g_BoardsTable = ORKADB_TableCreate( ORKAGD_g_DataBase, "Boards" );
}

ORKAGD_EC_t
ORKAGD_Init( const char *configFileSearchPath, const char *bitstreamSearchPath, const char *pathnameTempWrite )
{
    ORKAGD_EC_t rv = ORKAGD_EC_WRONG_PARAMETER;
    if ( configFileSearchPath )
    {
        // prepare paths/filenames

        // create the database
        ORKAGD_g_DataBase = ORKAGD_DBCreate( "ORKADatabase" );

        // Create Table with boards
        ORKADB_TableHandle_t *boardsTable = ORKADB_TableCreate( ORKAGD_g_DataBase, "Boards" );

        // Create fields of the table
        ORKAGD_g_BoardField1 = ORKADB_FieldCreate( boardsTable, "Comment", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField2 = ORKADB_FieldCreate( boardsTable, "InfrastructureName", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField3 = ORKADB_FieldCreate( boardsTable, "BoardName", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField4 = ORKADB_FieldCreate( boardsTable, "BlockDesignName", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField5 = ORKADB_FieldCreate( boardsTable, "ManufacturerBoard", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField6 = ORKADB_FieldCreate( boardsTable, "Drivers", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField7 = ORKADB_FieldCreate( boardsTable, "FPGAs", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing );
        ORKAGD_g_BoardField8 = ORKADB_FieldCreate( boardsTable, "PCIeBars", ORKADB_FieldType_Table, ORKADB_FieldOption_Nothing );

        char *fullName = NULL;
        //        // store addresses of registers
        //        ORKAGD_g_ipRegisterHandleMap = ORKAVEC_Create( sizeof( ORKAGD_FPGAComponentRegister_t * ) );

        // read in FPGA configs
        fullName = StringAddFilenameToPath( configFileSearchPath, "ORKAFPGAs.json" );
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: FpgaConfigFile: %s\n", fullName );
        bool rc = ORKAGD_FPGAFileRead( fullName );
        StringDestroy( fullName );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: FpgaConfigFile: %s\n", rc ? "(ok)" : "(Nok)" );

        // read in the interpreter file
        fullName = StringAddFilenameToPath( configFileSearchPath, "ORKAInterpreter.json" );
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: InterpreterConfigFile: %s\n", fullName );
        rc &= ORKAGD_InterpreterFileRead( fullName );
        StringDestroy( fullName );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: InterpreterConfigFile: %s\n", rc ? "(ok)" : "(Nok)" );

        // create component tables
        ORKAGD_ComponentTableCreate();

        // read in the configuration
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "\n" );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: ConfigProcess: %s\n", bitstreamSearchPath );
        rc &= ORKAGD_ConfigProcess( bitstreamSearchPath );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: ConfigProcess: %s\n", rc ? "(ok)" : "(Nok)" );
        ORKAGD_DBG_PRINTF( "ORKAGD_Init: Finished ...\n" );
        ORKAGD_DBG_PRINTF( "\n" );

        ORKAGD_g_PathnameTempWrite   = pathnameTempWrite;
        ORKAGD_g_BitstreamSearchPath = bitstreamSearchPath;

        rv = rc ? ORKAGD_EC_SUCCESS : ORKAGD_EC_WRONG_PARAMETER;
    }

    ORKAGD_g_Intern_Initialized = ( ORKAGD_EC_SUCCESS == rv );
    return rv;
}

void
ORKAGD_Deinit()
{
    if ( ORKAGD_g_Intern_Initialized )
    {
        ORKAGD_CleanUp();
    }
}

void *
ORKAGD_BoardListOpen( void *targetConfig )
{
    void *rv = NULL;

    // todo: select target from targetConfig
    // todo: secure code

    if ( ORKAGD_g_Intern_Initialized )
    {
        ORKAGD_ConfigTarget_t * configTarget = ( ORKAGD_ConfigTarget_t * ) targetConfig;
        ORKAGD_TargetBoardList *tbl          = ( ORKAGD_TargetBoardList * ) calloc( sizeof( ORKAGD_TargetBoardList ), 1 );
        if ( tbl )
        {
            tbl->dataBase                 = ORKAGD_DBOpen( "ORKADatabase" );
            tbl->tableBoard               = ORKADB_TableHandleGet( tbl->dataBase, "Boards" );
            tbl->fieldComment             = ORKADB_FieldOpen( tbl->tableBoard, "Comment" );
            tbl->fieldInfrastructureName  = ORKADB_FieldOpen( tbl->tableBoard, "InfrastructureName" );
            tbl->fieldBoardName           = ORKADB_FieldOpen( tbl->tableBoard, "BoardName" );
            tbl->fieldBlockDesignName     = ORKADB_FieldOpen( tbl->tableBoard, "BlockDesignName" );
            tbl->fieldManufacturerBoard   = ORKADB_FieldOpen( tbl->tableBoard, "ManufacturerBoard" );
            tbl->fieldManufacturerDrivers = ORKADB_FieldOpen( tbl->tableBoard, "Drivers" );
            tbl->fieldManufacturerFPGAs   = ORKADB_FieldOpen( tbl->tableBoard, "FPGAs" );
            tbl->fieldPCIeBars            = ORKADB_FieldOpen( tbl->tableBoard, "PCIeBars" );
            ORKADB_TableDump( tbl->dataBase, "Boards" );

            // now we create a list of records containing all boards matching
            // the requirements stated in the targetConfig
            tbl->recordList = ORKADB_RecordListCreate( tbl->tableBoard, tbl->fieldInfrastructureName, configTarget->m_InfrastructureFilename );

            // to be able to iterate over this list we create an iterator
            tbl->iter = ORKAVEC_IterCreate( tbl->recordList );

            // the first element is gathered here
            tbl->recordCurrent = ORKAVEC_IterBegin( tbl->iter );

            // as no element is read so far the first element is now already the next one
            tbl->recordNext = tbl->recordCurrent;

            do
            {
                // get the table of FPGAs
                ORKADB_TableHandle_t **tableFPGAs = ( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( tbl->recordCurrent, tbl->fieldManufacturerFPGAs ) ) ); // get back a pointer to the tablehandle
                if ( !tableFPGAs )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD: Error: No FPGAs found in config\n" );
                    break;
                }
                tbl->tableFPGAs = *tableFPGAs;
                ORKADB_TableDump( tbl->dataBase, "FPGAs" );

                // get the table of drivers
                ORKADB_TableHandle_t **tableDrivers = ( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( tbl->recordCurrent, tbl->fieldManufacturerDrivers ) ) ); // get back a pointer to the tablehandle
                if ( !tableDrivers )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD: Error: No drivers found in config\n" );
                    break;
                }
                tbl->tableDrivers = *tableDrivers;
                ORKADB_TableDump( tbl->dataBase, "Drivers" );

                // get the table of PCIe bars
                ORKADB_TableHandle_t **tablePCIeBars = ( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( tbl->recordCurrent, tbl->fieldPCIeBars ) ) ); // get back a pointer to the tablehandle
                if ( !tablePCIeBars )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD: Error: No PCIe bars found in config\n" );
                    break;
                }
                tbl->tablePCIeBars = *tablePCIeBars;
                ORKADB_TableDump( tbl->dataBase, "PCIeBars" );

                rv = ( void * ) tbl;
            } while ( 0 );
        }
    }
    return rv;
}

void
ORKAGD_BoardListClose( void *boardControlHandle )
{
    if ( ORKAGD_g_Intern_Initialized && boardControlHandle )
    {
        ORKAGD_TargetBoardList *tbl = ( ORKAGD_TargetBoardList * ) boardControlHandle;
        ORKAVEC_IterDestroy( tbl->iter );
        ORKADB_RecordListDestroy( tbl->recordList );
    }
}

bool_t
ORKAGD_BoardListRead( void *boardControlHandle )
{
    bool_t rv = FALSE;
    if ( ORKAGD_g_Intern_Initialized && boardControlHandle )
    {
        ORKAGD_TargetBoardList *tbl = ( ORKAGD_TargetBoardList * ) boardControlHandle;
        tbl->recordCurrent          = tbl->recordNext;
        rv                          = ORKAVEC_IterEnd( tbl->iter );
        tbl->recordNext             = ORKAVEC_IterNext( tbl->iter );
    }
    return rv;
}

char *
ORKAGD_BoardGetName( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl    = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  field  = tbl->fieldBoardName;
    char *                  rv     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, field ) ); // get back a pointer to the string-pointer
    return rv;
}
char *
ORKAGD_BoardGetComment( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl    = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  field  = tbl->fieldComment;
    char *                  rv     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, field ) ); // get back a pointer to the string-pointer
    return rv;
}
char *
ORKAGD_BoardGetInfrastructureName( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl    = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  field  = tbl->fieldInfrastructureName;
    char *                  rv     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, field ) ); // get back a pointer to the string-pointer
    return rv;
}
char *
ORKAGD_BoardGetManufacturerName( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl    = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  field  = tbl->fieldBoardName;
    char *                  rv     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, field ) ); // get back a pointer to the string-pointer
    return rv;
}
uint64_t
ORKAGD_BoardGetNumDrivers( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl          = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record       = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  field        = tbl->fieldManufacturerDrivers;
    ORKADB_TableHandle_t *  tableDrivers = *( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( record, field ) ) ); // get back a pointer to the tablehandle
    return ORKAVEC_Size( tableDrivers->records );
}
uint64_t
ORKAGD_BoardGetNumFPGAs( void *boardControlHandle )
{
    ORKAGD_TargetBoardList *tbl    = ( ORKAGD_TargetBoardList * ) boardControlHandle;
    ORKADB_RecordHandle_t * record = tbl->recordCurrent;
    ORKADB_RecordDump( record );
    ORKADB_FieldHandle_t *field      = tbl->fieldManufacturerFPGAs;
    ORKADB_TableHandle_t *tableFPGAs = *( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( record, field ) ) ); // get back a pointer to the tablehandle
    return ORKAVEC_Size( tableFPGAs->records );
}

// external known function
uint64_t
ORKAGD_FPGAComponentsGetNumOf( void *fpgaHandle )
{
    uint64_t rv = 0;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandeNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        rv                                = fpgaHandeNew->componentArrayNumEntries;
    }
    return rv;
}

// external known function
const ORKAGD_FPGAComponent_t *
ORKAGD_FPGAComponentsGetEntry( void *fpgaHandle, uint64_t index )
{
    ORKAGD_FPGAComponent_t *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandeNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        if ( index < fpgaHandeNew->componentArrayNumEntries )
        {
            rv = &( fpgaHandeNew->componentArrayData[ index ] );
        }
    }
    return rv;
}

static void
ORKADB_RecordDumpInternalxxx( ORKADB_RecordHandle_t *record )
{
    if ( record )
    {
        ORKADB_TableHandle_t *tableHandle = record->tableHandle;
        ORKAVEC_Vector_t *    fields      = tableHandle->fields;
        uint64_t              numFields   = ORKAVEC_Size( fields );

        for ( uint64_t j = 0; j < numFields; ++j )
        {
            ORKADB_FieldHandle_t **fieldHandle = ( ORKADB_FieldHandle_t ** ) ORKAVEC_GetAt( fields, j );
            if ( fieldHandle )
            {
                if ( *fieldHandle )
                {
                    // ORKADB_DBG_PRINTF( "%s, ", fieldHandle->fieldName );
                    void *fieldAddr = &( ( char * ) ( record->recordData ) )[ ( *fieldHandle )->fieldOffsetInRecord ];
                    switch ( ( *fieldHandle )->fieldType )
                    {
                        default:
                        case ORKADB_FieldType_UnknownPointer:
                        case ORKADB_FieldType_Table:
                        case ORKADB_FieldType_ValueI24:
                        case ORKADB_FieldType_ValueU24:
                            ORKADB_DBG_PRINTF_INT( PRIp ", ", *( ( void ** ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI8:
                            ORKADB_DBG_PRINTF_INT( "      0x%2.2x, ", *( ( int8_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU8:
                            ORKADB_DBG_PRINTF_INT( "      0x%2.2x, ", *( ( uint8_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI16:
                            ORKADB_DBG_PRINTF_INT( "    0x%4.4x, ", *( ( int16_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU16:
                            ORKADB_DBG_PRINTF_INT( "    0x%4.4x, ", *( ( uint16_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI32:
                            ORKADB_DBG_PRINTF_INT( "0x%8.8x, ", *( ( int32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU32:
                            ORKADB_DBG_PRINTF_INT( "0x%8.8x, ", *( ( uint32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI64:
                            ORKADB_DBG_PRINTF_INT( "0x%16.16" PRIx64 ", ", *( ( int64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU64:
                            ORKADB_DBG_PRINTF_INT( "0x%16.16" PRIx64 ", ", *( ( int64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueF32:
                            ORKADB_DBG_PRINTF_INT( "%-7.3f, ", *( ( float32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueF64:
                            ORKADB_DBG_PRINTF_INT( "%-7.3f, ", *( ( float64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_StringC:
                            ORKADB_DBG_PRINTF_INT( "%-60.60s, ", *( ( char ** ) fieldAddr ) );
                            break;
                    }
                }
            }
        }
        ORKADB_DBG_PRINTF_INT( "\n" );
    }
}

static void
ORKAGD_FPGAComponentsCreateList( void *fpgaHandle )
{
    do
    {
        if ( NULL == fpgaHandle )
        {
            break;
        }

        ORKAGD_FPGAHandle_t * fpgaHandeNew    = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKADB_TableHandle_t *tableComponents = fpgaHandeNew->tableComponents;
        uint64_t              numComponents   = ORKADB_TableNumEntries( tableComponents );

        if ( 0 == numComponents )
        {
            ORKADB_DBG_PRINTF( "ORKAGD_FPGAComponentsCreateList(): numComponents == 0" );
            break;
        }
        ORKAGD_FPGAComponent_t *componentArrayData = calloc( 1, numComponents * sizeof( ORKAGD_FPGAComponent_t ) );
        if ( NULL == componentArrayData )
        {
            ORKADB_DBG_PRINTF( "ORKAGD_FPGAComponentsCreateList(): componentArrayData == 0" );
            break;
        }
        fpgaHandeNew->componentArrayData       = componentArrayData;
        fpgaHandeNew->componentArrayNumEntries = numComponents;

        for ( uint64_t i = 0; i < numComponents; ++i )
        {
            // get desired record from database
            void *record = ( ( void * ) ORKADB_RecordGetAt( tableComponents, i ) );
            if ( record )
            {
                // get address of array element
                ORKAGD_FPGAComponent_t *componentArrayDataEntry = &componentArrayData[ i ];

                // fillup array element
                componentArrayDataEntry->ipDesignComponentName         = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsName ) );
                componentArrayDataEntry->ipOffset                      = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsOffset ) );
                componentArrayDataEntry->ipRange                       = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsRange ) );
                componentArrayDataEntry->ipType                        = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsType ) );
                componentArrayDataEntry->ipSubType                     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsSubType ) );
                componentArrayDataEntry->ipAccess                      = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsIpAccess ) );
                componentArrayDataEntry->ipDesignComponentTemplateName = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsIpAddress ) );
                componentArrayDataEntry->ipBitstream                   = NULL;       // tbd
                componentArrayDataEntry->fpgaHandle                    = fpgaHandle; // enables to access the FPGA by the component only
                componentArrayDataEntry->ipRegisterArray               = NULL;       // here we provide a structured access to registers give with the IP
                componentArrayDataEntry->ipRegisterArraySize           = 0;          // preinitialize
                // get table with registers
                void *tableHandleComponentRegistersAddr = ORKADB_RecordGetFieldAddrByHandle( record, fpgaHandeNew->fieldComponentsRegisters );
                if ( tableHandleComponentRegistersAddr ) // should always be successful
                {
                    // get pointer to table now
                    ORKADB_TableHandle_t *tableHandleComponentRegisters = *( ORKADB_TableHandle_t ** ) tableHandleComponentRegistersAddr;
                    if ( tableHandleComponentRegisters )
                    {
                        ORKADB_FieldHandle_t *fieldComponentsRegisterName = ORKADB_FieldOpen( tableHandleComponentRegisters, "name" );
                        ORKADB_FieldHandle_t *fieldComponentsRegisterAddr = ORKADB_FieldOpen( tableHandleComponentRegisters, "addr" );
                        ORKADB_FieldHandle_t *fieldComponentsRegisterBits = ORKADB_FieldOpen( tableHandleComponentRegisters, "bits" );

                        ORKAVEC_Vector_t *recordVector = tableHandleComponentRegisters->records;
                        ORKADB_DBG_PRINTF( "\n" );
                        ORKADB_DBG_PRINTF( "************************************\n" );
                        ORKADB_DBG_PRINTF( "TableDump: '%s'\n", tableHandleComponentRegisters->tableName );
                        if ( recordVector )
                        {
                            ORKADB_RecordHandle_t **entryHandles = ( ORKADB_RecordHandle_t ** ) ( recordVector->vector );
                            if ( entryHandles )
                            {
                                // here we are sure, that we really have a table with entries (if numRecords > 0)
                                uint64_t numRecords = ORKAVEC_Size( recordVector );

                                if ( numRecords > 0 )
                                {
                                    ORKAGD_FPGAComponentRegister_t *regArray = ( ORKAGD_FPGAComponentRegister_t * ) calloc( numRecords, sizeof( ORKAGD_FPGAComponentRegister_t ) );
                                    if ( regArray )
                                    {
                                        ORKADB_DBG_PRINTF( "TableDump: %s (%" PRId64 " entries, address: " PRIp ")\n", tableHandleComponentRegisters->tableName, numRecords, tableHandleComponentRegisters );

                                        // store real number of named registers
                                        componentArrayDataEntry->ipRegisterArraySize = numRecords;

                                        // loop over all table entries and copy them element for element into the new array
                                        for ( uint64_t idx = 0; idx < numRecords; ++idx )
                                        {
                                            // the record (line in table)
                                            ORKADB_RecordHandle_t *recordRegisterEntry = entryHandles[ idx ];

                                            ORKADB_RecordDumpInternalxxx( recordRegisterEntry );

                                            // extract table elements and fill into structure
                                            regArray[ idx ].name     = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( recordRegisterEntry, fieldComponentsRegisterName ) );
                                            regArray[ idx ].offset   = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordRegisterEntry, fieldComponentsRegisterAddr ) );
                                            regArray[ idx ].bitwidth = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordRegisterEntry, fieldComponentsRegisterBits ) );

                                            regArray[ idx ].absoluteOffset = ( componentArrayDataEntry->ipOffset ) + regArray[ idx ].offset;

                                            // to allow acces directly by a handle we have to store additional information here:
                                            regArray[ idx ].component = componentArrayDataEntry;
#if 0
                                            regArray[ idx ].handle = ORKAGD_g_ipRegisterHandle++;
                                            ORKAVEC_PushBack( ORKAGD_g_ipRegisterHandleMap, &regArray[ idx ] );
#endif
                                        }
                                        // make new array available for later access
                                        componentArrayDataEntry->ipRegisterArray = regArray;
                                    }
                                }
                            }
                            else
                            {
                                ORKADB_DBG_PRINTF( "TableDump: Error: No entries!\n" );
                            }
                        }
                        else
                        {
                            ORKADB_DBG_PRINTF( "TableDump: Error: No records!\n" );
                        }
                        ORKADB_DBG_PRINTF( "************************************\n\n" );
                        ORKADB_TableHandleDump( tableHandleComponentRegisters );
                    }
                }
            }
            else
            {
                break;
            }
        }
    } while ( 0 );
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool
ORKAGD_RegisterNameExist( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint64_t rc = false;
    if ( component )
    {
        ORKAGD_FPGAComponentRegister_t *regArray = component->ipRegisterArray;
        if ( regArray )
        {
            uint64_t numRecords = component->ipRegisterArraySize;

            // loop over all table entries and copy them element for element into the new array
            for ( uint64_t idx = 0; idx < numRecords; ++idx )
            {
                // extract table elements and fill into structure
                if ( 0 == strcmp( registerName, regArray[ idx ].name ) )
                {
                    rc = true;
                    break;
                }
            }
        }
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetOffsetByName( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint64_t rc = ORKA_ILLEGAL_VALUE;
    if ( component )
    {
        ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
        uint64_t                        numRecords = component->ipRegisterArraySize;

        // loop over all table entries and copy them element for element into the new array
        for ( uint64_t idx = 0; idx < numRecords; ++idx )
        {
            // extract table elements and fill into structure
            if ( 0 == strcmp( registerName, regArray[ idx ].name ) )
            {
                rc = regArray[ idx ].offset;
                break;
            }
        }
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetOffsetByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx )
{
    uint64_t rc = ORKA_ILLEGAL_VALUE;
    if ( component )
    {
        ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
        uint64_t                        numRecords = component->ipRegisterArraySize;

        // loop over all table entries and copy them element for element into the new array
        if ( idx < numRecords )
        {
            rc = regArray[ idx ].offset;
        }
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetOffsetByHandle( const uint64_t handle )
{
    uint64_t offset = ORKA_ILLEGAL_VALUE;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );

        offset = regEntry->offset;
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterGetOffsetByHandle(): Failed: Handle wrong ...n\n" );
    }
    return offset;
}

uint64_t
ORKAGD_RegisterGetBitWidthByName( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
    uint64_t                        numRecords = component->ipRegisterArraySize;
    uint64_t                        rc         = ORKA_ILLEGAL_VALUE;

    // loop over all table entries and copy them element for element into the new array
    for ( uint64_t idx = 0; idx < numRecords; ++idx )
    {
        // extract table elements and fill into structure
        if ( 0 == strcmp( registerName, regArray[ idx ].name ) )
        {
            rc = regArray[ idx ].bitwidth;
            break;
        }
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetBitWidthByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx )
{
    ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
    uint64_t                        numRecords = component->ipRegisterArraySize;
    uint64_t                        rc         = ORKA_ILLEGAL_VALUE;

    // loop over all table entries and copy them element for element into the new array
    if ( idx < numRecords )
    {
        rc = regArray[ idx ].bitwidth;
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetBitWidthByHandle( const uint64_t handle )
{
    uint64_t width = ORKA_ILLEGAL_VALUE;

    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );

        width = regEntry->bitwidth;
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterGetBitWidthByHandle(): Failed: Handle wrong ...n\n" );
    }
    return width;
}

uint64_t
ORKAGD_RegisterGetHandleByName( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
    uint64_t                        numRecords = component->ipRegisterArraySize;
    uint64_t                        rc         = 0ULL;
    ORKAGD_DBG_PRINTF( "ORKAGD_RegisterGetHandleByName(): enter (%s) ...\n", registerName );

    // loop over all table entries and copy them element for element into the new array
    for ( uint64_t idx = 0; idx < numRecords; ++idx )
    {
        // extract table elements and fill into structure
        if ( 0 == strcmp( registerName, regArray[ idx ].name ) )
        {
            rc = ( uint64_t ) ( ( void * ) ( &regArray[ idx ] ) );
            ORKAGD_DBG_PRINTF( "ORKAGD_RegisterGetHandleByName(): rc = 0x%16.16" PRIx64 "\n", rc );
            break;
        }
    }
    ORKAGD_DBG_PRINTF( "ORKAGD_RegisterGetHandleByName(): leave: rc = 0x%16.16" PRIx64 "\n", rc );
    return rc;
}

uint64_t
ORKAGD_RegisterGetHandleByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t idx )
{
    uint64_t rc = 0ULL;
    if ( component )
    {
        ORKAGD_FPGAComponentRegister_t *regArray = component->ipRegisterArray;
        if ( regArray )
        {
            uint64_t numRecords = component->ipRegisterArraySize;

            // loop over all table entries and copy them element for element into the new array
            if ( idx < numRecords )
            {
                rc = ( uint64_t ) ( ( void * ) ( &regArray[ idx ] ) );
            }
        }
    }
    return rc;
}

uint64_t
ORKAGD_RegisterGetNumIndexOf( const ORKAGD_FPGAComponent_t *component )
{
    uint64_t numRecords = ORKA_ILLEGAL_VALUE;
    if ( component )
    {
        numRecords = component->ipRegisterArraySize;
    }
    return numRecords;
}

uint64_t
ORKAGD_RegisterGetIndexOf( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint64_t rc = ORKA_ILLEGAL_VALUE;
    if ( component )
    {
        ORKAGD_FPGAComponentRegister_t *regArray   = component->ipRegisterArray;
        uint64_t                        numRecords = component->ipRegisterArraySize;
        if ( regArray )
        {
            // loop over all table entries and copy them element for element into the new array
            for ( uint64_t idx = 0; idx < numRecords; ++idx )
            {
                // extract table elements and fill into structure
                if ( 0 == strcmp( registerName, regArray[ idx ].name ) )
                {
                    rc = idx;
                    break;
                }
            }
        }
    }
    return rc;
}

bool
ORKAGD_RegisterWriteByName( const ORKAGD_FPGAComponent_t *component, const char *registerName, const void *value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t handle = ORKAGD_RegisterGetHandleByName( component, registerName );
        if ( handle )
        {
            rv = ORKAGD_RegisterWriteByHandle( handle, value );
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByNameU32( const ORKAGD_FPGAComponent_t *component, const char *registerName, const uint32_t value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByName( component, registerName );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ORKAGD_RegisterU32Write( component, offset, value );
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByNameU64( const ORKAGD_FPGAComponent_t *component, const char *registerName, const uint64_t value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByName( component, registerName );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ORKAGD_RegisterU32Write( component, offset, ( uint32_t ) value );
            rv &= ORKAGD_RegisterU32Write( component, offset + 4, ( uint32_t ) ( value >> 32 ) );
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const void *value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            uint64_t width = ORKAGD_RegisterGetBitWidthByIndex( component, registerIndex );
            switch ( width )
            {
                default:
                    rv = false;
                    break;
                case 64:
                    rv = ORKAGD_RegisterU32Write( component, offset + 4, ( *( ( uint64_t * ) value ) ) >> 32 );
                case 32:
                    rv &= ORKAGD_RegisterU32Write( component, offset, ( uint32_t ) ( *( ( uint64_t * ) value ) ) );
                    break;
            }
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByIndexU32( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint32_t value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ORKAGD_RegisterU32Write( component, offset, value );
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByIndexU64( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint64_t value )
{
    bool rv = false;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ORKAGD_RegisterU32Write( component, offset, ( uint32_t ) value );
            rv &= ORKAGD_RegisterU32Write( component, offset + 4, ( uint32_t ) ( value >> 32 ) );
        }
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByHandle( const uint64_t handle, const void *value )
{
    bool rv = false;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;
            uint64_t width  = regEntry->bitwidth;

            switch ( width )
            {
                default:
                    ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandle(): Failed: BitWidth not supported ...n\n" );
                    rv = false;
                    break;
                case 64:
                    rv = ORKAGD_RegisterU32Write( component, offset + 4, ( *( ( uint64_t * ) value ) ) >> 32 );
                case 32:
                    rv &= ORKAGD_RegisterU32Write( component, offset, ( uint32_t ) ( *( ( uint64_t * ) value ) ) );
                    break;
            }
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandle(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandle(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByHandleU32( const uint64_t handle, const uint32_t *value )
{
    bool rv = false;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;

            rv = ORKAGD_RegisterU32Write( component, offset, *value );
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandleU32(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandleU32(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

bool
ORKAGD_RegisterWriteByHandleU64( const uint64_t handle, const uint64_t *value )
{
    bool rv = false;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;

            rv = ORKAGD_RegisterU32Write( component, offset, ( uint32_t ) ( *value ) );
            rv &= ORKAGD_RegisterU32Write( component, offset + 4, ( uint32_t ) ( ( *value ) >> 32 ) );
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandleU64(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterWriteByHandleU64(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

uint64_t
ORKAGD_RegisterReadByName( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint64_t rv = 0ULL;
    if ( component )
    {
        uint64_t handle = ORKAGD_RegisterGetHandleByName( component, registerName );
        if ( handle )
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByName(): ORKAGD_RegisterGetHandleByName(): handle = 0x%16.16" PRIx64 "\n", handle );

            rv = ORKAGD_RegisterReadByHandle( handle );
        }
    }
    ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByName(): ORKAGD_RegisterReadByHandle(): rv = 0x%16.16" PRIx64 "\n", rv );
    return rv;
}

uint32_t
ORKAGD_RegisterReadByNameU32( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint32_t rv = 0ULL;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByName( component, registerName );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ORKAGD_RegisterU32Read( component, offset );
        }
    }
    return rv;
}

uint64_t
ORKAGD_RegisterReadByNameU64( const ORKAGD_FPGAComponent_t *component, const char *registerName )
{
    uint64_t rv = 0ULL;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByName( component, registerName );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            rv = ( ( uint64_t ) ( ORKAGD_RegisterU32Read( component, offset + 4 ) ) ) << 32;
            rv |= ORKAGD_RegisterU32Read( component, offset );
        }
    }
    return rv;
}

uint64_t
ORKAGD_RegisterReadByIndex( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex )
{
    uint64_t rv = 0;
    if ( component )
    {
        uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );
        if ( ORKA_ILLEGAL_VALUE != offset )
        {
            uint64_t width = ORKAGD_RegisterGetBitWidthByIndex( component, registerIndex );

            switch ( width )
            {
                default:
                    break;
                case 64:
                    rv = ( ( uint64_t ) ORKAGD_RegisterU32Read( component, offset + 4 ) ) << 32;
                case 32:
                    rv |= ORKAGD_RegisterU32Read( component, offset );
                    break;
            }
        }
    }
    return rv;
}

uint32_t
ORKAGD_RegisterReadByIndexU32( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex, const uint32_t value )
{
    uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );
    uint32_t rv     = ORKAGD_RegisterU32Read( component, offset );
    return rv;
}

uint64_t
ORKAGD_RegisterReadByIndexU64( const ORKAGD_FPGAComponent_t *component, const uint64_t registerIndex )
{
    uint64_t offset = ORKAGD_RegisterGetOffsetByIndex( component, registerIndex );

    uint64_t rv = ( uint64_t ) ORKAGD_RegisterU32Read( component, offset );
    rv |= ( ( uint64_t ) ORKAGD_RegisterU32Read( component, offset + 4 ) ) << 32;
    return rv;
}

uint64_t
ORKAGD_RegisterReadByHandle( const uint64_t handle )
{
    uint64_t rv = 0;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;
            uint64_t width  = regEntry->bitwidth;

            switch ( width )
            {
                default:
                    break;
                case 64:
                    rv = ( ( uint64_t ) ORKAGD_RegisterU32Read( component, offset + 4 ) ) << 32;
                case 32:
                    rv |= ORKAGD_RegisterU32Read( component, offset );
                    break;
            }
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandle(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandle(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

uint32_t
ORKAGD_RegisterReadByHandleU32( const uint64_t handle )
{
    uint32_t rv = 0;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;
            rv              = ORKAGD_RegisterU32Read( component, offset );
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU32(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU32(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

uint64_t
ORKAGD_RegisterReadByHandleU64( const uint64_t handle )
{
    uint64_t rv = 0;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;

            rv = ( uint64_t ) ORKAGD_RegisterU32Read( component, offset );
            rv |= ( ( uint64_t ) ORKAGD_RegisterU32Read( component, offset + 4 ) ) << 32;
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU64(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU64(): Failed: Handle wrong ...n\n" );
    }
    return rv;
}

// ===========================================================================================
// attention: gives back a value to the memory location where the pointer points to (*pvalue).
// This can be (dependent on the bitwidth of the register) 4 bytes OR 8 bytes (yet, so far) !
// ===========================================================================================
void
ORKAGD_RegisterReadByHandleEx( const uint64_t handle, void *pValue )
{
    uint64_t  rv64;
    uint64_t *prv64;
    uint32_t  rv32;
    uint32_t *prv32;

    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;
            uint64_t width  = regEntry->bitwidth;

            switch ( width )
            {
                default:
                    ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleEx(): Failed: BitWidth not supported ...n\n" );
                    break;
                case 64:
                    prv64 = ( uint64_t * ) pValue;
                    rv64  = ( ( uint64_t ) ( ORKAGD_RegisterU32Read( component, offset + 4 ) ) ) << 32;
                    rv64 |= ( ( uint64_t ) ( ORKAGD_RegisterU32Read( component, offset ) ) );
                    *prv64 = rv64;
                    break;
                case 32:
                    prv32  = ( uint32_t * ) pValue;
                    rv32   = ORKAGD_RegisterU32Read( component, offset );
                    *prv32 = rv32;
                    break;
            }
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleEx(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleEx(): Failed: Handle wrong ...n\n" );
    }
}

void
ORKAGD_RegisterReadByHandleU32Ex( const uint64_t handle, uint32_t *pValue )
{
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            uint64_t offset = regEntry->offset;
            *pValue         = ORKAGD_RegisterU32Read( component, offset );
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU32Ex(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU32Ex(): Failed: Handle wrong ...n\n" );
    }
}

void
ORKAGD_RegisterReadByHandleU64Ex( const uint64_t handle, uint64_t *pValue )
{
    uint64_t rv;
    if ( handle )
    {
        ORKAGD_FPGAComponentRegister_t *regEntry  = ( ORKAGD_FPGAComponentRegister_t * ) ( ( void * ) handle );
        const ORKAGD_FPGAComponent_t *  component = regEntry->component;
        if ( component )
        {
            if ( pValue )
            {
                uint64_t offset = regEntry->offset;

                rv = ( uint64_t ) ORKAGD_RegisterU32Read( component, offset );
                rv |= ( ( uint64_t ) ORKAGD_RegisterU32Read( component, offset + 4 ) ) << 32;
                *pValue = rv;
            }
        }
        else
        {
            ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU64Ex(): Failed: Component pointer wrong ...n\n" );
        }
    }
    else
    {
        ORKADB_DBG_PRINTF( "ORKAGD_RegisterReadByHandleU64Ex(): Failed: Handle wrong ...n\n" );
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if 0
// new version
void *
ORKAGD_FPGAHandleCreate( void *board, uint64_t indexFPGA )
{
    bool                    found                   = false;
    ORKAGD_TargetBoardList *tbl                     = ( ORKAGD_TargetBoardList * ) board;
    ORKADB_RecordHandle_t * recordBoard             = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  fieldFPGA               = tbl->fieldManufacturerFPGAs;
    ORKADB_FieldHandle_t *  fieldInfrastructureName = tbl->fieldInfrastructureName;
    char *                  infrastructureName      = *( ( char ** ) ( ORKADB_RecordGetFieldAddrByHandle( recordBoard, fieldInfrastructureName ) ) );   // get back a pointer to the string
    ORKADB_TableHandle_t *  tableFPGAs              = *( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( recordBoard, fieldFPGA ) ) ); // get back a pointer to the tablehandle
    ORKADB_TableHandle_t *  tableDrivers            = tbl->tableDrivers;
    ORKADB_TableHandle_t *  tablePCIeBars           = tbl->tablePCIeBars;

    // reserve space of a "collector struct"
    ORKAGD_FPGAHandle_t *rv = ( ORKAGD_FPGAHandle_t * ) calloc( 1, sizeof( ORKAGD_FPGAHandle_t ) );
    ORKAGD_DBG_PRINTF( "Handle = " PRIp "\n", rv );
    do // start pseudo loop (easier exit on error)
    {
        if ( !rv )
        {
            ORKAGD_DBG_PRINTF( "ERROR! Handle = " PRIp "\n", rv );
            break;
        }

        rv->board = tbl;
        ORKADB_TableHandleDump( tableFPGAs );

        // with the index of the FPGA we access the table holding all FPGAs. Here we get the complete record.
        ORKADB_RecordHandle_t **recPtr = ( ORKADB_RecordHandle_t ** ) ORKAVEC_GetAt( tableFPGAs->records, indexFPGA );
        if ( !recPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR! No FPGA record ...\n" );
            break;
        }
        rv->recordFPGA = *recPtr;

        // dump it out
        ORKADB_RecordDump( rv->recordFPGA );

        // to access the record, we have to know the filed information.
        rv->tableFPGAs             = tableFPGAs;
        rv->fieldFullNameQualifier = ORKADB_FieldHandleGet( tableFPGAs, "FullNameQualifier" );
        rv->fieldDriver            = ORKADB_FieldHandleGet( tableFPGAs, "Driver" );
        rv->fieldComponents        = ORKADB_FieldHandleGet( tableFPGAs, "Components" );
        rv->fieldMemoryRegions     = ORKADB_FieldHandleGet( tableFPGAs, "MemoryRegions" );

        // components table belonging to this specific FPGA
        // ================================================

        // here we get the content(!) of the fieldComponents field. This field represents a new table.
        ORKADB_TableHandle_t **handlePtr = ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldComponents ) ); // get back a pointer to the tablehandle
        if ( !handlePtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR! No componentstable found ...\n" );
            break;
        }
        rv->tableComponents = *handlePtr;

        // to access the records of this component table, we need information about its fields
        rv->fieldComponentsName      = ORKADB_FieldHandleGet( rv->tableComponents, "name" );
        rv->fieldComponentsOffset    = ORKADB_FieldHandleGet( rv->tableComponents, "offset" );
        rv->fieldComponentsRange     = ORKADB_FieldHandleGet( rv->tableComponents, "range" );
        rv->fieldComponentsType      = ORKADB_FieldHandleGet( rv->tableComponents, "type" );
        rv->fieldComponentsIpAddress = ORKADB_FieldHandleGet( rv->tableComponents, "ipAddress" );
        rv->fieldComponentsSubType   = ORKADB_FieldHandleGet( rv->tableComponents, "subtype" );
        rv->fieldComponentsIpAccess  = ORKADB_FieldHandleGet( rv->tableComponents, "ipAccess" );
        rv->fieldComponentsRegisters = ORKADB_FieldHandleGet( rv->tableComponents, "Registers" );

        // here we get the content(!) of the fieldMemoryRegions field. This field represents a new table.
        ORKADB_TableHandle_t **memRegionsPtr = ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldMemoryRegions ) ); // get back a pointer to the tablehandle
        if ( !memRegionsPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR! No memory regions table found ... [at least one entry should exist]\n" );
            break;
        }
        rv->tableMemoryRegions = *memRegionsPtr;

        // to access the records of this fieldMemoryRegions table, we need information about its fields
        rv->fieldMemoryRegionsOffset = ORKADB_FieldHandleGet( rv->tableMemoryRegions, "memcpyOffset" );
        void *    record             = ( ( void * ) ORKADB_RecordGetAt( rv->tableMemoryRegions, 0 ) );
        uint64_t *memcpyOffsetPtr    = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( record, rv->fieldMemoryRegionsOffset );

        // from board, get the driver parameters
        rv->fieldDriverParamsDriverName = ORKADB_FieldHandleGet( tableDrivers, "DriverName" );
        rv->fieldDriverParamsInstance   = ORKADB_FieldHandleGet( tableDrivers, "Instance" );
        rv->fieldDriverParamsPort       = ORKADB_FieldHandleGet( tableDrivers, "Port" );
        rv->fieldDriverParamsSpeed      = ORKADB_FieldHandleGet( tableDrivers, "Speed" );
        rv->fieldDriverParamsAddress    = ORKADB_FieldHandleGet( tableDrivers, "Address" );

        // from the board, get the PCIeBar parameters
        rv->board->fieldPCIeBarType = ORKADB_FieldHandleGet( tablePCIeBars, "type" );
        rv->board->fieldPCIeBarSize = ORKADB_FieldHandleGet( tablePCIeBars, "size" );

        // extract the full qualified FPGA name
        char **fnqPtr = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldFullNameQualifier ); // get back a pointer to the string-pointer
        if ( !fnqPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR! No FPGA full name qualifier found\n" );
            break;
        }
        char *fullNameQualifierNeeded = *fnqPtr;

        // get the driverIndex
        uint64_t *diPtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldDriver );
        if ( !fnqPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR! No driver index found\n" );
            break;
        }
        rv->driverIndex = *diPtr;

        uint64_t numDriversAvailable = ORKAVEC_Size( tbl->tableDrivers->records );
        ORKAGD_DBG_PRINTF( "numDrivers = %" PRId64 "\n", numDriversAvailable );
        if ( ( rv->driverIndex < numDriversAvailable ) && memcpyOffsetPtr )
        {
            rv->memcpyOffset = *memcpyOffsetPtr;

            // with the index we access now the specified driver parameter block
            ORKADB_RecordHandle_t *entryDriverParamsRecord = ( ( ORKADB_RecordHandle_t * ) ORKADB_RecordGetAt( tableDrivers, rv->driverIndex ) );
            if ( !entryDriverParamsRecord )
            {
                ORKAGD_DBG_PRINTF( "ERROR! No driver parameter record found\n" );
                break;
            }
            // ORKADB_RecordDump( entryDriverParamsRecord );

            // now look in the list of all FPGAs whether we support this FPGA
            ORKAVEC_Iter_t *iter = ORKAVEC_IterCreate( ORKAGD_g_FPGADescriptions );
            ORKAGD_DBG_PRINTF( "Requested FPGA is '%s' - Looking for appropriate FPGA from internal database ...\n", fullNameQualifierNeeded );
            for ( void *i = ORKAVEC_IterBegin( iter ); ORKAVEC_IterEnd( iter ); i = ORKAVEC_IterNext( iter ) )
            {
                ORKAGD_FPGADescription_t *fpgaDescription           = ( ORKAGD_FPGADescription_t * ) i; // get back a pointer to the string-pointer
                char *                    fullNameQualifierExamined = fpgaDescription->fullNameQualifier;

                if ( 0 == StringCompareIgnoreCase( fullNameQualifierExamined, fullNameQualifierNeeded ) )
                {
                    // The FPGA is supported ...
                    // now we have the FPGA manufacturer and can look into the drivers list
                    // for drivers of this manufacturer.
                    // We have to check then the specified driver name of the FPGA-Board config
                    // whether this name is available in the list of drivers
                    ORKAGD_DBG_PRINTF( "Check DB with FPGAName '%s' ... Match!\n", fullNameQualifierExamined );

                    ORKAVEC_Iter_t *iter2 = ORKAVEC_IterCreate( ORKAGD_g_TranslatorManufacturers );
                    for ( void *j = ORKAVEC_IterBegin( iter2 ); ( !found ) && ORKAVEC_IterEnd( iter2 ); j = ORKAVEC_IterNext( iter2 ) )
                    {
                        ORKAGD_TranslatorManufacturerBoard_t *translatorManufacturerBoard = ( ORKAGD_TranslatorManufacturerBoard_t * ) j; // get back a pointer to the string-pointer
                        // ORKAGD_DBG_PRINTF( "ManufacturerDrivers: %s\n", translatorManufacturerBoard->manufacturer );
                        if ( 0 == StringCompareIgnoreCase( translatorManufacturerBoard->manufacturer, fpgaDescription->manufacturerName ) )
                        {
                            // Now we look for drivers:
                            // ========================
                            //
                            // look in each entry of the vector whether there is one named as needed
                            ORKAVEC_Iter_t *iter3 = ORKAVEC_IterCreate( translatorManufacturerBoard->drivers );
                            for ( void *k = ORKAVEC_IterBegin( iter3 ); ORKAVEC_IterEnd( iter3 ); k = ORKAVEC_IterNext( iter3 ) )
                            {
                                ORKAGD_TranslatorDriver_t *translatorDriver = ( ORKAGD_TranslatorDriver_t * ) k; // get back a pointer to the driver struct
                                // we extract the desired name, instance and port
                                char *driverName = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsDriverName ) );
                                ORKAGD_DBG_PRINTF( "Check name '%s' with available names from interpreter: %s\n", driverName, translatorDriver->name );

                                // =================================================
                                // special case: TunnelClientServer
                                // in this case we know the access type to the HOST
                                // =================================================
                                if ( 0 == StringCompareIgnoreCase( driverName, ORKAGD_TS_DRIVER_NAME ) )
                                {
                                    ORKAGD_DBG_PRINTF( "TunnelClientServer recognized: %s\n", driverName );
                                    if ( ORKAGD_g_Config.m_TunnelClientEnabled )
                                    {
                                        ORKAGD_DBG_PRINTF( "TunnelClientServer enabled\n" );
                                        uint64_t instance                   = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsInstance ) );
                                        uint64_t port                       = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort ) );
                                        uint64_t connectionIndex            = ORKAGD_TS_ACCESS_ID_INDEX_ACCESS_GET( instance );
                                        uint64_t fileIndex                  = ORKAGD_TS_ACCESS_ID_INDEX_FILE_GET( instance );
                                        rv->interfaceTunnel.m_AccessID      = instance;
                                        rv->interfaceTunnel.connectionIndex = connectionIndex;
                                        rv->interfaceTunnel.fileIndex       = fileIndex;
                                        ORKAGD_TunnelConnectionData_t *tcd  = ( ORKAGD_TunnelConnectionData_t * ) ORKAVEC_GetAt( ORKAGD_g_Config.m_TunnelServerConnectionData, connectionIndex );
                                        if ( tcd )
                                        {
                                            // TODO: release this memory at the end of access !!!
                                            void *p = ORKAGD_calloc( 1, sizeof( ORKAGD_TunnelConnectionData_t ) );
                                            if ( p )
                                            {
                                                rv->interfaceTunnel.m_TunnelConnectionData = p;
                                                memcpy( p, ( void * ) tcd, sizeof( ORKAGD_TunnelConnectionData_t ) );
                                                rv->interfaceAccessType = ORKAGD_ACCESSTYPE_IPV4_TUNNEL;
                                                found                   = true;
                                            }
                                            else
                                            {
                                                ORKAGD_DBG_PRINTF( "ERROR!!! Out of memory\n" );
                                            }
                                        }
                                        else
                                        {
                                            ORKAGD_DBG_PRINTF( "ERROR!!! No connection data found ... (memory problem?)\n" );
                                        }
                                    }
                                    else
                                    {
                                        // server to client connection not implemented so far ...

                                        ORKAGD_DBG_PRINTF( "TunnelClientServer NOT enabled ... (is this desired?)\n" );
                                    }
                                }

                                // if previously not found, try translator driver names ...
                                if ( ( !found ) && 0 == StringCompareIgnoreCase( driverName, translatorDriver->name ) )
                                {

                                    rv->interfaceAccessType = translatorDriver->accessType;

                                    switch ( translatorDriver->accessType )
                                    {
                                        default:
                                        case ORKAGD_ACCESSTYPE_UNDEFINED:
                                        {
                                            ORKAGD_DBG_PRINTF( "* ERROR: accessundefined\n" );
                                            break;
                                        }
                                        case ORKAGD_ACCESSTYPE_XDMA:
                                        {
                                            // Xilinx DMA
                                            ORKAGD_DBG_PRINTF( "* Xilinx DMA access\n" );

                                            // get the access string of the driver interface and
                                            // replace macro keywords by the numbers
                                            uint64_t *instancePtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsInstance );
                                            uint64_t *portPtr     = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort );
                                            if ( instancePtr && portPtr )
                                            {
                                                uint64_t instance = *instancePtr;
                                                uint64_t port     = *portPtr;
#    ifdef ORKAGD_WINDOWS
                                                rv->interfacePCIe.m_DevicePCIConfigName      = "..\\winsim.org";
                                                rv->interfacePCIe.m_DeviceDMAReadName        = "..\\winsim.org";
                                                rv->interfacePCIe.m_DeviceDMAWriteName       = "..\\winsim.org";
                                                rv->interfacePCIe.m_DeviceMemoryMappedIOName = "..\\winsim.org";
#    else
                                                char *tmp;
                                                rv->interfacePCIe.m_DevicePCIConfigName = StringFindAndReplaceU64( translatorDriver->controlAccess, "%interface%", instance );
                                                tmp                                     = StringFindAndReplaceU64( translatorDriver->memcpyd2h, "%interface%", instance );
                                                rv->interfacePCIe.m_DeviceDMAReadName   = StringFindAndReplaceU64( tmp, "%dmachannel%", port );
                                                free( tmp ); // free temporary string
                                                tmp                                    = StringFindAndReplaceU64( translatorDriver->memcpyh2d, "%interface%", instance );
                                                rv->interfacePCIe.m_DeviceDMAWriteName = StringFindAndReplaceU64( tmp, "%dmachannel%", port );
                                                free( tmp ); // free temporary string
                                                rv->interfacePCIe.m_DeviceMemoryMappedIOName = StringFindAndReplaceU64( translatorDriver->registerAccess, "%interface%", instance );
#    endif
                                                found = true;
                                            }
                                            else
                                            {
                                                ORKAGD_DBG_PRINTF( "ERROR: instance or port not set !\n" );
                                            }
                                            break;
                                        }
                                        case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
                                        {
                                            ORKAGD_DBG_PRINTF( "* IntelIOCtl access\n" );
                                            // get the access string of the driver interface and
                                            // replace macro keywords by the numbers
                                            // TODO
                                            // uint64_t instance                            = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsInstance ) );
                                            // uint64_t port                                = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort ) );

                                            rv->interfacePCIe.m_DevicePCIConfigName      = translatorDriver->controlAccess;
                                            rv->interfacePCIe.m_DeviceDMAReadName        = translatorDriver->memcpyd2h;
                                            rv->interfacePCIe.m_DeviceDMAWriteName       = translatorDriver->memcpyh2d;
                                            rv->interfacePCIe.m_DeviceMemoryMappedIOName = translatorDriver->registerAccess;

                                            found = true;
                                            break;
                                        }
                                        case ORKAGD_ACCESSTYPE_IPV4:
                                        {
                                            // accesss with TCP/IP custom protocol
                                            ORKAGD_DBG_PRINTF( "* IPV4 access\n" );
                                            char **   addrPtr  = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsAddress );
                                            uint64_t *portPtr  = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort );
                                            uint64_t *speedPtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsSpeed );
                                            if ( addrPtr && ( *addrPtr ) && portPtr && speedPtr )
                                            {
                                                rv->interfaceIPv4.m_ipv4Address = *addrPtr;
                                                rv->interfaceIPv4.m_ipv4Port    = *portPtr;
                                                rv->interfaceIPv4.m_ipv4Speed   = *speedPtr;
                                                ORKAGD_DBG_PRINTF( "* TCP/IP Address: %s\n", rv->interfaceIPv4.m_ipv4Address );
                                                ORKAGD_DBG_PRINTF( "* TCP/IP Port: %" PRId64 "\n", rv->interfaceIPv4.m_ipv4Port );
                                                ORKAGD_DBG_PRINTF( "* TCP/IP Speed: %" PRId64 "\n", rv->interfaceIPv4.m_ipv4Speed );

                                                found = true;
                                            }
                                            else
                                            {
                                                ORKAGD_DBG_PRINTF( "ERROR: address, port or speed not set !\n" );
                                            }
                                            break;
                                        }
                                    }
                                }

                                if ( found )
                                {
                                    rv->infrastructureName = StringCreate( infrastructureName );

                                    ORKAGD_FPGAComponentsCreateList( rv );

                                    break;
                                }
                            }
                            ORKAVEC_IterDestroy( iter3 );
                        }
                    }
                    if ( !found )
                    {
                        ORKAGD_DBG_PRINTF( "Error: no FPGA match\n" );
                    }
                    ORKAVEC_IterDestroy( iter2 );

                    // we have found what we were looking for
                    rv->fpgaDescriprion = fpgaDescription;

                    // leave
                    break;
                }
                else
                {
                    ORKAGD_DBG_PRINTF( "Check DB with FPGAName '%s' ... no match ==> next if any ...\n", fullNameQualifierExamined );
                }
            }
            ORKAVEC_IterDestroy( iter );
        }
        else // if (( rv->driverIndex < numDriversAvailable ) && memcpyOffsetPtr )
        {
            if ( rv->driverIndex >= numDriversAvailable )
            {
                ORKAGD_DBG_PRINTF( "ERROR! Driver index too high [%" PRId64 ",%" PRId64 "]\n", rv->driverIndex, numDriversAvailable );
            }
            if ( !memcpyOffsetPtr )
            {
                ORKAGD_DBG_PRINTF( "ERROR! memcpyOffsetPtr not valid [0x%p == NULL ?] !\n", memcpyOffsetPtr );
            }
        }

        if ( found )
        {
            // ==> unsecure access
            ORKAVEC_Vector_t *recordListPCIeBars = ORKADB_RecordListCreateMatchValue( tablePCIeBars, rv->board->fieldPCIeBarType, "MMIO" );

            if ( 1 == ORKAVEC_Size( recordListPCIeBars ) )
            {
                ORKADB_FieldHandle_t *fieldHandleSize = ORKADB_FieldHandleGet( tablePCIeBars, "size" );

                ORKADB_RecordHandle_t *recordPCIeBAR = ( ORKADB_RecordHandle_t * ) ORKAVEC_GetAt( recordListPCIeBars, 0ULL );
                uint64_t *             sizeMMIOPtr   = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordPCIeBAR, fieldHandleSize );
                if ( sizeMMIOPtr )
                {
                    uint64_t sizeMMIO = *sizeMMIOPtr;
                    rv->mmioSize      = sizeMMIO;
                    ORKAGD_DBG_PRINTF( "sizeMMIO[A]=%" PRId64 "\n", sizeMMIO );
                }
                else
                {
                    ORKAGD_DBG_PRINTF( "sizeMMIO=<unknown> (error?)\n" );
                }
            }
            else
            {
                if ( 1 < ORKAVEC_Size( recordListPCIeBars ) )
                {
                    // TODO
                    ORKAGD_DBG_PRINTF( "WARNING: Found more than one MMIO BAR (found %" PRIx64 ")! Which one should I use?... TODO!!!\n", ORKAVEC_Size( recordListPCIeBars ) );
                    ORKAGD_DBG_PRINTF( "Assuming we are working with Intel -> Using the second BAR\n" );
                    ORKADB_FieldHandle_t * fieldHandleSize = ORKADB_FieldHandleGet( tablePCIeBars, "size" );
                    ORKADB_RecordHandle_t *recordPCIeBAR   = ( ORKADB_RecordHandle_t * ) ORKAVEC_GetAt( recordListPCIeBars, 1ULL );
                    uint64_t *             sizeMMIOPtr     = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordPCIeBAR, fieldHandleSize );
                    if ( sizeMMIOPtr )
                    {
                        uint64_t sizeMMIO = *sizeMMIOPtr;
                        rv->mmioSize      = sizeMMIO;
                        ORKAGD_DBG_PRINTF( "sizeMMIO[*]=%" PRId64 "\n", sizeMMIO );
                    }
                    else
                    {
                        ORKAGD_DBG_PRINTF( "sizeMMIO=<unknown> (error?)\n" );
                    }
                }
            }
        }
        else
        {
            ORKAGD_DBG_PRINTF( "Error: No board with suffcient components/FPGAs found ...\n" );
            rv = NULL;
        }

        if ( rv )
        {
            if ( NULL == rv->fpgaDescriprion )
            {
                // we havent support for this specific FPGA
                // todo: free strings
                free( rv );
                // say it loud
                rv = NULL;
            }
        }
    } while ( 0 );

    return ( void * ) rv;
}
#endif

void *
ORKAGD_FPGAHandleCreate( void *board, uint64_t indexFPGA )
{
    bool_t                  found                   = FALSE;
    ORKAGD_TargetBoardList *tbl                     = ( ORKAGD_TargetBoardList * ) board;
    ORKADB_RecordHandle_t * recordBoard             = tbl->recordCurrent;
    ORKADB_FieldHandle_t *  fieldFPGA               = tbl->fieldManufacturerFPGAs;
    ORKADB_FieldHandle_t *  fieldInfrastructureName = tbl->fieldInfrastructureName;
    char *                  infrastructureName      = *( ( char ** ) ( ORKADB_RecordGetFieldAddrByHandle( recordBoard, fieldInfrastructureName ) ) );   // get back a pointer to the string
    ORKADB_TableHandle_t *  tableFPGAs              = *( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( recordBoard, fieldFPGA ) ) ); // get back a pointer to the tablehandle
    ORKADB_TableHandle_t *  tableDrivers            = tbl->tableDrivers;
    ORKADB_TableHandle_t *  tablePCIeBars           = tbl->tablePCIeBars;

    // reserve space of a "collector struct"
    ORKAGD_FPGAHandle_t *rv = ( ORKAGD_FPGAHandle_t * ) calloc( 1, sizeof( ORKAGD_FPGAHandle_t ) );
    ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: Handle = " PRIp "\n", rv );
    do
    {
        if ( !rv )
        {
            ORKAGD_DBG_PRINTF( "ERROR: ORKAGD_FPGAHandleCreate: Creation failed\n" );
            break;
        }
        rv->board = tbl;
        ORKADB_TableHandleDump( tableFPGAs );

        // with the index of the FPGA we access the table holding all FPGAs. Here we get the complete record.
        ORKADB_RecordHandle_t **recordFPGAPtr = ( ORKADB_RecordHandle_t ** ) ORKAVEC_GetAt( tableFPGAs->records, indexFPGA );
        if ( !recordFPGAPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR: ORKAGD_FPGAHandleCreate: Creation failed\n" );
            break;
        }
        rv->recordFPGA = *recordFPGAPtr;

        // dump it out
        ORKADB_RecordDump( rv->recordFPGA );

        // to access the record, we have to know the filed information.
        rv->tableFPGAs             = tableFPGAs;
        rv->fieldFullNameQualifier = ORKADB_FieldOpen( tableFPGAs, "FullNameQualifier" );
        rv->fieldDriver            = ORKADB_FieldOpen( tableFPGAs, "Driver" );
        rv->fieldComponents        = ORKADB_FieldOpen( tableFPGAs, "Components" );
        rv->fieldMemoryRegions     = ORKADB_FieldOpen( tableFPGAs, "MemoryRegions" );

        // components table belonging to this specific FPGA
        // ================================================

        // here we get the content(!) of the fieldComponents field. This field represents a new table.
        ORKADB_TableHandle_t **tableCompPtr = ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldComponents ) ); // get back a pointer to the tablehandle
        if ( !tableCompPtr )
        {
            ORKAGD_DBG_PRINTF( "ERROR: Table of components: GetField failed\n" );
            break;
        }
        rv->tableComponents = *tableCompPtr;

        // to access the records of this component table, we need information about its fields
        rv->fieldComponentsName      = ORKADB_FieldOpen( rv->tableComponents, "name" );
        rv->fieldComponentsOffset    = ORKADB_FieldOpen( rv->tableComponents, "offset" );
        rv->fieldComponentsRange     = ORKADB_FieldOpen( rv->tableComponents, "range" );
        rv->fieldComponentsType      = ORKADB_FieldOpen( rv->tableComponents, "type" );
        rv->fieldComponentsIpAddress = ORKADB_FieldOpen( rv->tableComponents, "ipAddress" );
        rv->fieldComponentsSubType   = ORKADB_FieldOpen( rv->tableComponents, "subtype" );
        rv->fieldComponentsIpAccess  = ORKADB_FieldOpen( rv->tableComponents, "ipAccess" );
        rv->fieldComponentsRegisters = ORKADB_FieldOpen( rv->tableComponents, "Registers" );

        // here we get the content(!) of the fieldMemoryRegions field. This field represents a new table.
        rv->tableMemoryRegions = *( ( ORKADB_TableHandle_t ** ) ( ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldMemoryRegions ) ) ); // get back a pointer to the tablehandle

        // to access the records of this fieldMemoryRegions table, we need information about its fields
        rv->fieldMemoryRegionsOffset = ORKADB_FieldOpen( rv->tableMemoryRegions, "memcpyOffset" );
        void *record                 = ( ( void * ) ORKADB_RecordGetAt( rv->tableMemoryRegions, 0 ) );
        if ( record )
        {
            uint64_t *offsetPtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( record, rv->fieldMemoryRegionsOffset );
            if ( offsetPtr )
            {
                rv->memcpyOffset = *offsetPtr;
            }
            else
            {
                ORKAGD_DBG_PRINTF( "ERROR: Database is malformed (memcpyOffset)\n" );
                break;
            }
        }
        else
        {
            ORKAGD_DBG_PRINTF( "INFO: memcpyOffset is set to default.\n" );
            rv->memcpyOffset = 0ull;
        }
        ORKAGD_DBG_PRINTF( "INFO: memcpyOffset is 0x%" PRIx64 "\n", rv->memcpyOffset );

        // from board, get the driver parameters
        rv->fieldDriverParamsDriverName = ORKADB_FieldOpen( tableDrivers, "DriverName" );
        rv->fieldDriverParamsInstance   = ORKADB_FieldOpen( tableDrivers, "Instance" );
        rv->fieldDriverParamsPort       = ORKADB_FieldOpen( tableDrivers, "Port" );
        rv->fieldDriverParamsSpeed      = ORKADB_FieldOpen( tableDrivers, "Speed" );
        rv->fieldDriverParamsAddress    = ORKADB_FieldOpen( tableDrivers, "Address" );

        // from the board, get the PCIeBar parameters
        rv->board->fieldPCIeBarType = ORKADB_FieldOpen( tablePCIeBars, "type" );
        rv->board->fieldPCIeBarSize = ORKADB_FieldOpen( tablePCIeBars, "size" );

        // extract the full qualified FPGA name
        char *fullNameQualifierNeeded = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldFullNameQualifier ) ); // get back a pointer to the string-pointer

        // get the driverIndex
        rv->driverIndex              = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( rv->recordFPGA, rv->fieldDriver ) );
        uint64_t numDriversAvailable = ORKAVEC_Size( tbl->tableDrivers->records );
        ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: numDrivers = %" PRId64 "\n", numDriversAvailable );
        if ( rv->driverIndex < numDriversAvailable )
        {
            // with the index we access now the specified driver parameter block
            ORKADB_RecordHandle_t *entryDriverParamsRecord = ( ( ORKADB_RecordHandle_t * ) ORKADB_RecordGetAt( tableDrivers, rv->driverIndex ) );
            // ORKADB_RecordDump( entryDriverParamsRecord );

            // now look in the list of all FPGAs whether we support this FPGA
            ORKAVEC_Iter_t *iter = ORKAVEC_IterCreate( ORKAGD_g_FPGADescriptions );
            ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: Requested FPGA is '%s' - Looking for appropriate FPGA from internal database ...\n", fullNameQualifierNeeded );
            for ( void *i = ORKAVEC_IterBegin( iter ); ORKAVEC_IterEnd( iter ); i = ORKAVEC_IterNext( iter ) )
            {
                ORKAGD_FPGADescription_t *fpgaDescription = ( ORKAGD_FPGADescription_t * ) i; // get back a pointer to the string-pointer
                if ( fpgaDescription )
                {
                    char *fullNameQualifierExamined = fpgaDescription->fullNameQualifier;

                    if ( 0 == StringCompareIgnoreCase( fullNameQualifierExamined, fullNameQualifierNeeded ) )
                    {
                        // The FPGA is supported ...
                        // now we have the FPGA manufacturer and can look into the drivers list
                        // for drivers of this manufacturer.
                        // We have to check then the specified driver name of the FPGA-Board config
                        // whether this name is available in the list of drivers
                        ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: Check DB with FPGAName '%s' ... Match!\n", fullNameQualifierExamined );

                        ORKAVEC_Iter_t *iter2 = ORKAVEC_IterCreate( ORKAGD_g_TranslatorManufacturers );
                        for ( void *j = ORKAVEC_IterBegin( iter2 ); ( !found ) && ORKAVEC_IterEnd( iter2 ); j = ORKAVEC_IterNext( iter2 ) )
                        {
                            ORKAGD_TranslatorManufacturerBoard_t *translatorManufacturerBoard = ( ORKAGD_TranslatorManufacturerBoard_t * ) j; // get back a pointer to the string-pointer
                            // ORKAGD_DBG_PRINTF( "ManufacturerDrivers: %s\n", translatorManufacturerBoard->manufacturer );
                            if ( 0 == StringCompareIgnoreCase( translatorManufacturerBoard->manufacturer, fpgaDescription->manufacturerName ) )
                            {
                                // look in each entry of the vector whether there is one named as needed
                                ORKAVEC_Iter_t *iter3 = ORKAVEC_IterCreate( translatorManufacturerBoard->drivers );
                                for ( void *k = ORKAVEC_IterBegin( iter3 ); ORKAVEC_IterEnd( iter3 ); k = ORKAVEC_IterNext( iter3 ) )
                                {
                                    ORKAGD_TranslatorDriver_t *translatorDriver = ( ORKAGD_TranslatorDriver_t * ) k; // get back a pointer to the driver struct
                                    // we extract the desired name, instance and port
                                    char **driverNamePtr = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsDriverName );
                                    if ( driverNamePtr && ( *driverNamePtr ) )
                                    {
                                        char *driverName = *driverNamePtr;
                                        if ( 0 == StringCompareIgnoreCase( driverName, translatorDriver->name ) )
                                        {
                                            found                   = TRUE;
                                            rv->interfaceAccessType = translatorDriver->accessType;

                                            switch ( translatorDriver->accessType )
                                            {
                                                default:
                                                case ORKAGD_ACCESSTYPE_UNDEFINED:
                                                {
                                                    ORKAGD_DBG_PRINTF( "ERROR: accessType undefined\n" );
                                                    break;
                                                }
                                                case ORKAGD_ACCESSTYPE_XDMA:
                                                {
                                                    // Xilinx DMA

                                                    // get the access string of the driver interface and
                                                    // replace macro keywords by the numbers
                                                    uint64_t *instancePtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsInstance );
                                                    uint64_t *portPtr     = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort );
                                                    if ( ( !instancePtr ) || ( !portPtr ) )
                                                    {
                                                        ORKAGD_DBG_PRINTF( "ERROR: accessType XDMA: instance or port problem\n" );
                                                        break;
                                                    }
                                                    uint64_t instance = *instancePtr;
                                                    uint64_t port     = *portPtr;

#ifdef _MSC_VER
                                                    rv->interfacePCIe.m_DevicePCIConfigName      = "..\\winsim.org";
                                                    rv->interfacePCIe.m_DeviceDMAReadName        = "..\\winsim.org";
                                                    rv->interfacePCIe.m_DeviceDMAWriteName       = "..\\winsim.org";
                                                    rv->interfacePCIe.m_DeviceMemoryMappedIOName = "..\\winsim.org";
#else
                                                    char *tmp;
                                                    rv->interfacePCIe.m_DevicePCIConfigName = StringFindAndReplaceU64( translatorDriver->controlAccess, "%interface%", instance );
                                                    tmp                                     = StringFindAndReplaceU64( translatorDriver->memcpyd2h, "%interface%", instance );
                                                    rv->interfacePCIe.m_DeviceDMAReadName   = StringFindAndReplaceU64( tmp, "%dmachannel%", port );
                                                    free( tmp ); // free temporary string
                                                    tmp                                    = StringFindAndReplaceU64( translatorDriver->memcpyh2d, "%interface%", instance );
                                                    rv->interfacePCIe.m_DeviceDMAWriteName = StringFindAndReplaceU64( tmp, "%dmachannel%", port );
                                                    free( tmp ); // free temporary string
                                                    rv->interfacePCIe.m_DeviceMemoryMappedIOName = StringFindAndReplaceU64( translatorDriver->registerAccess, "%interface%", instance );
#endif
                                                    break;
                                                }
                                                case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
                                                {
                                                    // get the access string of the driver interface and
                                                    // replace macro keywords by the numbers
                                                    // TODO
                                                    // uint64_t instance                            = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsInstance ) );
                                                    // uint64_t port                                = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort ) );
                                                    rv->interfacePCIe.m_DevicePCIConfigName      = translatorDriver->controlAccess;
                                                    rv->interfacePCIe.m_DeviceDMAReadName        = translatorDriver->memcpyd2h;
                                                    rv->interfacePCIe.m_DeviceDMAWriteName       = translatorDriver->memcpyh2d;
                                                    rv->interfacePCIe.m_DeviceMemoryMappedIOName = translatorDriver->registerAccess;
                                                    break;
                                                }
                                                case ORKAGD_ACCESSTYPE_IPV4:
                                                {
                                                    // accesss with TCP/IP custom protocol
                                                    ORKAGD_DBG_PRINTF( "* TCP/IP access\n" );
                                                    char **   ipv4AddressPtr = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsAddress );
                                                    uint64_t *ipv4PortPtr    = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsPort );
                                                    uint64_t *ipv4SpeedPtr   = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( entryDriverParamsRecord, rv->fieldDriverParamsSpeed );
                                                    if ( ( !ipv4AddressPtr ) || ( !( *ipv4AddressPtr ) ) || ( !ipv4PortPtr ) || ( !ipv4SpeedPtr ) )
                                                    {
                                                        ORKAGD_DBG_PRINTF( "ERROR: accessType IPV4: ipv4AddressPtr, ipv4PortPtr or ipv4SpeedPtr problem\n" );
                                                        break;
                                                    }
                                                    rv->interfaceIPv4.m_ipv4Address = *ipv4AddressPtr;
                                                    rv->interfaceIPv4.m_ipv4Port    = *ipv4PortPtr;
                                                    rv->interfaceIPv4.m_ipv4Speed   = *ipv4SpeedPtr;
                                                    ORKAGD_DBG_PRINTF( "* TCP/IP Address: %s\n", rv->interfaceIPv4.m_ipv4Address );
                                                    ORKAGD_DBG_PRINTF( "* TCP/IP Port: %" PRId64 "\n", rv->interfaceIPv4.m_ipv4Port );
                                                    ORKAGD_DBG_PRINTF( "* TCP/IP Speed: %" PRId64 "\n", rv->interfaceIPv4.m_ipv4Speed );

                                                    break;
                                                }
                                            }
                                            rv->infrastructureName = StringCreate( infrastructureName );

                                            ORKAGD_FPGAComponentsCreateList( rv );

                                            break;
                                        }
                                    }
                                    else
                                    {
                                        ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: ERROR! Driver name field defect ...\n" );
                                    }
                                }

                                ORKAVEC_IterDestroy( iter3 );
                            }
                        }
                        if ( !found )
                        {
                            ORKAGD_DBG_PRINTF( "Error: no FPGA match\n" );
                        }
                        ORKAVEC_IterDestroy( iter2 );

                        // we have found what we were looking for
                        rv->fpgaDescriprion = fpgaDescription;

                        // leave
                        break;
                    }
                    else
                    {
                        ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: Check DB with FPGAName '%s' ... no match ==> next if any ...\n", fullNameQualifierExamined );
                    }
                }
                else
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_FPGAHandleCreate: ERROR! Check DB (fullNameQualifier) ...\n" );
                }
            }
            ORKAVEC_IterDestroy( iter );
        }

        if ( found )
        {
            // ==> unsecure access
            ORKAVEC_Vector_t *recordListPCIeBars = ORKADB_RecordListCreate( tablePCIeBars, rv->board->fieldPCIeBarType, "MMIO" );

            if ( 1 == ORKAVEC_Size( recordListPCIeBars ) )
            {
                ORKADB_FieldHandle_t *fieldHandleSize = ORKADB_FieldOpen( tablePCIeBars, "size" );

                ORKADB_RecordHandle_t *recordPtr   = ( ORKADB_RecordHandle_t * ) ORKAVEC_GetAt( recordListPCIeBars, 0ULL );
                uint64_t *             sizeMMIOPtr = ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordPtr, fieldHandleSize );
                if ( sizeMMIOPtr )
                {
                    uint64_t sizeMMIO = *sizeMMIOPtr;
                    rv->mmioSize      = sizeMMIO;
                    ORKAGD_DBG_PRINTF( "sizeMMIO=%" PRId64 "\n", sizeMMIO );
                }
                else
                {
                    ORKAGD_DBG_PRINTF( "WARNING: sizeMMIOPtr wrong\n" );
                }
            }
            else
            {
                if ( 1 < ORKAVEC_Size( recordListPCIeBars ) )
                {
                    // TODO
                    ORKAGD_DBG_PRINTF( "WARNING: Found more than one MMIO BAR (found %" PRIx64 ")! Which one should I use?... TODO!!!\n", ORKAVEC_Size( recordListPCIeBars ) );
                    ORKAGD_DBG_PRINTF( "Assuming we are working with Intel -> Using the second BAR\n" );
                    ORKADB_FieldHandle_t * fieldHandleSize = ORKADB_FieldOpen( tablePCIeBars, "size" );
                    ORKADB_RecordHandle_t *recordPtr       = ( ORKADB_RecordHandle_t * ) ORKAVEC_GetAt( recordListPCIeBars, 1ULL );
                    uint64_t               sizeMMIO        = *( ( uint64_t * ) ORKADB_RecordGetFieldAddrByHandle( recordPtr, fieldHandleSize ) );
                    rv->mmioSize                           = sizeMMIO;
                    ORKAGD_DBG_PRINTF( "sizeMMIO=%" PRId64 "\n", sizeMMIO );
                }
            }
        }
        else
        {
            ORKAGD_DBG_PRINTF( "Error: No board with suffcient components/FPGAs found ...\n" );
            rv = NULL;
        }

        if ( rv )
        {
            if ( NULL == rv->fpgaDescriprion )
            {
                // we havent support for this specific FPGA
                // todo: free strings
                free( rv );
                // say it loud
                rv = NULL;
            }
        }
    } while ( 0 ); // end dummy loop

    return ( void * ) rv;
}

void
ORKAGD_FPGAHandleDestroy( void *fpgaHandle )
{
    // close all db and tables
    // free memory
    free( fpgaHandle );
}
char *
ORKAGD_FPGAGetFullNameQualifier( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *  fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKADB_RecordHandle_t *record        = fpgaHandleNew->recordFPGA;
        ORKADB_FieldHandle_t * field         = fpgaHandleNew->fieldFullNameQualifier;
        rv                                   = *( ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record, field ) ); // get back a pointer to the string-pointer
    }
    return rv;
}
char *
ORKAGD_FPGAGetShortName( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->shortName;
    }
    return rv;
}
char *
ORKAGD_FPGAGetManufacturer( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->manufacturerName;
    }
    return rv;
}
char *
ORKAGD_FPGAGetCategory( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->category;
    }
    return rv;
}
char *
ORKAGD_FPGAGetFamily( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->family;
    }
    return rv;
}

char *
ORKAGD_FPGAGetPackage( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->package;
    }
    return rv;
}

char *
ORKAGD_FPGAGetSpeed( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->speedgrade;
    }
    return rv;
}

char *
ORKAGD_FPGAGetTemperature( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *     fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        ORKAGD_FPGADescription_t *fpga          = fpgaHandleNew->fpgaDescriprion;
        rv                                      = fpga->temperature;
    }
    return rv;
}

uint64_t
ORKAGD_FPGAGetMMIOSize( void *fpgaHandle )
{
    uint64_t mmioSize = 0ULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        mmioSize                           = fpgaHandleNew->mmioSize;
    }
    return mmioSize;
}

uint64_t
ORKAGD_FPGAGetComponentCount( void *fpgaHandle, char *identifier )
{
    uint64_t numComponents = 0ULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;

        uint64_t numComponentsComplete = ORKAGD_FPGAComponentsGetNumOf( ( void * ) fpgaHandleNew );
        for ( uint64_t i = 0; i < numComponentsComplete; ++i )
        {
            const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( ( void * ) fpgaHandleNew, i );
            if ( compEntry->ipType )
            {
                if ( 0 == strcmp( identifier, compEntry->ipType ) )
                {
                    numComponents++;
                }
            }
        }
    }
    return numComponents;
}

uint64_t
ORKAGD_FPGAGetMemoryRegionAddress( void *fpgaHandle, const char *identifierMemory, const uint64_t indexMemoryRegion )
{
    uint64_t memoryRegionAddress = 0ULL;
    uint64_t counter             = 0ULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;

        uint64_t numComponentsComplete = ORKAGD_FPGAComponentsGetNumOf( ( void * ) fpgaHandleNew );
        for ( uint64_t i = 0; i < numComponentsComplete; ++i )
        {
            const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( ( void * ) fpgaHandleNew, i );
            if ( compEntry->ipType )
            {
                if ( 0 == strcmp( identifierMemory, compEntry->ipType ) )
                {
                    if ( indexMemoryRegion == counter )
                    {
                        memoryRegionAddress = compEntry->ipOffset;
                        break;
                    }
                    counter++;
                }
            }
        }
    }
    return memoryRegionAddress;
}

uint64_t
ORKAGD_FPGAGetMemoryRegionSize( void *fpgaHandle, const char *identifierMemory, const uint64_t indexMemoryRegion )
{
    uint64_t memoryRegionSize = 0ULL;
    uint64_t counter          = 0ULL;
    if ( fpgaHandle )
    {
        ORKAGD_FPGAHandle_t *fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;

        uint64_t numComponentsComplete = ORKAGD_FPGAComponentsGetNumOf( ( void * ) fpgaHandleNew );
        for ( uint64_t i = 0; i < numComponentsComplete; ++i )
        {
            const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry( ( void * ) fpgaHandleNew, i );
            if ( compEntry->ipType )
            {
                if ( 0 == strcmp( identifierMemory, compEntry->ipType ) )
                {
                    if ( indexMemoryRegion == counter )
                    {
                        memoryRegionSize = compEntry->ipRange;
                        break;
                    }
                    counter++;
                }
            }
        }
    }
    return memoryRegionSize;
}

char *
ORKAGD_FPGAGetInfrastructureName( void *fpgaHandle )
{
    char *rv = NULL;
    if ( fpgaHandle )
    {
        // TODO:
        // This function retrieves (for now!) the infrastructure name from the board struct.
        // Later we want to differentiate between infrastructures per FPGA.
        // For example: On a board with 4 FPGAs we want to be able to equip all FPGAs with
        // different bitstreams. So the bitstream has to be FPGA bound and not board bound.
        ORKAGD_FPGAHandle_t *fpgaHandleNew = ( ORKAGD_FPGAHandle_t * ) fpgaHandle;
        rv                                 = fpgaHandleNew->infrastructureName;
    }
    return rv;
}
uint64_t
ORKAGD_FPGAGetBitstreamRegionCount( void *fpgaHandle )
{
    return 1;
}
void
ORKAGD_FPGABitstreamUploadInfrastructure( void *fpgaHandle )
{
    if ( fpgaHandle && ORKAGD_g_PathnameTempWrite )
    {

        const char *Manufacturer = ORKAGD_FPGAGetManufacturer( fpgaHandle );
        ORKAGD_DBG_PRINTF( "Manufacturer: %s\n", Manufacturer );
        if ( 0 == strcmp( "Xilinx", Manufacturer ) )
        {
            char *infraStructureName = ORKAGD_FPGAGetInfrastructureName( fpgaHandle );
            ORKAGD_DBG_PRINTF( "infraStructureName = %s\n", infraStructureName );
            size_t l = strlen( infraStructureName );
            if ( l > 5 )
            {
                if ( 0 == strncmp( ".json", &infraStructureName[ l - 5 ], 5 ) )
                {
                    char *commandBase = StringCreate( "/opt/Xilinx/SDK/2018.3/bin/xsct" );

                    commandBase = StringAddExt( commandBase, " " );
                    commandBase = StringAddExt( commandBase, "boot.tcl" );
                    commandBase = StringAddExt( commandBase, " " );
                    commandBase = StringAddExt( commandBase, ORKAGD_GetHostName() );
                    commandBase = StringAddExt( commandBase, " " );
                    commandBase = StringAddExt( commandBase, ORKAGD_FPGAGetShortName( fpgaHandle ) );
                    commandBase = StringAddExt( commandBase, " " );
                    commandBase = StringAddExt( commandBase, ORKAGD_g_BitstreamSearchPath );
                    //                const char *commandBase = "/opt/Xilinx/SDK/2018.3/bin/xsct boot.tcl blackpearl xcvu9p ../../../bitstreams/";
                    bool_t executionDone = FALSE;

                    do
                    {
                        if ( l <= 5 )
                        {
                            break;
                        }
                        char *bitstreamName = StringCreate( infraStructureName );
                        if ( !bitstreamName )
                        {
                            break;
                        }
                        strcpy( &bitstreamName[ l - 5 ], ".bit" );
                        const char *command = StringAddFilenameToPath( commandBase, bitstreamName );
                        if ( !command )
                        {
                            break;
                        }
                        ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Command=%s\n", command );
                        ORKAGD_Execute( command );
                        executionDone = TRUE;

                        StringDestroy( bitstreamName );
                        break;
                    } while ( 0 );

                    if ( !executionDone )
                    {
                        if ( l <= 5 )
                        {
                            ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Error: illegal bitstream/configuration name!\n" );
                        }
                        else
                        {
                            ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Error: no memory left!\n" );
                        }
                    }

                    StringDestroy( commandBase );
                }
                else
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Error: Extension wrong: %s\n", infraStructureName );
                }
            }
            else
            {
                ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Error: Extension wrong: %s\n", infraStructureName );
            }
        }
        else
        {
            ORKAGD_DBG_PRINTF( "ORKAGD_FPGABitstreamUploadInfrastructure: Error: Manufacturer '%s' not supported ...\n", Manufacturer );
        }
    }
}

static uint32_t
ORKAGD_FPGAPCIeOpen( ORKAGD_FPGAHandle_t *pTargetFPGA )
{
    uint32_t rv = 0xffffffff;
    if ( pTargetFPGA )
    {
        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_XDMA:
            {
                const char *deviceDMAReadName          = pTargetFPGA->interfacePCIe.m_DeviceDMAReadName;
                const char *deviceDMAWriteName         = pTargetFPGA->interfacePCIe.m_DeviceDMAWriteName;
                const char *devicePCIConfigName        = pTargetFPGA->interfacePCIe.m_DevicePCIConfigName;
                const char *deviceMemoryMappedIOName   = pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOName;
                int         deviceDMAReadHandle        = open( deviceDMAReadName, O_RDWR | O_NONBLOCK );
                int         deviceDMAWriteHandle       = open( deviceDMAWriteName, O_RDWR );
                int         devicePCIConfigHandle      = open( devicePCIConfigName, O_RDWR | O_SYNC );
                int         deviceMemoryMappedIOHandle = open( deviceMemoryMappedIOName, O_RDWR | O_SYNC );

                ORKAGD_DBG_PRINTF( "PCI-Open:\n" );
                ORKAGD_DBG_PRINTF( "PCI-deviceDMAReadName: %s\n", deviceDMAReadName );
                ORKAGD_DBG_PRINTF( "PCI-deviceDMAWriteName: %s\n", deviceDMAWriteName );
                ORKAGD_DBG_PRINTF( "PCI-devicePCIConfigName: %s\n", devicePCIConfigName );
                ORKAGD_DBG_PRINTF( "PCI-deviceMemoryMappedIOName: %s\n", deviceMemoryMappedIOName );
                ORKAGD_DBG_PRINTF( "Handles(4): %d, %d, %d, %d\n", deviceDMAReadHandle, deviceDMAWriteHandle, devicePCIConfigHandle, deviceMemoryMappedIOHandle );
                for ( ;; )
                {
                    if ( ( deviceDMAReadHandle >= 0 ) && ( deviceDMAWriteHandle >= 0 ) && ( devicePCIConfigHandle >= 0 ) && ( deviceMemoryMappedIOHandle >= 0 ) )
                    {
                        void *   registerMapBase = mmap( 0, pTargetFPGA->mmioSize, PROT_READ | PROT_WRITE, MAP_SHARED, deviceMemoryMappedIOHandle, 0 );
                        uint8_t *p               = &( ( ( uint8_t * ) registerMapBase )[ pTargetFPGA->mmioSize ] );
                        ORKAGD_DBG_PRINTF( "MMap: " PRIp " - " PRIp "\n", registerMapBase, p );
                        if ( ( void * ) -1 != registerMapBase )
                        {
                            pTargetFPGA->interfacePCIe.m_RegisterMapBase            = registerMapBase;
                            pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle        = deviceDMAReadHandle;
                            pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle       = deviceDMAWriteHandle;
                            pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle      = devicePCIConfigHandle;
                            pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle = deviceMemoryMappedIOHandle;

                            rv = 0;
                            // everything fine - break pseudo loop
                            break;
                        }
                        else
                        {
                            // mmap not working
                            ORKAGD_DBG_PRINTF( "ERROR: mmap failed with errno = %u: %s\n", errno, strerror( errno ) );
                            pTargetFPGA->interfacePCIe.m_RegisterMapBase            = 0;
                            pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle        = 0;
                            pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle       = 0;
                            pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle      = 0;
                            pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle = 0;
                            rv                                                      = 0xff;
                        }
                    }

                    // error case - clean up
                    if ( deviceDMAReadHandle >= 0 )
                    {
                        close( deviceDMAReadHandle );
                        deviceDMAReadHandle = 0xffffffff;
                    }
                    else
                    {
                        rv = 1;
                    }

                    if ( deviceDMAWriteHandle >= 0 )
                    {
                        close( deviceDMAWriteHandle );
                        deviceDMAWriteHandle = 0xffffffff;
                    }
                    else
                    {
                        rv = 2;
                    }

                    if ( devicePCIConfigHandle >= 0 )
                    {
                        close( devicePCIConfigHandle );
                        devicePCIConfigHandle = 0xffffffff;
                    }
                    else
                    {
                        rv = 3;
                    }

                    if ( deviceMemoryMappedIOHandle >= 0 )
                    {
                        close( deviceMemoryMappedIOHandle );
                        deviceMemoryMappedIOHandle = 0xffffffff;
                    }
                    else
                    {
                        rv = 4;
                    }

                    // break pseudo loop
                    break;
                }
                break;
            }
            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                const char *deviceMemoryMappedIOName   = pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOName;
                int         deviceMemoryMappedIOHandle = open( deviceMemoryMappedIOName, O_RDWR | O_SYNC );
                ORKAGD_DBG_PRINTF( "PCI-deviceMemoryMappedIOName: %s\n", deviceMemoryMappedIOName );
                ORKAGD_DBG_PRINTF( "Handle: %d\n", deviceMemoryMappedIOHandle );
                if ( deviceMemoryMappedIOHandle )
                {
                    pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle = deviceMemoryMappedIOHandle;
                    rv                                                      = 0;
                }
                else
                {
                    pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle = 0xffffffff;
                    rv                                                      = 4;
                }
                pTargetFPGA->interfacePCIe.m_RegisterMapBase       = 0;
                pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle   = 0;
                pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle  = 0;
                pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle = 0;
                break;
            }
        }
    }
    return rv;
}

static void
ORKAGD_FPGAPCIeClose( ORKAGD_FPGAHandle_t *pTargetFPGA )
{
    if ( pTargetFPGA )
    {
        void *registerMapBase = ( void * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
        if ( registerMapBase )
            munmap( registerMapBase, pTargetFPGA->mmioSize );
        if ( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle )
            close( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle );
        if ( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle )
            close( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle );
        if ( pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle )
            close( pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle );
        if ( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle )
            close( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle );
        pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle        = 0xffffffff;
        pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle       = 0xffffffff;
        pTargetFPGA->interfacePCIe.m_DevicePCIConfigHandle      = 0xffffffff;
        pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle = 0xffffffff;
    }
}

static uint64_t
ORKAGD_FPGATCPIPOpen( ORKAGD_FPGAHandle_t *pTargetFPGA )
{
    uint64_t rv = ~0ULL;
    if ( pTargetFPGA )
    {
        rv = ORKAGD_TcpIpInit( &ORKAGD_g_TcpIPControlBlock );
        if ( 0 == rv )
        {
            rv = ORKAGD_TcpIpOpen( &ORKAGD_g_TcpIPControlBlock, pTargetFPGA->interfaceIPv4.m_ipv4Address, pTargetFPGA->interfaceIPv4.m_ipv4Port );
        }
    }
    return rv;
}

static void
ORKAGD_FPGATCPIPClose( ORKAGD_FPGAHandle_t *pTargetFPGA )
{
    if ( pTargetFPGA )
    {
        ORKAGD_TcpIpDeInit( &ORKAGD_g_TcpIPControlBlock );
    }
}

uint64_t
ORKAGD_FPGAOpen( void *handleFPGA )
{
    uint64_t rv = ~0ULL;
    ORKAGD_DBG_PRINTF( "ORKAGD_TargetOpen: handle=" PRIp "\n", handleFPGA );
    if ( handleFPGA )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA = ( ORKAGD_FPGAHandle_t * ) handleFPGA;
        ORKAGD_DBG_PRINTF( "ORKAGD_TargetOpen: AccessType=%d\n", pTargetFPGA->interfaceAccessType );
        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
                rv = ORKAGD_FPGAPCIeOpen( pTargetFPGA );
                break;

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
                rv = ORKAGD_FPGAPCIeOpen( pTargetFPGA );
                break;

            case ORKAGD_ACCESSTYPE_IPV4:
                rv = ORKAGD_FPGATCPIPOpen( pTargetFPGA );
                break;
        }
    }
    ORKAGD_DBG_PRINTF( "ORKAGD_TargetOpen: rv=%" PRId64 "\n", rv );
    return rv;
}

void
ORKAGD_FPGAClose( void *handleFPGA )
{
    if ( handleFPGA )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA = ( ORKAGD_FPGAHandle_t * ) handleFPGA;
        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
                ORKAGD_FPGAPCIeClose( pTargetFPGA );
                break;

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
                ORKAGD_FPGAPCIeClose( pTargetFPGA );
                break;

            case ORKAGD_ACCESSTYPE_IPV4:
                ORKAGD_FPGATCPIPClose( pTargetFPGA );
                break;
        }
    }
}

#if 0
bool_t
ORKAGD_BitstreamUpload(
    ORKAGD_TargetFPGA_t *pTargetFPGA,
    uint32_t region,
    void *pBitstream,
    uint64_t bitstreamSize )
{
    bool_t rv = TRUE;
    if ( pTargetFPGA )
    {
        if ( region < pTargetFPGA->m_BitstreamRegionCount )
        {
            if ( pTargetFPGA->m_BitstreamRegions[ region ].m_BistreamData )
            {
                // already occupied
                rv = FALSE;
            }
            else
            {
                pTargetFPGA->m_BitstreamRegions[ region ].m_BitstreamSize = bitstreamSize;
                pTargetFPGA->m_BitstreamRegions[ region ].m_BistreamData = pBitstream;
            }
        }
    }
    return rv;
}

void
ORKAGD_BitstreamClean(
    ORKAGD_TargetFPGA_t *pTargetFPGA,
    uint32_t region )
{
    ORKAGD_BitstreamUpload(
        pTargetFPGA,
        region,
        NULL,
        0 );
}
#endif

bool_t
ORKAGD_RegisterU32Write( const ORKAGD_FPGAComponent_t *component, const uint64_t offset, const uint32_t value )
{
    bool_t rv = FALSE;

    if ( component )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA     = ( ORKAGD_FPGAHandle_t * ) ( component->fpgaHandle );
        uint64_t             targetIPAddress = component->ipOffset;

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                ORKAGD_DBG_PRINTF( "ORKAGD_RegisterU32Write: Access type undefined.\n" );
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
                uint8_t *registerMapBase = ( uint8_t * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
                uint8_t *baseAddress     = registerMapBase + targetIPAddress;

                ORKA_RegWrite32( baseAddress, offset, value );
                rv = TRUE;
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                ORKAGD_IntelIOCtl_t rw_args;
                rw_args.offset = ( uint32_t ) ( targetIPAddress + offset );
                rw_args.data   = value;
                ORKAGD_DBG_PRINTF_INT( "JSCDBG: offset=0x%8.8x\n", rw_args.offset );
                int ret = ioctl( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle, ORKAGD_FPGA_PR_REGION_WRITE, &rw_args );
                if ( 0 > ret )
                {
                    ORKAGD_DBG_PRINTF( "ioctl write error\n" );
                }
                else
                {
                    rv = TRUE;
                }
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {
                targetIPAddress += offset;

                if ( targetIPAddress & 0xffffffff00000000ULL )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_RegisterU32Write: Address of component register greater 32-bit: too high. Not implemented yet.\n" );
                }
                else
                {
                    rv = ORKAGD_TcpIPRegisterWriteA32V32( &ORKAGD_g_TcpIPControlBlock, ( uint32_t ) targetIPAddress, value );
                }
                break;
            }
        }
    }
    return rv;
}

uint32_t
ORKAGD_RegisterU32Read( const ORKAGD_FPGAComponent_t *component, const uint64_t offset )
{
    uint32_t rv = 0;
    if ( component )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA     = ( ORKAGD_FPGAHandle_t * ) ( component->fpgaHandle );
        uint64_t             targetIPAddress = component->ipOffset;

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                ORKAGD_DBG_PRINTF( "ORKAGD_RegisterU32Read: Access type undefined.\n" );
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
                uint8_t *registerMapBase = ( uint8_t * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
                uint8_t *baseAddress     = registerMapBase + targetIPAddress;

                rv = ORKA_RegRead32( baseAddress, offset );
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                ORKAGD_IntelIOCtl_t rw_args;
                rw_args.offset = ( uint32_t ) ( targetIPAddress + offset );

                ORKAGD_DBG_PRINTF_INT( "JSCDBG: offset=0x%8.8x\n", rw_args.offset );
                if ( ioctl( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle, ORKAGD_FPGA_PR_REGION_READ, &rw_args ) == -1 )
                {
                    ORKAGD_DBG_PRINTF( "ioctl read error\n" );
                }
                rv = rw_args.data;
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {
                targetIPAddress += offset;

                if ( targetIPAddress & 0xffffffff00000000ULL )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_RegisterU32Read: Address of component register greater 32-bit: too high. Not implemented yet.\n" );
                }
                else
                {
                    rv = ORKAGD_TcpIPRegisterReadA32V32( &ORKAGD_g_TcpIPControlBlock, ( uint32_t ) targetIPAddress );
                }
                break;
            }
        }
    }
    return rv;
}

bool_t
ORKAGD_MemcpyH2D( void *handleFPGA, const uint64_t dstDevice, const void *srcHost, const uint64_t byteSize )
{
    bool_t rv = FALSE;
    //    ORKAGD_DBG_PRINTF( "ORKAGD_MemcpyH2D: "PRIp" ==> 0x%" PRIx64 "\n", srcHost, destDevice );
    if ( handleFPGA && srcHost )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA = ( ORKAGD_FPGAHandle_t * ) handleFPGA;

        // Apply offset to FPGA target address, this is the offset to reach from
        // any interface (e.g. PCIe) the memory of the device.
        // The mapping of internal FPGA memory may be different for every FPGA as well
        // as for different components within the FPGA.
        // The memory controller returns only addresses understandable by the IP itself,
        // so conversion has to be done if it comes to memory transfers from host
        // into this memory.
        // [bespoken on 2021-06-11 Matthias Hellmann and Jesko Schwarzer]
        uint64_t dstDeviceInterface = dstDevice + ( pTargetFPGA->memcpyOffset );

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
#if ( ORKAGD_FILEFUNC64 == 1 )
                lseek( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle, dstDeviceInterface, SEEK_SET );
                uint64_t numBytes = write( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle, srcHost, byteSize );
                rv                = ( numBytes == byteSize );
#else
                lseek( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle, ( long ) dstDeviceInterface, SEEK_SET );
                size_t numBytes   = write( pTargetFPGA->interfacePCIe.m_DeviceDMAWriteHandle, srcHost, ( uint32_t ) byteSize );
                rv                = ( numBytes == ( size_t ) byteSize );
#endif
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                if ( ( 0 == ( byteSize & 0x3 ) ) && ( 0 == ( dstDeviceInterface & 0x3 ) ) )
                {
                    uint64_t  idx;
                    uint32_t *hostPtr = ( uint32_t * ) srcHost;

                    rv = true; // we expect no problems
                    for ( idx = 0; idx < byteSize; idx += sizeof( uint32_t ) )
                    {
                        ORKAGD_IntelIOCtl_t rw_args;
                        uint32_t            devPtr = ( uint32_t ) ( dstDeviceInterface + idx );
                        rw_args.offset             = devPtr;
                        rw_args.data               = *hostPtr;
                        // ORKAGD_DBG_PRINTF( "[%2" PRId64 "] Host=" PRIp ", Dev=%8.8x\n", idx, hostPtr, devPtr );
                        int ret = ioctl( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle, ORKAGD_FPGA_PR_REGION_WRITE, &rw_args );
                        if ( 0 > ret )
                        {
                            ORKAGD_DBG_PRINTF( "ERROR!! ORKAGD_MemcpyH2D(Intel): ioctl()=%d, srcHost=" PRIp " ==> dstDev=0x%8.8x\n", ret, hostPtr, devPtr );
                            rv = false;
                            break;
                        }
                        hostPtr++;
                    }
                }
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {
#if 1
                uint8_t *pSrc                     = ( uint8_t * ) srcHost;
                uint64_t pD                       = dstDeviceInterface;
                uint32_t numBytesCompleteTransfer = ( uint32_t ) byteSize;
                uint32_t maxBytesToTransfer       = 65536;
                uint32_t bytesTransferred         = 0;
                rv                                = true;
                uint32_t loopCnt                  = 1;
                while ( numBytesCompleteTransfer && rv )
                {
                    uint8_t *pS             = &pSrc[ bytesTransferred ];
                    uint64_t byteSizePacket = numBytesCompleteTransfer < maxBytesToTransfer ? numBytesCompleteTransfer : maxBytesToTransfer;
                    ORKAGD_DBG_PRINTF( "Calling TCP Copy[%d]: Host=0x%p Dev=0x%" PRIx64 " (%" PRId64 ")\n", loopCnt, pSrc, pD, byteSizePacket );

                    if ( 0 )
                    {
                        uint32_t i, j;
                        uint32_t size = ( uint32_t ) byteSizePacket;

                        ORKAGD_DBG_PRINTF_INT( "Dump2: size=%lu\n\r", size );
                        uint8_t *p8 = ( uint8_t * ) pSrc;
                        for ( i = 0; i < 1; i += 16 * 16 )
                        {
                            ORKAGD_DBG_PRINTF_INT( ">>> 0x%16.16" PRIx64 ": ", ( uint64_t ) p8 );
                            for ( j = 0; j < 16; j++ )
                            {
                                ORKAGD_DBG_PRINTF_INT( "%2.2x ", *p8++ );
                            }
                            ORKAGD_DBG_PRINTF_INT( "\n\r" );
                        }
                    }

                    uint64_t numBytes = ORKAGD_TcpIPMemcpyH2D( &ORKAGD_g_TcpIPControlBlock, pD, pSrc, byteSizePacket );
                    rv                = ( bool_t ) ( numBytes == byteSizePacket );
                    if ( rv )
                    {
                        bytesTransferred += ( uint32_t ) numBytes;
                        numBytesCompleteTransfer -= ( uint32_t ) numBytes;
                        pD += numBytes;
                        pSrc += numBytes;
                    }
                    else
                    {
                        ORKAGD_DBG_PRINTF( "Calling TCP Copy[%d]: ERROR! Little Problem ahead\n", loopCnt );
                        rv = false;
                    }
                    loopCnt++;
                }

#else
                uint64_t numBytes = ORKAGD_TcpIPMemcpyH2D( &ORKAGD_g_TcpIPControlBlock, dstDeviceInterface, srcHost, byteSize );
                rv                = ( bool_t ) ( numBytes == byteSize );
                break;
#endif
            }
        }
    }
    else
    {
        ORKAGD_DBG_PRINTF( "CopyH2D: ERROR!! Either handleFPGA = " PRIp " or srcHost = " PRIp " is wrong\n", handleFPGA, srcHost );
    }
    return rv;
}

bool_t
ORKAGD_MemcpyD2H( void *handleFPGA, void *dstHost, const uint64_t srcDevice, const uint64_t byteSize )
{
    bool_t rv = FALSE;
    //    ORKAGD_DBG_PRINTF( "CopyD2H: 0x%" PRIx64 " ==> "PRIp"\n", srcDevice, destHost );
    if ( handleFPGA )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA = ( ORKAGD_FPGAHandle_t * ) handleFPGA;

        // Apply offset to FPGA target address, this is the offset to reach from
        // any interface (e.g. PCIe) the memory of the device.
        // The mapping of internal FPGA memory may be different for every FPGA as well
        // as for different components within the FPGA.
        // The memory controller returns only addresses understandable by the IP itself,
        // so conversion has to be done if it comes to memory transfers from host
        // into this memory.
        // [bespoken on 2021-06-11 Matthias Hellmann and Jesko Schwarzer]
        uint64_t srcDeviceInterface = srcDevice + ( pTargetFPGA->memcpyOffset );

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
#if ( ORKAGD_FILEFUNC64 == 1 )
                lseek( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle, srcDeviceInterface, SEEK_SET );
                uint64_t numBytes = read( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle, dstHost, ( uint32_t ) byteSize );
                rv                = ( numBytes == byteSize );
#else
                lseek( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle, ( long ) srcDeviceInterface, SEEK_SET );
                uint64_t numBytes                 = read( pTargetFPGA->interfacePCIe.m_DeviceDMAReadHandle, ( void * ) dstHost, ( uint32_t ) byteSize );
                rv                                = ( numBytes == ( size_t ) byteSize );
#endif
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                if ( ( 0 == ( byteSize & 0x3 ) ) && ( 0 == ( srcDevice & 0x3 ) ) )
                {
                    uint64_t  idx;
                    uint32_t *hostPtr = ( uint32_t * ) dstHost;

                    rv = true; // we expect no problems
                    for ( idx = 0; idx < byteSize; idx += sizeof( uint32_t ) )
                    {
                        ORKAGD_IntelIOCtl_t rw_args;
                        uint32_t            devPtr = ( uint32_t ) ( srcDeviceInterface + idx );
                        rw_args.offset             = devPtr;
                        // ORKAGD_DBG_PRINTF( "[%2" PRId64 "] Host=" PRIp ", Dev=%8.8x", idx, hostPtr, devPtr );
                        int ret = ioctl( pTargetFPGA->interfacePCIe.m_DeviceMemoryMappedIOHandle, ORKAGD_FPGA_PR_REGION_READ, &rw_args );
                        if ( 0 > ret )
                        {
                            ORKAGD_DBG_PRINTF( "\n" );
                            ORKAGD_DBG_PRINTF( "ERROR!! ORKAGD_MemcpyH2D(Intel): ioctl()=%d, srcHost=" PRIp " ==> dstDev=0x%8.8x\n", ret, hostPtr, devPtr );
                            rv = false;
                            break;
                        }
                        // ORKAGD_DBG_PRINTF( ", Data=0x%8.8x\n", rw_args.data );
                        *hostPtr++ = rw_args.data;
                    }
                }
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {
#if 0
                uint64_t numBytes = ORKAGD_TcpIPMemcpyD2H( &ORKAGD_g_TcpIPControlBlock, dstHost, srcDeviceInterface, byteSize );
                rv                = ( bool_t )( numBytes == byteSize );
#else
                uint8_t *pDest                    = ( uint8_t * ) dstHost;
                uint64_t pS                       = srcDeviceInterface;
                uint32_t numBytesCompleteTransfer = ( uint32_t ) byteSize;
                uint32_t maxBytesToTransfer       = 4096;
                uint32_t bytesTransferred         = 0;
                rv                                = true;
                uint32_t loopCnt                  = 1;
                while ( numBytesCompleteTransfer && rv )
                {
                    uint8_t *pD             = &pDest[ bytesTransferred ];
                    uint64_t byteSizePacket = numBytesCompleteTransfer < maxBytesToTransfer ? numBytesCompleteTransfer : maxBytesToTransfer;
                    // ORKAGD_DBG_PRINTF( "Calling TCP Copy[%d]: Host=0x%p Dev=0x%" PRIx64 " (%" PRId64 ")\n", loopCnt, pDest, pS, byteSizePacket );
                    uint64_t numBytes = ORKAGD_TcpIPMemcpyD2H( &ORKAGD_g_TcpIPControlBlock, pD, pS, byteSizePacket );
                    rv                = ( bool_t ) ( numBytes == byteSizePacket );
                    if ( rv )
                    {
                        bytesTransferred += ( uint32_t ) numBytes;
                        numBytesCompleteTransfer -= ( uint32_t ) numBytes;
                        pS += numBytes;
                    }
                    else
                    {
                        ORKAGD_DBG_PRINTF( "Calling TCP Copy[%d]: ERROR! Little Problem ahead\n", loopCnt );
                        rv = false;
                    }
                    loopCnt++;
                }
#endif
                ORKAGD_DBG_PRINTF( "ORKAGD_MemcpyD2H: rv = %s\n", rv ? "true" : "false" );
                break;
            }
        }
    }
    return rv;
}

// acceleration block control
bool_t
ORKAGD_Axi4LiteBlockStart( const ORKAGD_FPGAComponent_t *component )
{
    bool_t rv = TRUE;
    if ( component )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA     = ( ORKAGD_FPGAHandle_t * ) ( component->fpgaHandle );
        uint64_t             targetIPAddress = component->ipOffset;

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                rv = FALSE;
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
                uint8_t *registerMapBase = ( uint8_t * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
                uint8_t *baseAddress     = registerMapBase + targetIPAddress;

                // Start IP
                ORKA_RegBitClr32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AUTO_RESTART ); // clr: AP_RESTRAT
                ORKA_RegBitSet32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AP_START );     // set: AP_START
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                // Start IP
                uint64_t startRegHandle = ORKAGD_RegisterGetHandleByName( component, "START" );
                uint64_t tmp            = ORKAGD_RegisterReadByHandle( startRegHandle ) | 0x1;
                ORKAGD_RegisterWriteByHandle( startRegHandle, &tmp );
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {

                if ( targetIPAddress & 0xffffffff00000000ULL )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_Axi4LiteBlockStart: Address of component register greater 32-bit: too high. Not implemented yet.\n" );
                }
                else
                {
                    rv &= ORKAGD_TcpIP_Axi4LiteBlockStartA32V32( &ORKAGD_g_TcpIPControlBlock, ( uint32_t ) targetIPAddress );
                }
                break;
            }
        }
    }
    return rv;
}

bool_t // return value says whether to still wait (TRUE) or being finished waiting (FALSE)
ORKAGD_Axi4LiteBlockWait( const ORKAGD_FPGAComponent_t *component )
{
    bool_t rv = true;
    if ( component )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA     = ( ORKAGD_FPGAHandle_t * ) ( component->fpgaHandle );
        uint64_t             targetIPAddress = component->ipOffset;

        switch ( pTargetFPGA->interfaceAccessType )
        {
            default:
            case ORKAGD_ACCESSTYPE_UNDEFINED:
                // do nothing here
                break;

            case ORKAGD_ACCESSTYPE_XDMA:
            {
                uint8_t *registerMapBase = ( uint8_t * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
                uint8_t *baseAddress     = registerMapBase + targetIPAddress;

                // Check if IP is Idle (AP_DONE is Clear on Read...)
                if ( ORKA_RegBitRead32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AP_IDLE ) )
                {
                    break;
                }

                // now wait for IP-Done
                uint64_t counter = 0;
                while ( !ORKA_RegBitRead32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AP_DONE ) )
                {
                    counter++;
                }
                break;
            }

            case ORKAGD_ACCESSTYPE_INTEL_IOCTL:
            {
                uint64_t doneRegHandle = ORKAGD_RegisterGetHandleByName( component, "INTERRUPT_STATUS" );

                uint64_t counter = 0;
                while ( ( ORKAGD_RegisterReadByHandle( doneRegHandle ) & 0x02 ) != 0x02 )
                {
                    counter++;
#if _MSC_VER
                    if ( counter )
                    {
                        break;
                        rv = false;
                    }
#endif
                }
                break;
            }

            case ORKAGD_ACCESSTYPE_IPV4:
            {

                if ( targetIPAddress & 0xffffffff00000000ULL )
                {
                    ORKAGD_DBG_PRINTF( "ORKAGD_Axi4LiteBlockWait: Address of component register greater 32-bit: too high. Not implemented yet.\n" );
                }
                else
                {
                    rv = ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32( &ORKAGD_g_TcpIPControlBlock, ( uint32_t ) targetIPAddress );
                }
                break;
            }
        }
    }
    return rv;

#if 0
    if ( component )
    {
        ORKAGD_FPGAHandle_t *pTargetFPGA = ( ORKAGD_FPGAHandle_t * ) ( component->fpgaHandle );
        uint64_t targetIPAddress = component->ipOffset;
        uint8_t *registerMapBase = ( uint8_t * ) ( pTargetFPGA->interfacePCIe.m_RegisterMapBase );
        uint8_t *baseAddress = registerMapBase + targetIPAddress;

        // Check if IP is Idle (AP_DONE is Clear on Read...)
        if ( ORKA_RegBitRead32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AP_IDLE ) )
        {
            return;
        }

        // now wait for IP-Done
        uint64_t counter = 0;
        while ( !ORKA_RegBitRead32( baseAddress, ORKAGD_AXILITES_AP_CTRL, ORKA_AXILITES_BIT_AP_DONE ) )
        {
            counter++;
        }

        //        ORKAGD_DBG_PRINTF( "NumLoops=%llu\n", ( long long unsigned int )( counter ) );
    }
#endif
}
