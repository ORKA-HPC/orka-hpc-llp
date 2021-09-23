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
// local includes
#include "database.h"
#include "liborkagdint.h"
#include "tiny-json.h"
#include "stringhelper.h"
#include "tcpipclient.h"

// global includes
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>

static uint64_t ORKAGD_g_TimeoutInMicroSec = 0;
// destinction
#ifdef _MSC_VER

// global includes
#    define WIN32_LEAN_AND_MEAN
#    include <windows.h>
#    include <winsock2.h>
#    include <ws2tcpip.h>

#    define ORKA_TIMEDOUT WSAETIMEDOUT

// Need to link with Ws2_32.lib, Mswsock.lib, and Advapi32.lib
#    pragma comment( lib, "Ws2_32.lib" )
#    pragma comment( lib, "Mswsock.lib" )
#    pragma comment( lib, "AdvApi32.lib" )

static DWORD ORKAGD_g_TcpIpTimeoutRecv = 0;

static void
ORKAGD_TcpIpSetTimeout( uint64_t timeoutInMicroSec )
{
    ORKAGD_g_TimeoutInMicroSec = timeoutInMicroSec;
    ORKAGD_g_TcpIpTimeoutRecv  = ( DWORD )( timeoutInMicroSec / 1000 ); // we need ms not µs
}
#else

#    define ORKA_TIMEDOUT ETIMEDOUT
static struct timeval ORKAGD_g_TcpIpTimeoutRecv = { 0 };

static void
ORKAGD_TcpIpSetTimeout( uint64_t timeoutInMicroSec )
{
    ORKAGD_g_TimeoutInMicroSec        = timeoutInMicroSec;
    uint64_t seconds                  = timeoutInMicroSec / 1000000;
    uint64_t microSec                 = timeoutInMicroSec - seconds * 1000000;
    ORKAGD_g_TcpIpTimeoutRecv.tv_sec  = ( long ) seconds;
    ORKAGD_g_TcpIpTimeoutRecv.tv_usec = ( long ) microSec;
}

long int
WSAGetLastError()
{
    // TODO: Find equivalent
    //    printf( "(error on linux TCPIP) " );
    return 0;
}

#endif

static uint8_t ORKAGD_g_TcpIpHex2Bin[ 256 ];
static uint8_t ORKAGD_g_TcpIpBin2Hex[ 16 ];

// buffer of memcopy functions (plz. free on exit)
static uint8_t *                   ORKAGD_g_TcpIpBufPtr       = NULL;
static ORKAGD_TcpIPControlBlock_t *ORKAGD_g_TcpIPControlBlock = NULL;

