#include <stdint.h>

void top( volatile uint32_t *OrkaAxiPort0, volatile uint32_t *OrkaAxiPort1)
{
#pragma HLS INTERFACE s_axilite port=return
#pragma HLS INTERFACE m_axi depth=64 offset=slave port=OrkaAxiPort0
#pragma HLS INTERFACE m_axi depth=64 offset=slave port=OrkaAxiPort1

    OrkaAxiPort0[0]++;
    OrkaAxiPort1[0]++;
}
