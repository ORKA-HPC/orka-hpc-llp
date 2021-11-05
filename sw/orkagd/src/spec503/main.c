#include "liborkagd.h"
#include "mmgmt.h"
#include "tcpipclient.h"
#include "types.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>

int main(int argc, char** argv)
{
    ORKAGD_ConfigTarget_t targetConfig;
    printf("TestProgram for LibORKAGD (FPGA GenericDriver)\n");
    printf("Version LibORKAGD: %s\n", ORKAGD_VersionString());

    ORKAGD_EC_t rc = ORKAGD_Init(
        "./",   // Location of JSON-Files
        "./",   // Location of bitstreams
        "./"); // Scratch area (writable)

    if (rc)
    {
        exit(1);
    }
    targetConfig.m_InfrastructureFilename = "bitstream.json";

    void *target = ORKAGD_BoardListOpen(&targetConfig);
    if (!ORKAGD_BoardListRead(target))
    {
        exit(2);
    }

    if (1 != ORKAGD_BoardGetNumFPGAs(target))
    {
        exit(3);
    }

    void *pTargetFPGA = ORKAGD_FPGAHandleCreate(target, 0);
    if (!pTargetFPGA)
    {
        exit(4);
    }

    ORKAGD_BoardListClose(target);

    // default init (can be overridden by ORKA module)
#define ORKAGD_EXAMPLE_FIRMWARE_SPACE (16ULL * ORKAGD_MBYTE)
    bool memoryManagerInitialized = false;

    const ORKAGD_FPGAComponent_t *orkaIPHandle  = NULL;
    uint64_t                      numComponents = ORKAGD_FPGAComponentsGetNumOf(pTargetFPGA);
    const ORKAGD_FPGAComponent_t *ledComponents[ 3 ];
    uint64_t                      ledAddresses[ 3 ];
    uint64_t                      NumLEDs = 0;
    printf("%-10s, %-15s, %-18s [%-18s] was '%-60s'\n", "ipType", "ipSubType", "  ipOffset", "  ipRange", "ipDesignComponentName");

    bool writeInfoAboutUndefinedJSonEntries = false;

    for (uint64_t i = 0; i < numComponents; ++i)
    {
        const ORKAGD_FPGAComponent_t *compEntry = ORKAGD_FPGAComponentsGetEntry(pTargetFPGA, i);
        if (!compEntry)
        {
            exit(5);
        }
        char ipTypeDummy[] = "---", *ipType = ipTypeDummy;
        char ipSubTypeDummy[] = "---", *ipSubType = ipSubTypeDummy;
        if (compEntry->ipType)
        {
            ipType = compEntry->ipType;
        }
        if (compEntry->ipSubType)
        {
            ipSubType = compEntry->ipSubType;
        }

        printf("%-10s, %-15s, 0x%16.16" PRIx64 " [0x%16.16" PRIx64 "] was '%-60s'\n", ipType, ipSubType, compEntry->ipOffset, compEntry->ipRange, compEntry->ipDesignComponentName);

        if (compEntry->ipType)
        {
            if (0 == strcmp("orkaip", compEntry->ipType))
            {
                if (0 == strcmp("register", compEntry->ipAccess))
                {
                    char regName0[] = "ORKAPARAM0";

                    uint64_t nReg  = ORKAGD_RegisterGetNumIndexOf(compEntry);
                    uint64_t offs  = ORKAGD_RegisterGetOffsetByName(compEntry, regName0);
                    uint64_t width = ORKAGD_RegisterGetBitWidthByName(compEntry, regName0);
                    uint64_t iReg  = ORKAGD_RegisterGetIndexOf(compEntry, regName0);

                    printf("found 'orkaip':\n");
                    printf("- nReg: %" PRId64 "\n", nReg);
                    printf("- regName: %s\n", regName0);
                    printf("- offs: %" PRId64 "\n", offs);
                    printf("- width: %" PRId64 "\n", width);
                    printf("- iReg: %" PRId64 "\n", iReg);

                    orkaIPHandle    = compEntry;
                    static bool_t x = TRUE;
                    if (x)
                    {
                        printf("Registered ORKA component:\n");
                        x = FALSE;
                    }
                    printf("Name:          %s\n", orkaIPHandle->ipDesignComponentName);
                    printf("SubType:       %s\n", orkaIPHandle->ipSubType);
                    printf("RegisterSpace: 0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n", orkaIPHandle->ipOffset, orkaIPHandle->ipOffset + orkaIPHandle->ipRange);
                }
                else
                {
                    printf("MemorySpace:   0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n", compEntry->ipOffset, compEntry->ipOffset + compEntry->ipRange);

                    // initialize MemoryManager
                    ORKAMM_DevMemInit(compEntry->ipOffset + ORKAGD_EXAMPLE_FIRMWARE_SPACE, compEntry->ipRange - ORKAGD_EXAMPLE_FIRMWARE_SPACE);

                    memoryManagerInitialized = true;
                }
            }
            else if ( 0 == strcmp( "gpio", compEntry->ipType ) )
            {
                if ( 0 == strcmp( "LEDsAndSwitches", compEntry->ipSubType ) )
                {
                    ledComponents[ NumLEDs ] = compEntry;
                    ledAddresses[ NumLEDs ]  = compEntry->ipOffset;
                    NumLEDs++;
                }
                continue;
            }
            else
            {
                continue;
            }
        }
    }

    if (!memoryManagerInitialized)
    {
        printf("Error: Device-Memory is not initialized - No ORKA IP found ...\n");
        exit(6);
    }
    ORKAGD_FPGAComponent_t orkaIPComponent;

    if (!orkaIPHandle)
    {
        exit(10);
    }

    if (ORKAGD_FPGAOpen(pTargetFPGA))
    {
        printf("FPGAOpen failed ...\n");
        exit(11);
    }
    // Init done ------------------------------------------------------------------------

    // led test -------------------------------------------------------------------------
    if (1)
    {
        printf("TEST: write and read back LED register\n");

        uint32_t led_all_off = 0;
        uint32_t led_all_white = 0xFFF;

        uint32_t led = led_all_white;

        // separate LED access (register)
        printf( "write = 0x%8.8x\n", led );

        ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_TRI", 0x00000000 );
        ORKAGD_RegisterWriteByNameU32( ledComponents[ 1 ], "GPIO_DATA", led );
        uint32_t value = ORKAGD_RegisterReadByNameU32( ledComponents[ 1 ], "GPIO_DATA" );
        printf( "read  = 0x%8.8x\n", value );
    }

    // write/read ip register -----------------------------------------------------------
    if (1)
    {
        printf("TEST: write and read back IP register\n");
        int val = 24;
        printf("write register...\n");
        ORKAGD_RegisterWriteByName(orkaIPHandle, "ORKAPARAM0", &val);
        printf("read register...\n");
        int ret = ORKAGD_RegisterReadByName(orkaIPHandle, "ORKAPARAM0");
        printf("%i == %i\n", val, ret);
        if (val != ret) printf("!!! ERROR !!!\n");
    }

    // memcpyXXX Test -------------------------------------------------------------------
    if (1)
    {
        printf("TEST: memcpy\n");
#define NUM_VALS 1000
        int    buff_Snd[ NUM_VALS ];
        int    buff_Rcv[ NUM_VALS ] = {0};
        for (int i=0; i<NUM_VALS; ++i)
        {
            buff_Snd[i] = i;
        }
        uint64_t var0  = ORKAMM_DevMalloc(NUM_VALS * sizeof(int));
        printf("writing...\n");
        ORKAGD_MemcpyH2D(pTargetFPGA, var0, (void *) buff_Snd, NUM_VALS * sizeof(int));
        printf("reading...\n");
        ORKAGD_MemcpyD2H(pTargetFPGA, (void *) buff_Rcv, var0, NUM_VALS * sizeof(int));
        for (int i=0; i<NUM_VALS; ++i)
        {
            if (buff_Snd[i] != buff_Rcv[i])
            {
                printf("ERROR: Memcpy failed\n");
                exit(12);
            }
        }
        printf("Memcpy test done\n");
    }

    ORKAGD_FPGAClose(pTargetFPGA);
    ORKAGD_FPGAHandleDestroy(pTargetFPGA);
    ORKAGD_Deinit();
    ORKAMM_DevMemDeInit();
    return 0;
}