uint64_t
ORKAGD_TcpIpInit( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock )
{
    uint64_t rv = ~0ULL;

    memset( ( void * ) ORKAGD_g_TcpIpHex2Bin, 0xff, sizeof( ORKAGD_g_TcpIpHex2Bin ) );
    ORKAGD_g_TcpIpHex2Bin[ '0' ] = 0;
    ORKAGD_g_TcpIpHex2Bin[ '1' ] = 1;
    ORKAGD_g_TcpIpHex2Bin[ '2' ] = 2;
    ORKAGD_g_TcpIpHex2Bin[ '3' ] = 3;
    ORKAGD_g_TcpIpHex2Bin[ '4' ] = 4;
    ORKAGD_g_TcpIpHex2Bin[ '5' ] = 5;
    ORKAGD_g_TcpIpHex2Bin[ '6' ] = 6;
    ORKAGD_g_TcpIpHex2Bin[ '7' ] = 7;
    ORKAGD_g_TcpIpHex2Bin[ '8' ] = 8;
    ORKAGD_g_TcpIpHex2Bin[ '9' ] = 9;
    ORKAGD_g_TcpIpHex2Bin[ 'a' ] = 10;
    ORKAGD_g_TcpIpHex2Bin[ 'b' ] = 11;
    ORKAGD_g_TcpIpHex2Bin[ 'c' ] = 12;
    ORKAGD_g_TcpIpHex2Bin[ 'd' ] = 13;
    ORKAGD_g_TcpIpHex2Bin[ 'e' ] = 14;
    ORKAGD_g_TcpIpHex2Bin[ 'f' ] = 15;
    ORKAGD_g_TcpIpHex2Bin[ 'A' ] = 10;
    ORKAGD_g_TcpIpHex2Bin[ 'B' ] = 11;
    ORKAGD_g_TcpIpHex2Bin[ 'C' ] = 12;
    ORKAGD_g_TcpIpHex2Bin[ 'D' ] = 13;
    ORKAGD_g_TcpIpHex2Bin[ 'E' ] = 14;
    ORKAGD_g_TcpIpHex2Bin[ 'F' ] = 15;

    memset( ( void * ) ORKAGD_g_TcpIpBin2Hex, 0xff, sizeof( ORKAGD_g_TcpIpBin2Hex ) );
    ORKAGD_g_TcpIpBin2Hex[ 0 ]  = '0';
    ORKAGD_g_TcpIpBin2Hex[ 1 ]  = '1';
    ORKAGD_g_TcpIpBin2Hex[ 2 ]  = '2';
    ORKAGD_g_TcpIpBin2Hex[ 3 ]  = '3';
    ORKAGD_g_TcpIpBin2Hex[ 4 ]  = '4';
    ORKAGD_g_TcpIpBin2Hex[ 5 ]  = '5';
    ORKAGD_g_TcpIpBin2Hex[ 6 ]  = '6';
    ORKAGD_g_TcpIpBin2Hex[ 7 ]  = '7';
    ORKAGD_g_TcpIpBin2Hex[ 8 ]  = '8';
    ORKAGD_g_TcpIpBin2Hex[ 9 ]  = '9';
    ORKAGD_g_TcpIpBin2Hex[ 10 ] = 'a';
    ORKAGD_g_TcpIpBin2Hex[ 11 ] = 'b';
    ORKAGD_g_TcpIpBin2Hex[ 12 ] = 'c';
    ORKAGD_g_TcpIpBin2Hex[ 13 ] = 'd';
    ORKAGD_g_TcpIpBin2Hex[ 14 ] = 'e';
    ORKAGD_g_TcpIpBin2Hex[ 15 ] = 'f';

    if ( tcpIPControlBlock )
    {
        ORKAGD_g_TcpIPControlBlock = tcpIPControlBlock; // DBG only

        // todo: check on already initialized
        uint32_t i;
        bool_t   zeroed = TRUE;
        uint8_t *p      = ( uint8_t * ) tcpIPControlBlock;
        for ( i = 0; i < sizeof( ORKAGD_TcpIPControlBlock_t ); ++i )
        {
            zeroed &= ( 0 == *p++ );
        }
        if ( zeroed )
        {
#ifdef _MSC_VER
            // Initialize Winsock
            rv = ( uint64_t ) WSAStartup( MAKEWORD( 2, 2 ), &( tcpIPControlBlock->wsaData ) );
            ORKATCP_DBG_PRINTF( "ORKAGD_TcipIPInit: WSAStartup = %" PRId64 "\n", rv );
#else
            rv = 0;
#endif
            if ( 0 == rv )
            {
                ORKAGD_TcpIpSetTimeout( 5000000 ); // maximum read wait time is 5000ms
                tcpIPControlBlock->initialized = TRUE;
            }
        }
    }
    return rv;
}

void
ORKAGD_TcpIpDeInit( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock )
{
    if ( tcpIPControlBlock )
    {
        ORKAGD_TcpIpClose( tcpIPControlBlock );
#ifdef _MSC_VER
        closesocket( tcpIPControlBlock->ConnectSocket );
        tcpIPControlBlock->ConnectSocket = ( SOCKET ) NULL;
        WSACleanup();
#else
        close( tcpIPControlBlock->ConnectSocket );
        tcpIPControlBlock->ConnectSocket = 0;
#endif
        // clean up all (wipe)
        memset( ( void * ) tcpIPControlBlock, 0x00, sizeof( ORKAGD_TcpIPControlBlock_t ) );
    }
    // if transfer buffer is allocated, clear and deallocate it
    if ( ORKAGD_g_TcpIpBufPtr )
    {
        memset( ( void * ) ORKAGD_g_TcpIpBufPtr, 0xda, ORKAGD_TCPIP_MEMCPY_BUFSIZE );
        free( ( void * ) ORKAGD_g_TcpIpBufPtr );
        ORKAGD_g_TcpIpBufPtr = NULL;
    }
}

