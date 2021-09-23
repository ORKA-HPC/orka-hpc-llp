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
#include "vector.h"
#include "mmgmt.h"
#include "random.h"

#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

// locally needed functions
static ORKAMM_DevMemEntry_t *ORKAMM_Helper_EntryCreate( uint64_t address, uint64_t size );
static void ORKAMM_Helper_EntryDestroy( ORKAMM_DevMemEntry_t *entry );
static bool ORKAMM_Helper_NewEntryPush( ORKAMM_DevMemList_t list, uint64_t address, uint64_t size );

// global variables
// ORKAGD_DevMemPools_t ORKAGD_g_DevMemPools;
ORKAMM_DevMemList_t ORKAMM_g_DevMemListFree = NULL;      // sorted free-list
ORKAMM_DevMemList_t ORKAMM_g_DevMemListAllocated = NULL; // unsorted allocations
ORKAVEC_Iter_t *ORKAMM_g_DevMemListFreeIterator = NULL;
ORKAVEC_Iter_t *ORKAMM_g_DevMemListAllocatedIterator = NULL;

// initialization and deinitialization
bool
ORKAMM_DevMemInit( uint64_t blockStartAddress, uint64_t blockSize )
{
    bool rv = false;

    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKAMMInit: offs=0x%16.16" PRIx64 ", range=0x%16.16" PRIx64 ", align=0x%8.8x (%d)\n", blockStartAddress, blockSize, ~( ORKAGD_MEM_ALIGNMENT - 1 ), ORKAGD_MEM_ALIGNMENT );

    // if something went wrong, clean now up before proceed
    if ( ORKAMM_g_DevMemListFree || ORKAMM_g_DevMemListAllocated )
    {
        ORKAMM_DevMemDeInit();
        ORKAMM_g_DevMemListFree = NULL;
        ORKAMM_g_DevMemListAllocated = NULL;
        // everything clean now
    }

    // create the vector with "free-blocks" (one entry)
    ORKAMM_g_DevMemListFree = ORKAVEC_Create( sizeof( ORKAMM_DevMemEntry_t * ) );
    if ( ORKAMM_g_DevMemListFree )
    {
        // create an entry in the free list
        rv = ORKAMM_Helper_NewEntryPush( ORKAMM_g_DevMemListFree, blockStartAddress, blockSize );

        // create an iterator for ease-of-use
        ORKAMM_g_DevMemListFreeIterator = ORKAVEC_IterCreate( ORKAMM_g_DevMemListFree );
    }
    ORKAMM_g_DevMemListAllocated = ORKAVEC_Create( sizeof( ORKAMM_DevMemEntry_t * ) );

    // create the cvector with "allocated-blocks" (empty)
    if ( ORKAMM_g_DevMemListAllocated )
    {
        // empty vector (so far)

        // create an iterator for ease-of-use
        ORKAMM_g_DevMemListAllocatedIterator = ORKAVEC_IterCreate( ORKAMM_g_DevMemListAllocated );
    }
    rv &= ORKAMM_g_DevMemListFree && ORKAMM_g_DevMemListFreeIterator && ORKAMM_g_DevMemListAllocatedIterator;

    return rv;
}

