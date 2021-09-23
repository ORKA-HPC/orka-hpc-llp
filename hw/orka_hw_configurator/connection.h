/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
#pragma once

#include <iostream>
#include <ostream>
#include <vector>

#include "ip.h"

struct connection
{
    ip src;
    port srcp;
    ip dst;
    port dstp;

    connection(const ip& srcip, const port& srcport, const ip& dstip, const port& dstport)
        : src(srcip), srcp(srcport), dst(dstip), dstp(dstport) {}
};

struct connection_list
{
    std::vector<connection> list;

    void print()
    {
        for (auto& i : list)
        {
            std::cout 
                << i.src.name << ":"
                << i.srcp.name << " -> "
                << i.dst.name << ":"
                << i.dstp.name 
                << std::endl;
        }
    }

    void write_file(std::ostream& dst)
    {
        for (auto& i : list)
        {
            dst
                << "connect_bd_intf_net [get_bd_intf_pins " << i.src.name << "/" << i.srcp.name 
                << "] [get_bd_intf_pins " << i.dst.name << "/" << i.dstp.name << "]" 
                << std::endl;
        }
    }
};
