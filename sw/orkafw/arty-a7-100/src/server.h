#ifndef SERVER_H__
#define SERVER_H__

#include "lwip/err.h"
#include "lwip/tcp.h"

// higher number filters more important information and reduces text noise
#define ORKAGD_FW_DEBUG_LEVEL ( 9 )

#if 0
#    define ORKAGD_FW_DBG_PRINTF( level, ... )
#    define ORKAGD_FW_DBG_PRINTF_NO_HEADER( level, ... )
#    define ORKAGD_FW_DBG_PRINT_BUF( level, name, buffer, buf_bytes )
#    define ORKAGD_FW_DBG_PRINT_BUF_HEX( level, name, buffer, buf_bytes )
#else
#    define ORKAGD_FW_DBG_PRINTF( level, fmt, ... )                                           \
        do                                                                                    \
        {                                                                                     \
            if ( level >= ORKAGD_FW_DEBUG_LEVEL )                                             \
                xil_printf( "ORKAGD_FW: [%d]%s(): " fmt, __LINE__, __func__, ##__VA_ARGS__ ); \
        } while ( 0 )
#    define ORKAGD_FW_DBG_PRINTF_NO_HEADER( level, fmt, ... ) \
        do                                                    \
        {                                                     \
            if ( level >= ORKAGD_FW_DEBUG_LEVEL )             \
                xil_printf( fmt, ##__VA_ARGS__ );             \
        } while ( 0 )
#    define ORKAGD_FW_DBG_PRINT_BUF( level, name, buffer, buf_bytes ) \
        if ( level >= ORKAGD_FW_DEBUG_LEVEL )                         \
            do                                                        \
            {                                                         \
                uint32_t jj;                                          \
                uint8_t *jb = buffer;                                 \
                ORKAGD_FW_DBG_PRINTF( level, "%s [", name );          \
                for ( jj = 0; jj < buf_bytes; ++jj )                  \
                    xil_printf( "%c", *jb++ );                        \
                xil_printf( "]\n\r" );                                \
        } while ( 0 )
#    define ORKAGD_FW_DBG_PRINT_BUF_HEX( level, name, buffer, buf_bytes ) \
        if ( level >= ORKAGD_FW_DEBUG_LEVEL )                             \
            do                                                            \
            {                                                             \
                uint32_t jj;                                              \
                uint8_t *jb = buffer;                                     \
                ORKAGD_FW_DBG_PRINTF( level, "%s [0x", name );            \
                for ( jj = 0; jj < buf_bytes; ++jj )                      \
                    xil_printf( "%2.2x,", *jb++ );                        \
                xil_printf( "]\n\r" );                                    \
        } while ( 0 )
#endif

#define ORKA_FW_SRV_BUFFER_SIZE                     ( 1024 * 1024 * 1 )         // 1MB
#define ORKA_FW_SRV_BUFFER_DATA_TRANSFER_CHUNK_SIZE ( ORKA_FW_SRV_BUFFER_SIZE ) // number of nibbles

// Specific definitions beside transportation

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

#define ORKA_LED_STATUS_BLACK   ( 0x00 )
#define ORKA_LED_STATUS_BLUE    ( 0x01 )
#define ORKA_LED_STATUS_GREEN   ( 0x02 )
#define ORKA_LED_STATUS_RED     ( 0x04 )
#define ORKA_LED_STATUS_CYAN    ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_GREEN )
#define ORKA_LED_STATUS_MAGENTA ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_RED )
#define ORKA_LED_STATUS_YELLOW  ( ORKA_LED_STATUS_GREEN | ORKA_LED_STATUS_RED )
#define ORKA_LED_STATUS_WHITE   ( ORKA_LED_STATUS_BLUE | ORKA_LED_STATUS_GREEN | ORKA_LED_STATUS_RED )

enum
{
    ORKAGD_FW_SRV_STATE_Unknown = 0,
    ORKAGD_FW_SRV_STATE_ModeTransmit,
    ORKAGD_FW_SRV_STATE_ModeReceive,
    ORKAGD_FW_SRV_STATE_ModeData,
    ORKAGD_FW_SRV_STATE_RegisterWrite32_32,
    ORKAGD_FW_SRV_STATE_RegisterRead32_32,
    ORKAGD_FW_SRV_STATE_RegisterBitSet32_32,
    ORKAGD_FW_SRV_STATE_RegisterBitClear32_32,
    ORKAGD_FW_SRV_STATE_AXI4_Start32_32,
    ORKAGD_FW_SRV_STATE_AXI4_Wait32_32,

    ORKAGD_FW_SRV_STATE_ModeBinary,
    ORKAGD_FW_SRV_STATE_ModeASCII,

    ORKAGD_FW_SRV_STATE_AddressModeUnknown = 0,
    ORKAGD_FW_SRV_STATE_AddressMode32,
    ORKAGD_FW_SRV_STATE_AddressMode64,

    ORKAGD_FW_SRV_STATE_SizeModeUnknown = 0,
    ORKAGD_FW_SRV_STATE_SizeMode16      = 2,
    ORKAGD_FW_SRV_STATE_SizeMode32      = 4,
    ORKAGD_FW_SRV_STATE_SizeMode64      = 8,

    ORKAGD_FW_SM_Error = 0,
    ORKAGD_FW_SM_Init,
    ORKAGD_FW_SM_CheckEnoughtData,
    ORKAGD_FW_SM_Magic_Prep,
    ORKAGD_FW_SM_Magic_Check,
    ORKAGD_FW_SM_Version_Prep,
    ORKAGD_FW_SM_Version_Get,
    ORKAGD_FW_SM_Cmd_Prep,
    ORKAGD_FW_SM_Cmd_Get,
    ORKAGD_FW_SM_CmdRcv_Prep,
    ORKAGD_FW_SM_CmdSnd_Prep,
    ORKAGD_FW_SM_CmdData_Prep,
    ORKAGD_FW_SM_Address_Prep,
    ORKAGD_FW_SM_Address_Get,
    ORKAGD_FW_SM_Size_Prep,
    ORKAGD_FW_SM_Size_Get,
    ORKAGD_FW_SM_Data_Handle_Prep,
    ORKAGD_FW_SM_Data_Handle_Dispatch,
    ORKAGD_FW_SM_MemcpyH2D,
    ORKAGD_FW_SM_MemcpyD2H,
    ORKAGD_FW_SM_RegWrite32_32,
    ORKAGD_FW_SM_RegRead32_32,
    ORKAGD_FW_SM_RegBitSet32_32,
    ORKAGD_FW_SM_RegBitClear32_32,
    ORKAGD_FW_SM_AXI4_Start,
    ORKAGD_FW_SM_AXI4_Wait,
    ORKAGD_FW_SM_AXI4_WaitContinue,

    // protocol implementation constants
    ORKAGD_FW_PROT_CMD_LEN               = 5,
    ORKAGD_FW_PROT_AddressSizePrefix     = 4,                                     // ".a0x" or ".s0x"
    ORKAGD_FW_PROT_AddressSizeMaxStorage = ORKAGD_FW_PROT_AddressSizePrefix + 16, // ".a0x" + <max number of nibbles in hex from number>

    ORKAGD_FW_SM_AXI4_Wait_RV_NOT_IDLE = 10000,
    ORKAGD_FW_SM_AXI4_Wait_RV_DONE     = 10001,
    ORKAGD_FW_SM_AXI4_Wait_RV_NOT_DONE = 10002,
};

// system prototypes
// (problem of Xilinx: Solved getting warnings)
void
enable_caches();
void
disable_caches();

// missing prototypes from incomplete XILNX port
int tolower(int argument);

// prototypes of our snd/rcv system
err_t
recv_callback( void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err );
err_t
accept_callback( void *arg, struct tcp_pcb *newpcb, err_t err );

#endif /* SERVER_H__ */
