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

#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <vector>

#include <nlohmann/json.hpp>
#include <tinyxml2.h>

//static unsigned instance_index = 0;

enum class porttype { unknown = -1, aximm, axis, reset, clock, interrupt, bram, acc_fifo_read, acc_fifo_write };
enum class portdirection { other = -1, master, slave };

struct port
{
    porttype type;
    portdirection direction;
    std::string name;
    bool taken;

    port() {}

    port(porttype t, portdirection d, std::string n)
        : type(t), direction(d), name(n), taken(false) {}
};

struct ip
{
    using json = nlohmann::json;

    std::string name;
    std::string name_from_xml;
    std::string vlnv;
    std::string path;
    std::string clock;
    std::string reg_map_file;
    std::string vendor;
    json reg_map_json;
    std::vector<port> ports;
    int przone = -1;
    int pralternative = -1;

    void print_ports(std::ostream& dst)
    {
        for (auto p : ports)
            dst << name << ":"
                << p.name << ":"
                << static_cast<typename std::underlying_type<porttype>::type>(p.type)
                << std::endl;
    }

    void readXML(const std::string& file)
    {
        tinyxml2::XMLDocument components;
        components.LoadFile(file.c_str());
        if (components.ErrorID())
        {
            std::cerr << "Error " << components.ErrorID() << ". Unable to load file: " << file << std::endl;
            throw std::runtime_error("READ ERROR");
        }

        tinyxml2::XMLElement* cmp = components.FirstChildElement("spirit:component");
        std::string vendor(cmp->FirstChildElement("spirit:vendor")->FirstChild()->ToText()->Value());
        std::string library(cmp->FirstChildElement("spirit:library")->FirstChild()->ToText()->Value());
        std::string name(cmp->FirstChildElement("spirit:name")->FirstChild()->ToText()->Value());
        std::string version(cmp->FirstChildElement("spirit:version")->FirstChild()->ToText()->Value());
        vlnv = vendor + ":" + library + ":" + name + ":" + version;
//        name_from_xml = name + std::to_string(instance_index++);
        name_from_xml = name;

        tinyxml2::XMLElement* bus = cmp->FirstChildElement("spirit:busInterfaces")->FirstChildElement("spirit:busInterface");
        while (bus != nullptr)
        {
            std::string bustype(bus->FirstChildElement("spirit:busType")->Attribute("spirit:name"));
            porttype t = porttype::unknown;
            portdirection d = portdirection::other;
            if (bustype == "aximm")
            {
                t = porttype::aximm;
                tinyxml2::XMLElement* direction = bus->FirstChildElement("spirit:master");
                if (direction != nullptr)
                    d = portdirection::master;
                else
                    d = portdirection::slave;
            }else if (bustype == "axis")
            {
                t = porttype::axis;
                tinyxml2::XMLElement* direction = bus->FirstChildElement("spirit:master");
                if (direction != nullptr)
                    d = portdirection::master;
                else
                    d = portdirection::slave;
            }else if (bustype == "reset")
            {
                t = porttype::reset;
                d = portdirection::other;
            }else if (bustype == "clock")
            {
                t = porttype::clock;
                d = portdirection::other;
            }else if (bustype == "interrupt")
            {
                t = porttype::interrupt;
                d = portdirection::other;
            }else if (bustype == "bram")
            {
                t = porttype::bram;
                d = portdirection::other;
            }else if (bustype == "acc_fifo_read")
            {
                t = porttype::acc_fifo_read;
                d = portdirection::other;
            }else if (bustype == "acc_fifo_write")
            {
                t = porttype::acc_fifo_write;
                d = portdirection::other;
            }
            port p(t, d, std::string(bus->FirstChildElement("spirit:name")->FirstChild()->ToText()->Value()));
            ports.push_back(p);
            bus = bus->NextSiblingElement();
        }
    }
    
