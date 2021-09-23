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
#ifndef STRINGHELPER_H__
#define STRINGHELPER_H__

#include <stdint.h>

#ifdef _MSC_VER
#define STRINGHELPER_DIR_SEPERATOR       ( '\\' )
#define STRINGHELPER_DIRECTORY_CURRENT   ( ".\\" )
#define STRINGHELPER_DIR_SEPERATOR_OTHER ( '/' )
#else
#define STRINGHELPER_DIR_SEPERATOR       ( '/' )
#define STRINGHELPER_DIRECTORY_CURRENT   ( "./" )
#define STRINGHELPER_DIR_SEPERATOR_OTHER ( '\\' )
#endif

char *StringCreate( const char *inputString );
void StringDestroy( char *inputString );
int StringCompareTemplate( const char *input, const char *template );
int StringCompareIgnoreCase( const char *input1, const char *input2 );
char *StringFindAndReplaceU64( const char *inputString, const char *searchString, const uint64_t replacement );
char *StringAdd( const char *inputString1, const char *inputString2 );
char *StringAddExt( char *inputString1, const char *inputString2 );
char *StringGetFilenameFromPath( const char *pathAndFilename );
char *StringAddFilenameToPath( const char *path, const char *filename );
char *StringAddFilenameToPathExt( char *path, const char *filename );
#endif
