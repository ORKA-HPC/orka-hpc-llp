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
#include "types.h"

#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

ORKAVEC_Vector_t **ORKAVEC_g_VectorsAll = NULL;
uint64_t ORKAVEC_g_VectorsNumVectorsAllocated = 0;
uint64_t ORKAVEC_g_VectorsIndexNext = 0;

ORKAVEC_Vector_t *
ORKAVEC_Create(
    uint64_t elementSize )
{
    ORKAVEC_Vector_t *myVecALL = NULL;
    ORKAVEC_Vector_t *myVec = NULL;
    if ( elementSize )
    {
        // Check whether there is already an vector array and if
        // yes, whether there is enough space in it.
        // Extend if needed.
        // =======================================================

        // already any vector in array ?
        if ( ORKAVEC_g_VectorsNumVectorsAllocated )
        {
            // yes, check if it needs extension
            if ( ORKAVEC_g_VectorsNumVectorsAllocated == ORKAVEC_g_VectorsIndexNext )
            {
                // yes, try to allocate enough memory
                uint64_t newNumberOfVectors = ORKAVEC_g_VectorsNumVectorsAllocated + ORKAVEC_VectorListAllocationIncrement;
                myVecALL = ORKAVEC_CALLOC( newNumberOfVectors, elementSize );
                if ( myVecALL )
                {
                    // was successful, so copy over old content and update number/pointer
                    memcpy( myVecALL, ORKAVEC_g_VectorsAll, ORKAVEC_g_VectorsNumVectorsAllocated * sizeof( ORKAVEC_Vector_t * ));
                    ORKAVEC_FREE(( void * ) ORKAVEC_g_VectorsAll );
                    ORKAVEC_g_VectorsAll = ( ORKAVEC_Vector_t ** ) myVecALL;
                    ORKAVEC_g_VectorsNumVectorsAllocated = newNumberOfVectors;
                }
            }
        }
        else
        {
            myVecALL = ORKAVEC_CALLOC( ORKAVEC_VectorListAllocationInitial, sizeof( ORKAVEC_Vector_t * ) );
            ORKAVEC_g_VectorsAll = ( ORKAVEC_Vector_t ** ) myVecALL;
            ORKAVEC_g_VectorsNumVectorsAllocated = ORKAVEC_VectorListAllocationInitial;
        }

        myVec = ( ORKAVEC_Vector_t * )ORKAVEC_CALLOC( 1, sizeof( ORKAVEC_Vector_t ));
        if ( myVec )
        {
            myVec->elementSize = elementSize;
            myVec->globalArrayIndex = ORKAVEC_g_VectorsIndexNext;
            ORKAVEC_g_VectorsAll[ ORKAVEC_g_VectorsIndexNext++ ] = myVec;
        }
    }
    return myVec;
}

void
ORKAVEC_Destroy(
    ORKAVEC_Vector_t *vector )
{
    if ( vector )
    {
        if ( vector->vector )
        {
            // clear vector array elements
            memset(( void * )( vector->vector ), 0xd9, vector->elementSize * vector->numElementsAllocated );
            // free memory of contents
            ORKAVEC_FREE( vector->vector );
        }
        // clear global vector collector
        ORKAVEC_g_VectorsAll[ vector->globalArrayIndex ] = NULL;
        // clear vector control structure
        memset(( void * ) vector, 0xd8, sizeof( ORKAVEC_Vector_t ) );
        // free memory of control structure
        ORKAVEC_FREE( vector );
    }
}