static bool_t
ORKAGD_TcpIPSendMagicAndVersion( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock )
{
    bool_t rv  = FALSE;
    int    res = -1;
    //                     MAGIC   .VERSION
    const char initialMagic[] = ".magic123.v00-03-a";
    const int  transferLen    = ( int ) strlen( initialMagic );
    if ( tcpIPControlBlock )
    {
        // Send an initial buffer
        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPSendMagic: send MAGIC and version\n" );
        res = send( tcpIPControlBlock->ConnectSocket, initialMagic, transferLen, 0 );

        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPSendMagic: send: failed with error: %ld\n", WSAGetLastError() );
        }
        else
        {
            rv = ( transferLen == res ) ? TRUE : FALSE;

            // receive answer from server whether MAGIC was received correctly
            uint8_t buffer;
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPSendMagic: wait for MAGIC acknowledge (max. %1.2fsec.)\n", ( ( float32_t ) ORKAGD_g_TimeoutInMicroSec ) / 1000000.0f );
            res = recv( tcpIPControlBlock->ConnectSocket, ( char * ) &buffer, 1, 0 );
            if ( SOCKET_ERROR == res )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPSendMagic: recv: failed with error: %ld\n", WSAGetLastError() );

                rv = FALSE;
            }
            else
            {
                if ( 1 != res )
                {
                    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPSendMagic: recv: failed with too-less-bytes error: %ld\n", WSAGetLastError() );

                    rv = FALSE;
                }
                else
                {
                    rv = ( 'M' == buffer );
                }
            }
        }
    }
    return rv;
}

uint64_t
ORKAGD_TcpIpOpen( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, char *url, uint64_t port )
{
    uint64_t         rv = ~0ULL;
    int              res;
    char             portBuffer[ 20 ];
    struct addrinfo *result = NULL;
    struct addrinfo *aiptr;
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: url=%s\n", url );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: port=%" PRId64 "\n", port );

    if ( tcpIPControlBlock )
    {
        sprintf( portBuffer, "%" PRId64, port );
        tcpIPControlBlock->ConnectSocket = INVALID_SOCKET;

        memset( ( void * ) &( tcpIPControlBlock->hints ), 0x00, sizeof( tcpIPControlBlock->hints ) );
        tcpIPControlBlock->hints.ai_family   = AF_UNSPEC;
        tcpIPControlBlock->hints.ai_socktype = SOCK_STREAM;
        tcpIPControlBlock->hints.ai_protocol = IPPROTO_TCP;

        // Resolve the server address and port
        res = getaddrinfo( url, portBuffer, &( tcpIPControlBlock->hints ), &result );
        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: getaddrinfo: res=%d\n", res );
        if ( res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: getaddrinfo failed with error: %d\n", res );
            return 1ULL;
        }

        // Attempt to connect to an address until one succeeds
        uint32_t connAttempt = 1;
        for ( aiptr = result; aiptr != NULL; aiptr = aiptr->ai_next )
        {
            printf(
                "Attempt to connect[%d]: %d.%d.%d.%d (%d)\n", connAttempt++, ( uint8_t ) result->ai_addr->sa_data[ 2 ], ( uint8_t ) result->ai_addr->sa_data[ 3 ], ( uint8_t ) result->ai_addr->sa_data[ 4 ], ( uint8_t ) result->ai_addr->sa_data[ 5 ],
                ( uint16_t )( port ) );
            // Create a SOCKET for connecting to server
            tcpIPControlBlock->ConnectSocket = socket( aiptr->ai_family, aiptr->ai_socktype, aiptr->ai_protocol );
#ifdef _MSC_VER
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: socket: ConnectSocket = 0x%p\n", ( void * ) ( tcpIPControlBlock->ConnectSocket ) );
#else
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: socket: ConnectSocket = 0x%8.8x\n", ( tcpIPControlBlock->ConnectSocket ) );
#endif
            if ( tcpIPControlBlock->ConnectSocket == INVALID_SOCKET )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: socket failed with error: %ld\n", WSAGetLastError() );
                rv = 2ULL;
                break;
            }

            // Connect to server.
            res = connect( tcpIPControlBlock->ConnectSocket, aiptr->ai_addr, ( int ) aiptr->ai_addrlen );
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: connect: res = %d\n", res );
            if ( SOCKET_ERROR == res )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPOpen: connect: connect failed with error = %d\n", res );
#ifdef _MSC_VER
                closesocket( tcpIPControlBlock->ConnectSocket );
                tcpIPControlBlock->ConnectSocket = ( SOCKET ) NULL;
#else
                close( tcpIPControlBlock->ConnectSocket );
                tcpIPControlBlock->ConnectSocket = 0;
#endif
                continue;
            }

            // everything is fine with init
            setsockopt( tcpIPControlBlock->ConnectSocket, SOL_SOCKET, SO_RCVTIMEO, ( const char * ) &ORKAGD_g_TcpIpTimeoutRecv, sizeof( ORKAGD_g_TcpIpTimeoutRecv ) );

            // check now communication start with MAGIC number and version
            rv = ( FALSE != ORKAGD_TcpIPSendMagicAndVersion( tcpIPControlBlock ) ) ? 0ULL : 3ULL;
            break;
        }

        freeaddrinfo( result );
    }
    return rv;
}

