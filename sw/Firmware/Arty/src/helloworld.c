/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

enum
{
	UART_COM_Uninit = 0,
	UART_COM_Init,
	UART_COM_Magic,

	UART_COM_ModeAddress16,
	UART_COM_ModeAddress32,
	UART_COM_ModeAddress64,
	UART_COM_ModeSize16,
	UART_COM_ModeSize32,
	UART_COM_ModeSize64,
	UART_COM_ModeReceive,
	UART_COM_ModeTransmit,
	UART_COM_ModeData,

	UART_COM_CmdReceive,
	UART_COM_Cmd_AddressRead,
	UART_COM_Cmd_SizeRead,
	UART_COM_Cmd_Data,
	UART_COM_DeInit,
	UART_COM_Error
};

uint8_t inputData[]=
	"abcd.t4x2.a0x78000000.s0x0018.d0123456789abcdef00112233445566778899aabbccddeeff";

static uint32_t a = 0;

int ReceiveData()
{
#if 1
	int c = inputData[ a++ ];
	if ( a >= sizeof( inputData ))
	{
		a = 0;
	}
#else
	int c = getchar();
#endif
	return c;
}

uint8_t ReceiveData2HexDigits()
{
	int byte = 0;


	// nibble #1
	int c = ReceiveData();
    if (( '0' <= c ) &&
        ( '9' >= c ))
    {
    	byte = c - '0';
    }
    else
    {
		if (( 'a' <= c ) &&
			( 'f' >= c ))
		{
			byte = c + 10 - 'a';
		}
		else
		{
			if (( 'A' <= c ) &&
				( 'F' >= c ))
			{
				byte = c + 10 - 'A';
			}
		}
    }

	// nibble #2
    byte <<= 4;
	c = ReceiveData();
    if (( '0' <= c ) &&
        ( '9' >= c ))
    {
    	byte |= c - '0';
    }
    else
    {
		if (( 'a' <= c ) &&
			( 'f' >= c ))
		{
			byte |= c + 10 - 'a';
		}
		else
		{
			if (( 'A' <= c ) &&
				( 'F' >= c ))
			{
				byte |= c + 10 - 'A';
			}
		}
    }
    return ( uint8_t ) byte;
}

