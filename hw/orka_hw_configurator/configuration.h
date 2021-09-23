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
#include <iomanip>
#include <stdexcept>
#include <stdlib.h> // realpath
#include <string>
#include <tuple>
#include <vector>

#if __GNUC__ > 7
#include <filesystem> // create_directories
namespace filesys = std::filesystem;
#else
#include <experimental/filesystem> // create_directories
namespace filesys = std::experimental::filesystem;
#endif

#include <nlohmann/json.hpp>

#include "connection.h"
#include "ip.h"


struct configuration
{
    using json = nlohmann::json;

    std::vector<ip> ips;
    std::vector<std::string> clocks;
    connection_list connections;
    json settings;
    std::string vendor;

    void dump_as_tcl(std::ostream& dst)
    {
        std::string prefix("set ");
        std::string postfix(";");

        for (auto& e : settings.items())
        {
            std::ostringstream indent;
            for (int i = std::max(0, 30 - (int)(std::string(e.key())).length()); i>0; --i)
                indent << " ";
//            dst << prefix << e.key() << indent.str() << "\"" << e.value() << "\"" << postfix << std::endl;
            dst << prefix << e.key() << indent.str() << e.value() << postfix << std::endl;
//            dst << prefix << e.key() << " " << e.value() << postfix << std::endl;
        }
    }


    void add_ip(const std::string& name, const std::string& path, const std::string& clock = "100")
    {
        try
        {
            ip i(name, path, clock, vendor);
            std::cout << "\tAdded IP: Name=" << i.name
                << " xml_name=" << i.name_from_xml
                << " Path=" << path
                << " Clock=" << clock << " MHz"
                << std::endl;
            ips.push_back(i);
            settings["enable_custom_ip"] = "1";
        } catch (...)
        {
            throw std::runtime_error("Could not add IP");
        }
    }

    void connect(const std::tuple<std::string, std::string, std::string, std::string>& names)
    {
        //find ips
        ip srcip, dstip;
        find_ip(std::get<0>(names), srcip);
        find_ip(std::get<2>(names), dstip);

        //find ports
        port srcport, dstport;
        find_port(std::get<1>(names), srcip, srcport);
        find_port(std::get<3>(names), dstip, dstport);

        connections.list.push_back(connection(srcip, srcport, dstip, dstport));

        //TODO mark ports as used

        std::cout << "\tNew connection: " << srcip.name << ":" << srcport.name << " -> " << dstip.name << ":" << dstport.name << std::endl;
    }

    void find_ip(const std::string name, ip& res)
    {
        for (auto& i : ips)
        {
            if (i.name == name || i.name_from_xml == name)
            {
                res = i;
                return;
            }
        }
        throw std::runtime_error("IP NOT FOUND");
    }

    void find_port(const std::string name, ip& i, port& res)
    {
        for (auto& p : i.ports)
        {
            if (p.name == name)
            {
                res = p;
                return;
            }
        }
        throw std::runtime_error("PORT NOT FOUND");
    }

    void list_ips()
    {
        std::cout << "VLNV / Name" << std::endl;
        for (auto& i : ips)
            std::cout << i.vlnv << "\t/\t" << i.name << std::endl;
    }

    void list_ports(const std::string ipname)
    {
        if (ipname == "")
            return;

        for (auto& i : ips)
        {
            if (i.name == ipname)
            {
                i.print_ports(std::cout);
                //TODO also print where ports are connected to
                return;
            }
        }
        std::cout << "No IP found with name: " << ipname << std::endl;
    }

    void file_to_json(json& j, const std::string file)
    {
        std::ifstream f;
        f.open(file.c_str());
        if (!f.is_open())
            throw std::runtime_error("Can't read JSON file");
        f >> j;
        f.close();
    }

    void parse_config_json(const std::string file)
    {
        json j;
        file_to_json(j, file);
        for (auto& it : j.items())
        {
            settings[it.key()]=it.value();
            if (it.key() == "vendor")
                vendor = it.value();
        }
    }

