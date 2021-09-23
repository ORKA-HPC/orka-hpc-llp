// derived from echo-server example from Xilinx

#include <stdio.h>
#include <string.h>

#include "platform.h"

#include "lwip/err.h"
#include "lwip/tcp.h"

#include "server.h"
#include "myVersion.h"

#if defined( __arm__ ) || defined( __aarch64__ )
#    include "xil_printf.h"
#endif

// uncomment if real memory operations are desired
#define ORKA_REAL_MEMOP

#define ORKA_FW_SRV_PORT  ( 6789 )
#define ORKA_FW_COLOR_LED ( 0x210000 )

uint32_t g_state             = ORKAGD_FW_SM_Init;
uint32_t g_stateNext         = 0;
uint32_t g_CommunicationMode = ORKAGD_FW_SRV_STATE_Unknown;
uint8_t  g_AddressMode       = ORKAGD_FW_SRV_STATE_AddressModeUnknown;
uint64_t g_AddressValue      = 0ULL;
uint32_t g_SizeMode          = ORKAGD_FW_SRV_STATE_SizeModeUnknown;
uint64_t g_SizeValue         = 0ULL;
uint8_t  g_VersionMajor      = 0;
uint8_t  g_VersionMinor      = 0;
uint8_t  g_VersionFlavor     = ORKAGD_FW_SRV_STATE_ModeBinary;

uint32_t       g_DataNeeded        = 0;
uint32_t       g_DataAvailable     = 0;
const char     g_MagicWordString[] = ".magic123";
const uint32_t g_MagicWordLen      = sizeof( g_MagicWordString ) - 1;
const char     g_VersionString[]   = ".vxx-yy-f"; // ".v"+"major-minor-flavor"
const uint32_t g_VersionStringLen  = sizeof( g_VersionString ) - 1;

// **************************************************************************************************************
// **
// ** Status display on Color-LEDs
// **
// **************************************************************************************************************
void
ORKA_FW_Status0( uint32_t x )
{
    ORKAGD_FW_DBG_PRINTF( 3, "Status0: %ld\n\r", x );
    volatile uint32_t *p = ( uint32_t * ) ORKA_FW_COLOR_LED;
    uint32_t           v = ( ( *p ) & 0xfffffff8 ) | ( ( x & 0x00000007 ) << 0 );
    *p                   = v;
}

void
ORKA_FW_Status1( uint32_t x )
{
    ORKAGD_FW_DBG_PRINTF( 3, "Status1: %ld\n\r", x );
    volatile uint32_t *p = ( uint32_t * ) ORKA_FW_COLOR_LED;
    uint32_t           v = ( ( *p ) & 0xffffffc7 ) | ( ( x & 0x00000007 ) << 3 );
    *p                   = v;
}

void
ORKA_FW_Status2( uint32_t x )
{
    ORKAGD_FW_DBG_PRINTF( 3, "Status2: %ld\n\r", x );
    volatile uint32_t *p = ( uint32_t * ) ORKA_FW_COLOR_LED;
    uint32_t           v = ( ( *p ) & 0xfffffe3f ) | ( ( x & 0x00000007 ) << 6 );
    *p                   = v;
}

void
ORKA_FW_Status3( uint32_t x )
{
    ORKAGD_FW_DBG_PRINTF( 3, "Status3: %ld\n\r", x );
    volatile uint32_t *p = ( uint32_t * ) ORKA_FW_COLOR_LED;
    uint32_t           v = ( ( *p ) & 0xfffff1ff ) | ( ( x & 0x00000007 ) << 9 );
    *p                   = v;
}

// **************************************************************************************************************
// **
// ** Buffer start
// **
// **************************************************************************************************************

static uint8_t  g_BufRcv[ ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE ];
static uint8_t  g_BufCnv[ ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE * 2 ];
static uint8_t  ORKAGD_FWBuffer[ ORKA_FW_SRV_BUFFER_SIZE ] = { 0 };
static uint32_t ORKAGD_FWBufferRdIdx                       = 0;
static uint32_t ORKAGD_FWBufferWrIdx                       = 0;

static void
ORKA_GD_FWBufferReset()
{
    ORKAGD_FWBufferRdIdx = 0;
    ORKAGD_FWBufferWrIdx = 0;
}

// This function tells us how much data may be read currently from buffer "ORKAGD_FWBuffer"
static uint32_t
ORKA_GD_FWBufferLevelRead()
{
    size_t sizeRead = ORKAGD_FWBufferWrIdx >= ORKAGD_FWBufferRdIdx ? ORKAGD_FWBufferWrIdx - ORKAGD_FWBufferRdIdx : ORKA_FW_SRV_BUFFER_SIZE - ( ORKAGD_FWBufferRdIdx - ORKAGD_FWBufferWrIdx );
    return sizeRead;
}

static uint32_t
ORKAGD_FWBufferWrite( void *bufferInputData, uint32_t bufferInputSize )
{
    uint32_t rc                      = 0;
    uint32_t bufferInputTransferSize = bufferInputSize >= ORKA_FW_SRV_BUFFER_SIZE ? ORKA_FW_SRV_BUFFER_SIZE : bufferInputSize;
    ORKAGD_FW_DBG_PRINTF( 3, "ORKAGD_FWBufferWrite: shallWrite: %ld [rdi=%ld, wri=%ld]\n\r", bufferInputSize, ORKAGD_FWBufferRdIdx, ORKAGD_FWBufferWrIdx );
    ORKAGD_FW_DBG_PRINT_BUF( 2, "ORKAGD_FWBufferWrite: ", bufferInputData, bufferInputSize );

    if ( ORKAGD_FWBufferWrIdx >= ORKAGD_FWBufferRdIdx )
    {
        // write is maybe reaching buffer end and has to be split.

        // 1.) copy write-ptr to end of buffer
        uint32_t bufferSpaceUpper = ORKA_FW_SRV_BUFFER_SIZE - ORKAGD_FWBufferWrIdx;
        if ( bufferInputTransferSize > bufferSpaceUpper )
        {
            // size is greater than write pointer up to end of buffer
            uint32_t bufferSpaceTail = bufferInputTransferSize - bufferSpaceUpper;
            // check for 0-byte copy
            if ( bufferSpaceUpper )
            {
                memcpy( ( void * ) ( &ORKAGD_FWBuffer[ ORKAGD_FWBufferWrIdx ] ), bufferInputData, bufferSpaceUpper );
                rc += bufferSpaceUpper;
            }
            ORKAGD_FWBufferWrIdx = 0;
            if ( bufferSpaceTail > 0 )
            {
                // 2.) now try to copy rest of data to front of buffer
                uint32_t bufferSpaceTailMaxSize = ( bufferSpaceTail >= ( ORKAGD_FWBufferRdIdx - 1 ) ) ? ( ORKAGD_FWBufferRdIdx - 1 ) : bufferSpaceTail;
                if ( bufferSpaceTailMaxSize )
                {
                    memcpy( ( void * ) ( &ORKAGD_FWBuffer[ 0 ] ), ( void * ) ( &( ( uint8_t * ) ( bufferInputData ) )[ bufferSpaceUpper ] ), bufferSpaceTailMaxSize );
                    rc += bufferSpaceTailMaxSize;
                }
                ORKAGD_FWBufferWrIdx = bufferSpaceTailMaxSize;
            }
        }
        else
        {
            memcpy( ( void * ) ( &ORKAGD_FWBuffer[ ORKAGD_FWBufferWrIdx ] ), bufferInputData, bufferInputTransferSize );
            rc += bufferInputTransferSize;
            ORKAGD_FWBufferWrIdx += bufferInputTransferSize;
        }
    }
    else
    {
        uint32_t bufferMaxSize = ORKAGD_FWBufferRdIdx - ORKAGD_FWBufferWrIdx - 1;
        if ( bufferMaxSize > 0 )
        {
            bufferInputTransferSize = bufferInputSize > bufferMaxSize ? bufferMaxSize : bufferInputSize;
            memcpy( ( void * ) ( &ORKAGD_FWBuffer[ ORKAGD_FWBufferWrIdx ] ), bufferInputData, bufferInputTransferSize );
            rc += bufferInputTransferSize;
            ORKAGD_FWBufferWrIdx += bufferInputTransferSize;
        }
    }
    ORKAGD_FW_DBG_PRINTF( 3, "ORKAGD_FWBufferWrite: isWritten:  %ld\n\r", rc );
    return rc;
}