void
ORKAGD_TcpIpClose( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock )
{
    char exitSeq[] = ".x___"; // need 5 character to fill up for default CMD len
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIpClose: %s\n", exitSeq );
    if ( tcpIPControlBlock )
    {
        // Send an exit sequence
        send( tcpIPControlBlock->ConnectSocket, exitSeq, ( int ) strlen( exitSeq ), 0 );
    }
}

bool_t
ORKAGD_TcpIPRegisterWriteA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value )
{
    bool_t rv                 = TRUE;
    int    res                = -1;
    char   registerSeqWrite[] = ".p4x4.a0x00000000.s0x00000000.d0x00000000";
    sprintf(
        &registerSeqWrite[ 0 ], ".p4x4.a0x%8.8x.s0x%8.8x.d0x%8.8x",
        address, // address of register
        4, value );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterWriteA32V32[w]: %s\n", registerSeqWrite );
    if ( tcpIPControlBlock )
    {
        // receive and discard data - DEBUG!!!! START <<<<<<<<<<<<<<<<<<<<<<<<
        static bool en = false;
        if ( en )
        {
            do
            {
                char buffer[ 1024 ];
                res = recv( tcpIPControlBlock->ConnectSocket, buffer, sizeof( buffer ), MSG_PEEK );
                if ( SOCKET_ERROR != res )
                {
                    res = recv( tcpIPControlBlock->ConnectSocket, buffer, sizeof( buffer ), 0 );
                    ORKATCP_DBG_PRINTF( "%s[res=%d]: recv=0x%8.8x [%.4s]\n", __func__, res, *( ( uint32_t * ) buffer ), ( char * ) &buffer );
                }
            } while ( ( SOCKET_ERROR != res ) && ( 0 != res ) );
            ORKATCP_DBG_PRINTF( "%s: before send ...\n", __func__ );
        }
        // receive and discard data - DEBUG!!!! END <<<<<<<<<<<<<<<<<<<<<<<<<<

        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqWrite, ( int ) strlen( registerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterWriteA32V32: send: failed with error: %ld\n", WSAGetLastError() );

            rv = FALSE;
        }
    }
    return rv;
}

uint32_t
ORKAGD_TcpIPRegisterReadA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address )
{
    uint32_t rv                = 0;
    int      res               = -1;
    char     registerSeqRead[] = ".q4x4.a0x00000000.s0x00000000.d";
    sprintf(
        &registerSeqRead[ 0 ], ".q4x4.a0x%8.8x.s0x%8.8x.d",
        address, // address of register
        4 );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterReadA32V32[r]: %s\n", registerSeqRead );
    if ( tcpIPControlBlock )
    {
        // receive and discard data - DEBUG!!!! START <<<<<<<<<<<<<<<<<<<<<<<<
        static bool en = false;
        if ( en )
        {
            do
            {
                char buffer[ 1024 ];
                res = recv( tcpIPControlBlock->ConnectSocket, buffer, sizeof( buffer ), MSG_PEEK );
                if ( SOCKET_ERROR != res )
                {
                    res = recv( tcpIPControlBlock->ConnectSocket, buffer, sizeof( buffer ), 0 );
                    ORKATCP_DBG_PRINTF( "%s[res=%d]: recv=0x%8.8x [%.4s]\n", __func__, res, *( ( uint32_t * ) buffer ), ( char * ) &buffer );
                }
            } while ( ( SOCKET_ERROR != res ) && ( 0 != res ) );
            ORKATCP_DBG_PRINTF( "%s: before send ...\n", __func__ );
        }
        // receive and discard data - DEBUG!!!! END <<<<<<<<<<<<<<<<<<<<<<<<<<

        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqRead, ( int ) strlen( registerSeqRead ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterReadA32V32: send: failed with error: %ld\n", WSAGetLastError() );
        }

        do
        {
            uint8_t registerValue[ 11 ];

            // read back data
            res = recv( tcpIPControlBlock->ConnectSocket, ( char * ) registerValue, 2 + 8, 0 );

            registerValue[ 10 ] = 0;
            if ( SOCKET_ERROR != res )
            {
                sscanf( ( char * ) &registerValue[ 2 ], "%8x", &rv );
                ORKATCP_DBG_PRINTF( "%s[res=%d]: recv=0x%8.8x [%.4s]\n", __func__, res, *( ( uint32_t * ) registerValue ), ( char * ) &registerValue );
            }
            else
            {
                ORKATCP_DBG_PRINTF( "%s[res=%d]: recv=0x%8.8x [%.4s]\n", __func__, res, *( ( uint32_t * ) registerValue ), ( char * ) &registerValue );
            }
        } while ( ( ORKA_TIMEDOUT == res ) && ( 0 != res ) );
    }

    return rv;
}

