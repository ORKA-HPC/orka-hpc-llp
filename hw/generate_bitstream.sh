#!/bin/bash
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
hw_dir="`dirname \"$BASH_SOURCE\"`"
hw_dir="`( cd \"$hw_dir\" && pwd )`"
if [ -z "$hw_dir" ] ; then
    exit 1
fi

if [[ "$#" -ne 1 ]] ; then
    echo "Please provide path to the output directory when you ran orka_hw_configurator!"
    exit 1
fi

# Read path to generated configuration files and make absolute path
config_dir="$(realpath "$1")"

vendor="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['vendor'])")"

shopt -s nocasematch
if [[ "$vendor" == "Xilinx" ]]; then
    shopt -u nocasematch
    source "$hw_dir/xilinx/generate_bitstream.sh" "$config_dir"
elif [[ "$vendor" == "Intel" ]]; then
    shopt -u nocasematch
    source "$hw_dir/intel/generate_bitstream.sh" "$config_dir"
else
    shopt -u nocasematch
    echo "Error: Unsupported Vendor: $vendor."
fi

# Merge HLS register maps into bitstream json
${hw_dir}/orka_hw_configurator/merge_json -settings="${config_dir}/settings.json"

# Export ORKAFPGAs.json and ORKAInterpreter.json to bitstream_export_dir dir
bed="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['bitstream_export_dir'])")"
cp -n "${hw_dir}/../sw/orkagd/src/orkadistro/ORKAFPGAs.json" "$bed"
cp -n "${hw_dir}/../sw/orkagd/src/orkadistro/ORKAInterpreter.json" "$bed"