void
ORKAMM_DevMemDeInit()
{
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKAMMDeInit:\n" );

    // destroy free-list
    ORKAMM_DBG_DumpListFree();
    if ( ORKAMM_g_DevMemListFree )
    {
        uint32_t idx = 0;
        for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( ORKAMM_g_DevMemListFreeIterator ); ORKAVEC_IterEnd( ORKAMM_g_DevMemListFreeIterator );
              i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListFreeIterator ) )
        {
            uint64_t recAddress = ( *i )->start;
            uint64_t recSize = ( *i )->size;
            ORKAMM_DBG_PRINTF( "MemoryBlockFreed  #%d: %16.16" PRIx64 ", %16.16" PRIx64 "\n", idx, recAddress, recSize );
            ORKAMM_Helper_EntryDestroy( *i );
            idx++;
        }
        ORKAVEC_IterDestroy( ORKAMM_g_DevMemListFreeIterator );
        ORKAMM_g_DevMemListFreeIterator = NULL;
        ORKAVEC_Destroy( ORKAMM_g_DevMemListFree );
        ORKAMM_g_DevMemListFree = NULL;
    }

    // destroy allocated-list
    ORKAMM_DBG_DumpListAllocated();
    if ( ORKAMM_g_DevMemListAllocated )
    {
        uint32_t idx = 0;
        for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( ORKAMM_g_DevMemListAllocatedIterator ); ORKAVEC_IterEnd( ORKAMM_g_DevMemListAllocatedIterator );
              i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListAllocatedIterator ) )
        {
            uint64_t recAddress = ( *i )->start;
            uint64_t recSize = ( *i )->size;
            ORKAMM_DBG_PRINTF( "MemoryBlockAlloced#%d: %16.16" PRIx64 ", %16.16" PRIx64 "\n", idx, recAddress, recSize );
            ORKAMM_Helper_EntryDestroy( *i );
            idx++;
        }
        ORKAVEC_IterDestroy( ORKAMM_g_DevMemListAllocatedIterator );
        ORKAMM_g_DevMemListAllocatedIterator = NULL;
        ORKAVEC_Destroy( ORKAMM_g_DevMemListAllocated );
        ORKAMM_g_DevMemListAllocated = NULL;
    }
}

// core functions of device memory management DevMalloc and DevFree
uint64_t
ORKAMM_DevMalloc( const uint64_t size )
{
    uint64_t res = 0ULL;
    ORKAMM_DBG_PRINTF( "\n" );
    ORKAMM_DBG_PRINTF( "ORKA_DevMalloc(0): size=0x%16.16" PRIx64 " (%" PRId64 ")\n", size, size );

    uint64_t newSize = size + ORKAGD_MEM_ALIGNMENT - 1;
    uint64_t mask = ( uint64_t ) ( ~( ORKAGD_MEM_ALIGNMENT - 1 ) );
    newSize &= mask;
    ORKAMM_DBG_PRINTF( "ORKA_DevMalloc(1): size=0x%16.16" PRIx64 " (%" PRId64 ")\n", newSize, newSize );

    // if list of free blocks is empty - we simply have nothing to offer. Exit.
    // same with zero-size. Cannot handle it. Exit.
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
    if ( s && newSize )
    {
        uint32_t idx = 0;
        for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( ORKAMM_g_DevMemListFreeIterator ); ORKAVEC_IterEnd( ORKAMM_g_DevMemListFreeIterator );
              i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListFreeIterator ) )
        {
            // parameters of a "free" block
            uint64_t recAddress = ( *i )->start;
            uint64_t recSize = ( *i )->size;
            //            ORKAMM_DBG_PRINTF( " - ORKA_DevMalloc(s): MemoryBlock#%d: %16.16" PRIx64 ", %16.16" PRIx64 "\n", idx, recAddress, recSize );

            // does request fit into empty block ?
            if ( recSize >= newSize )
            {
                // requested block fits into empty section
                // =======================================

                // returned address is start of empty block (always)
                res = recAddress;

                // now check whether it fills up the entire empty block, or leaves left another
                // smaller empty block (after allocation area)
                if ( recSize == newSize )
                {
                    // "allocated-block" fills up "free-block" entirely.
                    // =================================================

                    // destroy free-entry
                    ORKAMM_Helper_EntryDestroy( *i );

                    // delete entry from list
                    ORKAVEC_Delete( ORKAMM_g_DevMemListFree, i );

                    // create an entry in allocated list (remember: this is an unsorted list!)
                    ORKAMM_Helper_NewEntryPush( ORKAMM_g_DevMemListAllocated, recAddress, newSize );
                }
                else
                {
                    // ====================================================================
                    // a "free" block is left. So create an entry in the allocated-list and
                    // update values in the free-list to reflect the new address and size.
                    // ====================================================================

                    // create an entry in the free list
                    //                    ORKAMM_DBG_DumpListAllocated();
                    ORKAMM_Helper_NewEntryPush( ORKAMM_g_DevMemListAllocated, recAddress, newSize );
                    //                    ORKAMM_DBG_DumpListAllocated();

                    // new start of empty section is behind allocation.
                    // size of empty block is reduced by size of allocation
                    //                    ORKAMM_DBG_DumpListFree();
                    ( *i )->start = recAddress + newSize;
                    ( *i )->size = recSize - newSize;
                    //                    ORKAMM_DBG_DumpListFree();

                    // leave loop - searching for empty blocks
                    break;
                }
            } // if ( recSize >= newSize )
            idx++;
        } // loop over all free blocks
    }     // free blocks available ?

    if ( 0 == res )
    {
        ORKAMM_DBG_PRINTF( "ORKA_DevMalloc(x): Failed\n" );
    }
    ORKAMM_DBG_PRINTF( "ORKA_DevMalloc(2): Returned address=0x%16.16" PRIx64 "\n", res );
    return res;
}

