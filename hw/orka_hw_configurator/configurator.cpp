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
#include <algorithm> // std::max()
#include <cctype> // std::tolower()
#include <cstdlib> // realpath()
#include <exception>
#include <iostream>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread> // std::thread::hardware_concurrency()

#include "cmdline.h"
#include "configuration.h"

namespace uuid
{
static std::random_device              rd;
static std::mt19937                    gen(rd());
static std::uniform_int_distribution<> dis(0, 15);
static std::uniform_int_distribution<> dis2(8, 11);

std::string generate_uuid_v4() {
    std::stringstream ss;
    int i;
    ss << std::hex;
    for (i = 0; i < 8; i++) {
        ss << dis(gen);
    }
    ss << "-";
    for (i = 0; i < 4; i++) {
        ss << dis(gen);
    }
    ss << "-4";
    for (i = 0; i < 3; i++) {
        ss << dis(gen);
    }
    ss << "-";
    ss << dis2(gen);
    for (i = 0; i < 3; i++) {
        ss << dis(gen);
    }
    ss << "-";
    for (i = 0; i < 12; i++) {
        ss << dis(gen);
    };
    return ss.str();
}
} // namespace uuid

bool is_number(const std::string& s)
{
    return !s.empty() && std::find_if(s.begin(),
            s.end(), [](unsigned char c) { return !std::isdigit(c); }) == s.end();
}

int main(int argc, char** argv)
{
    // parse cmd args
    support::cmdline cmd(argc, argv);

    configuration config;

    // parse json files
    if (!cmd.defaultconfigfile.empty())
    {
        try
        {
            config.parse_config_json(cmd.defaultconfigfile);
        } catch (const std::exception& e)
        {
            std::cerr << "ERROR parsing JSON file: "
                << cmd.defaultconfigfile << "\n"
                << e.what() << std::endl;
            exit(1);
        }
    }
    try
    {
        config.parse_config_json(cmd.configfile);
    } catch (const std::exception& e)
    {
        std::cerr << "ERROR parsing JSON file: "
            << cmd.configfile << "\n"
            << e.what() << std::endl;
        exit(1);
    }

    // if filenames for bitstream and json were not specified within configs: set them with UUIDs
    std::string fne = ".bit";
    if (config.settings["vendor"] == "Intel")
        fne = ".sof";
    if (!config.settings.contains("bitstream_filename"))
        config.settings["bitstream_filename"] = uuid::generate_uuid_v4() + fne;
    if (!config.settings.contains("json_filename"))
        config.settings["json_filename"] = uuid::generate_uuid_v4() + ".json";

    // force .sof file name extension for intel desings (otherwise quartus_pgm crashes...)
    // might be able to remove this restriction once bitstream upload is integrated into orkagd
    if (config.settings["vendor"] == "Intel")
    {
        std::string bf = config.settings["bitstream_filename"];
        for (auto& c : bf)
            c = std::tolower(c);
        if (bf.length() < 4 || bf.substr(bf.length()-4, 4) != fne)
            config.settings["bitstream_filename"] = std::string(config.settings["bitstream_filename"]) + fne;
    }

    // if design_dir or bitstream_export_dir was specified on cmdline then overwrite value read from jsons
    if (!cmd.designdir.empty())
        config.settings["design_dir"] = cmd.designdir;
    if (!cmd.bitstreamexportdir.empty())
        config.settings["bitstream_export_dir"] = cmd.bitstreamexportdir;
    // if bitstream_export_dir is still not set then set it to design_dir
    if (!config.settings.contains("bitstream_export_dir"))
        config.settings["bitstream_export_dir"] = config.settings["design_dir"];


    // parse ips json (if option was specified)
    if (!cmd.ipfile.empty())
    {
        config.parse_ip_json(cmd.ipfile);
    }

    // add ips specified in cmdline args
    for (auto& i : cmd.iplist)
    {
        if (config.settings["vendor"] == "Xilinx")
        {
            try
            {
                i.path = std::string(realpath(i.path.c_str(), nullptr));
                auto xml = i.path + "/component.xml";
                struct stat buffer;
                if (stat(xml.c_str(), &buffer) != 0)
                {
                    xml = i.path + "/ip/component.xml";
                    if (stat(xml.c_str(), &buffer) != 0)
                    {
                        std::cerr << "Error: No IP found in " << i.path << std::endl;
                        std::cerr << "Error: No IP found in " << i.path + "/ip" << std::endl;
                        continue;
                    } else
                    {
                        i.path = i.path + "/ip";
                    }
                }
                std::cout << "Info: Found IP in " << i.path << std::endl;
                config.add_ip(i.name, i.path, i.clk);
            } catch (...)
            {
                std::cerr << "ERROR: Could not find component.xml inside IP directory:\n"
                    << i.path << std::endl;
            }
        } else {
            config.add_ip(i.name, i.path, i.clk);
        }
    }

    // handle remaining flags
    config.settings["only_build_bd"] = std::to_string(cmd.only_bd);
    config.settings["enable_gui"] = std::to_string(cmd.enable_gui);
    // set num_cpu_cores after sanity checks
    if (cmd.num_cpu_cores > 0)
    {
        config.settings["num_cpu_cores"] = std::to_string(cmd.num_cpu_cores);
    }
    else
    {
        if (cmd.num_cpu_cores < 0)
            throw std::runtime_error("invalid argument '" + std::to_string(cmd.num_cpu_cores) + "' for option '" + "cpus" + "'");
        // fallback to num_cpu_cores in config json file
        if (!config.settings.contains("num_cpu_cores"))
        {
            const auto cores = std::max(1u, std::thread::hardware_concurrency());
            std::cout << "WARNING: num_cpu_cores not set. "
                << "Either use cmdline option '-cpus' or extend JSON config with 'num_cpu_cores' entry!"
                << "\nUsing " << cores << " cores for LLP synthesis."
                << std::endl;
            config.settings["num_cpu_cores"] = std::to_string(cores);
        } else if (!is_number(config.settings["num_cpu_cores"])
                || std::stoi(std::string(config.settings["num_cpu_cores"])) < 0)
        {
            throw std::runtime_error("invalid entry in JSON config: " "num_cpu_cores='" + std::string(config.settings["num_cpu_cores"]) + "'");
        }
    }

    // export hw configuration
    config.write_configuration(cmd.exportdir, cmd.force_overwrite_files);

    return 0;
}