bool_t
ORKAGD_TcpIPRegisterBitSetA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value )
{
    bool_t rv                 = TRUE;
    int    res                = -1;
    char   registerSeqWrite[] = ".s4x4.a0x00000000.s0x00000000.d0x00000000";
    sprintf(
        &registerSeqWrite[ 0 ], ".s4x4.a0x%8.8x.s0x%8.8x.d0x%8.8x",
        address, // address of register
        4, 1 << value );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterBitSetA32V32: %s\n", registerSeqWrite );
    if ( tcpIPControlBlock )
    {
        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqWrite, ( int ) strlen( registerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterBitSetA32V32: send: failed with error: %ld\n", WSAGetLastError() );

            rv = FALSE;
        }
    }
    return rv;
}

bool_t
ORKAGD_TcpIPRegisterBitClearA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value )
{
    bool_t rv                 = TRUE;
    int    res                = -1;
    char   registerSeqWrite[] = ".c4x4.a0x00000000.s0x00000000.d0x00000000";
    sprintf(
        &registerSeqWrite[ 0 ], ".c4x4.a0x%8.8x.s0x%8.8x.d0x%8.8x",
        address, // address of register
        4, 1 << value );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterBitClearA32V32: %s\n", registerSeqWrite );
    if ( tcpIPControlBlock )
    {
        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqWrite, ( int ) strlen( registerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPRegisterBitClearA32V32: send: failed with error: %ld\n", WSAGetLastError() );

            rv = FALSE;
        }
    }
    return rv;
}

bool_t
ORKAGD_TcpIP_Axi4LiteBlockStartA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address )
{
    bool_t rv                 = TRUE;
    int    res                = -1;
    char   registerSeqWrite[] = ".a4x4.a0x00000000.s0x00000000.d";
    sprintf(
        &registerSeqWrite[ 0 ], ".a4x4.a0x%8.8x.s0x%8.8x.d",
        address, // address of AXI4-BaseRegister
        4 );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockStartA32V32: %s\n", registerSeqWrite );
    if ( tcpIPControlBlock )
    {
        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqWrite, ( int ) strlen( registerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockStartA32V32: send: failed with error: %ld\n", WSAGetLastError() );
            rv = FALSE;
        }
    }
    return rv;
}

