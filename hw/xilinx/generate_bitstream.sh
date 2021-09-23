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
    echo "Please provide path to the output directory when you ran orka_hw_configurator!"
    exit 1
fi

# Read path to generated configuration files
config_dir=$1

vivado -mode batch -source "${root_path}/src/main.tcl" -tclargs "${root_path}" "${config_dir}"
