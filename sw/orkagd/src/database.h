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
#ifndef DATABASE_H__
#define DATABASE_H__

#include "vector.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>
#include <stdint.h>

#if 1
#    define ORKADB_DBG_PRINTF_INT( ... ) printf( __VA_ARGS__ )
#    define ORKADB_DBG_PRINTF( ... )     printf( " ORKADB: " __VA_ARGS__ )
#    define ORKADB_DBG_PRINTF_AVAILABLE
#else
#    define ORKADB_DBG_PRINTF_INT( ... )
#    define ORKADB_DBG_PRINTF( ... )
#endif

typedef struct ORKADB_DBHandle_tag    ORKADB_DBHandle_t;
typedef struct ORKADB_TableHandle_tag ORKADB_TableHandle_t;

typedef enum
{
    ORKADB_FieldType_UnknownPointer = 0,
    ORKADB_FieldType_ValueI8,
    ORKADB_FieldType_ValueI16,
    ORKADB_FieldType_ValueI24,
    ORKADB_FieldType_ValueI32,
    ORKADB_FieldType_ValueI64,
    ORKADB_FieldType_ValueU8,
    ORKADB_FieldType_ValueU16,
    ORKADB_FieldType_ValueU24,
    ORKADB_FieldType_ValueU32,
    ORKADB_FieldType_ValueU64,
    ORKADB_FieldType_ValueF32,
    ORKADB_FieldType_ValueF64,
    ORKADB_FieldType_StringC,
    ORKADB_FieldType_Table
} ORKADB_FieldTypes_t;

typedef enum
{
    ORKADB_FieldOption_Nothing,
    ORKADB_FieldOption_Unique,
    ORKADB_FieldOption_FastLookup,
} ORKADB_FieldOptions_t;

typedef struct
{
    uint64_t              recordUniqueID;
    uint64_t              recordIndex;
    void *                recordData;
    ORKADB_TableHandle_t *tableHandle;
} ORKADB_RecordHandle_t;

typedef struct
{
    char *                fieldName;
    uint64_t              fieldSize;
    uint64_t              fieldOffsetInRecord;
    ORKADB_FieldTypes_t   fieldType;
    ORKADB_FieldOptions_t fieldOptions;
    ORKADB_TableHandle_t *tableHandle;
} ORKADB_FieldHandle_t;

struct ORKADB_TableHandle_tag
{
    char *             tableName;
    ORKADB_DBHandle_t *database;
    ORKAVEC_Vector_t * fields;
    ORKAVEC_Vector_t * records;
    uint64_t           recordSizeFinal;
    uint64_t           recordSizeCurrent;
    uint64_t           recordUniqueID;
    uint64_t           uniqueNum;
};

struct ORKADB_DBHandle_tag
{
    char *            databaseName;
    ORKAVEC_Vector_t *tables;
};

typedef struct
{
    char *   name;
    uint64_t offset;
    uint64_t range;
} ORKADB_DBG_ComponentRecord_t;

typedef struct
{
    char *                boardname;
    uint64_t              fpganr;
    ORKADB_TableHandle_t *pciBars;
    char *                blockdesignname;
    ORKADB_TableHandle_t *components;
} ORKADB_DBG_BoardRecord_t;

ORKADB_DBHandle_t *
ORKAGD_DBCreate( const char *databaseName );
ORKADB_DBHandle_t *
ORKAGD_DBOpen( const char *databaseName );
void
ORKADB_DBDestroy( ORKADB_DBHandle_t *databaseHandle );
ORKADB_TableHandle_t *
ORKADB_TableCreate( ORKADB_DBHandle_t *databaseHandle, char *tableName );
ORKADB_TableHandle_t *
ORKADB_TableHandleGet( ORKADB_DBHandle_t *databaseHandle, char *tableName );
void
ORKADB_TableDestroy( ORKADB_TableHandle_t *tableHandle );
uint64_t
ORKADB_TableNumEntries( ORKADB_TableHandle_t *tableHandle );
ORKADB_FieldHandle_t *
ORKADB_FieldCreate( ORKADB_TableHandle_t *tableHandle, const char *fieldName, ORKADB_FieldTypes_t fieldType, ORKADB_FieldOptions_t fieldOptions );
void
ORKADB_FieldDestroy( ORKADB_FieldHandle_t *fieldHandle );
ORKADB_FieldHandle_t *
ORKADB_FieldOpen( ORKADB_TableHandle_t *tableHandle, const char *fieldName );
void
ORKADB_FieldClose( ORKADB_FieldHandle_t *fieldHandle );
ORKADB_RecordHandle_t *
ORKADB_RecordCreate( ORKADB_TableHandle_t *tableHandle );
void
ORKADB_EntryFieldValueSetCopy( ORKADB_RecordHandle_t *entryHandle, ORKADB_FieldHandle_t *fieldHandle, const void *value );
void *
ORKADB_RecordGetFieldAddrByHandle( ORKADB_RecordHandle_t *record, ORKADB_FieldHandle_t *field );
// void ORKADB_EntryFieldValueSetRef( ORKADB_RecordHandle_t *entryHandle, ORKADB_FieldHandle_t *fieldHandle, void *value );
void
ORKADB_RecordDestroyLast( ORKADB_RecordHandle_t *recordHandle );
void *
ORKADB_RecordDataGet( ORKADB_RecordHandle_t *recordHandle );
void *
ORKADB_RecordGetAt( ORKADB_TableHandle_t *tableHandle, uint64_t index );
void
ORKADB_RecordDump( ORKADB_RecordHandle_t *record );
ORKAVEC_Vector_t *
ORKADB_RecordListCreate( ORKADB_TableHandle_t *tableHandle, ORKADB_FieldHandle_t *fieldHandle, void *searchData );
void
ORKADB_RecordListDestroy( ORKAVEC_Vector_t *recordListCreate );
void
ORKADB_TableDump( ORKADB_DBHandle_t *databaseHandle, char *tableName );
void
ORKADB_TableHandleDump( ORKADB_TableHandle_t *tableHandle );
#endif
