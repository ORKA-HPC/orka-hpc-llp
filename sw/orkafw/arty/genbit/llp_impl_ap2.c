#include <liborkagd.h>
#include <llp.h>
#include <mmgmt.h>
#include <unistd.h>

#include "debug.h"
#include "orka_types.h"

struct llp_ap2_context {
  void *target_fpga;
  size_t ip_list_len;
  ORKAGD_FPGAComponent_t const **orka_ip_list;
  bool verbose;
};

// struct llp_ap2_context sollte hier rein:
// #include <llp_context.h>

#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

void launch_blocking(const char *tf_name, const int id, void *llp_context,
                     const char *types, ...) {
  debug_print(stderr, "tfname: %s, id: %d, types: %s, context: %p\n", tf_name,
              id, types, llp_context);

  va_list varargs;
  va_start(varargs, types);

  struct llp_ap2_context *actx = llp_context;

  ORKAGD_FPGAComponent_t const **orkaIpList = actx->orka_ip_list;
  int orkaIpList_len = actx->ip_list_len;

  // get ip handle
  if (id < 1000) {
    debug_print(stderr, "launch blocking found invalid id\n");
    abort();
  }
  const ORKAGD_FPGAComponent_t *ipHandle = orkaIpList[id - 1000];

  if (!ipHandle) {
    debug_print(stderr, "No ip found! %s\n", tf_name);
    abort();
  }

  // Digest varargs
  char next_type;
  int index = 0;
  while (next_type = types[index]) {
    char orkaParamName[256];
    sprintf(orkaParamName, "ORKAPARAM%d", index);

    switch (next_type) {
    case 'P': {
      debug_print(stderr, "take another buffer from varargs\n");
      uint64_t dev_mem_handle = va_arg(varargs, uint64_t);
      debug_print(stderr, "dev memory handle: %ld\n", dev_mem_handle);
      debug_print(stderr, "write register by name\n");
      bool rv =
          ORKAGD_RegisterWriteByName(ipHandle, orkaParamName, &dev_mem_handle);
      if (!rv) {
        debug_print(stderr, "Error during write register by name\n");
        exit(1);
      }
    } break;
    case 1:
    case 2:
    case 4: {
      debug_print(stderr, "take another scalar from varargs\n");
      uint32_t scalar_value = va_arg(varargs, uint32_t);
      debug_print(stderr, "take another scalar from varargs\n");
      bool rv =
          ORKAGD_RegisterWriteByNameU32(ipHandle, orkaParamName, scalar_value);
      if (!rv) {
        debug_print(stderr, "Error during write register by name U32\n");
        exit(1);
      }
    } break;
    case 8: {
      uint64_t scalar_value = va_arg(varargs, uint64_t);
      bool rv =
          ORKAGD_RegisterWriteByNameU64(ipHandle, orkaParamName, scalar_value);
      if (!rv) {
        debug_print(stderr, "Error during write register by name U64\n");
        exit(1);
      }
    } break;
    default:
      debug_print(stderr, "invalid program path\n");
      abort();
    }

    index++;
  }

  va_end(varargs);

  debug_print(stderr, "trying to start ip: %s \n", tf_name);
  bool_t res_start = ORKAGD_Axi4LiteBlockStart(ipHandle);
  if (!res_start) {
    debug_print(stderr, "ORKAGD_Axi4LiteBlockStart unsuccessfull\n");
    exit(1);
  }
  debug_print(stderr, "ORKAGD_Axi4LiteBlockStart successful\n");

  while (!ORKAGD_Axi4LiteBlockWait(ipHandle))
    ;

  debug_print(stderr, "ORKAGD_Axi4LiteBlockWait successfull\n");
}

