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

# Check if quartus, quartus_sh and quartus_cmd are in PATH
if ! { which quartus &> /dev/null \
        && which quartus_sh &> /dev/null \
        && which quartus_cmd &> /dev/null; } ; then
    # Check if a folder with 'quartus' in its name is already in PATH
    if ! echo $PATH| grep -q 'quartus'; then
        # Check if INTEL_FPGA_DIR is set
        if [[ -z ${INTEL_FPGA_DIR} ]]; then
            echo "Error: INTEL_FPGA_DIR not set. Please set it to your Quartus install dir."
            return 1
        fi
        #Add quartus bin
        PATH="$PATH:${INTEL_FPGA_DIR}/quartus/bin"
        #Add hls i++ bin
        PATH="$PATH:${INTEL_FPGA_DIR}/hls/bin"
#        #Add modelsim bin
#        PATH="$PATH:${INTEL_FPGA_DIR}/modelsim_ae/bin"
#        PATH="$PATH:${INTEL_FPGA_DIR}/modelsim_ase/bin"
    fi
    # Check if it worked
    if ! { which quartus &> /dev/null && which quartus_cmd &> /dev/null; } ; then
        echo "Error: Couldn't find quartus installation in expected location"
        echo "Please make sure that INTEL_FPGA_DIR is set correctly"
    fi

#    # Initialise the HLS Toolchain
#    source "${INTEL_FPGA_DIR}/hls/init_hls.sh"
fi