void *
ORKAVEC_PushBack(
    ORKAVEC_Vector_t *vector,   // the container you want to store at
    const void *value )         // give the start address of that what you want to store
{
    void *rv = NULL;
    if ( vector && value )
    {
        if ( vector->vector )
        {
            // vector control struct exists and elements are already stored
            if ( vector->curIndex == vector->numElementsAllocated )
            {
                // new element exceeds space, extend space by allocating new
                // and copying over old content, then free old location
                uint64_t newNumberOfElements = vector->numElementsAllocated + ORKAVEC_VectorAllocationIncrement;
                void *myElementListNew = ORKAVEC_CALLOC( newNumberOfElements, vector->elementSize );
                if ( myElementListNew )
                {
                    // copy over from previous location to new one 
                    memcpy( myElementListNew, vector->vector, vector->numElementsAllocated * vector->elementSize );
                    ORKAVEC_FREE( vector->vector );
                    vector->vector = myElementListNew;
                    vector->numElementsAllocated = newNumberOfElements;
                }
            }
        }
        else
        {
            // OK, vector control struct exists, but no current space for elements
            // create enough space for elements
            vector->vector = ORKAVEC_CALLOC( ORKAVEC_VectorAllocationInitial, vector->elementSize );
            vector->numElementsAllocated = ORKAVEC_VectorAllocationInitial;
        }

        // allocation successful or already done
        if ( vector->vector )
        {
            // calculate address of element
            const uint64_t addr = vector->curIndex * vector->elementSize;
            uint8_t *baseAddress = ( uint8_t * ) ( vector->vector );
            rv = ( void * ) ( &baseAddress[ addr ] );
            // store new vector element
            memcpy( rv, value, vector->elementSize );
            vector->curIndex++;
        }
    }
    return rv;
}

void *
ORKAVEC_Insert(
    ORKAVEC_Vector_t *vector,
    const void *iter,
    const void *value )
{
    void *rv = NULL;

    uint64_t s = ORKAVEC_Size( vector );
    if ( s )
    {
        uint64_t recordSize = ORKAVEC_SizeElement( vector );
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( vector );
        if ( it && recordSize )
        {
            // here we try to find the position to insert
            // (which is given by the iterator-pointer)
            uint32_t idx = 0;
            uint64_t idxFound = 0ULL;
            bool found = false;
            for ( void *i = ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ORKAVEC_IterNext( it ) )
            {
                // if pointer of element is found in vector ...
                if ( iter == i )
                {
                    //                    printf( "Found !!!! %" PRId64 "\n", recordSize );
                    idxFound = idx;
                    found = true;
                    break;
                }
                idx++;
            }
            // we do not need the iterator anymore
            ORKAVEC_IterDestroy( it );

            if ( found )
            {
                // create a new element to be added at the end
                void *p = ORKAVEC_CALLOC( 1, recordSize );
                if ( p )
                {
                    // push new (zeroed element) to vector end.

                    // the intention is to copy all elements one up
                    // (bottom -> down to the insertition point)
                    void *newElement = ORKAVEC_PushBack( vector, p );
                    if ( newElement )
                    {
                        // copy down from top to index where to insert all elements
                        // we are starting at the top element.
                        // 's' was on above the top element, but we added (by pushBack a new element)

                        // get position of top element as the destination of copy
                        void *pDst = newElement;
                        // position of source element is determined within loop
                        void *pSrc = NULL;
                        uint64_t i = s - 1; // s is at least 1 (always greater than zero)
                        for ( ; i > idxFound; --i )
                        {
                            //                            printf( "%" PRId64 "\n", i );
                            pSrc = ORKAVEC_GetAt( vector, i );
                            //                            printf( "%" PRId64 ": 0x%16.16" PRIx64 " ==> %" PRId64 ": 0x%16.16" PRIx64 "\n",
                            //                                    i, *(( uint64_t * )pSrc ),
                            //                                    i + 1, *(( uint64_t * )pDst ));
                                                        // now copy up (lower element to higher)
                            memcpy( pDst, pSrc, recordSize );
                            // former lower element is next loop round the destination (higher element)
                            pDst = pSrc;
                        }

                        // copy last element
                        pSrc = ORKAVEC_GetAt( vector, i );
                        //                        printf( "%" PRId64 ": 0x%16.16" PRIx64 " ==> %" PRId64 ": 0x%16.16" PRIx64 "\n",
                        //                                i, *( ( uint64_t * ) pSrc ),
                        //                                i + 1, *( ( uint64_t * ) pDst ) );
                        memcpy( pDst, pSrc, recordSize );
                        pDst = pSrc;

                        // insert new element
                        memcpy( pDst, value, recordSize );
                        rv = pDst;
                    }
                }
            }
            else
            {
                // this element is inserted at the end if iterator-pointer is not found
                rv = ORKAVEC_PushBack( vector, value );
            }
        }
    }
    else
    {
        // this element is inserted as the only element if vector was empty
        rv = ORKAVEC_PushBack( vector, value );
    }

    return rv;
}

