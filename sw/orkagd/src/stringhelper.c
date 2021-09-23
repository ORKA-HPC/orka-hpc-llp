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
#include "stringhelper.h"
#include "types.h"

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include <inttypes.h>

char *
StringCreate( const char *inputString )
{
    char *rv = NULL;
    if ( inputString )
    {
        size_t len = ( size_t ) strlen( inputString );
        len++; // trailling zero
        rv = malloc( len );
        if ( rv )
        {
            memcpy( ( void * ) rv, ( void * ) inputString, len );
        }
    }
    return rv;
}

void
StringDestroy( char *inputString )
{
    if ( inputString )
    {
        free( inputString );
    }
}

int
StringCompareSubstring( char *input, char *template )
{
    return -1;
}

int
StringCompareTemplate(
    const char *input,
    const char *template )
{
    //printf( "StringCompareTemplate: %s, %s\n", input, template );
    int rv = -1;
    if ( input && template )
    {
        size_t templateEnd = strlen( template );
        size_t inputEnd = strlen( input );
        size_t inputCurrent = 0;

        rv = 0;     // 0: string identical, -1: not
        char ci = 1;
        for ( size_t i = 0; ( 0 == rv ) && ( i < templateEnd ) && ci; ++i )
        {
            char ct = template[ i ];
            ci = input[ inputCurrent ];
            switch ( ct )
            {
                default:
                    if ( ct != ci )
                    {
                        rv = -1;
                        break;
                    }
                    break;
                case '?':
                    //rv = StringCompareTemplate( &input[ inputStart ], &template[ templateStart ]);
                    //if ( 0 == rv )
                    //{
                        // proceed behind '?'
                        i++;
                        // ignore characters of inputString if we stay on digits
                        inputCurrent++;
                        while ( ( input[ inputCurrent ] >= '0' ) && ( input[ inputCurrent ] <= '9' ) && ( inputCurrent < inputEnd ) )
                        {
                            inputCurrent++;
                        }
                    //}
                    break;
                //case '*':
                //    break;
            }
            inputCurrent++;
        }
    }
    //printf( "StringCompareTemplate: %d\n", rv );
    return rv;
}

int
StringCompareIgnoreCase(
    const char *input1,
    const char *input2 )
{
    int rv = -1;
    if ( input1 && input2 )
    {
        size_t input1Len = strlen( input1 );
        size_t input2Len = strlen( input2 );
        if ( input1Len == input2Len )
        {
            rv = 0;
            for ( size_t i = 0; i < input1Len; ++i )
            {
                char ci1 = ( char )tolower( *input1++ );
                char ci2 = ( char )tolower( *input2++ );
                if ( ci1 != ci2 )
                {
                    rv = -1;
                    break;
                }
            }
        }
    }
    return rv;
}

char *
StringGetFilenameFromPath(
    const char *pathAndFilename )
{
    char *c = strrchr( pathAndFilename, STRINGHELPER_DIR_SEPERATOR );
    if ( c )
    {
        c++;
    }
    return c;
}

char *
StringFindAndReplaceU64(
    const char *inputString,
    const char *searchString,
    const uint64_t replacement )
{
    char *rv = NULL;
    if ( inputString && searchString )
    {
        size_t l = strlen( inputString );
        size_t ls = strlen( searchString );
        for ( size_t i = 0; i < l; ++i )
        {
            char c = inputString[ i ];
            if ( c == searchString[ 0 ] )
            {
                bool_t found = TRUE;
                size_t j;
                for ( j = 1; j < ls; ++j )
                {
                    if ( j + i >= l )
                    {
                        break;
                    }
                    c = inputString[ i + j ];
                    char d = searchString[ j ];
                    if ( c != d )
                    {
                        found = FALSE;
                        break;
                    }
                }
                if ( found )
                {
                    char number[ 100 ];
                    memset(( void *) number, 0x00, 100 );
                    //itoa( ( int ) replacement, number, 10 );
                    snprintf( number, 100 - 1, "%" PRId64, replacement );
                    size_t ln = strlen( number );
                    rv = calloc( 1, l - ls + ln + 1 );

                    // copy identical prefix
                    memcpy( ( void * ) rv, inputString, i );
                    // copy in the number as ascii
                    memcpy( ( void * ) &rv[ i ], number, ln );
                    // copy tail behind macro to the end
                    memcpy( ( void * ) &rv[ i + ln ], ( void * ) ( &inputString[ i + ls ]), l - i - ls );
                    break;
                }
            }
        }
    }
    return rv;
}

// Creates a new string with contents of inputString1 and inputString2.
char *
StringAdd(
    const char *inputString1,
    const char *inputString2 )
{
    char *rv = NULL;
    if ( inputString1 && inputString2 )
    {
        size_t l1 = strlen( inputString1 );
        size_t l2 = strlen( inputString2 );
        size_t l = l1 + l2 + 1;
        rv = ( char * ) calloc( 1, l );
        if ( rv )
        {
            memcpy(( void * ) &rv[ 0 ],  ( void * ) inputString1, l1 );
            memcpy(( void * ) &rv[ l1 ], ( void * ) inputString2, l2 );
        }
    }
    return rv;
}

// Creates a new string with contents of inputString1 and inputString2.
// Destroys inputString1
char *
StringAddExt(
    char *inputString1,
    const char *inputString2 )
{
    char *rv = StringAdd( inputString1, inputString2 );
    if ( rv )
    {
        free(( void * ) inputString1 );
    }
    return rv;
}

char *
StringAddFilenameToPath(
    const char *path,
    const char *filename )
{
    char *rv = NULL;
    if ( path && filename )
    {
        size_t lp = strlen( path );
        if ( STRINGHELPER_DIR_SEPERATOR == path[ lp - 1 ] )
        {
            rv = StringAdd( path, filename );
        }
        else
        {
            char seperator[ 2 ];
            seperator[ 0 ] = STRINGHELPER_DIR_SEPERATOR;
            seperator[ 1 ] = 0;
            char *tmp = StringAdd( path, seperator );
            rv = StringAdd( tmp, filename );
            StringDestroy( tmp );
        }
    }
    return rv;
}

char *
StringAddFilenameToPathExt(
    char *path,
    const char *filename )
{
    char *rv = StringAddFilenameToPath( path, filename );
    if ( rv )
    {
        StringDestroy( path );
    }
    return rv;
}
