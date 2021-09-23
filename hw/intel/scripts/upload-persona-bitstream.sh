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

#Get Persona Name from args
if [[ "$#" -ne 1 ]]; then
    echo "Wrong Number of Arguments. Please run with PERSONA_NAME as argument."
fi
PERSONA_NAME="$1"

if [[ "${PERSONA_NAME}" = "default" ]]; then
    echo "reconfiguring pr-zone with default persona"
    #Reconfigure the FPGA with the default persona
    ../software/drivers/fpga_pcie/fpga-configure -p ${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/a10_pcie_devkit_cvp.local_qsys.rbf 10000
elif [[ "${PERSONA_NAME}" = "debug" ]]; then
    echo "reconfiguring pr-zone with debug persona a10_pcie_devkit_cvp_basic_hls3"
    #Reconfigure the FPGA with the hls1 persona
    ../software/drivers/fpga_pcie/fpga-configure -p ${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/a10_pcie_devkit_cvp_basic_hls3.local_qsys.rbf 10000
else
    file="${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/${PERSONA_NAME}.local_qsys.rbf"
    if [[ -f "${file}" ]]; then
        echo "reconfiguring pr-zone with ${PERSONA_NAME} persona"
        #Reconfigure the FPGA with the hls1 persona
        ../software/drivers/fpga_pcie/fpga-configure -p ${file} 10000
    else
        echo "ERROR: rbf file not found"
    fi
fi


##check with example_host_uio if the correct persona is loaded.
#../software/ref_designs/Q19.3_a10_pcie_devkit_cvp/software/util/example_host_uio 
