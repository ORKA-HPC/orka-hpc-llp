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
#include "database.h"
#include "vector.h"
#include "stringhelper.h"
#include "types.h"

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint64_t ORKADB_DabaseListNumEntries = 0;
ORKAVEC_Vector_t *ORKADB_g_DatabaseListEntries = NULL;

ORKADB_DBHandle_t *
ORKAGD_DBCreate( const char *databaseName )
{
    ORKADB_DBHandle_t *rv = NULL;
    if ( databaseName )
    {
        if ( NULL == ORKADB_g_DatabaseListEntries )
        {
            ORKADB_g_DatabaseListEntries = ORKAVEC_Create( sizeof( ORKADB_DBHandle_t ) );
        }
        ORKADB_DBHandle_t db;
        db.databaseName = StringCreate( databaseName );
        if ( db.databaseName )
        {
            db.tables = ORKAVEC_Create( sizeof( ORKADB_TableHandle_t ) );
            if ( ORKADB_g_DatabaseListEntries && db.tables )
            {
                rv = ( ORKADB_DBHandle_t * )ORKAVEC_PushBack( ORKADB_g_DatabaseListEntries, ( void * ) &db );
            }
            else
            {
                StringDestroy( db.databaseName );
                db.databaseName = NULL;
            }
        }
    }
    return rv;
}

ORKADB_DBHandle_t *
ORKAGD_DBOpen( const char *databaseName )
{
    ORKADB_DBHandle_t *rv = NULL;
    if ( databaseName )
    {
        if ( ORKADB_g_DatabaseListEntries )
        {
            uint64_t numDatabases = ORKAVEC_Size( ORKADB_g_DatabaseListEntries );
            for ( uint64_t i = 0; i < numDatabases; ++i )
            {
                ORKADB_DBHandle_t *db = ( ORKADB_DBHandle_t * )ORKAVEC_GetAt( ORKADB_g_DatabaseListEntries, i );
                if ( db )
                {
                    if ( 0 == strcmp( databaseName, db->databaseName ) )
                    {
                        rv = db;
                        break;
                    }
                }
            }
        }
    }
    return rv;
}

void
ORKADB_DBDestroy( ORKADB_DBHandle_t *databaseHandle )
{
}

ORKADB_TableHandle_t *
ORKADB_TableCreate( ORKADB_DBHandle_t *databaseHandle, char *tableName )
{
    ORKADB_TableHandle_t *rv = NULL;
    static uint64_t DbgNumTable = 1;
    //ORKADB_DBG_PRINTF( "ORKADB_TableCreate[0x%p, %" PRId64 "]: %s\n", databaseHandle, DbgNumTable, tableName );
    if ( databaseHandle && tableName )
    {
        ORKADB_TableHandle_t *table = ( ORKADB_TableHandle_t * )calloc( 1, sizeof( ORKADB_TableHandle_t ));
        if ( table )
        {
            table->uniqueNum = DbgNumTable;
            table->database = databaseHandle;
            table->tableName = StringCreate( tableName );
            if ( table->tableName )
            {
                table->fields = ORKAVEC_Create( sizeof( ORKADB_FieldHandle_t * ) );
                table->recordSizeCurrent = 0;
                table->recordSizeFinal = 0;
                table->recordUniqueID = 1;
                if ( table->fields )
                {
                    table->records = ORKAVEC_Create( sizeof( ORKADB_RecordHandle_t * ) );
                    if ( table->records )
                    {
                        rv = ( ORKADB_TableHandle_t * ) ORKAVEC_PushBack( databaseHandle->tables, ( void * ) &table );
                        if ( rv )
                        {
                            rv = table;
                        }
                        else
                        {
                            ORKAVEC_Destroy( table->fields );
                            table->fields = NULL;

                            StringDestroy( table->tableName );
                            table->tableName = NULL;

                            memset( ( void * ) table, 0x68, sizeof( ORKADB_TableHandle_t ) );
                            free( table );
                        }
                    }
                    else
                    {
                        ORKAVEC_Destroy( table->fields );
                        table->fields = NULL;

                        StringDestroy( table->tableName );
                        table->tableName = NULL;

                        memset( ( void * ) table, 0x67, sizeof( ORKADB_TableHandle_t ) );
                        free( table );
                    }
                }
                else
                {
                    StringDestroy( table->tableName );
                    table->tableName = NULL;

                    memset( ( void * ) table, 0x66, sizeof( ORKADB_TableHandle_t ) );
                    free( table );
                }
            }
            else
            {
                memset( ( void * ) table, 0x66, sizeof( ORKADB_TableHandle_t ) );
                free( table );
            }
        }
    }
    DbgNumTable++;
    return rv;
}