bool_t
ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address )
{
    bool_t   rv                 = TRUE;
    int      res                = -1;
    char     registerSeqWrite[] = ".w4x4.a0x00000000.s0x00000000.d";
    uint32_t result             = 0;

    sprintf(
        &registerSeqWrite[ 0 ], ".w4x4.a0x%8.8x.s0x%8.8x.d",
        address, // address of AXI4-BaseRegister
        4 );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: %s\n", registerSeqWrite );
    if ( tcpIPControlBlock )
    {
        // Send an initial buffer
        res = send( tcpIPControlBlock->ConnectSocket, registerSeqWrite, ( int ) strlen( registerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: send: failed with error: %ld\n", WSAGetLastError() );
            rv = FALSE;
        }
        else
        {
            do
            {
                // receive Answer
                res = recv( tcpIPControlBlock->ConnectSocket, ( char * ) &result, sizeof( result ), 0 );
                // ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: recv=0x%8.8x [%.4s]\n", result, ( char * ) &result );
                if ( SOCKET_ERROR == res )
                {
                    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: recv: failed with error: %ld\n", WSAGetLastError() );
                    rv = FALSE;
                    break;
                }

                if ( sizeof( result ) != ( uint32_t ) res )
                {
                    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: recv: failed with too-less-bytes error: %ld\n", WSAGetLastError() );
                    //                    rv = FALSE;
                    //                    break;
                }
                if ( 0 == ( uint32_t ) res )
                {
                    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32: recv: failed - no bytes: %ld\n", WSAGetLastError() );
                    //                    rv = FALSE;
                    //                    break;
                }

            } while ( ORKAGD_FW_SM_AXI4_Wait_RV_DONE != result );
        }
    }
    return rv;
}

uint64_t
ORKAGD_TcpIP_DebugTrigger( void *block )
{
    bool_t rv                   = TRUE;
    int    res                  = -1;
    char   dbgTriggerSeqWrite[] = ".z___";
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_DebugTrigger\n" );
    if ( ORKAGD_g_TcpIPControlBlock )
    {
        // Send an initial buffer
        res = send( ORKAGD_g_TcpIPControlBlock->ConnectSocket, dbgTriggerSeqWrite, ( int ) strlen( dbgTriggerSeqWrite ), 0 );
        if ( SOCKET_ERROR == res )
        {
            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIP_DebugTrigger: send: failed with error: %ld\n", WSAGetLastError() );

            rv = FALSE;
        }
    }
    return rv;
}

uint64_t // returns number of bytes transmitted
ORKAGD_TcpIPMemcpyH2D( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, const uint64_t dstDevice, const void *srcHost, const uint64_t byteSize )
{
    int         res                 = -1;
    uint64_t    rv                  = ~0ULL;
    static char memorySeqTransmit[] = ".t8x4.a0x0000000081001000.s0x0000000000000018.d";
    sprintf(
        memorySeqTransmit, ".t8x8.a0x%16.16" PRIx64 ".s0x%16.16" PRIx64 ".d",
        dstDevice, // address of memory within device
        byteSize );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyH2D: %s\n", memorySeqTransmit );
    if ( tcpIPControlBlock )
    {
        if ( NULL == ORKAGD_g_TcpIpBufPtr )
        {
            ORKAGD_g_TcpIpBufPtr = calloc( 1, ORKAGD_TCPIP_MEMCPY_BUFSIZE );
        }
        if ( ORKAGD_g_TcpIpBufPtr )
        {
            // Send an initial buffer-sequence (header)
            res = send( tcpIPControlBlock->ConnectSocket, memorySeqTransmit, ( int ) strlen( memorySeqTransmit ), 0 );
            if ( SOCKET_ERROR == res )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyH2D: send: failed with error: %ld\n", WSAGetLastError() );
            }
            else
            {
                uint64_t bytesToProcess = byteSize;
                uint8_t *sptr           = ( uint8_t * ) srcHost;
                rv                      = bytesToProcess;
                uint32_t loopCnt        = 1;
                while ( bytesToProcess )
                {
                    // ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyH2D: Bytes to transfer: %" PRId64 " (Loop: %d)\n", bytesToProcess, loopCnt++ );
                    // calculate max number of bytes we are able to process
                    uint32_t numBytes = bytesToProcess > ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY ? ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY : ( ( uint32_t ) bytesToProcess );

                    if ( 0 )
                    {
                        uint32_t i, j;
                        uint32_t size = numBytes;

                        printf( "Dump1: size=%lu\n\r", size );
                        uint8_t *p8 = ( uint8_t * ) sptr;
                        for ( i = 0; i < 1; i += 16 * 16 )
                        {
                            printf( ">>> 0x%8.8x: ", p8 );
                            for ( j = 0; j < 16; j++ )
                            {
                                printf( "%2.2x ", *p8++ );
                            }
                            printf( "\n\r" );
                        }
                    }

                    uint32_t numBytesToProcess = numBytes;
                    uint8_t *dptr              = ORKAGD_g_TcpIpBufPtr;
                    while ( numBytesToProcess > 0 )
                    {
                        uint8_t value = *sptr++;

                        *dptr++ = ORKAGD_g_TcpIpBin2Hex[ value >> 4 ];
                        *dptr++ = ORKAGD_g_TcpIpBin2Hex[ value & 0x0f ];
                        numBytesToProcess--;
                    }

                    // reduces size by chunk size
                    bytesToProcess -= numBytes;

                    // ASCII Nibbles are stored character wise and two are needed per byte
                    uint32_t numNibbles = numBytes << 1;
                    // send nibbles-chunk
                    // ORKATCP_DBG_PRINTF( "send(): bytes=%d\n", numNibbles );

                    if ( 0 )
                    {
                        uint32_t i, j;
                        uint32_t size = numNibbles;

                        printf( "Dump2: size=%lu\n\r", size );
                        uint8_t *p8 = ( uint8_t * ) ORKAGD_g_TcpIpBufPtr;
                        for ( i = 0; i < 1; i += 16 * 16 )
                        {
                            printf( ">>> 0x%8.8x: ", p8 );
                            for ( j = 0; j < 16; j++ )
                            {
                                printf( "%2.2x ", *p8++ );
                            }
                            printf( "\n\r" );
                        }
                    }

                    res = send( tcpIPControlBlock->ConnectSocket, ( char * ) ORKAGD_g_TcpIpBufPtr, numNibbles, 0 );
                    if ( SOCKET_ERROR == res )
                    {
                        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyH2D: send: failed with error: %ld\n", WSAGetLastError() );

                        break;
                    }

                    if ( numNibbles != ( uint32_t ) res )
                    {
                        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyH2D: send: failed with too-less-bytes error: %ld\n", WSAGetLastError() );

                        break;
                    }
                }
                rv = byteSize - bytesToProcess;
            }
        }
    }
    return rv;
}

