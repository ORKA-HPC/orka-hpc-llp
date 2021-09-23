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
if [[ "$#" -ne 2 ]]; then
    echo "Wrong Number of Arguments. Usage: 'add-persona.sh PERSONA_NAME HLS_PROJECT_DIR'"
fi
PERSONA_NAME="$1"
HLS_PROJECT_DIR="$2"

#Check if variables are set
if [[ -z $PROJECT_DEST_DIR \
        || -z $TEMPLATE_DIR \
        || -z $TEMPLATE_PROJECT \
        || -z $TEMPLATE_PROJECT_NAME \
        || -z $TEMPLATE_QSF_FILENAME ]]; then
    echo "ERROR: Variables not set."
fi

#Add Template Files
PRD="${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}"
PSD="${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/source"
cp "${TEMPLATE_DIR}/${TEMPLATE_QSF_FILENAME}" "${PRD}/${PERSONA_NAME}.qsf"
mkdir -p "${PSD}/${PERSONA_NAME}"
cp -R "${TEMPLATE_DIR}/${TEMPLATE_HLS}/." "${PSD}/${PERSONA_NAME}/"
mv "${PSD}/${PERSONA_NAME}/ip/local_qsys/local_qsys_PERSONA_NAME_internal_0.ip" "${PSD}/${PERSONA_NAME}/ip/local_qsys/local_qsys_${PERSONA_NAME}_internal_0.ip"

#Change Paths in {PERSONA_NAME}.qsf
#TODO change project name (top level entity) as well if necessary
echo "Replacing placeholders in QSF and QSYS"
sed -i -e "s/PERSONA_NAME/${PERSONA_NAME}/g" "${PRD}/${PERSONA_NAME}.qsf"
sed -i -e "s;HLS_PROJECT_DIR;${HLS_PROJECT_DIR};g" "${PRD}/${PERSONA_NAME}.qsf"
sed -i -e "s;TLF_NAME;${PERSONA_NAME};g" "${PSD}/${PERSONA_NAME}/local_qsys.qsys"
sed -i -e "s;PERSONA_NAME;${PERSONA_NAME};g" "${PSD}/${PERSONA_NAME}/ip/local_qsys/local_qsys_${PERSONA_NAME}_internal_0.ip"

#TODO change persona ID
# Start Quartus with the default qpf file. Start the Platform Deisgner. Open the  Platform Designer system source/basic_hls2_persona/local_qsys.qsys
# Change the value of the sysid_qsys_0 which stores the Persona ID. Change the value to 0xfeedaffe.

#manually add revision
QPF="${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/${TEMPLATE_PROJECT_NAME}.qpf"
if ! grep -q "PROJECT_REVISION = \"${PERSONA_NAME}\"" "${QPF}"; then
    echo -e "\nPROJECT_REVISION = \"${PERSONA_NAME}\"" >> "${QPF}"
fi

pushd .
cd ${PRD}
quartus_sh -t ${SCRIPTS_ROOT_DIR}/add-persona.tcl -PROJECT_NAME ${TEMPLATE_PROJECT_NAME} -PERSONA_NAME ${PERSONA_NAME} -HLS_PROJECT_DIR ${HLS_PROJECT_DIR}
popd
