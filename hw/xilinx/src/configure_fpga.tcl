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
set bitstream_file [lindex $argv 0]

open_hw
connect_hw_server
open_hw_target
set device [lindex [get_hw_devices] 0]
current_hw_device [get_hw_devices $device]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $device] 0]
set_property PROBES.FILE {} [get_hw_devices $device]
set_property FULL_PROBES.FILE {} [get_hw_devices $device]
set_property PROGRAM.FILE ${bitstream_file} [get_hw_devices $device]
program_hw_devices [get_hw_devices $device]
refresh_hw_device [lindex [get_hw_devices $device] 0]