#if 0
uint64_t // num bytes transmitted
ORKAGD_TcpIPMemcpyD2H( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, const void *destHost, const uint64_t srcDevice, const uint64_t byteSize )
{
    int         res             = -1;
    uint64_t    rv              = ~0ULL;
    static char memorySeqRead[] = ".r8x4.a0x0000000081001000.s0x0000000000000018.d0123456789abcdef00112233445566778899aabbccddeeff.r4x4.a0x81001000.s0x00000012.d";
    sprintf(
        memorySeqRead, ".r8x8.a0x%16.16" PRIx64 ".s0x%16.16" PRIx64 ".d",
        srcDevice, // address of memory within device
        byteSize );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: %s\n", memorySeqRead );
    if ( tcpIPControlBlock )
    {
        if ( NULL == ORKAGD_g_TcpIpBufPtr )
        {
            ORKAGD_g_TcpIpBufPtr = calloc( 1, ORKAGD_TCPIP_MEMCPY_BUFSIZE );
        }
        if ( ORKAGD_g_TcpIpBufPtr )
        {
            // Send an initial buffer-sequence (header)
            ORKATCP_DBG_PRINTF( "send(Command)=%d\n", ( int ) strlen( memorySeqRead ) );
            // ORKATCP_DBG_PRINTF( "sleep1\n" );
            // Sleep( 5000 );
            // ORKATCP_DBG_PRINTF( "send\n" );
            res = send( tcpIPControlBlock->ConnectSocket, memorySeqRead, ( int ) strlen( memorySeqRead ), 0 );
            if ( SOCKET_ERROR == res )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: send: failed with error: %ld\n", WSAGetLastError() );
            }
            else
            {
                uint64_t bytesToProcess = byteSize;
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: Bytes to transfer: %" PRId64 "\n", byteSize );
                uint8_t *dptr           = ( uint8_t * ) destHost;
                rv                      = bytesToProcess;
                uint32_t loopCnt        = 1;
                while ( bytesToProcess )
                {
                    // calculate max number of bytes we are able to process
                    uint32_t numBytes = bytesToProcess > ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY ? ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY : ( ( uint32_t ) bytesToProcess );

                    // ASCII Nibbles are stored character wise and two are needed per byte
                    uint32_t numNibbles = numBytes << 1;

                    // receive nibbles-chunk
                    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: Bytes to transfer: %" PRId64 " - %d nibbles (total: %" PRId64 ", Loop: %d)\n", byteSize, numNibbles, bytesToProcess, loopCnt++ );
                    res = recv( tcpIPControlBlock->ConnectSocket, ( char * ) ORKAGD_g_TcpIpBufPtr, numNibbles, 0 );
                    if ( SOCKET_ERROR == res )
                    {
                        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: recv: failed with error: %ld\n", WSAGetLastError() );
                        break;
                    }

                    if ( numNibbles != ( uint32_t ) res )
                    {
                        int rc = WSAGetLastError();
                        if ( rc )
                        {
                            ORKATCP_DBG_PRINTF( "Critical-Warning: recv returned %d [0x%8.8x]\n", res, res );
                            ORKATCP_DBG_PRINTF( " - failed with too-less-bytes error [returned %d bytes instead of requested %d bytes]: WSAGetLastError = %d\n", res, numBytes, rc );
                        }
                        // recalculate real received bytes to process
                        numBytes = res >> 1;
                    }

                    uint8_t *nibbleBuffer      = ORKAGD_g_TcpIpBufPtr;
                    uint32_t numBytesToProcess = numBytes;
                    while ( numBytesToProcess > 0 )
                    {

                        *dptr++ = ( ORKAGD_g_TcpIpHex2Bin[ *nibbleBuffer ] << 4 ) | ( ORKAGD_g_TcpIpHex2Bin[ *( nibbleBuffer + 1 ) ] );
                        nibbleBuffer += 2;
                        numBytesToProcess--;
                    }

                    // reduces size by chunk size
                    bytesToProcess -= numBytes;
                }
                rv = byteSize - bytesToProcess;
            }
        }
    }
    return rv;
}
#endif