void
ORKAMM_DevFree( const uint64_t address )
{
    ORKAMM_DBG_PRINTF( "ORKA_DevFree(0): address=0x%16.16" PRIx64 "\n", address );

    bool found = false;
    uint64_t recAllocatedAddress = 0ULL;
    uint64_t recAllocedSize = 0ULL;
    uint64_t recFreeAddress = 0ULL;
    uint64_t recFreeSize = 0ULL;

    // eliminate record in 'ORKAMM_g_DevMemListAllocated'-list:
    // 1.) free current element
    // 2.) shrink vector (copy down upper elements)
    // 3.) pop last element
    // extend or create record in 'ORKAMM_g_DevMemListFree'-list:
    // 4.) search for relevant record (to insert at or extent)
    // ==============================================================

    ORKAMM_DBG_DumpListAllocated();

    // look within allocated blocks
    uint32_t idx = 0;
    for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( ORKAMM_g_DevMemListAllocatedIterator ); ORKAVEC_IterEnd( ORKAMM_g_DevMemListAllocatedIterator );
          i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListAllocatedIterator ) )
    {
        recAllocatedAddress = ( *i )->start;
        recAllocedSize = ( *i )->size;
        if ( recAllocatedAddress == address )
        {
            // to 1.) free current element
            ORKAMM_FREE( *i );

            // to 2.) shrink vector (copy down upper elements)
            ORKAMM_DevMemEntry_t **j = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListAllocatedIterator );
            while ( ORKAVEC_IterEnd( ORKAMM_g_DevMemListAllocatedIterator ) )
            {
                *i = *j;
                i = j;
                j = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListAllocatedIterator );
            }

            // to 3.) pop last element
            ORKAVEC_PopBack( ORKAMM_g_DevMemListAllocated );
            found = true;
            break;
        }
        idx++;
    }
    ORKAMM_DBG_DumpListAllocated();

    if ( found )
    {
        // 4.) search for relevant record in free-list (to insert-at or extent)
        // ====================================================================
        //
        // Attn.: Complex job ...
        //
        // "recAllocatedAddress" & "recAllocedSize" ==>
        //      Address to be freed and integrated into free-list.
        //      Called the "block".
        // *a) check whether block concatenates to this block in front
        // *b) check whether block concatenates to this block in the back
        // *c) check whether block concatenates current and next block
        // *d) check to insert between two ordinary blocks
        // *e) check whether we simly add a new block at the end
        // *f) add single block within list
        // *g) if list is empty, create a single entry

        ORKAMM_DBG_DumpListFree();
        ORKAMM_DBG_PRINTF( "\n" );
        ORKAMM_DBG_PRINTF( "free(    0x%16.16" PRIx64 " ) - Size: %" PRId64 "\n", recAllocatedAddress, recAllocedSize );
        ORKAMM_DBG_PRINTF( "         0x%16.16" PRIx64 " .. 0x%16.16" PRIx64 " (%" PRId64 ")\n", recAllocatedAddress, recAllocatedAddress + recAllocedSize, recAllocedSize );
        ORKAMM_DBG_PRINTF( "\n" );

        bool entryConsumed = false;
        uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
        if ( s )
        {
            idx = 0;
            for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( ORKAMM_g_DevMemListFreeIterator ); ORKAVEC_IterEnd( ORKAMM_g_DevMemListFreeIterator );
                  i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( ORKAMM_g_DevMemListFreeIterator ) )
            {
                // a free list record
                recFreeAddress = ( *i )->start;
                recFreeSize = ( *i )->size;
                ORKAMM_DBG_PRINTF( "  block: 0x%16.16" PRIx64 " .. 0x%16.16" PRIx64 " (%" PRId64 ")\n", recFreeAddress, recFreeAddress + recFreeSize, recFreeSize );
                //            ORKAMM_DBG_PRINTF( "ORKA_DevFree(0): address=0x%16.16" PRIx64 ". size=0x%16.16" PRIx64 "\n", recFreeAddress, recFreeSize );

                if ( recAllocatedAddress < recFreeAddress )
                {
                    // generate new "free-block" (insert entry)
                    // Exception: If newly generated block preceds seemlesly the current block
                    // check for it ...
                    if ( ( recAllocatedAddress + recAllocedSize ) == recFreeAddress )
                    {
                        // Case *a)
                        // Here we have seemlessly connecting blocks.
                        // Merge both in currently available free block
                        ( *i )->start = recAllocatedAddress;
                        ( *i )->size = recAllocedSize + recFreeSize;
                    }
                    else
                    {
                        // Case *f)
                        // Unfortunately the newly freed block is disjunct from the other one.
                        // insert a new element in list (copy up all elements and free up a new entry)
                        ORKAMM_DevMemEntry_t *dme = ORKAMM_Helper_EntryCreate( recAllocatedAddress, recAllocedSize );
                        ORKAVEC_Insert( ORKAMM_g_DevMemListFree, i, ( void * ) &dme );
                    }

                    entryConsumed = true;
                    break;
                }
                else
                {
                    // recAllocatedAddress: Adress of block to be freed
                    // recFreeAddress: Address of current entry in free list
                    if ( recAllocatedAddress == recFreeAddress )
                    {
                        ORKAMM_DBG_PRINTF( "ORKA_DevFree: Error - Address is already freed ...\n" );

                        entryConsumed = true;
                        break;
                    }
                    else
                    {
                        // check new record for concatenation on current block (at end)
                        if ( recFreeAddress + recFreeSize == recAllocatedAddress )
                        {
                            // ok current start address + size is exactly
                            // the address of the new record ... the both fit seamlessly

                            // now there can be tha case that in addition the new block
                            // is exactly between current and next entry in free-list.
                            // So get next entry in free list and check it.
                            uint64_t curIndex = ORKAVEC_IterIndex( ORKAMM_g_DevMemListFreeIterator );
                            uint64_t nextIndex = curIndex + 1;
                            bool_t check = ORKAVEC_IndexIsValid( ORKAMM_g_DevMemListFree, nextIndex );
                            if ( check )
                            {
                                // ok - there is an entry behind the current one.
                                // check, whether new entry (which already
                                // concatenates with the current entry) also
                                // concatenates with next entry ... (case c)
                                // ===============================================

                                // a free list record
                                ORKAMM_DevMemEntry_t **next = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_GetAt( ORKAMM_g_DevMemListFree, nextIndex );
                                uint64_t recFreeNextAddress = ( *next )->start;
                                uint64_t recFreeNextSize = ( *next )->size;
                                if ( ( recFreeAddress + recFreeSize + recAllocedSize ) == recFreeNextAddress )
                                {
                                    // Case *c)
                                    // ok: new block contains current size + new size + next size
                                    // and extents the current block.
                                    ( *i )->size += recAllocedSize + recFreeNextSize;

                                    // the next block must be eliminated as his size is already
                                    // consumed in current block (see line before).
                                    ORKAMM_DevMemEntry_t **delete = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterSet( ORKAMM_g_DevMemListFreeIterator, nextIndex );
                                    ORKAVEC_Delete( ORKAMM_g_DevMemListFree, delete );

                                    entryConsumed = true;
                                    break;
                                }
                                // if we fall through here, then the address of next block does
                                // not match the sum of the address of the current block, its
                                // size and the size of the new block
                            }
                            // if we are here, then either there is NO NEXT BLOCK (check==FALSE) or
                            // the address does not match.

                            // Case *b)
                            // new to be freed block starts at end of current free block.
                            // so we extend the current free block and make it bigger.
                            ( *i )->size += recAllocedSize;

                            entryConsumed = true;
                            break;
                        }
                        else
                        {
                            // Case *d)
                            // do nothing
                            // - checked whether we can concatenate after last - negative
                            // - next round: check to insert before next block
                        }
                    }
                }
                idx++;
            }
        }

        // if entry is not processed (e.g. free-list was empty or
        // block is behind last free element) create a new block
        // at the end of the list.
        if ( !entryConsumed )
        {
            // Case *e/*g)
            ORKAMM_Helper_NewEntryPush( ORKAMM_g_DevMemListFree, recAllocatedAddress, recAllocedSize );
        }
        ORKAMM_DBG_DumpListFree();
    }
}

