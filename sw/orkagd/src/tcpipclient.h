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
#ifndef TCPIPCLIENT_H__
#define TCPIPCLIENT_H__

// local includes
#include "database.h"
#include "liborkagd.h"
#include "liborkagdint.h"
#include "tiny-json.h"
#include "stringhelper.h"


#ifdef _MSC_VER

    // global includes
    #define WIN32_LEAN_AND_MEAN
    #include <windows.h>
    #include <winsock2.h>
    #include <ws2tcpip.h>

    typedef struct
    {
        bool_t initialized;
        WSADATA wsaData;
        struct addrinfo hints;
        SOCKET ConnectSocket;
    } ORKAGD_TcpIPControlBlock_t;

#else

    #include <netdb.h> 
    #include <sys/types.h> 
    #include <netinet/in.h> 
    #include <sys/socket.h> 
    #include <unistd.h>

    #include <stdio.h> 
    #include <stdlib.h> 
    #include <errno.h> 
    #include <string.h> 

    #define INVALID_SOCKET          (~0)
    #define SOCKET_ERROR            (-1)
 
    typedef struct
    {
        bool_t initialized;
        struct addrinfo hints;
        int ConnectSocket;
    } ORKAGD_TcpIPControlBlock_t;

#endif


#if 1
#    define ORKATCP_DBG_PRINTF( fmt, ... ) printf( "ORKATCP: [%d]%s(): " fmt, __LINE__, __func__, ##__VA_ARGS__ )
#define ORKATCP_DBG_PRINTF_AVAILABLE
#else
#define ORKATCP_DBG_PRINTF( ... )
#endif

#define ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY ( 4096 )
#define ORKAGD_TCPIP_MEMCPY_BUFSIZE         ( ORKAGD_TCPIP_MEMCPY_BUFBYTECAPACYTY * 2 )

#define ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_BYTES  ( 65536 )
#define ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_NIBBLE ( ORKAGD_TCPIP_MEMCPY_D2H_BUFFER_BYTES * 2 )

    enum
{
    ORKAGD_FW_SM_AXI4_Wait_RV_NOT_IDLE = 10000,
    ORKAGD_FW_SM_AXI4_Wait_RV_DONE = 10001,
    ORKAGD_FW_SM_AXI4_Wait_RV_NOT_DONE = 10002,
};

uint64_t ORKAGD_TcpIpInit( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock );
void ORKAGD_TcpIpDeInit( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock );
uint64_t ORKAGD_TcpIpOpen( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, char *url, uint64_t port );
void ORKAGD_TcpIpClose( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock );

bool_t ORKAGD_TcpIPRegisterWriteA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value );
uint32_t ORKAGD_TcpIPRegisterReadA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address );
bool_t ORKAGD_TcpIPRegisterBitSetA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value );
bool_t ORKAGD_TcpIPRegisterBitClearA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address, uint32_t value );
uint64_t ORKAGD_TcpIPMemcpyD2H( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, const void *dstHost, const uint64_t srcDevice, const uint64_t byteSize );
uint64_t ORKAGD_TcpIPMemcpyH2D( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, const uint64_t dstDevice, const void *srcHost, const uint64_t byteSize );

bool_t ORKAGD_TcpIP_Axi4LiteBlockStartA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address );
bool_t ORKAGD_TcpIP_Axi4LiteBlockWaitA32V32( ORKAGD_TcpIPControlBlock_t *tcpIPControlBlock, uint32_t address );

// DBG
uint64_t ORKAGD_TcpIP_DebugTrigger( void *block );

#endif