uint64_t // num bytes transmitted
ORKAGD_TcpIPMemcpyD2H( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, const void *destHost, const uint64_t srcDevice, const uint64_t byteSize )
{
    int         res             = -1;
    uint64_t    rv              = ~0ULL;
    bool        sockErr         = false;
    static char memorySeqRead[] = ".r8x4.a0x0000000081001000.s0x0000000000000018.d0123456789abcdef00112233445566778899aabbccddeeff.r4x4.a0x81001000.s0x00000012.d";
    sprintf(
        memorySeqRead, ".r8x8.a0x%16.16" PRIx64 ".s0x%16.16" PRIx64 ".d",
        srcDevice, // address of memory within device
        byteSize );
    ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: %s\n", memorySeqRead );
    if ( tcpIPControlBlock )
    {
        // reserve memory for nibbles
        if ( NULL == ORKAGD_g_TcpIpBufPtr )
        {
            ORKAGD_g_TcpIpBufPtr = calloc( 1, ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_NIBBLE );
        }

        if ( ORKAGD_g_TcpIpBufPtr )
        {
            // Send an initial buffer-sequence (header)
            res = send( tcpIPControlBlock->ConnectSocket, memorySeqRead, ( int ) strlen( memorySeqRead ), 0 );
            if ( SOCKET_ERROR == res )
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: send: failed with error: %ld\n", WSAGetLastError() );
            }
            else
            {
                ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: From device 0x%" PRIx64 " %" PRId64 " bytes\n", srcDevice, byteSize );

                // here we start a loop over all requested bytes (all nibbles)
                uint32_t bytesToProcess = ( uint32_t ) byteSize;
                uint32_t loopCnt        = 1;
                uint8_t *dptr           = ( uint8_t * ) destHost;
                while ( bytesToProcess )
                {
                    // ASCII Nibbles are stored character wise and two are needed per byte
                    uint32_t numNibbles = bytesToProcess << 1;

                    // calculate max number of bytes we are able to process
                    uint32_t numBytes = numNibbles > ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_NIBBLE ? ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_NIBBLE : numNibbles;
                    numBytes          = numNibbles > 4096 ? 4096 : numNibbles;
                    // this loop is to get the buffer full with nibbles
                    uint8_t *nextNibblesToStore = ( uint8_t * ) ORKAGD_g_TcpIpBufPtr;
                    uint32_t numReceivedSoFar   = 0;
                    uint32_t loopCntInner       = 1;
                    do
                    {
                        // receive nibbles-chunk
                        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: InnerLoop=%d, %d nibbles\n", loopCntInner, numBytes );
                        uint8_t *nibbleStore = &nextNibblesToStore[ numReceivedSoFar ];
                        res                  = recv( tcpIPControlBlock->ConnectSocket, ( void * ) nibbleStore, numBytes, MSG_WAITALL );
                        sockErr              = ( SOCKET_ERROR == res );
                        if ( sockErr )
                        {
                            ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: recv: failed with error: %ld\n", WSAGetLastError() );
                            break;
                        }
                        else
                        {
                            numBytes -= res;
                            numReceivedSoFar += res;
                        }
                        loopCntInner++;
                    } while ( numBytes && ( !sockErr ) );

                    if ( sockErr )
                    {
                        break;
                    }

                    if ( numReceivedSoFar & 0x01 )
                    {
                        ORKATCP_DBG_PRINTF( "ORKAGD_TcpIPMemcpyD2H: ERROR!!!! Nibbles must be pairwise !!!! - exiting ...\n" );
                        exit( 1 );
                    }

                    while ( numReceivedSoFar )
                    {
                        *dptr++ = ( ORKAGD_g_TcpIpHex2Bin[ *nextNibblesToStore ] << 4 ) | ( ORKAGD_g_TcpIpHex2Bin[ *( nextNibblesToStore + 1 ) ] );
                        numReceivedSoFar -= 2;
                        bytesToProcess--;
                        nextNibblesToStore += 2;
                    }
                }
                rv = byteSize - bytesToProcess;
            }
        }
    }
    return rv;
}