ORKADB_TableHandle_t *
ORKADB_TableHandleGet( ORKADB_DBHandle_t *databaseHandle, char *tableName )
{
    ORKADB_TableHandle_t *rv = NULL;
    if ( databaseHandle && tableName )
    {
        ORKAVEC_Vector_t *tables = databaseHandle->tables;

        uint64_t numTables = ORKAVEC_Size( tables );
        for ( uint64_t i = 0; i < numTables; ++i )
        {
            ORKADB_TableHandle_t **table = ( ORKADB_TableHandle_t ** ) ORKAVEC_GetAt( tables, i );
            if ( table )
            {
                if ( 0 == strcmp( tableName, ( *table )->tableName ) )
                {
                    rv = *table;
                    break;
                }
            }
        }
    }
    return rv;
}

void
ORKADB_TableDestroy(
    ORKADB_TableHandle_t *tableHandle )
{
}

ORKADB_FieldHandle_t *
ORKADB_FieldCreate(
    ORKADB_TableHandle_t *tableHandle,
    const char *fieldName,
    ORKADB_FieldTypes_t fieldType,
    ORKADB_FieldOptions_t fieldOptions )
{
    ORKADB_FieldHandle_t *rv = NULL;
    if ( tableHandle && fieldName )
    {
        // no record created yet ? (Then we are not allowed to add fields)
        if ( 0 == tableHandle->recordSizeFinal )
        {
            ORKADB_FieldHandle_t *field = calloc( 1, sizeof( ORKADB_FieldHandle_t ));
            if ( field )
            {
                field->fieldName = StringCreate( fieldName );
                if ( field->fieldName )
                {
                    field->fieldType = fieldType;
                    field->fieldOptions = fieldOptions;
                    field->tableHandle = tableHandle;
                    uint64_t size;
                    switch ( fieldType )
                    {
                        default:
                            size = 0;
                            break;
                        case ORKADB_FieldType_ValueI8:
                        case ORKADB_FieldType_ValueU8:
                            size = 1;
                            break;
                        case ORKADB_FieldType_ValueI16:
                        case ORKADB_FieldType_ValueU16:
                            size = 2;
                            break;
                        case ORKADB_FieldType_ValueI24:
                        case ORKADB_FieldType_ValueU24:
                            size = 3;
                            break;
                        case ORKADB_FieldType_ValueI32:
                        case ORKADB_FieldType_ValueU32:
                        case ORKADB_FieldType_ValueF32:
                            size = 4;
                            break;
                        case ORKADB_FieldType_ValueI64:
                        case ORKADB_FieldType_ValueU64:
                        case ORKADB_FieldType_ValueF64:
                            size = 8;
                            break;
                        case ORKADB_FieldType_UnknownPointer:
                        case ORKADB_FieldType_StringC:
                        case ORKADB_FieldType_Table:
                            size = sizeof( void * );
                            break;
                    }
                    field->fieldSize = size;
                    field->fieldOffsetInRecord = tableHandle->recordSizeCurrent;
                    tableHandle->recordSizeCurrent += size;
                    ORKAVEC_PushBack( tableHandle->fields, ( void * ) &field );
                    rv = field;
                }
            }
        }
    }
    return rv;
}