// ===========================================================================================
//                               =============================================================
// Debug and test routines below =============================================================
//                               =============================================================
// ===========================================================================================

// debug functions
uint64_t
ORKAMM_DBG_DumpListFreeSize()
{
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
    return s;
}

uint64_t
ORKAMM_DBG_DumpListAllocatedSize()
{
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListAllocated );
    return s;
}

void
ORKAMM_DBG_DumpListFree()
{
#if defined( ORKAMM_DBG_OUTPUT_LEVEL )

    // if list of free blocks is empty - we simply have nothing to offer. Exit.
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
    ORKAMM_DBG_PRINTF( "\n=====================================================================\n" );
    ORKAMM_DBG_PRINTF( "ORKAMM_DBG_DumpListFree (%" PRId64 "):\n", s );
    if ( s )
    {
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( ORKAMM_g_DevMemListFree );
        if ( it )
        {
            ORKAMM_DBG_PRINTF( "Free            #    StartAddress    -    EndAddress   ,    Size (Hex)     Size (Dec)\n" );
            ORKAMM_DBG_PRINTF( "============== === ================= - ================, ================ ============\n" );
            uint32_t idx = 0;
            for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( it ) )
            {
                // parameters of a "free" block
                uint64_t recAddress = ( *i )->start;
                uint64_t recSize = ( *i )->size;
                ORKAMM_DBG_PRINTF( " - MemoryBlock#%3d: %16.16" PRIx64 " - %16.16" PRIx64 ", %16.16" PRIx64 " (%10." PRId64 ")\n", idx, recAddress, recAddress + recSize - 1, recSize, recSize );
                idx++;
            }
            ORKAVEC_IterDestroy( it );
        }
    }
