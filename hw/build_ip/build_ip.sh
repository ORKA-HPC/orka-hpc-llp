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

# Get path to source files (= path to this script)
root_path="`dirname \"$BASH_SOURCE\"`"
root_path="`( cd \"$root_path\" && pwd )`"
if [ -z "$root_path" ] ; then
      exit 1
fi

target_board="$1"
export_dir="$2"
src_dir="$3"
tlf="$4"
clock="$5"
flags="$6"
shift 6
sourcefiles=("$@")

export_dir="$(realpath $export_dir)"
src_dir="$(realpath $src_dir)"
mkdir -pv "$export_dir"

source "$root_path/board_support"
if [[ -z "$target_part" || -z "$part_vendor" ]]; then
    echo "Error: target_part not set. Board not supported?"
    exit 1
fi

# for xilinx/vivado: write to tcl file that will be read later
if [[ ! -z "$flags" ]]; then
    echo "set cflags \"$flags\"" > $export_dir/cflags.tcl
fi

if [ "$part_vendor" = "Xilinx" ]; then
    echo "Starting Xilinx Toolchain to build IP"
    [[ $(type -P "vitis_hls") ]] &&
        xilinx_hls="vitis_hls" ||
        { type -P "vivado_hls" &> /dev/null &&
            xilinx_hls="vivado_hls"; }
    if [[ -z "$xilinx_hls" ]]; then
        echo "ERROR: Neither vitis_hls nor vivado_hls in PATH. Aborting..."
        exit 1
    fi
    $xilinx_hls -f ${root_path}/xilinx.tcl -tclargs \
            "${root_path}" \
            "${target_board}" \
            "${target_part}" \
            "${export_dir}" \
            "${clock}" \
            "${src_dir}" \
            "${tlf}" \
            "${sourcefiles[@]}"

elif [ "$part_vendor" = "Intel" ]; then
    echo "Starting Intel Toolchain to build IP"
    source "${root_path}"/intel.sh
fi
