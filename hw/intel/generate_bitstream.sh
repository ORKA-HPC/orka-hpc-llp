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
root_path="`dirname \"$BASH_SOURCE\"`"
root_path="`( cd \"$root_path\" && pwd )`"
if [ -z "$root_path" ] ; then
    exit 1
fi

if [[ $# -ne 1 ]] ; then
    echo "ERROR: Wrong number of args!"
    exit 1
fi

# Read path to generated configuration files
config_dir=$1

PROJECT_DEST_DIR="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['design_dir'])")"
TEMPLATE_DIR="${root_path}/base_designs"
TEMPLATE_HLS="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['template_persona'])")"
TEMPLATE_QSF_FILENAME="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['template_persona_qsf'])")"
TEMPLATE_PROJECT="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['template_project'])")"
TEMPLATE_PROJECT_NAME="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['template_project_name'])")"
BITSTREAM_EXPORT_DIR="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['bitstream_export_dir'])")"
BITSTREAM_FILENAME="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['bitstream_filename'])")"
JSON_FILENAME="$(python3 -c "import sys, json; print(json.load(open('${config_dir}/settings.json'))['json_filename'])")"

# Read IP Names and Paths from ips.json
IP_NAMES="$(python3 -c "import sys, json; [print(i['name'] + ' ') for i in (json.load(open('${config_dir}/ips.json'))['ips'])];")"
IP_PATHS="$(python3 -c "import sys, json; [print(i['path'] + ' ') for i in (json.load(open('${config_dir}/ips.json'))['ips'])];")"
IP_NAMES=($IP_NAMES)
IP_PATHS=($IP_PATHS)
declare -a IP_PRJ_DIR
for p in "${IP_PATHS[@]}"
do
    IP_PRJ_DIR+="${p}/fpga.prj/"
done

## DONT MODIFY BELOW THIS LINE #################################################
source ${root_path}/scripts/init.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Only run if static bitstream doesnt exist
if [[ ! -f ${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/${TEMPLATE_PROJECT_NAME}.sof ]]; then
    # Create new project
    source ${root_path}/scripts/create-new-project-copy.sh

    # Only run if static bitstream doesnt exist
    if [[ ! -f ${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/${TEMPLATE_PROJECT_NAME}.sof ]]; then
        # Compile static region
        source ${root_path}/scripts/compile-static-region.sh
    fi

    # Copy static bitstream and JSON to bitstream_export_dir
    #TODO add 'force' option and only overwrite files if it is set...
    mkdir -p "${BITSTREAM_EXPORT_DIR}"
    cp "${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/${TEMPLATE_PROJECT_NAME}.sof" "${BITSTREAM_EXPORT_DIR}/${BITSTREAM_FILENAME}"
    cp "${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/${TEMPLATE_PROJECT_NAME}.json" "${BITSTREAM_EXPORT_DIR}/${JSON_FILENAME}"
    # change bitstream filename in json file
    sed -i -e "s/a10_pcie_devkit_cvp.sof/${BITSTREAM_FILENAME}/g" "${BITSTREAM_EXPORT_DIR}/${JSON_FILENAME}"
fi

# Create persona for each IP
for (( index=0; index<${#IP_NAMES[@]}; index++ ))
do
    abs_path="$(cd "${IP_PRJ_DIR[$index]}"; pwd -P)"
    source ${root_path}/scripts/add-persona.sh ${IP_NAMES[$index]} $abs_path

    # Compile persona (pr region)
    source ${root_path}/scripts/compile-pr-region.sh ${IP_NAMES[$index]}

    # Copy pr bitstream to bitstream_export_dir
    #TODO add 'force' option and only overwrite files if it is set...
    cp "${PROJECT_DEST_DIR}/${TEMPLATE_PROJECT_NAME}/output_files/${IP_NAMES[$index]}.local_qsys.rbf" "${BITSTREAM_EXPORT_DIR}/"

    # Extend JSON with component info:
	JSONFILE="${BITSTREAM_EXPORT_DIR}/${JSON_FILENAME}"
	CNAME="${IP_NAMES[$index]}"
	COFFSET="0x00000100"
	CRANGE="0x00001000"
	python3 - <<EOF
import sys, json
f = open("$JSONFILE", "r")
j = json.load(f)
es = """{
    "name":"$CNAME",
    "offset":"$COFFSET",
    "range":"$CRANGE"
}"""
e = json.loads(es)
j["FPGAs"][0]["Components"].append(e)
f = open("$JSONFILE", "w")
json.dump(j, f, ensure_ascii=False, indent=4)
EOF

done


