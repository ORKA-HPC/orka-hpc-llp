#ifndef MM_H__
#define MM_H__

#include "types.h"
#include <stdint.h>

#ifdef __SYNTHESIS__
#define ORKA_VOLATILE volatile
#define ORKA_DBG_PRINTF( ... )
#else
#define ORKA_VOLATILE
#define ORKA_DBG_PRINTF( ... ) printf(" - " __VA_ARGS__ )
#endif


#define MEMORY_ALIGN               ( 0x0010 )
#define MEMORY_ALIGNED_SIZE( x )   ((( x ) + MEMORY_ALIGN - 1 ) & ( ~( MEMORY_ALIGN - 1 )))

typedef float32_t                  MatType_t;

#endif