    void parse_ip_json(const std::string file)
    {
        json j;
        std::vector<std::tuple<std::string, std::string, std::string, std::string>> c;

        file_to_json(j, file);

        for (auto& ip : j["ips"])
        {
            std::string name = ip["name"];

            std::string path = ip["path"];

            // can't use regex since we are using compilers from the stone age...
            //std::string path = std::regex_replace(p, std::regex("^(~|\\$HOME)"), getenv("HOME")));
            // do it manually instead
            if (path.at(0) == '~')
                path = getenv("HOME") + path.substr(1, path.size() - 1);
            if (path.substr(0, 5) == "$HOME")
                path = getenv("HOME") + path.substr(5, path.size() - 1);
            path = realpath(path.c_str(), NULL);

            bool clock_set = false;
            std::string clk;
            if (ip.contains("clock"))
            {
                clock_set = true;
                clk = ip["clock"];
            }
            if (ip.contains("connections"))
            {
                for (auto& con : ip["connections"])
                {
                    auto src_ip   = name;
                    auto src_port = con["src_port"];
                    auto dst_ip   = con["dst_ip"];
                    auto dst_port = con["dst_port"];
                    c.push_back(std::make_tuple(src_ip, src_port, dst_ip, dst_port));
                }
            }
            // add IPs
            if (clock_set)
            {
                add_ip(name, path, clk);
            }
            else
            {
                add_ip(name, path);
            }
        }
        // make port connections
        for (auto& i : c)
        {
            connect(i);
        }
    }

