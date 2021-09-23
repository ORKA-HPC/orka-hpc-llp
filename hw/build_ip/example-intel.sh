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

target_board="arria10"
export_dir="./output_files"
src_dir="./ip_example_intel"
tlf="slavereg_comp"
clock="10ns"
sourcefiles="hls1.cpp"

INTEL_FPGA_DIR=/opt/inteldevstack/intelFPGA_pro/20.1/ source prepare_intel_tools.sh
LM_LICENSE_FILE=28518@lm-intel6.rrz.uni-koeln.de

./build_ip.sh $target_board \
    $export_dir \
    $src_dir \
    $tlf \
    $clock \
    $sourcefiles