int main()
{
    init_platform();

    uint32_t s = UART_COM_Init;
    uint32_t modeCommunication = UART_COM_Uninit;
    uint32_t modeSize = UART_COM_Uninit;
    uint32_t modeAddress = UART_COM_Uninit;
    uint32_t dataAddr = 0;
    uint32_t dataSize = 0;
    int c = 0;
    for (;;)
    {
        switch ( s )
        {
        	case UART_COM_Error:
        	{
        	    printf("dbg: Error - restart\n\r");
        	    printf("dbg: =============================================================\n\r");
        		s = UART_COM_Init;
        		a = 0;
        		break;
        	}

        	default:
        	case UART_COM_Init:
			{
        	    printf("hello: ORKAGD-Support\n\r");
        	    s = UART_COM_Magic;
				break;
			}

        	case UART_COM_Magic:
			{
			    printf("dbg: UART_COM_Magic: start\n\r");
        		s = UART_COM_Error;
			    c = ReceiveData();
			    if ( 'a' != c )
			    	break;
			    printf("dbg: UART_COM_Magic: start: 1:%c\n\r", c);
			    c = ReceiveData();
			    if ( 'b' != c )
			    	break;
			    printf("dbg: UART_COM_Magic: start: 2:%c\n\r", c);
			    c = ReceiveData();
			    if ( 'c' != c )
			    	break;
			    printf("dbg: UART_COM_Magic: start: 3:%c\n\r", c);
			    c = ReceiveData();
			    if ( 'd' != c )
			    	break;
			    printf("dbg: UART_COM_Magic: start: 4:%c\n\r", c);
			    s = UART_COM_CmdReceive;
			    print("dbg: UART_COM_Magic: end\n\r");
			    break;
			}

        	case UART_COM_CmdReceive:
        	{
			    print("dbg: UART_COM_CmdReceive: start\n\r");
        		s = UART_COM_Error;
			    c = ReceiveData();
			    if ( '.' != c )
			    	break;
			    char cc = ReceiveData();
			    switch ( cc )
			    {
					case 't':
					case 'T':
						modeCommunication = UART_COM_ModeTransmit;
						break;
					case 'r':
					case 'R':
						modeCommunication = UART_COM_ModeReceive;
						break;
					case 'd':
					case 'D':
						modeCommunication = UART_COM_ModeData;
						break;
					default:
						break;
			    }
			    // get address-mode
			    cc = ReceiveData();
			    switch ( cc )
			    {
					case '4':
						modeAddress = UART_COM_ModeAddress32;
						break;
					case '8':
						modeAddress = UART_COM_ModeAddress64;
						break;
					default:
						break;
			    }
			    c = ReceiveData();
			    if ( 'x' != c )
			    	break;
			    // get size-mode
			    cc = ReceiveData();
			    switch ( cc )
			    {
					case '2':
						modeSize = UART_COM_ModeSize16;
						break;
					case '4':
						modeSize = UART_COM_ModeSize32;
						break;
					case '8':
						modeSize = UART_COM_ModeSize64;
						break;
					default:
						break;
			    }
				s = UART_COM_Cmd_AddressRead;
			    print("dbg: UART_COM_CmdReceive: end\n\r");
        		break;
        	}

        	case UART_COM_Cmd_AddressRead:
        	{
			    printf("dbg: UART_COM_Cmd_AddressRead: start\n\r");
        		s = UART_COM_Error;
			    c = ReceiveData();
			    if ( '.' != c )
			    	break;
			    c = ReceiveData();
			    if ( 'a' != c )
			    	break;
			    c = ReceiveData();
			    if ( '0' != c )
			    	break;
			    printf("dbg: UART_COM_Cmd_AddressRead: %c\n\r", c);
			    c = ReceiveData();
			    if ( 'x' != c )
			    	break;
			    printf("dbg: UART_COM_Cmd_AddressRead: %c\n\r", c);

			    uint32_t aMaxI = ( modeAddress == UART_COM_ModeAddress32 ) ? 8 : (( modeAddress == UART_COM_ModeAddress64 ) ? 16 : 0 );
			    for ( uint8_t i = 0; i < aMaxI; ++i )
			    {
				    c = ReceiveData();
                    if (( '0' <= c ) &&
                        ( '9' >= c ))
                    {
                    	dataAddr = ( dataAddr << 4 ) | ( c - '0' );
                    }
                    else
                    {
						if (( 'a' <= c ) &&
							( 'f' >= c ))
						{
							dataAddr = ( dataAddr << 4 ) | ( c + 10 - 'a' );
						}
						else
						{
							if (( 'A' <= c ) &&
								( 'F' >= c ))
							{
								dataAddr = ( dataAddr << 4 ) | ( c + 10 - 'A' );
							}
						}
                    }
			    }
			    printf("dbg: UART_COM_Cmd_AddressRead: Addr: 0x%8.8x\n\r", dataAddr);

        		s = UART_COM_Cmd_SizeRead;
			    printf("dbg: UART_COM_Cmd_AddressRead: end\n\r");
        		break;
        	}


        	case UART_COM_Cmd_SizeRead:
        	{
			    printf("dbg: UART_COM_Cmd_SizeRead: start\n\r");
        		s = UART_COM_Error;
			    c = ReceiveData();
			    if ( '.' != c )
			    	break;
			    c = ReceiveData();
			    if ( 's' != c )
			    	break;
			    c = ReceiveData();
			    if ( '0' != c )
			    	break;
			    printf("dbg: UART_COM_Cmd_SizeRead: %c\n\r", c);
			    c = ReceiveData();
			    if ( 'x' != c )
			    	break;
			    printf("dbg: UART_COM_Cmd_SizeRead: %c\n\r", c);

			    uint32_t sMaxI = ( modeSize == UART_COM_ModeSize16 ) ?  4 :
			    		        (( modeSize == UART_COM_ModeSize32 ) ?  8 :
			    		       ((( modeSize == UART_COM_ModeSize64 ) ? 16 :
			    		    	                                        0
							   )));
			    for ( uint8_t i = 0; i < sMaxI; ++i )
			    {
				    c = ReceiveData();
                    if (( '0' <= c ) &&
                        ( '9' >= c ))
                    {
                    	dataSize = ( dataSize << 4 ) | ( c - '0' );
                    }
                    else
                    {
						if (( 'a' <= c ) &&
							( 'f' >= c ))
						{
							dataSize = ( dataSize << 4 ) | ( c + 10 - 'a' );
						}
						else
						{
							if (( 'A' <= c ) &&
								( 'F' >= c ))
							{
								dataSize = ( dataSize << 4 ) | ( c + 10 - 'A' );
							}
						}
                    }
			    }
			    printf("dbg: UART_COM_Cmd_SizeRead: Size: 0x%4.4x\n\r", dataSize);
        		s = UART_COM_Cmd_Data;
			    printf("dbg: UART_COM_Cmd_SizeRead: end\n\r");

        		break;
        	}

        	case UART_COM_Cmd_Data:
        	{
			    printf("dbg: UART_COM_Cmd_Data: start\n\r");
        		s = UART_COM_Error;
			    c = ReceiveData();
			    if ( '.' != c )
			    	break;
			    c = ReceiveData();
			    if ( 'd' != c )
			    	break;

			    switch ( modeCommunication )
			    {
			    	case UART_COM_ModeTransmit:
			    	{
			    		uint32_t i = 0;
			    		void *v = ( void * ) dataAddr;
			    		uint8_t *p = ( uint8_t * )v;
			    		uint8_t d;
			    		do
			    		{
			    			d = ReceiveData2HexDigits();
			    			printf("%2.2x", d );
			    			*p++ = d;
			    		} while ( ++i < dataSize );
			    		printf("\n");
			    	}
			    }

			    s = UART_COM_DeInit;
			    printf("dbg: UART_COM_Cmd_Data: end\n\r");
        		break;
        	}

        	case UART_COM_DeInit:
        	{
        		printf("dbg: endless wait ...\n\r");
        		for (;;);
        	}
        }
    }

    cleanup_platform();
    return 0;
}