ORKADB_FieldHandle_t *
ORKADB_FieldOpen(
    ORKADB_TableHandle_t *tableHandle,
    const char *fieldName )
{
    ORKADB_FieldHandle_t *rv = NULL;
    if ( tableHandle && fieldName )
    {
        ORKAVEC_Vector_t *fields = tableHandle->fields;
        uint64_t numFields = ORKAVEC_Size( fields );
        for ( uint64_t i = 0; i < numFields; ++i )
        {
            ORKADB_FieldHandle_t **field = ( ORKADB_FieldHandle_t ** ) ORKAVEC_GetAt( fields, i );
            if ( field )
            {
                if ( *field )
                {
                    if ( 0 == strcmp( fieldName, ( *field )->fieldName ) )
                    {
                        rv = *field;
                        break;
                    }
                }
            }
        }
    }
    return rv;
}

void
ORKADB_FieldClose(
    ORKADB_FieldHandle_t *fieldHandle )
{
    fieldHandle = fieldHandle;
}
void
ORKADB_FieldDestroy(
    ORKADB_FieldHandle_t *fieldHandle )
{
}

void
ORKADB_RecordDestroyLast(
    ORKADB_RecordHandle_t *recordHandle )
{
    if ( recordHandle )
    {
        ORKADB_TableHandle_t *tableHandle = recordHandle->tableHandle;
        if ( tableHandle )
        {
            //ORKADB_DBG_PRINTF( "0x%p\n", recordHandle );
            //void *recordHandle2 = ORKAVEC_GetLast( tableHandle->records );
            //ORKADB_DBG_PRINTF( "0x%p\n", recordHandle2 );
        }
    }
}

ORKADB_RecordHandle_t *
ORKADB_RecordCreate(
    ORKADB_TableHandle_t *tableHandle )
{
    ORKADB_RecordHandle_t *rv = NULL;
    if ( tableHandle )
    {
        uint64_t sizeRecord = 0;
        uint64_t numFields = ORKAVEC_Size( tableHandle->fields );
        for ( uint64_t i = 0; i < numFields; ++i )
        {
            ORKADB_FieldHandle_t *fh = *(( ORKADB_FieldHandle_t ** ) ORKAVEC_GetAt( tableHandle->fields, i ));
            uint64_t sizeField = fh->fieldSize;
            //ORKADB_DBG_PRINTF( "Field [Nr=%" PRId64 ", Size=%" PRId64 "]: %s\n", i, sizeField, fh->fieldName );
            sizeRecord += sizeField;
        }
        //ORKADB_DBG_PRINTF( "RecordSize: %" PRId64 "\n", sizeRecord );
        void *recordData = calloc( 1, tableHandle->recordSizeCurrent );
        if ( recordData )
        {
            ORKADB_RecordHandle_t *recordHandle = calloc( 1, sizeof( ORKADB_RecordHandle_t ));
            if ( recordHandle )
            {
                recordHandle->recordUniqueID = ( tableHandle->recordUniqueID )++;
                tableHandle->recordSizeFinal = tableHandle->recordSizeCurrent;
                recordHandle->recordIndex = ORKAVEC_Size( tableHandle->records );
                recordHandle->recordData = recordData;
                recordHandle->tableHandle = tableHandle;    // for debug only

                rv = ( ORKADB_RecordHandle_t * ) ORKAVEC_PushBack( tableHandle->records, ( void * ) &recordHandle );
                if ( NULL == rv )
                {
                    // clear contents
                    memset( recordData, 0xda, tableHandle->recordSizeFinal );
                    // free elements
                    free( recordData );
                }
                else
                {
                    rv = recordHandle;
                }
            }
            else
            {
                memset( recordData, 0xaa, tableHandle->recordSizeCurrent );
                free( recordData );
            }
        }
    }
    return rv;
}

