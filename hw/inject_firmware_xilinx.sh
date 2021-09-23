#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

root_path="`dirname \"$BASH_SOURCE\"`"
root_path="`( cd \"$root_path\" && pwd )`"
if [ -z "$root_path" ] ; then
    exit 1
fi

DESIGN_DIR=.
ELF_BINARY_FILE=
BITSTREAM_FILE=bitstream.bit
OUT_BITSTREAM_FILE=bitstream.bit
BACKUP_BITSTREAM_FILE="${BITSTREAM_FILE//.bit}_backup.bit"
# "${4:-}"

while [ "${1:-}" != "" ]; do
    case "$1" in
        "--firmware-file" | "-f")
            shift
            ELF_BINARY_FILE="$1"
        ;;
        "--show-firmwares")
            ls "${root_path}"/xilinx/firmware
            exit 0
        ;;
        "--bitstream-file")
            shift
            BITSTREAM_FILE="$1"
        ;;
        "--design-dir")
            shift
            DESIGN_DIR="$1"
        ;;
    esac
    shift
done

function backupBitstream() {
    echo Save old bitstream
    cp "$BITSTREAM_FILE" "$BACKUP_BITSTREAM_FILE"
}

function injectFirmware() {
    echo Running with parameters:
    echo DESIGN_DIR="$DESIGN_DIR"
    echo ELF_BINARY_FILE="$ELF_BINARY_FILE"
    echo BITSTREAM_FILE="$BITSTREAM_FILE"
    echo BACKUP_BITSTREAM_FILE="$BACKUP_BITSTREAM_FILE"

    "${root_path}/xilinx/inject_microblaze_elf.sh" \
        "${DESIGN_DIR}" "${ELF_BINARY_FILE}" \
        "${BITSTREAM_FILE}" "${BITSTREAM_FILE}"
}

backupBitstream
injectFirmware