    void write_configuration(std::string& destination_path, bool force_overwrite)
    {
        // 'mkdir -p' on destination_path
        filesys::create_directories(destination_path.c_str());

        // Check for old files (remove if force_overwrite is set, otherwise abort)
        std::vector<std::string> names = {
            "ips.tcl", "ips.json", "reg_map.json",
            "settings.tcl", "settings.json",
            "connections.tcl", "connections.json",
            "ORKAFPGAs.json", "ORKAInterpreter.json",
            std::string(settings["bitstream_filename"]),
            std::string(settings["json_filename"])
        };
        for (auto& n : names)
        {
            std::string filename = destination_path + "/" + n;
            filesys::path path = filename;
            std::ifstream f(path);
            if (f.good())
            {
                if (!force_overwrite)
                {
                    std::cerr << "Error: " << filename << " already exists and would be overwritten. "
                        << "You can force overwriting files with cmdline option '-f'" << std::endl;
                    throw std::runtime_error("Can't write file: file already exists!");
                }
                else
                {
                    std::cout << "Removing old file: " << filename << std::endl;
                    filesys::remove(path);
                }
            }
        }


        // write ips.tcl
        if (ips.size())
        {
            std::ofstream ips_file;
            ips_file.open(destination_path + "/ips.tcl");
            if (!ips_file.is_open())
                throw std::runtime_error("Can't write file: file already exists!");
            ips_file << "set ip_names {";
            for (auto& i : ips)
                ips_file << " " << i.name;
            ips_file << " }" << std::endl;

            ips_file << "set ip_paths {";
            for (auto& i : ips)
                ips_file << " " << i.path;
            ips_file << " }" << std::endl;
            std::vector<std::string> clocks;
            for (auto i : ips)
            {
                auto idx = std::find(clocks.begin(), clocks.end(), i.clock);
                if (idx == clocks.end())
                    clocks.push_back(i.clock);
                idx = std::find(clocks.begin(), clocks.end(), i.clock);
                ips_file << "set " << i.name << "_clk_idx " << idx - clocks.begin() << std::endl;
            }
            ips_file << "set hls_ip_clocks { ";
            for (auto c : clocks)
            {
                ips_file << c << " ";
            }
            ips_file << "}" << std::endl;
            ips_file << "set ip_vlnvs { ";
            for (auto& i : ips)
            {
                ips_file << " " << i.vlnv;
            }
            ips_file << " }" << std::endl;
            ips_file << "set ip_portnames { ";
            for (auto& i : ips)
            {
                for (auto& p : i.ports)
                {
                    ips_file << p.name << ";";
                }
                ips_file << " ";
            }
            ips_file << " }" << std::endl;
            ips_file << "set ip_porttypes { ";
            for (auto& i : ips)
            {
                for (auto& p : i.ports)
                {
                    switch (p.type)
                    {
                    case porttype::aximm:
                        ips_file << "aximm;";
                        break;
                    case porttype::axis:
                        ips_file << "axis;";
                        break;
                    case porttype::reset:
                        ips_file << "reset;";
                        break;
                    case porttype::clock:
                        ips_file << "clock;";
                        break;
                    case porttype::interrupt:
                        ips_file << "interrupt;";
                        break;
                    case porttype::bram:
                        ips_file << "bram;";
                        break;
                    case porttype::acc_fifo_read:
                        ips_file << "acc_fifo_read;";
                        break;
                    case porttype::acc_fifo_write:
                        ips_file << "acc_fifo_write;";
                        break;
                    case porttype::unknown:
                        ips_file << "unknown;";
                        break;
                    }
                }
                ips_file << " ";
            }
            ips_file << " }" << std::endl;
            ips_file << "set ip_portmodes { ";
            for (auto& i : ips)
            {
                for (auto& p : i.ports)
                {
                    switch (p.direction)
                    {
                    case portdirection::master:
                        ips_file << "master;";
                        break;
                    case portdirection::slave:
                        ips_file << "slave;";
                        break;
                    case portdirection::other:
                        ips_file << "other;";
                        break;
                    }
                }
                ips_file << " ";
            }
            ips_file << " }" << std::endl;
            ips_file.close();
            // write ips.json
            json ips_json;
            for (auto& i : ips)
                ips_json["ips"].push_back({{"name", i.name},{"path", i.path},{"clock", i.clock},{"vlnv", i.vlnv}});
            ips_file.open(destination_path + "/ips.json");
            if (!ips_file.is_open())
                throw std::runtime_error("Can't write file: file already exists!");
            ips_file << ips_json.dump(4) << std::endl;
            ips_file.close();
        }


        // write connections.tcl
        if (connections.list.size())
        {
            std::ofstream connections_file;
            connections_file.open(destination_path + "/connections.tcl");
            if (!connections_file.is_open())
                throw std::runtime_error("Can't write file: file already exists!");
            connections.write_file(connections_file);
            connections_file.close();
            // write connections.json
            json connections_json;
            for (auto& c : connections.list)
                connections_json["connections"].push_back(
                        {{"srcip", c.src.name},{"srcport", c.srcp.name},
                        {"dstip", c.dst.name},{"dstport", c.dstp.name}}
                        );
            connections_file.open(destination_path + "/connections.json");
            if (!connections_file.is_open())
                throw std::runtime_error("Can't write file: file already exists!");
            connections_file << connections_json.dump(4) << std::endl;
            connections_file.close();
        }

        // write settings.tcl
        std::ofstream settings_file;
        settings_file.open(destination_path + "/settings.tcl");
        if (!settings_file.is_open())
            throw std::runtime_error("Can't write file: file already exists!");
        dump_as_tcl(settings_file);
        settings_file.close();
        // write settings.json
        std::ofstream settings_json_file;
        settings_json_file.open(destination_path + "/settings.json");
        if (!settings_json_file.is_open())
            throw std::runtime_error("Can't write file: file already exists!");
        settings_json_file << settings.dump(4) << std::endl;
        settings_json_file.close();

        // write reg_map.json
        if (ips.size())
        {
            std::ofstream reg_map_file;
            reg_map_file.open(destination_path + "/reg_map.json");
            if (!reg_map_file.is_open())
                throw std::runtime_error("Can't write file: file already exists!");
            json j;
            for (auto& i : ips)
            {
                j[i.name] = i.reg_map_json;
            }
            reg_map_file << j.dump(4) << std::endl;
            reg_map_file.close();
        }
    }
};