bool_t
ORKAVEC_Delete(
    ORKAVEC_Vector_t *vector,
    const void *iter )
{
    bool_t rv = FALSE;

    uint64_t s = ORKAVEC_Size( vector );
    if ( s )
    {
        uint64_t recordSize = ORKAVEC_SizeElement( vector );
        ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( vector );
        if ( it && recordSize )
        {
            // here we try to find the position to insert
            // (which is given by the iterator-pointer)
            void *j = NULL;
            bool_t found = FALSE;
            for ( void *i = ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ORKAVEC_IterNext( it ) )
            {
                if ( found )
                {
                    // successive copy down upper elements ("i") to lower/previous elements ("j")
                    memcpy( j, i, recordSize );
                }

                // if pointer of element is found in vector ...
                if ( iter == i )
                {
                    found = TRUE;
                }

                j = i;
            }
            // we do not need the iterator anymore
            ORKAVEC_IterDestroy( it );

            if ( found )
            {
                // reduce number of elements by one
                ( vector->curIndex )--;
            }
            rv = found;
        }
    }

    return rv;
}

void *
ORKAVEC_GetLast(
    ORKAVEC_Vector_t *vector )
{
    void *rv = NULL;
    if ( vector->vector )
    {
        if ( vector->curIndex )
        {
            const uint64_t idx = vector->curIndex - 1;
            // calculate address of element
            const uint64_t addr = idx * vector->elementSize;
            uint8_t *baseAddress = ( uint8_t * ) ( vector->vector );
            // destroy vector element
            rv = ( void * ) ( &baseAddress[ addr ] );
        }
    }
    return rv;
}

void
ORKAVEC_PopBack(
    ORKAVEC_Vector_t *vector )
{
    void *item = ORKAVEC_GetLast( vector );
    if ( item )
    {
        // destroy vector element
        memset( item, 0xd9, vector->elementSize );
        ( vector->curIndex )--;
    }
}

uint64_t
ORKAVEC_Size(
    ORKAVEC_Vector_t *vector )
{
    uint64_t rv = 0;
    //printf("ORKAVEC_Size: 0x%p\n", vector );
    if ( vector )
    {
        rv = vector->curIndex;
        //printf("ORKAVEC_Size: %d\n", (int)rv);
    }
    return rv;
}

uint64_t
ORKAVEC_SizeElement(
    ORKAVEC_Vector_t *vector )
{
    uint64_t rv = 0;
    if ( vector )
    {
        rv = vector->elementSize;
    }
    return rv;
}

void *
ORKAVEC_GetAt(
    ORKAVEC_Vector_t *vector,
    uint64_t index )
{
    void *rv = NULL;
    if ( vector )
    {
        if ( index < vector->curIndex )
        {
            // calculate address of element
            const uint64_t addr = index * vector->elementSize;
            uint8_t *baseAddress = ( uint8_t * ) ( vector->vector );
            rv = ( void * ) ( &baseAddress[ addr ]);
        }
    }
    return rv;
}

ORKAVEC_Iter_t *
ORKAVEC_IterCreate(
    ORKAVEC_Vector_t *vector )
{
    ORKAVEC_Iter_t *rv = NULL;
    if ( vector )
    {
        rv = ( ORKAVEC_Iter_t * ) ORKAVEC_CALLOC( 1, sizeof( ORKAVEC_Iter_t ) );
        if ( rv )
        {
            rv->currVec = vector;
            rv->idx = 0;
        }
    }
    return rv;
}

void
ORKAVEC_IterDestroy(
    ORKAVEC_Iter_t *iter )
{
    if ( iter )
    {
        memset( ( void * ) iter, 0xea, sizeof( ORKAVEC_Iter_t ) );
        ORKAVEC_FREE( iter );
    }
}

void *
ORKAVEC_IterBegin(
    ORKAVEC_Iter_t *vectorIterator )
{
    void *rv = NULL;
    if ( vectorIterator )
    {
        vectorIterator->idx = 0LLU;
        rv = ORKAVEC_GetAt( vectorIterator->currVec, vectorIterator->idx );
    }
    return rv;
}

