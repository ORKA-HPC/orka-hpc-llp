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
#ifndef VECTOR_H__
#define VECTOR_H__

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>
#include <stdint.h>

#include "types.h"

#ifdef ORKAVEC_MMGMT_EXT
#define ORKAVEC_FREE( addr )         ( ORKAVEC_EXT_FREE( addr ))
#define ORKAVEC_MALLOC( size )       ( ORKAVEC_EXT_MALLOC( size ))
#define ORKAVEC_CALLOC( num, size )  ( ORKAVEC_EXT_CALLOC( num, size ))
#else
#define ORKAVEC_FREE( addr )         ( free( addr ))
#define ORKAVEC_MALLOC( size )       ( malloc( size ))
#define ORKAVEC_CALLOC( num, size )  ( calloc( num, size ))
#endif

typedef enum
{
    ORKAVEC_VectorListAllocationInitial = 1,
    ORKAVEC_VectorListAllocationIncrement = 1,
    ORKAVEC_VectorAllocationInitial = 1,
    ORKAVEC_VectorAllocationIncrement = 1,
} ORKAVEC_Constants_t;

typedef struct
{
    void *vector;
    uint64_t globalArrayIndex;      // index value: points to global list of all vectors
    uint64_t elementSize;           // size of individual elements in vector
    uint64_t numElementsAllocated;  // current number of allocated memory space for elements
    uint64_t curIndex;              // current index to store next element
} ORKAVEC_Vector_t;


typedef struct
{
    ORKAVEC_Vector_t *currVec;
    uint64_t idx;
} ORKAVEC_Iter_t;

ORKAVEC_Vector_t *ORKAVEC_Create( uint64_t elementSize );
void ORKAVEC_Destroy( ORKAVEC_Vector_t *vector );
void *ORKAVEC_PushBack( ORKAVEC_Vector_t *vector, const void *value );
void ORKAVEC_PopBack( ORKAVEC_Vector_t *vector );
void *ORKAVEC_Insert( ORKAVEC_Vector_t *vector, const void *iter, const void *value );
bool_t ORKAVEC_Delete( ORKAVEC_Vector_t *vector, const void *iter );
void *ORKAVEC_GetLast( ORKAVEC_Vector_t *vector );
uint64_t ORKAVEC_Size( ORKAVEC_Vector_t *vector );
uint64_t ORKAVEC_SizeElement( ORKAVEC_Vector_t *vector );
void *ORKAVEC_GetAt( ORKAVEC_Vector_t *vector, uint64_t index );
ORKAVEC_Iter_t *ORKAVEC_IterCreate( ORKAVEC_Vector_t *vector );
void ORKAVEC_IterDestroy( ORKAVEC_Iter_t *iter );
void *ORKAVEC_IterBegin( ORKAVEC_Iter_t *vectorIterator );
bool_t ORKAVEC_IterEnd( ORKAVEC_Iter_t *vectorIterator );
void *ORKAVEC_IterNext( ORKAVEC_Iter_t *vectorIterator );
void *ORKAVEC_IterSet( ORKAVEC_Iter_t *vectorIterator, uint64_t index );
uint64_t ORKAVEC_IterIndex( ORKAVEC_Iter_t *vectorIterator );
bool_t ORKAVEC_IndexIsValid( ORKAVEC_Vector_t *vector, uint64_t index );

#endif