static uint32_t
ORKAGD_FWBufferRead( void *bufferData, uint32_t bufferReadSize )
{
    uint32_t readData = 0;
    ORKAGD_FW_DBG_PRINTF( 3, "ORKAGD_FWBufferRead: w=%ld, r=%ld (%ld)\n\r", ORKAGD_FWBufferWrIdx, ORKAGD_FWBufferRdIdx, bufferReadSize );
    // xil_printf( "ORKAGD_FWBufferRead: w=%ld, r=%ld (%ld)\n\r", ORKAGD_FWBufferWrIdx, ORKAGD_FWBufferRdIdx, bufferReadSize );
    if ( ORKAGD_FWBufferWrIdx != ORKAGD_FWBufferRdIdx )
    {
        if ( ORKAGD_FWBufferWrIdx > ORKAGD_FWBufferRdIdx )
        {
            uint32_t maxReadSize = ORKAGD_FWBufferWrIdx - ORKAGD_FWBufferRdIdx;
            readData             = maxReadSize < bufferReadSize ? maxReadSize : bufferReadSize;
            memcpy( bufferData, ( void * ) ( &ORKAGD_FWBuffer[ ORKAGD_FWBufferRdIdx ] ), readData );
            ORKAGD_FWBufferRdIdx += readData;
            ORKAGD_FW_DBG_PRINTF( 3, "ORKAGD_FWBufferRead: r=%ld\n\r", ORKAGD_FWBufferRdIdx );
            // xil_printf( "ORKAGD_FWBufferRead[c]: rIdx=%ld [%ld]\n\r", ORKAGD_FWBufferRdIdx, readData );
        }
        else
        {
            // Status: read request and write ptr below read pointer
            // =====================================================
            //
            // - reading means: read until end of buffer (if needed)
            // - if further reading is needed, start over from beginning and read until write ptr is reached

            // Part1:
            // copy read ptr until end of buffer (at max) into destination
            uint32_t maxReadSize = ORKA_FW_SRV_BUFFER_SIZE - ORKAGD_FWBufferRdIdx;
            readData             = maxReadSize < bufferReadSize ? maxReadSize : bufferReadSize;
            memcpy( bufferData, ( void * ) ( &ORKAGD_FWBuffer[ ORKAGD_FWBufferRdIdx ] ), readData );

            // Part2:
            // we already processed readData bytes. Is there more to transfer?
            // if yes, get it from beginning of ring buffer.
            uint32_t tailDataSize = bufferReadSize - readData;
            if ( tailDataSize )
            {
                // read at maximum until write ptr. Beyond there is undefined data.
                uint32_t readDataTail = tailDataSize > ORKAGD_FWBufferWrIdx ? ORKAGD_FWBufferWrIdx : tailDataSize;
                if ( readDataTail )
                {
                    memcpy( &( ( uint8_t * ) bufferData )[ readData ], ( void * ) ( &ORKAGD_FWBuffer[ 0 ] ), readDataTail );
                    ORKAGD_FWBufferRdIdx = readDataTail;
                    readData += readDataTail;
                }
                else
                {
                    // no more data, just correct the new read ptr
                    ORKAGD_FWBufferRdIdx += readData;
                }
            }
            else
            {
                // no more data, just correct the new read ptr
                ORKAGD_FWBufferRdIdx += readData;
            }
            // xil_printf( "ORKAGD_FWBufferRead[ht]: rIdx=%ld [%ld]\n\r", ORKAGD_FWBufferRdIdx, readData );
        }
    }
    return readData;
}

static void
ORKAGD_FWBufferReadUndo( uint32_t bufferUndoReadSize )
{
    if ( ORKAGD_FWBufferRdIdx >= bufferUndoReadSize )
    {
        ORKAGD_FWBufferRdIdx -= bufferUndoReadSize;
    }
    else
    {
        ORKAGD_FWBufferRdIdx += ORKA_FW_SRV_BUFFER_SIZE - bufferUndoReadSize;
    }
}

uint8_t bufa[ 64 ];
uint8_t bufb[ 64 ];
uint8_t bufc[ 64 ];

void
TestRingBuffer()
{
    printf( "TestRingBuffer\n\r" );
    ORKA_GD_FWBufferReset();
    memset( bufa, '0', sizeof( bufa ) );
    memset( bufb, '1', sizeof( bufb ) );
    memset( bufc, '2', sizeof( bufc ) );

    ORKAGD_FWBufferWrite( bufa, 63 );
    ORKAGD_FWBufferWrite( bufb, 63 );
    printf( "%c,%c\n\r", ORKAGD_FWBuffer[ 62 ], ORKAGD_FWBuffer[ 63 ] );
    ORKAGD_FWBufferWrite( bufc, 63 );
    printf( "%c,%c\n\r", ORKAGD_FWBuffer[ 61 ], ORKAGD_FWBuffer[ 62 ] );
    for ( ;; )
        ;
}

// **************************************************************************************************************
// **
// ** Buffer end
// **
// **************************************************************************************************************

uint64_t
ORKAGD_FW_Hex2uint64( uint8_t *buf, uint8_t size )
{
    uint64_t res = 0;
    for ( uint8_t i = 0; i < size; ++i )
    {
        uint8_t c = buf[ i ];
        if ( ( '0' <= c ) && ( '9' >= c ) )
        {
            res = ( res << 4 ) | ( c - '0' );
        }
        else
        {
            if ( ( 'a' <= c ) && ( 'f' >= c ) )
            {
                res = ( res << 4 ) | ( c + 10 - 'a' );
            }
            else
            {
                if ( ( 'A' <= c ) && ( 'F' >= c ) )
                {
                    res = ( res << 4 ) | ( c + 10 - 'A' );
                }
                else
                {
                    // illegal
                    res = 0;
                    break;
                }
            }
        }
    }
    return res;
}

uint8_t
ORKAGD_FW_Hex2ui8( uint8_t *buf )
{
    uint8_t *p = buf;
    uint8_t  v = 0;
    uint8_t  r = 0;

    // high nibble
    uint8_t c = *p++;
    if ( ( c >= '0' ) && ( c <= '9' ) )
    {
        v = c - '0';
    }
    else
    {
        if ( ( c >= 'a' ) && ( c <= 'z' ) )
        {
            v = c - 'a' + 10;
        }
        else
        {
            if ( ( c >= 'A' ) && ( c <= 'Z' ) )
            {
                v = c - 'A' + 10;
            }
            else
            {
                // illegal
                v = 0;
            }
        }
    }
    r = v << 4;

    // low nibble
    c = *p++;
    if ( ( c >= '0' ) && ( c <= '9' ) )
    {
        v = c - '0';
    }
    else
    {
        if ( ( c >= 'a' ) && ( c <= 'z' ) )
        {
            v = c - 'a' + 10;
        }
        else
        {
            if ( ( c >= 'A' ) && ( c <= 'Z' ) )
            {
                v = c - 'A' + 10;
            }
            else
            {
                // illegal
                v = 0;
            }
        }
    }
    r |= v;

    return r;
}

uint32_t
ORKAGD_FW_Dez2ui32( uint8_t *buf, uint8_t digits )
{
    uint8_t *p = buf;
    uint8_t  r = 0;

    while ( digits > 0 )
    {
        uint8_t c = *p++;
        if ( ( c >= '0' ) && ( c <= '9' ) )
        {
            const uint8_t v = c - '0';
            r *= 10;
            r += ( uint32_t ) v;
        }
        else
        {
            break;
        }
        digits--;
    }

    return r;
}