void *init(bool verbose) {
  struct llp_ap2_context *context = malloc(sizeof(struct llp_ap2_context));

  // init orkagd device
  ORKAGD_ConfigTarget_t targetConfig;
  debug_print(stderr, "LibORKAGD (FPGA GenericDriver)\n");
  debug_print(stderr, "Version LibORKAGD: %s\n", ORKAGD_VersionString());

  char cwd[300];
  getcwd(cwd, 300);
  debug_print(stderr, "pwd: %s\n", cwd);
  ORKAGD_EC_t rc = ORKAGD_Init("./", "./", "./");
  if (rc) {
    debug_print(stderr, "Loading of config jsons failed...\n");
    abort();
  }

  targetConfig.m_InfrastructureFilename = "bitstream.json";

  void *target = ORKAGD_BoardListOpen(&targetConfig);
  if (!ORKAGD_BoardListRead(target)) {
    debug_print(stderr, "BoardListRead funciton failed\n");
    abort();
  }

  if (1 != ORKAGD_BoardGetNumFPGAs(target)) {
    debug_print(stderr,
                "More than 1 fpgas is not supported using this wrapper\n");
    abort();
  }

  context->target_fpga = ORKAGD_FPGAHandleCreate(target, 0);
  if (!context->target_fpga) {
    debug_print(stderr, "FPGAHandleCreate function failed\n");
    abort();
  }

  ORKAGD_BoardListClose(target);

  uint32_t currentNum = 0;
  static uint32_t memory_initialized = 0;
  uint64_t numComponents = ORKAGD_FPGAComponentsGetNumOf(context->target_fpga);
  context->orka_ip_list =
      calloc(sizeof(ORKAGD_FPGAComponent_t *) * numComponents, 1);
  context->ip_list_len = 0;
  for (uint64_t i = 0; i < numComponents; ++i) {
    const ORKAGD_FPGAComponent_t *compEntry =
        ORKAGD_FPGAComponentsGetEntry(context->target_fpga, i);
    if (!compEntry) {
      debug_print(stderr, "compEntry is NULL\n");
      abort();
    }

    char ipTypeDummy[] = "---", *ipType = ipTypeDummy;
    char ipSubTypeDummy[] = "---", *ipSubType = ipSubTypeDummy;
    if (compEntry->ipType) {
      ipType = compEntry->ipType;
    }
    if (compEntry->ipSubType) {
      ipSubType = compEntry->ipSubType;
    }
    debug_print(stderr,
                "%-10s, %-15s, 0x%16.16" PRIx64 " [0x%16.16" PRIx64
                "] was '%-60s'\n",
                ipType, ipSubType, compEntry->ipOffset, compEntry->ipRange,
                compEntry->ipDesignComponentName);
    if (compEntry->ipType) {
      if (0 == strcmp("orkaip", compEntry->ipType)) {
        if (0 == strcmp("register", compEntry->ipAccess)) {
          debug_print(stderr, "Design componennt name: %s\n",
                      compEntry->ipDesignComponentName);
          char *substr = strstr(compEntry->ipDesignComponentName, "HlsKernel");
          if (!substr) {
            debug_print(stderr, "Bad HlsKernel-naming\n");
            abort();
          }
          unsigned long id = atol(substr + 9);
          debug_print(stderr, "HlsKernel id found %lu\n", id);
          if (id < 1000) {
            debug_print(stderr, "Invalid id!\n");
            abort();
          }
          id -= 1000;
          context->orka_ip_list[id] = compEntry;
          debug_print(stderr, "Written\n");
          context->ip_list_len++;
        } else {
          if (!memory_initialized) {
            debug_print(
                stderr,
                "MemorySpace:   0x%16.16" PRIx64 " - 0x%16.16" PRIx64 "\n",
                compEntry->ipOffset, compEntry->ipOffset + compEntry->ipRange);
#define ORKA_FW_SPACE (16ULL * 1024ULL * 1024ULL)
            ORKAMM_DevMemInit(compEntry->ipOffset + ORKA_FW_SPACE,
                              compEntry->ipRange);
            memory_initialized = 1;
          }
        }
      }
    }
  }
  if (context->ip_list_len == 0) {
    debug_print(stderr, "No Hls-ips found!\n");
    abort();
  }
  if (ORKAGD_FPGAOpen(context->target_fpga)) {
    debug_print(stderr, "FPGAOpen failed\n");
    abort();
  }

  context->ip_list_len = currentNum;
  context->verbose = verbose;
  return context;
}

void deinit(void *context) {
  debug_print(stderr, "Deinit: 0x%p ... Unimplemented\n", context);
}

orka_llp_mem_hnd llp_malloc(size_t s, void *c) {
  struct llp_ap2_context *context = c;
  uint64_t dev_addr = ORKAMM_DevMalloc(s);
  debug_print(stderr, "llp_malloc(%" PRIx64 ") = 0x%16.16" PRIx64 "\n", s,
              dev_addr);
  if (!dev_addr) {
    debug_print(stderr, "ORKAMM_DevMalloc(%ld) returned error!\n", s);
  }

  return dev_addr;
}

bool llp_free(orka_llp_mem_hnd t, void *c) {
  return true; // TODO
}

orka_llp_mem_hnd llp_memcpy_h2d(orka_llp_mem_hnd dest, const void *src,
                                size_t s, void *c) {
  struct llp_ap2_context *context = c;
  if (context->verbose) {
    debug_print(stderr, "dest: %ld src: %p size: %ld\n", dest, src, s);
  }

  bool_t res = ORKAGD_MemcpyH2D(context->target_fpga, (uint64_t)dest, src, s);

  if (!res) {
    debug_print(stderr, "failed to copy memory "
                        "from Host to Device using ORKAGD (AP2)\n");
    abort();
  }

  return dest;
}

void *llp_memcpy_d2h(void *dest, const orka_llp_mem_hnd src, size_t s,
                     void *c) {
  struct llp_ap2_context *context = c;
  if (context->verbose) {
    debug_print(stderr, "dest: %p, src: %ld, size: %ld\n", dest, src, s);
  }

  bool_t res = ORKAGD_MemcpyD2H(context->target_fpga, dest, (uint64_t)src, s);

  if (!res) {
    debug_print(stderr, "failed to copy memory "
                        "from Host to Device using ORKAGD (AP2)\n");
    abort();
  }

  return dest;
}
