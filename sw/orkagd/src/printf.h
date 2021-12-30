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

#ifndef PRINTF_H__
#define PRINTF_H__

/*
 * Change how many messages will be printed.
 *
 * Valid values are:
 *  0: Mute
 *  1: Errors only
 *  2: Verbose
*/
#define ORKAGD_VERBOSITY 2
#define ORKADB_VERBOSITY 2
#define ORKATCP_VERBOSITY 2

// printf available?
#define ORKAGD_PRINTF_AVAILABLE
#define ORKADB_PRINTF_AVAILABLE
#define ORKATCP_PRINTF_AVAILABLE

// set verbosity to 0 if printf is not availble
#ifndef ORKAGD_PRINTF_AVAILABLE
#define ORKAGD_VERBOSITY 0
#endif // ORKAGD_DBG_PRINTF_AVAILABLE
#ifndef ORKADB_PRINTF_AVAILABLE
#define ORKADB_VERBOSITY 0
#endif // ORKADB_DBG_PRINTF_AVAILABLE
#ifndef ORKATCP_PRINTF_AVAILABLE
#define ORKATCP_VERBOSITY 0
#endif // ORKAGD_PRINTF_AVAILABLE

// ORKAGD_DBG_PRINTF
#define ORKAGD_DBG_PRINTF( ... ) \
    do { if (ORKAGD_VERBOSITY == 2) fprintf( stdout, " ORKAGD: " __VA_ARGS__ ); } while (0)
// ORKAGD_DBG_PRINTF_INT
#define ORKAGD_DBG_PRINTF_INT( ... ) \
    do { if (ORKAGD_VERBOSITY == 2) fprintf( stdout, __VA_ARGS__ ); } while (0)
// ORKAGD_ERR_PRINTF
#define ORKAGD_ERR_PRINTF( ... ) \
    do { if (ORKAGD_VERBOSITY >= 1) fprintf( stderr, __VA_ARGS__ ); } while (0)

// ORKADB_DBG_PRINTF
#define ORKADB_DBG_PRINTF( ... ) \
    do { if (ORKADB_VERBOSITY == 2) fprintf( stdout, " ORKADB: " __VA_ARGS__ ); } while (0)
// ORKADB_DBG_PRINTF_INT
#define ORKADB_DBG_PRINTF_INT( ... ) \
    do { if (ORKADB_VERBOSITY == 2) fprintf( stdout, __VA_ARGS__ ); } while (0)
// ORKADB_ERR_PRINTF
#define ORKADB_ERR_PRINTF( ... ) \
    do { if (ORKADB_VERBOSITY >= 1) fprintf( stderr, __VA_ARGS__ ); } while (0)

// ORKATCP_DBG_PRINTF
#define ORKATCP_DBG_PRINTF( fmt, ... ) \
    do { if (ORKATCP_VERBOSITY == 2) fprintf( stdout, "ORKATCP: [%d]%s(): " fmt, __LINE__, __func__, ##__VA_ARGS__ ); } while (0)
// ORKATCP_ERR_PRINTF
#define ORKATCP_ERR_PRINTF( fmt, ... ) \
    do { if (ORKATCP_VERBOSITY >= 1) fprintf( stderr, "ORKATCP: [%d]%s(): " fmt, __LINE__, __func__, ##__VA_ARGS__ ); } while (0)


#endif // PRINTF_H__