int
start_application()
{
    struct tcp_pcb *pcb;
    err_t           err;
    unsigned        port = ORKA_FW_SRV_PORT;

    // TestRingBuffer();

    /* create new TCP PCB structure */
    pcb = tcp_new_ip_type( IPADDR_TYPE_ANY );
    if ( !pcb )
    {
        ORKAGD_FW_DBG_PRINTF( 9, "Error creating PCB. Out of Memory\n\r" );
        return -1;
    }

    /* bind to specified @port */
    err = tcp_bind( pcb, IP_ANY_TYPE, port );
    if ( err != ERR_OK )
    {
        ORKAGD_FW_DBG_PRINTF( 9, "Unable to bind to port %d: err = %d\n\r", port, err );
        return -2;
    }

    /* we do not need any arguments to callback functions */
    tcp_arg( pcb, NULL );

    /* listen for connections */
    pcb = tcp_listen( pcb );
    if ( !pcb )
    {
        ORKAGD_FW_DBG_PRINTF( 9, "Out of memory while tcp_listen\n\r" );
        return -3;
    }

    /* specify callback to use for incoming connections */
    tcp_accept( pcb, accept_callback );

    ORKAGD_FW_DBG_PRINTF_NO_HEADER( 9, "Server listening on port %d\n\r", port );
    ORKA_GD_FWBufferReset();

    return 0;
}

err_t
accept_callback( void *arg, struct tcp_pcb *newpcb, err_t err )
{
    static int connection = 0;

    ORKAGD_FW_DBG_PRINTF( 8, "Accept_callback called: %d\n\r", connection );

    /* set the receive callback for this connection */
    tcp_recv( newpcb, recv_callback );

    /* just use an integer number indicating the connection id as the callback argument */
    tcp_arg( newpcb, ( void * ) ( UINTPTR ) connection );

    /* increment for subsequent accepted connections */
    connection++;

    return ERR_OK;
}

int
transfer_data()
{
// static uint32_t xxx=0; if ((xxx++&0xfffff)==0)	xil_printf("*\r\n");
#if 0
    // let the UART show: its not DEAD
    static uint32_t c = 0;
    c++;
    c &= 0x7fff;
    if ( 0 == c )
    {
        printf(".");fflush(stdout);
    }
#endif
#if 0
    {
        // let the green LEDs run
        uint32_t *p = ( uint32_t * ) 0x200000;
        static uint32_t x = 0;
        *p = ( x++ ) >> 19;

    }
#endif
#if 0
    {
        // let the RGB LEDs run
        uint32_t *p = ( uint32_t *) 0x210000;
        static uint32_t x = 0;
        *p = ( x++ ) >> 18;
    }
#endif
    return 0;
}

void
print_app_header()
{
    ORKAGD_FW_DBG_PRINTF_NO_HEADER( 10, "\n\r\n\rORKA GenericDriver Firmware for TCP/IP Communication (%s, %s) V%d.%2.2d.%04d\n\r", __DATE__, __TIME__, BUILD_VERSION_MAJOR, BUILD_VERSION_MINOR, BUILD_VERSION_BUILD );
#if ( LWIP_IPV6 == 0 )
    ORKAGD_FW_DBG_PRINTF_NO_HEADER( 10, "==> (IP4)\n\r" );
#else
    ORKAGD_FW_DBG_PRINTF_NO_HEADER( 10, "==> (IP6)\n\r" );
#endif
    ORKAGD_FW_DBG_PRINTF( 10, "Hint: Listening on port %d\n\r", ORKA_FW_SRV_PORT );
}

