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

echo "performing pci rescan (needs root privileges)"

# Remove Intel FPGA
device_id="$(lspci -d1172: | head -n 1 | awk '{print substr($0,0,7)}')"
if [[ -z "$device_id" ]]; then
    echo 1 | sudo tee /sys/bus/pci/devices/0000\:${device_id}/remove
fi

# Remove Xilinx FPGA
device_id="$(lspci -d10ee: | head -n 1 | awk '{print substr($0,0,7)}')"
if [[ -z "$device_id" ]]; then
    echo 1 | sudo tee /sys/bus/pci/devices/0000\:${device_id}/remove
fi

# Rescan
echo 1 | sudo tee /sys/bus/pci/rescan

# List info
sudo lspci -vvvd1172:
sudo lspci -vvvd10ee:
