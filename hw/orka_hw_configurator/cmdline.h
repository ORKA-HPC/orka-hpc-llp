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
#include <stdexcept>
#include <stdlib.h> // realpath
#include <string>
#include <sys/stat.h>
#include <utility> // std::pair
#include <vector>

#include <Support/CmdLine.h>
#include <Support/CmdLineUtil.h>

namespace support
{

struct cmdline
{
    using cmdline_options = std::vector<std::shared_ptr<cl::OptionBase>>;

    void add_cmdline_option( std::shared_ptr<cl::OptionBase> option )
    {
        options.emplace_back(option);
    }

    void parse_cmd_line(int argc, char** argv)
    {
        for (auto& opt : options)
        {
            cmd.add(*opt);
        }

        auto args = std::vector<std::string>(argv + 1, argv + argc);
        cl::expandWildcards(args);
        cl::expandResponseFiles(args, cl::TokenizeUnix());

        cmd.parse(args, allow_unknown_args);
    }

    // custom parser that runs realpath() and checks if valid
    struct pathparser : public cl::Parser<std::string>
    {
        void operator()(StringRef arg_name, StringRef arg, std::string& value)
        {
            try
            {
                std::string v = realpath(arg.data(), NULL);
                value = v;
            } catch (...)
            {
                std::cerr << "ERROR: Path/file does not exist!\n"
                    << "-" << arg_name.str() << " " << arg.str()
                    << std::endl;
                exit(1);
            }
        }
    };

    cmdline(int argc, char** argv)
    {
        add_cmdline_option( cl::makeOption<std::string&>(
                    cl::Parser<>(),
                    "o",
                    cl::Desc("Export dir for Configuration Files"),
                    cl::Required,
                    cl::ArgRequired,
                    cl::init(this->exportdir)
                    ) );

        add_cmdline_option( cl::makeOption<std::string&>(
                    pathparser(),
                    "config",
                    cl::Desc("JSON File with FPGA Configuration"),
                    cl::Required,
                    cl::ArgRequired,
                    cl::init(this->configfile)
                    ) );

        add_cmdline_option( cl::makeOption<std::string&>(
                    pathparser(),
                    "defaults",
                    cl::Desc("JSON File with Default FPGA Configuration"),
                    cl::ArgRequired,
                    cl::init(this->defaultconfigfile)
                    ) );

        add_cmdline_option( cl::makeOption<std::string&>(
                    pathparser(),
                    "ips",
                    cl::Desc("JSON File with IP Info"),
                    cl::ArgRequired,
                    cl::init(this->ipfile)
                    ) );

        add_cmdline_option( cl::makeOption<std::string>(
                    [&](StringRef arg_name, StringRef arg, std::string value) {
                        ip i;
                        auto pos1 = arg.str().find_first_of(":");
                        i.path = arg.str().substr(0, pos1);
                        i.name = arg.str().substr(pos1+1);
                        i.clk = "100";
                        auto pos2 = i.name.find_last_of(":");
                        if (pos2 != std::string::npos)
                        {
                            i.clk = i.name.substr(pos2+1);
                            i.name = i.name.substr(0, pos2);
                        }
                        iplist.push_back(i);
                    },
                    "ip",
                    cl::Desc("Specify HLS IP to be added PATH:NAME[:CLOCK]."),
                    cl::ZeroOrMore,
                    cl::ArgRequired
                    ) );

        add_cmdline_option( cl::makeOption<int&>(
                    cl::Parser<>(),
                    "cpus",
                    cl::Desc("How many CPU Cores to use during Synthesis and Implementation. Must be a natural number!"),
                    cl::Optional,
                    cl::ArgRequired,
                    cl::init(this->num_cpu_cores)
                    ) );

        add_cmdline_option( cl::makeOption<bool>(
                    [&](StringRef, StringRef arg, bool& value) {
                        only_bd = true;
                    },
                    "only_bd",
                    cl::Desc("Only run scripts to build Block Design (skip synth,impl,bs-gen)."),
                    cl::Optional,
                    cl::ArgDisallowed
                    ) );

        add_cmdline_option( cl::makeOption<bool>(
                    [&](StringRef, StringRef arg, bool& value) {
                        enable_gui = true;
                    },
                    "gui",
                    cl::Desc("Launch Vivado GUI while generating HW."),
                    cl::Optional,
                    cl::ArgDisallowed
                    ) );

        add_cmdline_option( cl::makeOption<bool>(
                    [&](StringRef, StringRef arg, bool& value) {
                        force_overwrite_files = true;
                    },
                    "f",
                    cl::Desc("Overwrite existing files (force)."),
                    cl::Optional,
                    cl::ArgDisallowed
                    ) );

        add_cmdline_option( cl::makeOption<std::string>(
                    cl::Parser<>(),
                    "help",
                    cl::ArgName("option"),
                    cl::ArgOptional,
                    cl::Hidden
                    ) );

        add_cmdline_option( cl::makeOption<std::string&>(
                    pathparser(),
                    "design_dir",
                    cl::Desc("Vivado working dir"),
                    cl::Optional,
                    cl::ArgRequired,
                    cl::init(this->designdir)
                    ) );

        add_cmdline_option( cl::makeOption<std::string&>(
                    pathparser(),
                    "bitstream_export_dir",
                    cl::Desc("Export dir for Bitstream and JSON Config"),
                    cl::Optional,
                    cl::ArgRequired,
                    cl::init(this->bitstreamexportdir)
                    ) );

        try
        {
            parse_cmd_line(argc, argv);
        }
        catch (...)
        {
            std::cout << cmd.help(argv[0]) << '\n';
            throw;
        }
    }

    bool only_bd = false;
    bool enable_gui = false;
    bool force_overwrite_files = false;
    int num_cpu_cores = 0;
    std::string configfile;
    std::string defaultconfigfile;
    std::string ipfile;
    std::string exportdir;
    std::string bitstreamexportdir = "";
    std::string designdir = "";
    struct ip { std::string path, name, clk; };
    std::vector<ip> iplist;

    cmdline_options options;
    cl::CmdLine cmd;
    bool allow_unknown_args = false;
};

} // namespace support