err_t
recv_callback( void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err )
{
    static uint32_t call = 0;

    ORKAGD_FW_DBG_PRINTF( 3, "recv_callback: enter [0x%8.8x, 0x%8.8x, 0x%8.8x]\n\r", ( unsigned int ) arg, ( unsigned int ) tpcb, ( unsigned int ) p );

    /* do not read the packet if we are not in ESTABLISHED state */
    if ( !p )
    {
        ORKAGD_FW_DBG_PRINTF( 8, "recv_callback [Connect=%1ld]: Shutting down !!!\n\r", ( uint32_t ) arg );
        tcp_close( tpcb );
        tcp_recv( tpcb, NULL );

        // reset data communication: clear buffer and states
        ORKA_GD_FWBufferReset();
        g_DataNeeded = 0;
        g_state      = ORKAGD_FW_SM_Init;
        return ERR_OK;
    }

    ORKAGD_FW_DBG_PRINTF( 5, "recv_callback [Connect=%1ld]: Call#%3ld, ReceivedBytes=%d\n\r", ( uint32_t ) arg, call++, p->len );

    /* indicate that the packet has been received */
    tcp_recved( tpcb, p->len );

    // write data into internal buffer(s)
    uint32_t writtenIntoBuffer = 0;

    /*
     * problem(s):
     * + writing to internal buffers can be only successful in part:
     *   + writing is incomplete due to "not enough space"
     *   + writing is not possible (no space anymore)
     * + state machine for processing
     *   + not enough data for proceeding
     */

    uint8_t *bufferIncomingData        = ( uint8_t * ) ( p->payload );
    uint32_t bufferIncomingDataSize    = ( uint32_t )( p->len );
    uint32_t bufferIncomingDataReadPos = 0;
    uint32_t bufferReadData            = 0;

    // Outer loop consumes as may bytes as possible from TCP/IP connection until ALL data is written into buffer.
    // This does not mean that all data is processed by state machine ...
    // Still thinking about some dead-locks or race conditions here
    char            myString[ 256 ];
    static uint32_t myCall = 0;
    sprintf( myString, "ORKAGD_FWBufferWrite: [Call#%4ld,%4ld]: ", myCall++, bufferIncomingDataSize );
    ORKAGD_FW_DBG_PRINT_BUF( 2, myString, bufferIncomingData, bufferIncomingDataSize );

    do
    {
        writtenIntoBuffer = ORKAGD_FWBufferWrite( ( void * ) ( &bufferIncomingData[ bufferIncomingDataReadPos ] ), bufferIncomingDataSize );

        // loop state machine until not enough data anymore
        g_DataAvailable = ORKA_GD_FWBufferLevelRead();

        static uint32_t x = 0;
        ORKAGD_FW_DBG_PRINTF( 4, "%ld: DataNeeded=%ld, DataAvailable=%ld\n\r", x++, g_DataNeeded, g_DataAvailable );
        while ( g_DataNeeded <= g_DataAvailable )
        {
            switch ( g_state )
            {
                default:
                case ORKAGD_FW_SM_Error:
                    ORKAGD_FW_DBG_PRINTF( 10, "::ORKAGD_FW_SM_Error\n\r" );
                    // reset read buffer
                    ORKA_GD_FWBufferReset();
                    g_DataNeeded    = 0;
                    g_DataAvailable = 0;

                    ORKAGD_FW_DBG_PRINTF( 4, "==> Restart with MAGIC again ...\n\r" );
                    g_state = ORKAGD_FW_SM_Init;

                case ORKAGD_FW_SM_Init:
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Init\n\r" );

                    ORKAGD_FW_DBG_PRINTF( 4, "Start reception: Waiting for magic and commands ...\n\r" );
                    g_state = ORKAGD_FW_SM_Magic_Prep;
                    break;

                case ORKAGD_FW_SM_CheckEnoughtData:
                {
                    uint32_t bufLevel = ORKA_GD_FWBufferLevelRead();
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_CheckEnoughtData: %ld available, %ld needed\n\r", bufLevel, g_DataNeeded );

                    if ( bufLevel >= g_DataNeeded )
                    {
                        g_state = g_stateNext;
                        ORKAGD_FW_DBG_PRINTF( 3, "NextState=%ld\n\r", g_state );
                        g_stateNext = ORKAGD_FW_SM_Error;
                    }
                    else
                    {
                        ORKAGD_FW_DBG_PRINTF( 2,
                                              "Data reception needed. Leave function and wait for recall with more data\n\r" ); // not implemented now
                    }
                    break;
                }
                case ORKAGD_FW_SM_Magic_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Magic_Prep\n\r" );

                    g_DataNeeded = g_MagicWordLen;
                    g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                    g_stateNext  = ORKAGD_FW_SM_Magic_Check;
                    break;
                }
                case ORKAGD_FW_SM_Magic_Check:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Magic_Check\n\r" );

                    uint8_t buf[ g_MagicWordLen ];
                    bufferReadData = ORKAGD_FWBufferRead( buf, g_MagicWordLen );
                    g_DataAvailable -= bufferReadData;
                    g_DataNeeded = 0;

                    ORKAGD_FW_DBG_PRINT_BUF( 8, "ORKAGD_FW_SM_Magic_Check", buf, bufferReadData );

                    int     r                   = strncmp( ( char * ) buf, g_MagicWordString, g_MagicWordLen );
                    uint8_t magicResultHasError = ( uint8_t )( ( g_MagicWordLen != bufferReadData ) || r );
                    if ( magicResultHasError )
                    {
                        ORKAGD_FW_DBG_PRINTF( 9, "Magic *WRONG*\n\r" );
                        g_state = ORKAGD_FW_SM_Error;
                    }
                    else
                    {
                        ORKAGD_FW_DBG_PRINTF( 8, "Magic successfully received\n\r" );
                        g_state = ORKAGD_FW_SM_Version_Prep;
                    }

                    // send back result from magic number test as 1-byte result
                    uint8_t magicResult = ( FALSE == magicResultHasError ) ? ( uint8_t ) 'M' : ( uint8_t ) 'E';
                    err                 = tcp_write( tpcb, &magicResult, 1, 1 );
                    if ( ERR_OK != err )
                    {
                        g_state = ORKAGD_FW_SM_Error;
                        break;
                    }

                    break;
                }
                case ORKAGD_FW_SM_Version_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 9, "::ORKAGD_FW_SM_Version_Prep\n\r" );

                    g_DataNeeded = g_VersionStringLen;
                    g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                    g_stateNext  = ORKAGD_FW_SM_Version_Get;
                    break;
                }
                case ORKAGD_FW_SM_Version_Get:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Version_Get\n\r" );

                    uint8_t buf[ g_VersionStringLen ];
                    g_state = ORKAGD_FW_SM_Error;

                    bufferReadData = ORKAGD_FWBufferRead( buf, g_VersionStringLen );
                    g_DataAvailable -= bufferReadData;
                    g_DataNeeded = 0;

                    if ( ( g_VersionStringLen == bufferReadData ) && ( '.' == buf[ 0 ] ) && ( 'v' == buf[ 1 ] ) && ( '-' == buf[ 4 ] ) && ( '-' == buf[ 7 ] ) )
                    {
                        uint8_t g_VersionMajor  = ORKAGD_FW_Dez2ui32( &buf[ 2 ], 2 );
                        uint8_t g_VersionMinor  = ORKAGD_FW_Dez2ui32( &buf[ 5 ], 2 );
                        uint8_t g_VersionFlavor = ( 'a' == buf[ 8 ] ) ? ORKAGD_FW_SRV_STATE_ModeASCII : ORKAGD_FW_SRV_STATE_ModeBinary;

                        ORKAGD_FW_DBG_PRINTF( 8, "Version received: %d.%d (%c)\n\r", g_VersionMajor, g_VersionMinor, ( ORKAGD_FW_SRV_STATE_ModeASCII == g_VersionFlavor ) ? 'a' : 'b' );
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    else
                    {
                        ORKAGD_FW_DBG_PRINTF( 9, "Magic *WRONG*\n\r" );
                    }

                    break;
                }
                case ORKAGD_FW_SM_Cmd_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 9, "::ORKAGD_FW_SM_Cmd_Prep\n\r" );

                    g_DataNeeded = ORKAGD_FW_PROT_CMD_LEN;
                    g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                    g_stateNext  = ORKAGD_FW_SM_Cmd_Get;
                    break;
                }
                case ORKAGD_FW_SM_Cmd_Get:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Cmd_Get\n\r" );

                    uint8_t buf[ ORKAGD_FW_PROT_CMD_LEN ];
                    bufferReadData = ORKAGD_FWBufferRead( buf, ORKAGD_FW_PROT_CMD_LEN );
                    g_DataAvailable -= bufferReadData;
                    g_DataNeeded = 0;

                    ORKAGD_FW_DBG_PRINTF( 3, "CMD read: %ld\n\r", bufferReadData );
                    ORKAGD_FW_DBG_PRINT_BUF( 3, "ORKAGD_FW_SM_Cmd_Get", buf, bufferReadData );

                    // check EXIT
                    if ( ( ORKAGD_FW_PROT_CMD_LEN == bufferReadData ) && ( '.' == buf[ 0 ] ) && ( 'x' == buf[ 1 ] ) )
                    {
                        // exit transmitted, switch back to start state
                        g_state = ORKAGD_FW_SM_Init;
                        break;
                    }

                    // check MAGIC again
                    if ( ( ORKAGD_FW_PROT_CMD_LEN == bufferReadData ) && ( '.' == buf[ 0 ] ) && ( 'm' == buf[ 1 ] ) )
                    {
                        // something went wrong, so user initiated new sequence
                        ORKAGD_FWBufferReadUndo( ORKAGD_FW_PROT_CMD_LEN );
                        g_DataAvailable += bufferReadData;
                        g_state = ORKAGD_FW_SM_Magic_Prep;
                        break;
                    }

                    // check DBG trigger
                    if ( ( ORKAGD_FW_PROT_CMD_LEN == bufferReadData ) && ( '.' == buf[ 0 ] ) && ( 'z' == buf[ 1 ] ) )
                    {
                        // something went wrong, so user initiated new sequence
                        ORKAGD_FWBufferReadUndo( ORKAGD_FW_PROT_CMD_LEN );
                        g_DataAvailable += bufferReadData;

                        uint64_t baseWorkingAddress = 0x0000000080000000ULL;
                        uint64_t targetIPAddress    = 0x0000000001000000ULL;
                        uint8_t *registerMapBase    = ( uint8_t * ) ( NULL );
                        uint8_t *baseAddress        = registerMapBase + targetIPAddress;

                        ORKA_RegWrite32( baseAddress, ORKAGD_AXILITES_AXI_DATA_L, ( uint32_t )( baseWorkingAddress & 0x00000000ffffffffULL ) );
                        ORKA_RegWrite32( baseAddress, ORKAGD_AXILITES_AXI_DATA_H, ( uint32_t )( ( baseWorkingAddress >> 32 ) & 0x00000000ffffffffULL ) );

                        // Start IP
                        ORKA_RegBitClr32( baseAddress, ORKAGD_AXILITES_AP_CTRL,
                                          ORKA_AXILITES_BIT_AUTO_RESTART ); // clr: AP_RESTRAT
                        ORKA_RegBitSet32( baseAddress, ORKAGD_AXILITES_AP_CTRL,
                                          ORKA_AXILITES_BIT_AP_START ); // set: AP_START

                        g_state = ORKAGD_FW_SM_Magic_Prep;
                        break;
                    }

                    g_state = ORKAGD_FW_SM_Error;

                    if ( ( ORKAGD_FW_PROT_CMD_LEN == bufferReadData ) && ( '.' == buf[ 0 ] ) && ( 'x' == tolower( buf[ 3 ] ) ) )
                    {
                        switch ( tolower( buf[ 1 ] ) )
                        {
                            case 't': // transmit memory "MemcpyH2D()"
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_ModeTransmit;
                                break;
                            case 'r': // receive memory "MemcpyD2H()"
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_ModeReceive;
                                break;
                            case 'd': // data transport
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_ModeData;
                                break;
                            case 'p': // put register
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_RegisterWrite32_32;
                                break;
                            case 'q': // query register
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_RegisterRead32_32;
                                break;
                            case 's': // set bit within register
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_RegisterBitSet32_32;
                                break;
                            case 'c': // clear bit within register
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_RegisterBitClear32_32;
                                break;
                            case 'a': // AXI4 BlockStart
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_AXI4_Start32_32;
                                break;
                            case 'w': // AXI4 BlockWait
                                g_CommunicationMode = ORKAGD_FW_SRV_STATE_AXI4_Wait32_32;
                                break;
                            default:
                                break;
                        }
                        ORKAGD_FW_DBG_PRINTF( 2, "CMD: Mode=%ld\n\r", g_CommunicationMode );

                        switch ( buf[ 2 ] )
                        {
                            case '4':
                                g_AddressMode = ORKAGD_FW_SRV_STATE_AddressMode32;
                                break;
                            case '8':
                                g_AddressMode = ORKAGD_FW_SRV_STATE_AddressMode64;
                                break;
                            default:
                                break;
                        }
                        ORKAGD_FW_DBG_PRINTF( 3, "CMD: Addr=%d\n\r", g_AddressMode );

                        switch ( buf[ 4 ] )
                        {
                            case '2':
                                g_SizeMode = ORKAGD_FW_SRV_STATE_SizeMode16;
                                break;
                            case '4':
                                g_SizeMode = ORKAGD_FW_SRV_STATE_SizeMode32;
                                break;
                            case '8':
                                g_SizeMode = ORKAGD_FW_SRV_STATE_SizeMode64;
                                break;
                            default:
                                break;
                        }
                        ORKAGD_FW_DBG_PRINTF( 3, "CMD: Size=%ld\n\r", g_SizeMode );
                        g_state = ORKAGD_FW_SM_Address_Prep;
                    }
                    break;
                }
                case ORKAGD_FW_SM_Address_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Address_Prep\n\r" );

                    g_state = ORKAGD_FW_SM_Error;
                    if ( ORKAGD_FW_SRV_STATE_AddressModeUnknown != g_AddressMode )
                    {
                        // ".a0x" + <number of nibbles in hex from number>
                        g_DataNeeded = 4 + ( ORKAGD_FW_SRV_STATE_AddressMode32 == g_AddressMode ? 8 : 16 );
                        g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                        g_stateNext  = ORKAGD_FW_SM_Address_Get;
                    }
                    break;
                }
                case ORKAGD_FW_SM_Address_Get:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Address_Get\n\r" );

                    uint8_t buf[ ORKAGD_FW_PROT_AddressSizeMaxStorage ];
                    g_state = ORKAGD_FW_SM_Error;
                    if ( ( ORKAGD_FW_PROT_AddressSizeMaxStorage >= g_DataNeeded ) && ( ORKAGD_FW_PROT_AddressSizePrefix < g_DataNeeded ) )
                    {
                        bufferReadData = ORKAGD_FWBufferRead( buf, g_DataNeeded );
                        g_DataAvailable -= bufferReadData;

                        if ( 0 == strncmp( ".a0x", ( char * ) buf, ORKAGD_FW_PROT_AddressSizePrefix ) )
                        {
                            g_AddressValue = ORKAGD_FW_Hex2uint64( &buf[ ORKAGD_FW_PROT_AddressSizePrefix ], g_DataNeeded - ORKAGD_FW_PROT_AddressSizePrefix );
                            g_DataNeeded   = 0;
                            ORKAGD_FW_DBG_PRINTF( 3, "Addr=0x%016" PRIx64 "\n\r", g_AddressValue );
                            g_state = ORKAGD_FW_SM_Size_Prep;
                        }
                    }
                    break;
                }

                case ORKAGD_FW_SM_Size_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Size_Prep\n\r" );

                    g_state = ORKAGD_FW_SM_Error;
                    if ( ORKAGD_FW_SRV_STATE_SizeModeUnknown != g_SizeMode )
                    {
                        // ".s0x" + <number of nibbles in hex from number>
                        g_DataNeeded = 4 + 2 * g_SizeMode;
                        g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                        g_stateNext  = ORKAGD_FW_SM_Size_Get;
                    }
                    break;
                }

                case ORKAGD_FW_SM_Size_Get:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Size_Get\n\r" );

                    uint8_t buf[ ORKAGD_FW_PROT_AddressSizeMaxStorage ];
                    g_state = ORKAGD_FW_SM_Error;
                    if ( ( ORKAGD_FW_PROT_AddressSizeMaxStorage >= g_DataNeeded ) && ( ORKAGD_FW_PROT_AddressSizePrefix < g_DataNeeded ) )
                    {
                        bufferReadData = ORKAGD_FWBufferRead( buf, g_DataNeeded );
                        g_DataAvailable -= bufferReadData;

                        if ( 0 == strncmp( ".s0x", ( char * ) buf, ORKAGD_FW_PROT_AddressSizePrefix ) )
                        {
                            g_SizeValue  = ORKAGD_FW_Hex2uint64( &buf[ ORKAGD_FW_PROT_AddressSizePrefix ], g_DataNeeded - ORKAGD_FW_PROT_AddressSizePrefix );
                            g_DataNeeded = 0;
                            ORKAGD_FW_DBG_PRINTF( 3, "Size=0x%016" PRIx64 "\n\r", g_SizeValue );
                            g_state = ORKAGD_FW_SM_Data_Handle_Prep;
                        }
                        else
                        {
                            ORKAGD_FW_DBG_PRINT_BUF( 2, "ORKAGD_FW_SM_Size_Get", buf, ORKAGD_FW_PROT_AddressSizePrefix );
                        }
                    }
                    break;
                }

                case ORKAGD_FW_SM_Data_Handle_Prep:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Data_Handle_Prep\n\r" );

                    g_DataNeeded = 2; //( ".d" )
                    g_state      = ORKAGD_FW_SM_CheckEnoughtData;
                    g_stateNext  = ORKAGD_FW_SM_Data_Handle_Dispatch;
                    break;
                }

                case ORKAGD_FW_SM_Data_Handle_Dispatch:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_Data_Handle_Dispatch\n\r" );

                    uint8_t buf[ 2 ];
                    g_state        = ORKAGD_FW_SM_Error;
                    bufferReadData = ORKAGD_FWBufferRead( buf, g_DataNeeded );
                    g_DataAvailable -= bufferReadData;
                    g_DataNeeded = 0;

                    if ( 0 == strncmp( ".d", ( char * ) buf, 2 ) )
                    {
                        ORKAGD_FW_DBG_PRINTF( 7, "::ORKAGD_FW_SM_Data_Handle_Dispatch: g_CommunicationMode = %ld\n\r", g_CommunicationMode );
                        switch ( g_CommunicationMode )
                        {
                            case ORKAGD_FW_SRV_STATE_ModeTransmit:
                                g_state = ORKAGD_FW_SM_MemcpyH2D;
                                // we need number of bytes times 2 because we get nibbles
                                g_DataNeeded = g_SizeValue * 2;
                                break;

                            case ORKAGD_FW_SRV_STATE_ModeReceive:
                                g_state = ORKAGD_FW_SM_MemcpyD2H;
                                // we need number of bytes times 2 because we get nibbles
                                g_DataNeeded = 0;
                                break;

                            case ORKAGD_FW_SRV_STATE_RegisterWrite32_32:
                                g_state      = ORKAGD_FW_SM_RegWrite32_32;
                                g_DataNeeded = g_SizeValue * 2 + 2; // "0x" + number of nibbles
                                break;

                            case ORKAGD_FW_SRV_STATE_RegisterRead32_32:
                                g_state      = ORKAGD_FW_SM_RegRead32_32;
                                g_DataNeeded = 0; // read memory data is sent back to host
                                break;

                            case ORKAGD_FW_SRV_STATE_RegisterBitSet32_32:
                                g_state      = ORKAGD_FW_SM_RegBitSet32_32;
                                g_DataNeeded = g_SizeValue * 2 + 2; // "0x" + number of nibbles
                                break;

                            case ORKAGD_FW_SRV_STATE_RegisterBitClear32_32:
                                g_state      = ORKAGD_FW_SM_RegBitClear32_32;
                                g_DataNeeded = g_SizeValue * 2 + 2; // "0x" + number of nibbles
                                break;

                            case ORKAGD_FW_SRV_STATE_AXI4_Start32_32:
                                g_state      = ORKAGD_FW_SM_AXI4_Start;
                                g_DataNeeded = 0; // Start AXI4 Lite Block (ORKA)
                                break;

                            case ORKAGD_FW_SRV_STATE_AXI4_Wait32_32:
                                g_state      = ORKAGD_FW_SM_AXI4_Wait;
                                g_DataNeeded = 0; // Wait for AXI4 Lite Block to finish (ORKA)
                                break;

                            default:
                                ORKAGD_FW_DBG_PRINTF( 9, "::ORKAGD_FW_SM_Data_Handle_Dispatch: unhandled state\n\r" );
                                break;
                        }
                    }
                    else
                    {
                        ORKAGD_FW_DBG_PRINT_BUF_HEX( 2, "ORKAGD_FW_SM_Data_Handle_Dispatch - ERROR!: ", buf, 2 );
                    }
                    break;
                }

                case ORKAGD_FW_SM_RegWrite32_32:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_RegWrite32_32 (%" PRId64 ")\n\r", g_SizeValue );

                    uint64_t sizeBufferReadRaw    = ( uint64_t ) ORKA_GD_FWBufferLevelRead();
                    uint64_t sizeBufferReadUsable = sizeBufferReadRaw & ( ~( 0x1 ) );
                    uint64_t sizeBufferReadBytes  = sizeBufferReadRaw >> 1;
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );

                    // g_DataNeeded: Bytes to copy
                    uint64_t processBytes = g_DataNeeded > sizeBufferReadUsable ? sizeBufferReadUsable : g_DataNeeded;
                    //                  processBytes = processBytes > ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ) ? ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ): processBytes;
                    if ( processBytes > 0 )
                    {
                        //                      if ( sizeBufferReadBytes <= g_DataNeeded )
                        //                      {
                        uint32_t realReadBufBytes = ORKAGD_FWBufferRead( g_BufRcv, processBytes );
                        g_DataAvailable -= realReadBufBytes;

                        // skip leading "0x"
                        uint32_t val = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 0 * 2 ] ) << 24;
                        val |= ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 1 * 2 ] ) << 16;
                        val |= ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 2 * 2 ] ) << 8;
                        val |= ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 3 * 2 ] );