#endif
}

void
ORKAMM_DBG_DumpListAllocated()
{
#if defined( ORKAMM_DBG_OUTPUT_LEVEL )

    // if list of free blocks is empty - we simply have nothing to offer. Exit.
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListAllocated );
    ORKAMM_DBG_PRINTF( "\n=====================================================================\n" );
    ORKAMM_DBG_PRINTF( "ORKAMM_DBG_DumpListAllocated (%" PRId64 "):\n", s );
    if ( s )
    {
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( ORKAMM_g_DevMemListAllocated );
        if ( it )
        {
            ORKAMM_DBG_PRINTF( "Allocated       #    StartAddress    -    EndAddress   ,    Size (Hex)     Size (Dec)\n" );
            ORKAMM_DBG_PRINTF( "============== === ================= - ================, ================ ============\n" );
            uint32_t idx = 0;
            for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( it ) )
            {
                // parameters of an "allocated" block
                uint64_t recAddress = ( *i )->start;
                uint64_t recSize = ( *i )->size;
                ORKAMM_DBG_PRINTF( " - MemoryBlock#%3d: %16.16" PRIx64 " - %16.16" PRIx64 ", %16.16" PRIx64 " (%10." PRId64 ")\n", idx, recAddress, recAddress + recSize - 1, recSize, recSize );
                idx++;
            }
            ORKAVEC_IterDestroy( it );
        }
    }
#endif
}

