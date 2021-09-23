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
TINYXMLPATH = ../../3rdparty/tinyxml2/
JSONPATH = ../../3rdparty/json/include/
CMDLINEPATH = ../../3rdparty/CmdLine/

CXXFLAGS = -std=c++17 -O3
LDFLAGS = -lstdc++fs

all: libtinyxml2 configurator merge_json

debug: CXXFLAGS += -Wall -Wpedantic -g -O0
debug: all

clean:
	-@rm -f *.o configurator libtinyxml2.a libcmdline.a libcmdlineutil.a merge_json

configurator: libtinyxml2.a libcmdline.a libcmdlineutil.a configurator.o
	g++ $(CXXFLAGS) -o $@ configurator.o libtinyxml2.a libcmdline.a libcmdlineutil.a $(LDFLAGS)

configurator.o: cmdline.h configuration.h connection.h ip.h configurator.cpp
	g++ $(CXXFLAGS) -c -I$(TINYXMLPATH) -I$(JSONPATH) -I$(CMDLINEPATH)include configurator.cpp -o $@

libtinyxml2: libtinyxml2.a

libtinyxml2.a: tinyxml2.o
	ar crs $@ $^

tinyxml2.o: $(TINYXMLPATH)tinyxml2.cpp $(TINYXMLPATH)tinyxml2.h
	g++ -c -fPIC $(TINYXMLPATH)tinyxml2.cpp -o tinyxml2.o

libcmdline: libcmdline.a

libcmdline.a: cmdline.o
	ar crs $@ $^

cmdline.o: $(CMDLINEPATH)src/CmdLine.cpp
	g++ -c -fPIC $(CXXFLAGS) $(CMDLINEPATH)src/CmdLine.cpp -I$(CMDLINEPATH)include -o cmdline.o

libcmdlineutil: libcmdlineutil.a

libcmdlineutil.a: cmdlineutil.o
	ar crs $@ $^

cmdlineutil.o: $(CMDLINEPATH)src/CmdLineUtil.cpp
	g++ -c -fPIC $(CXXFLAGS) $(CMDLINEPATH)src/CmdLineUtil.cpp -I$(CMDLINEPATH)include -o cmdlineutil.o

merge_json: libcmdline.a libcmdlineutil.a merge_json.o
	g++ $(CXXFLAGS) -o $@ merge_json.o libcmdline.a libcmdlineutil.a

merge_json.o: cmdline.h merge_json.cpp
	g++ $(CXXFLAGS) -c -I$(JSONPATH) -I$(CMDLINEPATH)include merge_json.cpp
