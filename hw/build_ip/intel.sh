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

# Build HLS IP

pushd "${export_dir}"

# make array from sourcefile list
# (expecting array or space separated string)
# and then prepend src_dir to filenames
sourcefiles=(${sourcefiles[@]})
declare -a sfs=()
for f in "${sourcefiles[@]}"
do
    sfs+=("${src_dir}/${f}")
done

set -x
i++ -march=${target_part} \
    ${sfs[*]} \
    -I${src_dir} \
    ${flags[*]} \
    -ghdl -o fpga --simulator none
set +x

# Change component property "INTERNAL" from true to false
echo "Changing component property 'INTERNAL' from true to false."
#sed -i -e "s/INTERNAL true/INTERNAL false/g" "${f%.*}.prj/components/${tlf}/${tlf}_internal_hw.tcl"
sed -i -e "s/INTERNAL true/INTERNAL false/g" "fpga.prj/components/${tlf}/${tlf}_internal_hw.tcl"
# copy register header file
cp -f "fpga.prj/components/${tlf}/${tlf}_csr.h" "${export_dir}/reg_map"

popd
