// main.cpp
// 01.04.2020

// ***************************************************************************
// Copyright (c) 2020, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "hls1.h"
#include <stdlib.h> // malloc, free
#include <string>

#define TESTSIZE 1024
#define NUM_FRAMES 5

// Arg checking must be done with public domain implementation of getopt on MSVC
#ifndef _MSC_VER
#include <unistd.h> // getopt
#else
#include "getopt_local.h"
#endif

using namespace std;
float avm_memory [TESTSIZE];

avm1        mm_avm_memory(avm_memory,sizeof(float) * TESTSIZE);

int main() {
	unsigned long erg;
    // define the Buffers
    

    for (int i=0;i<=TESTSIZE;i++)
        avm_memory[i] = (float) i;

    for (int itr = 0; itr < NUM_FRAMES; itr++) {
        // ihc_hls_enqueue_noret(&slavereg_comp, mm_avm_memory, i, 2000);
       
        erg = slavereg_comp(mm_avm_memory,5,2000); 
	printf("Ergebnis: %08X\n",erg);
    }
    // ihc_hls_component_run_all(&cal1_task);

    for (int itr = 0; itr < 20; itr++) {
        printf("Results : %10.5f\n",avm_memory[itr]);
    }
    return 0;
}