#ifdef ORKA_REAL_MEMOP
                        volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t ) g_AddressValue );

                        // access data
                        disable_caches();
                        *ptr = val;
                        enable_caches();
#else
                        ORKAGD_FW_DBG_PRINTF( 3, "RegWrite32/32: (*0x%8.8lx) = 0x%8.8lx\n\r", ( uint32_t ) g_AddressValue, val );
#endif
                        g_AddressValue += processBytes;
                        g_DataNeeded -= processBytes;
                    }

                    // only if we are finished with data processing we want to switch the state
                    if ( 0 == g_DataNeeded )
                    {
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    break;
                }

                case ORKAGD_FW_SM_RegRead32_32:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_RegRead32_32 (%" PRId64 ")\n\r", g_SizeValue );

#ifdef ORKA_REAL_MEMOP
                    volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t ) g_AddressValue );

                    // access data
                    disable_caches();
                    uint32_t val = *ptr;
                    enable_caches();
#else
                    uint32_t val = 0x12345678;
#endif
                    ORKAGD_FW_DBG_PRINTF( 1, "RegRead32/32: (*0x%8.8lx) = 0x%8.8lx\n\r", ( uint32_t ) g_AddressValue, val );
                    sprintf( ( char * ) g_BufRcv, "0x%8.8lx", val );
                    err = tcp_write( tpcb, g_BufRcv, 2 + 8, 1 );
                    ORKAGD_FW_DBG_PRINTF( 3, "err=%d\n\r", err );
                    g_state = ORKAGD_FW_SM_Cmd_Prep;

                    break;
                }

                case ORKAGD_FW_SM_RegBitSet32_32:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_RegBitSet32_32 (%" PRId64 ")\n\r", g_SizeValue );

                    uint64_t sizeBufferReadRaw    = ( uint64_t ) ORKA_GD_FWBufferLevelRead();
                    uint64_t sizeBufferReadUsable = sizeBufferReadRaw & ( ~( 0x1 ) );
                    uint64_t sizeBufferReadBytes  = sizeBufferReadRaw >> 1;
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );

                    // g_DataNeeded: Bytes to copy
                    uint64_t processBytes = g_DataNeeded > sizeBufferReadUsable ? sizeBufferReadUsable : g_DataNeeded;
                    //                  processBytes = processBytes > ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ) ? ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ): processBytes;
                    if ( processBytes > 0 )
                    {
                        //                      if ( sizeBufferReadBytes <= g_DataNeeded )
                        //                      {
                        uint32_t realReadBufBytes = ORKAGD_FWBufferRead( g_BufRcv, processBytes );
                        g_DataAvailable -= realReadBufBytes;

                        uint8_t *p = g_BufRcv;
                        // skip leading "0x"
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 3 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 2 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 1 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 0 * 2 ] );
                        uint32_t val = *( ( uint32_t * ) &g_BufRcv );

                        volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t ) g_AddressValue );
