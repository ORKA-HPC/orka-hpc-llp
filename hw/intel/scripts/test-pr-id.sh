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

# reconfigure the FPGA with the new persona:
DRIVER_DIR="../software/drivers/fpga_pcie"
${DRIVER_DIR}/fpga-configure -p ${PROJECT_DIR}/output_files/${PROJECT_NAME}_${PERSONA_NAME}.pr_partition.rbf 10000


# Update the example_host_uio in software/utils with the new Persona ID
# navigate to the software/utils folder and edit the example_host_uio.c
# add the following lines in the case statement at the end of the file:
#  case 0xfeedaffe:
#  ret = do_basic_HLS2(number_of_runs, verbose, fd);
#  break;
# search for the do_basic_HLS function  copy it to do_basic_HLS2 and modify the function for your needs. (At least  change the addition to multiplication for test result testing...)
# $ make
# $ /software/util/example_host_uio
# expected output:
#Persona ID: 0xFEEDAFFE
# This is Basic HLS2 Persona
#Beginning test 1 of 3
#Test 1 of 3 PASS
#Beginning test 2 of 3
#Test 2 of 3 PASS
#Beginning test 3 of 3
#Test 3 of 3 PASS
#HLS2 Arithmetic persona PASS