void
ORKADB_EntryFieldValueSetCopy(
    ORKADB_RecordHandle_t *recordHandle,
    ORKADB_FieldHandle_t *fieldHandle,
    const void *value )
{
    if ( recordHandle && fieldHandle )
    {
        uint8_t *addr = &(( uint8_t * )( recordHandle->recordData ))[ fieldHandle->fieldOffsetInRecord ];
        switch ( fieldHandle->fieldType )
        {
            default:
            case ORKADB_FieldType_UnknownPointer:
            case ORKADB_FieldType_Table:
                *( ( void ** ) addr ) = ( void * )value;
                break;
            case ORKADB_FieldType_ValueI8:
            case ORKADB_FieldType_ValueU8:
                *addr = *( ( uint8_t * ) value );
                break;
            case ORKADB_FieldType_ValueI16:
            case ORKADB_FieldType_ValueU16:
                *( ( uint16_t * ) addr ) = *(( uint16_t * ) value );
                break;
            case ORKADB_FieldType_ValueI24:
            case ORKADB_FieldType_ValueU24:
                memcpy( ( void * ) addr, value, 3 );
                break;
            case ORKADB_FieldType_ValueI32:
            case ORKADB_FieldType_ValueU32:
            case ORKADB_FieldType_ValueF32:
                *( ( uint32_t * ) addr ) = *(( uint32_t * ) value );
                break;
            case ORKADB_FieldType_StringC:
                *( ( char ** ) addr ) = StringCreate( ( char * ) value );
                break;
            case ORKADB_FieldType_ValueI64:
            case ORKADB_FieldType_ValueU64:
            case ORKADB_FieldType_ValueF64:
                *( ( uint64_t * ) addr ) = *(( uint64_t * ) value );
                break;
        }
    }
}

uint64_t
ORKADB_TableNumEntries(
    ORKADB_TableHandle_t *tableHandle )
{
    uint64_t rv = 0;
    if ( tableHandle )
    {
        ORKAVEC_Vector_t *recordsOfTable = tableHandle->records;
        rv = ORKAVEC_Size( recordsOfTable );
    }
    return rv;
}

void *
ORKADB_RecordGetAt(
    ORKADB_TableHandle_t *tableHandle,
    uint64_t index )
{
    void *rv = NULL;
    if ( tableHandle )
    {
        ORKAVEC_Vector_t *recordVector = tableHandle->records;
        ORKADB_RecordHandle_t **entryHandles = ( ORKADB_RecordHandle_t ** ) ( recordVector->vector );
        if ( index < recordVector->curIndex )
        {
            ORKADB_RecordHandle_t *record = entryHandles[ index ];
            //ORKADB_DBG_PRINTF( "Record.recordUniqueID: %" PRId64 "\n", record->recordUniqueID );
            //ORKADB_DBG_PRINTF( "Record.recordIndex:    %" PRId64 "\n", record->recordIndex );
            //ORKADB_DBG_PRINTF( "Record.recordData:     0x%p\n", record->recordData );
            rv = ( void * ) record;
        }
    }
    return rv;
}

void *
ORKADB_RecordDataGet(
    ORKADB_RecordHandle_t *recordHandle )
{
    void *rv = NULL;
    if ( recordHandle )
    {
        rv = ( void* ) ( recordHandle->recordData );
    }
    return rv;
}