#ifdef ORKA_REAL_MEMOP
                        // access data
                        disable_caches();
                        *ptr |= val;
                        enable_caches();
#else
                        ORKAGD_FW_DBG_PRINTF( 3, "RegWrite32/32: (*0x%8.8lx) = 0x%8.8lx\n\r", ( uint32_t ) g_AddressValue, ( *ptr ) | val );
#endif
                        g_AddressValue += processBytes;
                        g_DataNeeded -= processBytes;
                    }

                    // only if we are finished with data processing we want to switch the state
                    if ( 0 == g_DataNeeded )
                    {
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    break;
                }

                case ORKAGD_FW_SM_RegBitClear32_32:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_RegBitSet32_32 (%" PRId64 ")\n\r", g_SizeValue );

                    uint64_t sizeBufferReadRaw    = ( uint64_t ) ORKA_GD_FWBufferLevelRead();
                    uint64_t sizeBufferReadUsable = sizeBufferReadRaw & ( ~( 0x1 ) );
                    uint64_t sizeBufferReadBytes  = sizeBufferReadRaw >> 1;
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );

                    // g_DataNeeded: Bytes to copy
                    uint64_t processBytes = g_DataNeeded > sizeBufferReadUsable ? sizeBufferReadUsable : g_DataNeeded;
                    //                  processBytes = processBytes > ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ) ? ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ): processBytes;
                    if ( processBytes > 0 )
                    {
                        //                      if ( sizeBufferReadBytes <= g_DataNeeded )
                        //                      {
                        uint32_t realReadBufBytes = ORKAGD_FWBufferRead( g_BufRcv, processBytes );
                        g_DataAvailable -= realReadBufBytes;

                        uint8_t *p = g_BufRcv;
                        // skip leading "0x"
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 3 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 2 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 1 * 2 ] );
                        *p++         = ORKAGD_FW_Hex2ui8( &g_BufRcv[ 2 + 0 * 2 ] );
                        uint32_t val = *( ( uint32_t * ) &g_BufRcv );

                        volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t ) g_AddressValue );
#ifdef ORKA_REAL_MEMOP
                        // access data
                        disable_caches();
                        *ptr &= ~val;
                        enable_caches();
#else
                        ORKAGD_FW_DBG_PRINTF( 3, "RegWrite32/32: (*0x%8.8lx) = 0x%8.8lx\n\r", ( uint32_t ) g_AddressValue, ( *ptr ) & ( ~val ) );
#endif
                        g_AddressValue += processBytes;
                        g_DataNeeded -= processBytes;
                    }

                    // only if we are finished with data processing we want to switch the state
                    if ( 0 == g_DataNeeded )
                    {
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    break;
                }

                case ORKAGD_FW_SM_AXI4_Start:
                {
                    //                    ORKA_FW_Status0( ORKA_LED_STATUS_GREEN );
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_AXI4_Start (%" PRId64 ")\n\r", g_SizeValue );
                    //                    disable_caches();

                    volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t )( g_AddressValue + ORKAGD_AXILITES_AP_CTRL ) );
                    uint32_t           val = *ptr;
                    val &= ~( 1 << ORKA_AXILITES_BIT_AUTO_RESTART );
                    val |= ( 1 << ORKA_AXILITES_BIT_AP_START );