bool_t
ORKAVEC_IterEnd(
    ORKAVEC_Iter_t *vectorIterator )
{
    bool_t rv = FALSE;
    if ( vectorIterator )
    {
        if ( vectorIterator->idx < vectorIterator->currVec->curIndex )
        {
            rv = TRUE;
        }
    }
    return rv;
}

void *
ORKAVEC_IterNext(
    ORKAVEC_Iter_t *vectorIterator )
{
    void *rv = NULL;
    if ( vectorIterator )
    {
        vectorIterator->idx++;
        rv = ORKAVEC_GetAt( vectorIterator->currVec, vectorIterator->idx );
    }
    return rv;
}

void *
ORKAVEC_IterSet(
    ORKAVEC_Iter_t *vectorIterator,
    uint64_t index )
{
    void *rv = NULL;
    if ( vectorIterator )
    {
        if ( vectorIterator->idx < vectorIterator->currVec->curIndex )
        {
            vectorIterator->idx = index;
            rv = ORKAVEC_GetAt( vectorIterator->currVec, vectorIterator->idx );
        }
    }
    return rv;
}


uint64_t
ORKAVEC_IterIndex(
    ORKAVEC_Iter_t *vectorIterator )
{
    uint64_t rv = 0xffffffffffffffffULL;
    if ( vectorIterator )
    {
        rv = vectorIterator->idx;
    }
    return rv;
}

bool_t
ORKAVEC_IndexIsValid(
    ORKAVEC_Vector_t *vector,
    uint64_t index )
{
    bool_t rv = FALSE;
    if ( vector )
    {
        rv = ( index < vector->curIndex );
    }
    return rv;
}


typedef float float32_t;
typedef double float64_t;