// helper functions
static ORKAMM_DevMemEntry_t *
ORKAMM_Helper_EntryCreate( uint64_t address, uint64_t size )
{
    ORKAMM_DevMemEntry_t *devMemEntry = ( ORKAMM_DevMemEntry_t * ) ORKAMM_CALLOC( 1, sizeof( ORKAMM_DevMemEntry_t ) );
    if ( devMemEntry )
    {
        devMemEntry->start = address;
        devMemEntry->size = size;
    }
    return devMemEntry;
}

static void
ORKAMM_Helper_EntryDestroy( ORKAMM_DevMemEntry_t *entry )
{
    if ( entry )
    {
        ORKAMM_DBG_PRINTF( "ORKAMM_Helper_EntryDestroy: Free address: 0x%016" PRIxPTR "\n", ( uintptr_t ) entry );
        ORKAMM_FREE( entry );
    }
}

static bool
ORKAMM_Helper_NewEntryPush( ORKAMM_DevMemList_t list, uint64_t address, uint64_t size )
{
    bool rv = false;
    if ( list )
    {
        ORKAMM_DevMemEntry_t *devMemEntry = ORKAMM_Helper_EntryCreate( address, size );
        if ( devMemEntry )
        {
            // we store a pointer to our entry by giving the address of this pointer
            void *r = ORKAVEC_PushBack( list, ( void * ) &devMemEntry );
            rv = ( NULL != r );
        }
    }
    return rv;
}

uint64_t
ORKAMM_DevFreeBytes()
{
    uint64_t res = 0ULL;

    // if list of free blocks is empty - we simply have nothing to offer. Exit.
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
    ORKAMM_DBG_PRINTF( "\n=====================================================================\n" );
    ORKAMM_DBG_PRINTF( "ORKAMM_DBG_DumpListFree (%" PRId64 "):\n", s );
    if ( s )
    {
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( ORKAMM_g_DevMemListFree );
        if ( it )
        {
            ORKAMM_DBG_PRINTF( "Free            #    StartAddress    -    EndAddress   ,    Size (Hex)     Size (Dec)\n" );
            ORKAMM_DBG_PRINTF( "============== === ================= - ================, ================ ============\n" );
            uint32_t idx = 0;
            for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( it ) )
            {
                // parameters of a "free" block
                uint64_t recAddress = ( *i )->start;
                uint64_t recSize = ( *i )->size;
                ORKAMM_DBG_PRINTF( " - MemoryBlock#%3d: %16.16" PRIx64 " - %16.16" PRIx64 ", %16.16" PRIx64 " (%10." PRId64 ")\n", idx, recAddress, recAddress + recSize - 1, recSize, recSize );
                idx++;
                res += recSize;
            }
            ORKAVEC_IterDestroy( it );
        }
    }
    return res;
}

uint64_t
ORKAMM_DevFreeBiggestBlock()
{
    uint64_t res = 0ULL;

    // if list of free blocks is empty - we simply have nothing to offer. Exit.
    uint64_t s = ORKAVEC_Size( ORKAMM_g_DevMemListFree );
    ORKAMM_DBG_PRINTF( "\n=====================================================================\n" );
    ORKAMM_DBG_PRINTF( "ORKAMM_DBG_DumpListFree (%" PRId64 "):\n", s );
    if ( s )
    {
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( ORKAMM_g_DevMemListFree );
        if ( it )
        {
            ORKAMM_DBG_PRINTF( "Free            #    StartAddress    -    EndAddress   ,    Size (Hex)     Size (Dec)\n" );
            ORKAMM_DBG_PRINTF( "============== === ================= - ================, ================ ============\n" );
            uint32_t idx = 0;
            for ( ORKAMM_DevMemEntry_t **i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( ORKAMM_DevMemEntry_t ** ) ORKAVEC_IterNext( it ) )
            {
                // parameters of a "free" block
                uint64_t recAddress = ( *i )->start;
                uint64_t recSize = ( *i )->size;
                ORKAMM_DBG_PRINTF( " - MemoryBlock#%3d: %16.16" PRIx64 " - %16.16" PRIx64 ", %16.16" PRIx64 " (%10." PRId64 ")\n", idx, recAddress, recAddress + recSize - 1, recSize, recSize );
                idx++;
                res = recSize > res ? recSize : res;
            }
            ORKAVEC_IterDestroy( it );
        }
    }
    return res;
}

