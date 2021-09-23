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

#Path to Intel FPGA Software
INTEL_FPGA_DIR="/opt/intel/intelFPGA_pro/20.1"

#Destination for new project copy
PROJECT_DEST_DIR="./arria10inst"

#Path to template project
TEMPLATE_DIR="./base_designs"
TEMPLATE_PROJECT_DIR="${TEMPLATE_DIR}/arria10_v1"
TEMPLATE_HLS="hls_persona_template"
TEMPLATE_QSF_FILENAME="hls_persona_template.qsf"
TEMPLATE_PROJECT_NAME="a10_pcie_devkit_cvp"

#TODO arrays? what else do I need? cflags?
IP_NAMES=("testkernel0" "testkernel1")
IP_PRJ_DIR=("./testkernel0/hls1.prj" "./testkernel1/hls1.prj")

## DONT MODIFY BELOW THIS LINE #################################################
source scripts/init.sh

#TODO if static bitstream doesnt exist
if [[ ! -d ${PROJECT_DEST_DIR} ]]; then
    # Create new project
    source ./scripts/create-new-project-copy.sh

    # Compile static region
    source ./scripts/compile-static-region.sh
fi

# Create persona for each IP
for (( index=0; index<${#IP_NAMES[@]}; index++ ))
do
    abs_path="$(cd "${IP_PRJ_DIR[$index]}"; pwd -P)"
    echo "source ./scripts/add-persona.sh ${IP_NAMES[$index]} $abs_path"
    source ./scripts/add-persona.sh ${IP_NAMES[$index]} $abs_path

    # Compile persona (pr region)
    echo "source ./scripts/compile-pr-region.sh $PERSONA_NAME"
    source ./scripts/compile-pr-region.sh $PERSONA_NAME
done