static void
ORKAVEC_TestInteratorsDumpVector(
    ORKAVEC_Vector_t *myVec64 )
{
    printf( "ORKAVEC_TestInteratorsDumpVector: Start\n" );
    if ( myVec64 )
    {
        uint64_t se = ORKAVEC_SizeElement( myVec64 );
        printf( " - ElementSize = %" PRId64 "\n", se );
        uint64_t s = ORKAVEC_Size( myVec64 );
        printf( " - NumElements = %" PRId64 "\n", s );
        if ( s )
        {
            ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( myVec64 );
            if ( it )
            {
                uint32_t idx = 0;
                for ( uint64_t *i = ( uint64_t * ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( uint64_t * ) ORKAVEC_IterNext( it ) )
                {
                    printf( " - >%d: 0x%16.16" PRIx64 "\n", idx, *i );
                    idx++;
                }
                ORKAVEC_IterDestroy( it );
            }
        }
    }
    printf( "ORKAVEC_TestInteratorsDumpVector: End\n" );
}

static void
ORKAVEC_TestIteratorsInsertStandard()
{
    uint32_t idxInsert = 3;
    uint64_t insert = 0xf00d2bad43531f00ULL;
    printf( "ORKAVEC_TestInteratorsStandard: Insert value 0x%16.16" PRIx64 "\n", insert );

    ORKAVEC_Vector_t *myVec64 = ORKAVEC_Create( sizeof( uint64_t ) );
    if ( myVec64 )
    {
        uint64_t a = 0x1234567890abcdefULL;
        uint64_t b = 0x21234567890abcdeULL;
        uint64_t c = 0x321234567890abcdULL;
        uint64_t d = 0x4321234567890abcULL;
        uint64_t e = 0x54321234567890abULL;

        ORKAVEC_PushBack( myVec64, ( void * ) &a );
        ORKAVEC_PushBack( myVec64, ( void * ) &b );
        ORKAVEC_PushBack( myVec64, ( void * ) &c );
        ORKAVEC_PushBack( myVec64, ( void * ) &d );
        ORKAVEC_PushBack( myVec64, ( void * ) &e );
        printf( "ORKAVEC_TestInterators: Dump contents start:\n" );
        ORKAVEC_TestInteratorsDumpVector( myVec64 );

        uint64_t se = ORKAVEC_SizeElement( myVec64 );
        printf( "ORKAVEC_TestInterators: ElementSize = %" PRId64 "\n", se );
        uint64_t s = ORKAVEC_Size( myVec64 );
        printf( "ORKAVEC_TestInterators: NumElements = %" PRId64 "\n", s );
        if ( s )
        {
            ORKAVEC_Iter_t *it = ORKAVEC_IterCreate( myVec64 );
            if ( it )
            {
                uint32_t idx = 0;

                for ( uint64_t *i = ( uint64_t * ) ORKAVEC_IterBegin( it ); ORKAVEC_IterEnd( it ); i = ( uint64_t * ) ORKAVEC_IterNext( it ) )
                {
                    if ( idx == idxInsert )
                    {
                        ORKAVEC_Insert(
                            myVec64,
                            ( void * ) i,
                            ( void * ) &insert );
                        break;
                    }
                    printf( "%d: 0x%16.16" PRIx64 "\n", idx, *i );
                    idx++;
                }
                ORKAVEC_IterDestroy( it );
            }
        }
        ORKAVEC_TestInteratorsDumpVector( myVec64 );

        ORKAVEC_Destroy( myVec64 );
        printf( "ORKAVEC_TestInteratorsStandard: Dump contents end:\n" );
    }
}

static void
ORKAVEC_TestIteratorsInsertAtEnd()
{
    uint64_t insert = 0xf00d2bad43531f00ULL;
    printf( "ORKAVEC_TestInteratorsStandard: Insert value 0x%16.16" PRIx64 "\n", insert );

    ORKAVEC_Vector_t *myVec64 = ORKAVEC_Create( sizeof( uint64_t ) );
    if ( myVec64 )
    {
        uint64_t a = 0x1234567890abcdefULL;
        uint64_t b = 0x21234567890abcdeULL;
        uint64_t c = 0x321234567890abcdULL;
        uint64_t d = 0x4321234567890abcULL;
        uint64_t e = 0x54321234567890abULL;

        ORKAVEC_PushBack( myVec64, ( void * ) &a );
        ORKAVEC_PushBack( myVec64, ( void * ) &b );
        ORKAVEC_PushBack( myVec64, ( void * ) &c );
        ORKAVEC_PushBack( myVec64, ( void * ) &d );
        ORKAVEC_PushBack( myVec64, ( void * ) &e );
        printf( "ORKAVEC_TestInterators: Dump contents start:\n" );
        ORKAVEC_TestInteratorsDumpVector( myVec64 );

        uint64_t se = ORKAVEC_SizeElement( myVec64 );
        printf( "ORKAVEC_TestInterators: ElementSize = %" PRId64 "\n", se );
        uint64_t s = ORKAVEC_Size( myVec64 );
        printf( "ORKAVEC_TestInterators: NumElements = %" PRId64 "\n", s );
        if ( s )
        {
            ORKAVEC_Insert(
                myVec64,
                NULL,
                ( void * ) &insert );
        }
        ORKAVEC_TestInteratorsDumpVector( myVec64 );

        ORKAVEC_Destroy( myVec64 );
        printf( "ORKAVEC_TestInteratorsStandard: Dump contents end:\n" );
    }
}


int
main_TestVec()
{
    ORKAVEC_TestIteratorsInsertStandard();
    ORKAVEC_TestIteratorsInsertAtEnd();

    ORKAVEC_Create( sizeof( uint8_t ) );
    ORKAVEC_Create( sizeof( uint16_t ) );
    ORKAVEC_Create( sizeof( uint32_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Create( sizeof( int8_t ) );
    ORKAVEC_Create( sizeof( int16_t ) );
    ORKAVEC_Create( sizeof( int32_t ) );
    ORKAVEC_Create( sizeof( int64_t ) );
    ORKAVEC_Create( sizeof( float32_t ) );
    ORKAVEC_Create( sizeof( float64_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Create( sizeof( uint64_t ) );
    ORKAVEC_Vector_t *myVec16 = ORKAVEC_Create( sizeof( uint64_t ) );

    uint64_t a = 0x1234567890abcdefULL;
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_PushBack( myVec16, ( void * ) &a );
    ORKAVEC_Destroy( myVec16 );

    return 0;
}