ORKAVEC_Vector_t *
ORKADB_RecordListCreate(
    ORKADB_TableHandle_t *tableHandle,
    ORKADB_FieldHandle_t *fieldHandle,
    void *searchData )
{
    ORKAVEC_Vector_t *rv = NULL;
    if ( tableHandle && fieldHandle && searchData )
    {
        void *fieldAddr;
        bool_t alreadyInitialized = FALSE;
        ORKAVEC_Vector_t *recordVector = tableHandle->records;
        ORKADB_RecordHandle_t **entryHandles = ( ORKADB_RecordHandle_t ** )( recordVector->vector );
        //ORKADB_DBG_PRINTF( "RecordListCreate: %" PRId64 " entries\n", recordVector->curIndex );
        for ( uint64_t i = 0; i < recordVector->curIndex; ++i )
        {
            bool_t cmpRes = FALSE;
            ORKADB_RecordHandle_t *record = entryHandles[ i ];
            //ORKADB_DBG_PRINTF( "Record.recordUniqueID: %" PRId64 "\n", record->recordUniqueID );
            //ORKADB_DBG_PRINTF( "Record.recordIndex:    %" PRId64 "\n", record->recordIndex );
            //ORKADB_DBG_PRINTF( "Record.recordData:     0x%p\n", record->recordData );
            fieldAddr = &(( char * )( record->recordData ))[ fieldHandle->fieldOffsetInRecord ];
            switch ( fieldHandle->fieldType )
            {
                default:
                case ORKADB_FieldType_UnknownPointer:
                case ORKADB_FieldType_Table:
                case ORKADB_FieldType_ValueI24:
                case ORKADB_FieldType_ValueU24:
                    // not supported yet
                    break;
                case ORKADB_FieldType_ValueI8:
                    cmpRes = ( *( ( int8_t * ) searchData ) == *( ( int8_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueU8:
                    cmpRes = ( *( ( uint8_t * ) searchData ) == *( ( uint8_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueI16:
                    cmpRes = ( *( ( int16_t * ) searchData ) == *( ( int16_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueU16:
                    cmpRes = ( *( ( uint16_t * ) searchData ) == *( ( uint16_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueI32:
                    cmpRes = ( *( ( int32_t * ) searchData ) == *( ( int32_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueU32:
                    cmpRes = ( *( ( uint32_t * ) searchData ) == *( (uint32_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueI64:
                    cmpRes = ( *( ( int64_t * ) searchData ) == *( ( int64_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueU64:
                    cmpRes = ( *( ( uint64_t * ) searchData ) == *( ( uint64_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueF32:
                    cmpRes = ( *( ( float32_t * ) searchData ) == *( ( float32_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_ValueF64:
                    cmpRes = ( *( ( float64_t * ) searchData ) == *( ( float64_t * ) fieldAddr ) );
                    break;
                case ORKADB_FieldType_StringC:
                    cmpRes = ( 0 == StringCompareTemplate( *( ( char ** ) fieldAddr ), ( char * ) searchData ) );
                    break;
            }
            if ( cmpRes )
            {
                if ( !alreadyInitialized )
                {
                    rv = ORKAVEC_Create( sizeof( ORKADB_RecordHandle_t ));
                    alreadyInitialized = TRUE;
                }
                if ( rv )
                {
                    ORKAVEC_PushBack( rv, record );
                }
            }
        }
    }
    return rv;
}

// this function returns the address of the field in the record.
// Attention: In some cases there is a pointer stored. So one has
// to interpret this return value as a pointer to a pointer.
// For strings or tables for example ...
// char *string = *(( char ** )ORKADB_RecordGetFieldAddrByHandle(...));
void *
ORKADB_RecordGetFieldAddrByHandle( ORKADB_RecordHandle_t *record, ORKADB_FieldHandle_t *field )
{
    void *rv = NULL;
    if ( record && field )
    {
        if ( record->recordData )
        {
            // Get ADDRESS (not content) of the field
            rv = ( void * ) &( ( char * ) ( record->recordData ) )[ field->fieldOffsetInRecord ];
        }
    }
    return rv;
}

void
ORKADB_RecordListDestroy( ORKAVEC_Vector_t *recordListCreate )
{
    recordListCreate = recordListCreate;
}

static void
ORKADB_TableDumpHeadline( ORKADB_TableHandle_t *tableHandle )
{
    if ( tableHandle )
    {
        ORKAVEC_Vector_t *fields = tableHandle->fields;
        uint64_t numFields = ORKAVEC_Size( fields );
        for ( uint64_t j = 0; j < numFields; ++j )
        {
            ORKADB_FieldHandle_t **fieldHandle = ( ORKADB_FieldHandle_t ** ) ORKAVEC_GetAt( fields, j );
            if ( fieldHandle )
            {
                if ( *fieldHandle )
                {
                    switch ( ( *fieldHandle )->fieldType )
                    {
                        default:
                        case ORKADB_FieldType_ValueI24:
                        case ORKADB_FieldType_ValueU24:
                        case ORKADB_FieldType_ValueI8:
                        case ORKADB_FieldType_ValueU8:
                        case ORKADB_FieldType_ValueI16:
                        case ORKADB_FieldType_ValueU16:
                        case ORKADB_FieldType_ValueI32:
                        case ORKADB_FieldType_ValueU32:
                            ORKADB_DBG_PRINTF_INT( "%-10.10s, ", ( *fieldHandle )->fieldName );
                            break;
                        case ORKADB_FieldType_UnknownPointer:
                        case ORKADB_FieldType_Table:
                        case ORKADB_FieldType_ValueI64:
                        case ORKADB_FieldType_ValueU64:
                            ORKADB_DBG_PRINTF_INT( "%-18.18s, ", ( *fieldHandle )->fieldName );
                            break;
                        case ORKADB_FieldType_ValueF32:
                        case ORKADB_FieldType_ValueF64:
                            ORKADB_DBG_PRINTF_INT( "%-11.11s, ", ( *fieldHandle )->fieldName );
                            break;
                        case ORKADB_FieldType_StringC:
                            ORKADB_DBG_PRINTF_INT( "%-60.60s, ", ( *fieldHandle )->fieldName );
                            break;
                    }
                }
            }
        }
        ORKADB_DBG_PRINTF_INT( "\n" );
    }
}

static void
ORKADB_RecordDumpInternal( ORKADB_RecordHandle_t *record )
{
    if ( record )
    {
        ORKADB_TableHandle_t *tableHandle = record->tableHandle;
        ORKAVEC_Vector_t *fields = tableHandle->fields;
        uint64_t numFields = ORKAVEC_Size( fields );

        for ( uint64_t j = 0; j < numFields; ++j )
        {
            ORKADB_FieldHandle_t **fieldHandle = ( ORKADB_FieldHandle_t ** ) ORKAVEC_GetAt( fields, j );
            if ( fieldHandle )
            {
                if ( *fieldHandle )
                {
                    //ORKADB_DBG_PRINTF( "%s, ", fieldHandle->fieldName );
#ifdef ORKADB_DBG_PRINTF_AVAILABLE
                    void *fieldAddr = &( ( char * ) ( record->recordData ) )[ ( *fieldHandle )->fieldOffsetInRecord ];
#endif
                    switch ( ( *fieldHandle )->fieldType )
                    {
                        default:
                        case ORKADB_FieldType_UnknownPointer:
                        case ORKADB_FieldType_Table:
                        case ORKADB_FieldType_ValueI24:
                        case ORKADB_FieldType_ValueU24:
                            ORKADB_DBG_PRINTF_INT( "0x%p, ", *( ( void ** ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI8:
                            ORKADB_DBG_PRINTF_INT( "      0x%2.2x, ", *( ( int8_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU8:
                            ORKADB_DBG_PRINTF_INT( "      0x%2.2x, ", *( ( uint8_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI16:
                            ORKADB_DBG_PRINTF_INT( "    0x%4.4x, ", *( ( int16_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU16:
                            ORKADB_DBG_PRINTF_INT( "    0x%4.4x, ", *( ( uint16_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI32:
                            ORKADB_DBG_PRINTF_INT( "0x%8.8x, ", *( ( int32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU32:
                            ORKADB_DBG_PRINTF_INT( "0x%8.8x, ", *( ( uint32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueI64:
                            ORKADB_DBG_PRINTF_INT( "0x%16.16" PRIx64 ", ", *( ( int64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueU64:
                            ORKADB_DBG_PRINTF_INT( "0x%16.16" PRIx64 ", ", *( ( int64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueF32:
                            ORKADB_DBG_PRINTF_INT( "%-7.3f, ", *( ( float32_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_ValueF64:
                            ORKADB_DBG_PRINTF_INT( "%-7.3f, ", *( ( float64_t * ) fieldAddr ) );
                            break;
                        case ORKADB_FieldType_StringC:
                            ORKADB_DBG_PRINTF_INT( "%-60.60s, ", *( ( char ** ) fieldAddr ) );
                            break;
                    }
                }
            }
        }
        ORKADB_DBG_PRINTF_INT( "\n" );
    }
}

void
ORKADB_RecordDump( ORKADB_RecordHandle_t *record )
{
    if ( record )
    {
        ORKADB_TableHandle_t *tableHandle = record->tableHandle;

        ORKADB_DBG_PRINTF( "==================================================================\n" );
        ORKADB_DBG_PRINTF( "RecordDump (Table: %s, UniqueID: %" PRId64 ", Index: %" PRId64 "):\n",
            tableHandle->tableName,
            record->recordUniqueID,
            record->recordIndex );

        ORKADB_TableDumpHeadline( tableHandle );
        ORKADB_RecordDumpInternal( record );
        ORKADB_DBG_PRINTF( "==================================================================\n" );
    }
}

void
ORKADB_TableHandleDump(
    ORKADB_TableHandle_t *tableHandle )
{
#ifdef ORKADB_DBG_PRINTF_AVAILABLE
    if ( tableHandle )
    {
        ORKAVEC_Vector_t *recordVector = tableHandle->records;
        ORKADB_DBG_PRINTF( "\n" );
        ORKADB_DBG_PRINTF( "************************************\n" );
        ORKADB_DBG_PRINTF( "TableDump: '%s'\n", tableHandle->tableName );
        if ( recordVector )
        {
            ORKADB_RecordHandle_t **entryHandles = ( ORKADB_RecordHandle_t ** ) ( recordVector->vector );
            if ( entryHandles )
            {
                uint64_t numRecords = recordVector->curIndex;
                ORKADB_DBG_PRINTF( "TableDump: %s (%" PRId64 " entries, address: 0x%p)\n", tableHandle->tableName, numRecords, tableHandle );

                ORKADB_TableDumpHeadline( tableHandle );

                for ( uint64_t i = 0; i < numRecords; ++i )
                {
                    ORKADB_RecordHandle_t *record = entryHandles[ i ];
                    ORKADB_RecordDumpInternal( record );
                }
            }
            else
            {
                ORKADB_DBG_PRINTF( "TableDump: Error: No entries!\n" );
            }
        }
        else
        {
            ORKADB_DBG_PRINTF( "TableDump: Error: No records!\n" );
        }
        ORKADB_DBG_PRINTF( "************************************\n\n" );
    }
#endif
}

void
ORKADB_TableDump(
    ORKADB_DBHandle_t *databaseHandle,
    char *tableName )
{
    if ( databaseHandle &&
         tableName )
    {
        ORKADB_TableHandle_t *tableHandle = ORKADB_TableHandleGet( databaseHandle, tableName );
        ORKADB_TableHandleDump( tableHandle );
    }
}

#if 0
static void
writeDB()
{
    ORKADB_DBHandle_t *dataBaseTmp = ORKAGD_DBCreate( "TestDatabaseTmp" );
    ORKADB_DBHandle_t *dataBase = ORKAGD_DBCreate( "TestDatabase" );
    ORKADB_TableHandle_t *table1 = ORKADB_TableCreate( dataBase, "xilinx" );

    ORKADB_FieldHandle_t *field1 = ORKADB_FieldCreate( table1, "boardname", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
    ORKADB_FieldHandle_t *field2 = ORKADB_FieldCreate( table1, "fpganr", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
    ORKADB_FieldHandle_t *field3 = ORKADB_FieldCreate( table1, "pcibarnr", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );
    ORKADB_FieldHandle_t *field4 = ORKADB_FieldCreate( table1, "pcibartype", ORKADB_FieldType_StringC, ORKADB_FieldOption_Nothing );
    ORKADB_FieldHandle_t *field5 = ORKADB_FieldCreate( table1, "pcibarsize", ORKADB_FieldType_ValueU64, ORKADB_FieldOption_Nothing );

    ORKADB_RecordHandle_t *record1 = ORKADB_RecordCreate( table1 );
    uint64_t fpgaNr = 4711;
    uint64_t barNr0 = 0;
    uint64_t barSize0 = 0x0000000020000000ULL;
    ORKADB_EntryFieldValueSetCopy( record1, field1, ( void * ) "Xilinx_VCU118_PCIE" );
    ORKADB_EntryFieldValueSetCopy( record1, field2, ( void * ) &fpgaNr );
    ORKADB_EntryFieldValueSetCopy( record1, field3, ( void * ) &barNr0 );
    ORKADB_EntryFieldValueSetCopy( record1, field4, ( void * ) "MMIO" );
    ORKADB_EntryFieldValueSetCopy( record1, field5, ( void * ) &barSize0 );

    ORKADB_RecordHandle_t *record2 = ORKADB_RecordCreate( table1 );
    uint64_t barNr1 = 1;
    uint64_t barSize1 = 0x0000000004000000ULL;
    ORKADB_EntryFieldValueSetCopy( record2, field1, ( void * ) "INTEL_ABC123" );
    ORKADB_EntryFieldValueSetCopy( record2, field2, ( void * ) &fpgaNr );
    ORKADB_EntryFieldValueSetCopy( record2, field3, ( void * ) &barNr1 );
    ORKADB_EntryFieldValueSetCopy( record2, field4, ( void * ) "DMA" );
    ORKADB_EntryFieldValueSetCopy( record2, field5, ( void * ) &barSize1 );

    ORKADB_RecordHandle_t *record3 = ORKADB_RecordCreate( table1 );
    uint64_t barNr2 = 1;
    uint64_t barSize2 = 0x0000000004000000ULL;
    ORKADB_EntryFieldValueSetCopy( record3, field1, ( void * ) "Xilinx_VCU108_PCIE" );
    ORKADB_EntryFieldValueSetCopy( record3, field2, ( void * ) &fpgaNr );
    ORKADB_EntryFieldValueSetCopy( record3, field3, ( void * ) &barNr2 );
    ORKADB_EntryFieldValueSetCopy( record3, field4, ( void * ) "DMA" );
    ORKADB_EntryFieldValueSetCopy( record3, field5, ( void * ) &barSize2 );

    char **name = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( record3, field1 );
    ORKADB_DBG_PRINTF( "Name: %s\n", *name );

    // ============================

    ORKADB_DBHandle_t *dataBase2 = ORKAGD_DBOpen( "TestDatabase" );
    ORKADB_TableHandle_t *table2 = ORKADB_TableHandleGet( dataBase2, "xilinx" );

    ORKADB_FieldHandle_t *fieldNew1 = ORKADB_FieldOpen( table2, "boardname" );
    ORKADB_FieldHandle_t *fieldNew2 = ORKADB_FieldOpen( table2, "fpganr" );
    ORKADB_FieldHandle_t *fieldNew3 = ORKADB_FieldOpen( table2, "pcibarnr" );
    ORKADB_FieldHandle_t *fieldNew4 = ORKADB_FieldOpen( table2, "pcibartype" );
    ORKADB_FieldHandle_t *fieldNew5 = ORKADB_FieldOpen( table2, "pcibarsize" );
}

static void
readDB()
{
    ORKADB_DBHandle_t *dataBase = ORKAGD_DBOpen( "TestDatabase" );
    ORKADB_TableHandle_t *table1 = ORKADB_TableHandleGet( dataBase, "xilinx" );
    ORKADB_FieldHandle_t *field1 = ORKADB_FieldOpen( table1, "boardname" );
    ORKAVEC_Vector_t *recordList = ORKADB_RecordListCreate( table1, field1, "Xilinx_VCU1?8_PCIE" );
    ORKAVEC_Iter_t *iter = ORKAVEC_IterCreate( recordList );
    uint32_t idx = 0;
    for ( void *i = ORKAVEC_IterBegin( iter ); ORKAVEC_IterEnd( iter ); i = ORKAVEC_IterNext( iter ) )
    {
        char **name = ( char ** ) ORKADB_RecordGetFieldAddrByHandle( i, field1 ); // get back a pointer to the string-pointer
        ORKADB_DBG_PRINTF( "Board#%d: %s\n", idx, *name );
        idx++;
    }
    OKAVEC_IterDestroy( iter );
    ORKADB_RecordListDestroy( recordList );
}

int
main7()
{
    ORKADB_DBG_PRINTF( "ORKADB Test\n" );
    writeDB();
    readDB();

    return 0;
}
#endif