#ifdef ORKA_REAL_MEMOP
                    // access data
                    disable_caches();
                    *ptr = val;
                    enable_caches();
#else
                    ORKAGD_FW_DBG_PRINTF( 3, "RegWrite32/32: (*0x%8.8lx) = 0x%8.8lx\n\r", ( uint32_t ) ptr, val );
#endif

                    g_state = ORKAGD_FW_SM_Cmd_Prep;
                    break;
                }

                case ORKAGD_FW_SM_AXI4_Wait:
                {
                    //                    ORKA_FW_Status1( ORKA_LED_STATUS_GREEN );
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_AXI4_Wait (%" PRId64 ")\n\r", g_SizeValue );

                    volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t )( g_AddressValue + ORKAGD_AXILITES_AP_CTRL ) );

                    g_state           = ORKAGD_FW_SM_Cmd_Prep;
                    uint32_t sendBack = ORKAGD_FW_SM_AXI4_Wait_RV_NOT_IDLE;

                    // access data
                    disable_caches();
                    uint32_t val = *ptr;
                    enable_caches();

                    ORKAGD_FW_DBG_PRINTF( 3, "ORKAGD_AXILITES_AP_CTRL: 0x%8.8x\n\r", val );
                    if ( val & ( 1 << ORKA_AXILITES_BIT_AP_IDLE ) )
                    {
                        ORKAGD_FW_DBG_PRINTF( 3, "AP_DONE or not: %8.8x\n\r", ( *ptr & ( 1 << ORKA_AXILITES_BIT_AP_IDLE ) ) );
                        if ( val & ( 1 << ORKA_AXILITES_BIT_AP_DONE ) )
                        {
                            sendBack = ORKAGD_FW_SM_AXI4_Wait_RV_DONE;
                            ORKAGD_FW_DBG_PRINTF( 3, "AP_DONE set\n\r" );
                        }
                        else
                        {
                            g_state  = ORKAGD_FW_SM_AXI4_WaitContinue;
                            sendBack = ORKAGD_FW_SM_AXI4_Wait_RV_NOT_DONE;
                            ORKAGD_FW_DBG_PRINTF( 3, "AP_DONE not set\n\r" );
                        }
                    }

                    err = tcp_write( tpcb, &sendBack, 4, 1 );
                    ORKAGD_FW_DBG_PRINTF( 3, "err=%d\n\r", err );
                    break;
                }

                case ORKAGD_FW_SM_AXI4_WaitContinue:
                {
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_AXI4_WaitContinue (%" PRId64 ")\n\r", g_SizeValue );

                    // DBGJSC - only a hack
                    disable_caches();

                    volatile uint32_t *ptr = ( uint32_t * ) ( ( uint32_t )( g_AddressValue + ORKAGD_AXILITES_AP_CTRL ) );

                    uint32_t sendBack = 0x12345678; // dummy to identify malfunction better

                    // access data
                    disable_caches();
                    uint32_t val = *ptr & ( 1 << ORKA_AXILITES_BIT_AP_DONE );
                    enable_caches();

                    if ( val )
                    {
                        g_state  = ORKAGD_FW_SM_Cmd_Prep;
                        sendBack = ORKAGD_FW_SM_AXI4_Wait_RV_DONE;
                    }
                    else
                    {
                        g_state  = ORKAGD_FW_SM_AXI4_WaitContinue;
                        sendBack = ORKAGD_FW_SM_AXI4_Wait_RV_NOT_DONE;
                    }
                    err = tcp_write( tpcb, &sendBack, 4, 1 );
                    ORKAGD_FW_DBG_PRINTF( 3, "err=%d\n\r", err );

                    break;
                }

                case ORKAGD_FW_SM_MemcpyH2D: // data sent to us (in fact a reception for us)
                {                            // ORKAGD_TcpIPMemcpyH2D()
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_MemcpyH2D (%" PRId64 ")\n\r", g_SizeValue );

                    uint64_t sizeBufferReadRaw    = ( uint64_t ) ORKA_GD_FWBufferLevelRead();
                    uint64_t sizeBufferReadUsable = sizeBufferReadRaw & ( ~( 0x1 ) );
                    uint64_t sizeBufferReadBytes  = sizeBufferReadRaw >> 1;
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );

                    // g_DataNeeded: Bytes to copy
                    uint64_t processBytes = g_DataNeeded > sizeBufferReadUsable ? sizeBufferReadUsable : g_DataNeeded;
                    //					processBytes = processBytes > ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ) ? ( ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE / 2 ): processBytes;
                    uint32_t addr = ( uint32_t ) g_AddressValue;
                    xil_printf( "ORKAGD_FW_SM_MemcpyH2D: copy to   0x%8.8x %d nibbles ...\n\r", addr, processBytes );
                    if ( processBytes > 0 )
                    {
                        //						if ( sizeBufferReadBytes <= g_DataNeeded )
                        //						{
                        uint32_t realReadBufBytes = ORKAGD_FWBufferRead( g_BufRcv, processBytes );
                        g_DataAvailable -= realReadBufBytes;

                        // replace two nibbles by binary byte in this buffer
                        uint8_t *p = g_BufRcv;
                        uint32_t numBinaryBytes= realReadBufBytes/2;
                        for ( uint32_t i = 0; i < realReadBufBytes; i += 2 )
                        {
                            *p++ = ORKAGD_FW_Hex2ui8( &g_BufRcv[ i ] );
                        }

                        // copy converted via memcpy to final destination
                        void *addr = ( void * ) ( ( int ) g_AddressValue );
                        memcpy( addr, g_BufRcv, numBinaryBytes );
                        disable_caches();
                        enable_caches();

                        if ( 0 )
                        {
                            uint32_t i, j;
                            uint32_t size = processBytes << 1;

                            xil_printf( "Dump: size=%lu\n\r", size );
                            uint8_t *p8 = ( uint8_t * ) g_BufRcv;
                            for ( i = 0; i < size; i += 16 * 16 )
                            {
                                xil_printf( ">>> 0x%8.8x: ", p8 );
                                for ( j = 0; j < 16; j++ )
                                {
                                    xil_printf( "%2.2x ", *p8++ );
                                }
                                xil_printf( "\n\r" );
                                p8 += 15 * 16;
                            }
                        }

                        if ( 0 )
                        {
                            uint32_t i, j;
                            uint32_t size = processBytes << 1;

                            xil_printf( "Dump: size=%lu\n\r", size );
                            uint8_t *p8 = ( uint8_t * ) addr;
                            for ( i = 0; i < 1; i += 16 * 16 )
                            {
                                xil_printf( ">>> 0x%8.8x: ", p8 );
                                for ( j = 0; j < 16; j++ )
                                {
                                    xil_printf( "%2.2x ", *p8++ );
                                }
                                xil_printf( "\n\r" );
                            }
                        }

                        g_AddressValue += numBinaryBytes;
                        g_DataNeeded -= realReadBufBytes;
                    }

                    // only if we are finished with data processing we want to switch the state
                    if ( 0 == g_DataNeeded )
                    {
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    break;
                }

                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                case ORKAGD_FW_SM_MemcpyD2H: // data sent from us (in fact a transmission from us)
                {                            // ORKAGD_TcpIPMemcpyD2H()

                    // we enter here with input values:
                    // g_BufRcv: the buffer address receiving the nibbles of data
                    // g_SizeValue: the number of bytes received (the "nibbles" - each ASCII character is a byte)

                    uint32_t sAddr = ( uint32_t ) g_AddressValue;
                    xil_printf( "ORKAGD_FW_SM_MemcpyD2H: copy from 0x%8.8x %" PRId64 " nibbles\n\r", sAddr, g_SizeValue );
                    const uint8_t Hex2DecCnv[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
                    ORKAGD_FW_DBG_PRINTF( 4, "::ORKAGD_FW_SM_MemcpyD2H (%" PRId64 ")\n\r", g_SizeValue );

                    const uint32_t maxTransferedBytes = 4096;

                    uint8_t *bufSrcPtr = ( uint8_t * ) sAddr;
                    while ( g_SizeValue )
                    {
                        // maximum of bytes to process.
                        // !!>> this results in double the space we need to process the data <<!!
                        uint32_t processBytes = ( uint32_t )( g_SizeValue > maxTransferedBytes ? maxTransferedBytes : g_SizeValue );

                        // reset conversion-pointer to start
                        uint8_t *bufRcvCnvPtr = g_BufCnv;

                        // debug output
                        uint32_t *pDeb = ( uint32_t * ) bufSrcPtr;
                        // xil_printf( "0x%p: 0x%8.8x\n\r", bufSrcPtr, *pDeb );

                        // convert data to ascii-hex
                        disable_caches();
                        enable_caches();
                        for ( uint32_t idx = 0; idx < processBytes; ++idx )
                        {
                            uint8_t b       = *bufSrcPtr++;
                            *bufRcvCnvPtr++ = Hex2DecCnv[ b >> 4 ];
                            *bufRcvCnvPtr++ = Hex2DecCnv[ b & 0xf ];
                        }

                        if ( 0 )
                        {
                            uint32_t i, j;
                            uint32_t size = processBytes << 1;
                            xil_printf( "Dump: size=%lu\n\r", size );
                            uint8_t *p8 = ( uint8_t * ) pDeb;
                            for ( i = 0; i < size; i += 16 )
                            {
                                xil_printf( ">>> 0x%8.8x: ", pDeb );
                                for ( j = 0; j < 16; j++ )
                                {
                                    xil_printf( "%2.2x ", *p8++ );
                                }
                                xil_printf( "\n\r" );
                                pDeb = ( uint32_t * ) p8;
                            }
                        }

                        if ( 0 )
                        {
                            uint32_t i, j;
                            uint32_t size = processBytes << 1;
                            xil_printf( "Dump: size=%lu\n\r", size );
                            uint8_t *p8 = ( uint8_t * ) sAddr;
                            for ( i = 0; i < 1; i += 16 )
                            {
                                xil_printf( ">>> 0x%8.8x: ", p8 );
                                for ( j = 0; j < 16; j++ )
                                {
                                    xil_printf( "%2.2x ", *p8++ );
                                }
                                xil_printf( "\n\r" );
                            }
                        }

                        // write the data back to the host
                        // xil_printf( "ORKAGD_FW_SM_MemcpyD2H: tcp_write dPtr=0x%8.8x [%d bytes]\n\r", ( uint32_t ) pDeb, processBytes );
                        err = tcp_write( tpcb, g_BufCnv, processBytes << 1, 1 );
                        if ( err < 0 )
                        {
                            xil_printf( "ORKAGD_FW_SM_MemcpyD2H: %p [%d] ==> ERROR! (%d)\n\r", g_BufCnv, processBytes, err );
                            g_state = ORKAGD_FW_SM_Error;
                            break;
                        }
                        // xil_printf( "ORKAGD_FW_SM_MemcpyD2H: tcp_write returned %d\n\r", err );

                        // being here means, everything fine.
                        // we have transferred (processBytes * 2) Nibbles

                        g_SizeValue -= processBytes;
                    }
                    // only if we are finished with data processing we want to switch the state
                    if ( g_SizeValue )
                    {
                        xil_printf( "ORKAGD_FW_SM_MemcpyD2H: Next state 'STAY' (rest=%" PRId64 ")\n\r", g_SizeValue );
                    }
                    else
                    {
                        //                        xil_printf( "ORKAGD_FW_SM_MemcpyD2H: Next state 'CmdPrep'\n\r" );
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
//                    xil_printf( "ORKAGD_FW_SM_MemcpyD2H: leave ... %ld\n\r", g_SizeValue );
#if 0
                    // uint64_t sizeBufferReadRaw    = ( uint64_t ) ORKA_GD_FWBufferLevelRead();
                    // uint64_t sizeBufferReadUsable = sizeBufferReadRaw & ( ~( 0x1 ) );
                    // uint64_t sizeBufferReadBytes  = sizeBufferReadRaw >> 1;
                    // xil_printf( "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    // xil_printf( "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    // xil_printf( "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );
                    // ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (raw)   =%" PRId64 "\n\r", sizeBufferReadRaw );
                    // ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (usable)=%" PRId64 "\n\r", sizeBufferReadUsable );
                    // ORKAGD_FW_DBG_PRINTF( 3, "Contents of buffer (bytes) =%" PRId64 "\n\r", sizeBufferReadBytes );

                    uint64_t processBytes = g_SizeValue > ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE ? ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE : g_SizeValue;

                    uint32_t sAddr = ( uint32_t ) g_AddressValue;

                    // convert data to ascii-hex
                    uint8_t * bufRcvPtr           = g_BufRcv;
                    uint32_t  toBeTransferedBytes = processBytes;
                    uint32_t  maxTransferedBytes  = 4096;
                    uint32_t  loopCnt             = 1;
                    uint32_t *pSrc                = ( uint32_t * ) g_BufRcv;

                    xil_printf( "ARTYBuffer=*(0x%8.8lx)=0x%8.8lx (size=%" PRId64 ")\n\r", sAddr, *pSrc, processBytes );
                    while ( g_SizeValue )
                    {
                        processBytes          = toBeTransferedBytes > maxTransferedBytes ? maxTransferedBytes : toBeTransferedBytes;
                        uint8_t *bufRcvCnvPtr = g_BufCnv;
                        for ( uint64_t idx = 0; idx < processBytes; ++idx )
                        {
                            uint8_t b       = *bufRcvPtr++;
                            *bufRcvCnvPtr++ = Hex2DecCnv[ b >> 4 ];
                            *bufRcvCnvPtr++ = Hex2DecCnv[ b & 0xf ];
                        }

                        ORKAGD_FW_DBG_PRINT_BUF( 3, "ORKAGD_FW_SM_MemcpyD2H", g_BufCnv, processBytes * 2 );
                        xil_printf( "LoopCnt: %d, tcp_write( processBytes = %d)\n\r", loopCnt++, processBytes << 1 );
                        err = tcp_write( tpcb, g_BufCnv, processBytes << 1, 1 );

                        if ( ERR_OK != err )
                        {
                            xil_printf( "ORKAGD_FW_SM_MemcpyD2H: %p [%d] ==> ERROR! (%d)\n\r", g_BufCnv, processBytes, err );
                            g_state = ORKAGD_FW_SM_Error;
                            break;
                        }
                        toBeTransferedBytes -= processBytes;
                        g_AddressValue += processBytes;
                        g_SizeValue -= processBytes;
                        xil_printf( "ORKAGD_FW_SM_MemcpyD2H: %p [%d] - ok (sizeVal=%d)\n\r", g_BufCnv, processBytes, g_SizeValue );
                    }

                    // only if we are finished with data processing we want to switch the state
                    if ( g_SizeValue )
                    {
                        xil_printf( "ORKAGD_FW_SM_MemcpyD2H: Next state 'STAY\n\r" );
                    }
                    else
                    {
                        xil_printf( "ORKAGD_FW_SM_MemcpyD2H: Next state 'CmdPrep'\n\r" );
                        g_state = ORKAGD_FW_SM_Cmd_Prep;
                    }
                    break;
#endif
                }
            }
        }

        // try to get rest of data from the TCP/IP buffer
        bufferIncomingDataReadPos += writtenIntoBuffer;
        bufferIncomingDataSize -= writtenIntoBuffer;
    } while ( bufferIncomingDataSize ); // HARD: if "writtenIntoBuffer" is ZERO we would have a potential endless loop - so we leave here for security and safety reasons

    /* free the received pbuf */
    pbuf_free( p );
    ORKAGD_FW_DBG_PRINTF( 5, "recv_callback: leave with OK\n\r" );
    return ERR_OK;
}