    void load_reg_map(const std::string& file)
    {
        std::ifstream f;
        f.open(file.c_str());
        if (!f.is_open())
            throw std::runtime_error("READ ERROR");
        if (!name_from_xml.empty())
            reg_map_json["name_from_component_xml"] = name_from_xml;
        std::string line;
        while (std::getline(f, line))
        {
            // get lines that start with #define but name doesn't start with "__"
            if (line.substr(0, 7) == "#define" && line.substr(8, 2) != "__")
            {
                // remove some characters
                char unwanted_chars[] = "()";
                for (size_t i = 0; i < strlen(unwanted_chars); ++i)
                    line.erase(std::remove(line.begin(), line.end(), unwanted_chars[i]), line.end());

                // read name and value
                std::istringstream iss(line.substr(8, std::string::npos));
                std::string regname, regval;
                if (!(iss >> regname >> regval))
                    throw std::runtime_error("READ ERROR");

                bool is_addr = false;
                bool is_bits = false;
                if (vendor == "Xilinx")
                {
                    // check if it is an address or bitsize
                    is_addr = regname.find("_AXILITES_ADDR_") != std::string::npos;
                    is_bits = regname.find("_AXILITES_BITS_") != std::string::npos;
                    // cut name
                    if (is_addr || is_bits)
                    {
                        regname = regname.substr(regname.find("_AXILITES_") + 15);
                        // trim _OFFSET_DATA from end
                        if (regname.length() > 12 && 0 == regname.compare(regname.length() - 12, 12, "_OFFSET_DATA"))
                            regname = regname.substr(0, regname.length() - 12);
                        // trim _DATA from end
                        if (regname.length() > 5 && 0 == regname.compare(regname.length() - 5, 5, "_DATA"))
                            regname = regname.substr(0, regname.length() - 5);
                    }
                } else if (vendor == "Intel")
                {
                    if (regname.length() > 5)
                    {
                        is_addr = regname.substr(regname.length() - 4) == "_REG";
                        is_bits = regname.substr(regname.length() - 5) == "_SIZE";
                        if (is_addr || is_bits)
                        {
                            // trim start
                            bool contains_csr_arg = regname.find("_CSR_ARG_") != std::string::npos;
                            bool contains_csr =     regname.find("_CSR_") != std::string::npos;
                            if (contains_csr_arg && regname.length() > 9)
                                regname = regname.substr(regname.find("_CSR_ARG_") + 9);
                            else if (contains_csr && regname.length() > 5)
                                regname = regname.substr(regname.find("_CSR_") + 5);
                            // trim end
                            if (is_addr && regname.length() > 4)
                                regname = regname.substr(0, regname.length() - 4);
                            if (is_bits && regname.length() > 5)
                                regname = regname.substr(0, regname.length() - 5);
                        }
                        // size is in bytes. need to multiply by 8
                        if (is_bits)
                        {
                            regval = std::to_string(std::stoi(regval) * 8);
                        }
                    }
                    
                }

                // try to insert in case name has been parsed previously
                bool found = false;
                for (auto& i : reg_map_json["registers"])
                {
                    if (i["name"] == regname)
                    {
                        if (is_addr)
                            i["addr"] = regval;
                        else if (is_bits)
                            i["bits"] = regval;
                        else
                            i["value"] = regval;
                        found = true;
                        break;
                    }
                }
                // make new object and push_back
                if (!found)
                {
                    json e;
                    e["name"]=regname;
                    if (is_addr)
                        e["addr"] = regval;
                    else if (is_bits)
                        e["bits"] = regval;
                    else
                        e["value"] = regval;
                    reg_map_json["registers"].push_back(e);
                }
            }
        }
        f.close();
    }

    ip(){}

    ip(std::string n, std::string p, std::string clk, std::string v)
//    : name(n + "_" + std::to_string(instance_index++)), path(p), clock(clk), vendor(v)
    : name(n), path(p), clock(clk), vendor(v), vlnv("unknown")
    {
        if (vendor == "Xilinx")
        {
            readXML(path + "/component.xml");
        }
        // load reg_map and make json
        load_reg_map(path + "/reg_map");
    }
};
