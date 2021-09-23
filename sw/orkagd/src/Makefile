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
all: liborkagd.so mini.out mini-intel.out sysmgmt.out liborkagd.a

liborkagd.so: liborkagd.o
	gcc -shared -o liborkagd.so liborkagd.o tcpipclient.o tiny-json.o stringhelper.o vector.o database.o

liborkagd.a: liborkagd.o tcpipclient.o tiny-json.o stringhelper.o vector.o database.o mmgmt.o
	@echo using ar in order to generate static library for object files:
	@echo $^
	ar rcs $@ $^

#mm.out: mainmm.c liborkagd.h
#        #-std=gnu99
#        # be sure to add path to source to get access to header file
#	gcc -O2 -std=gnu99 -L./ -I ../../../example/hls/src -Wall -o $@ $< -lorkagd

mini.out: mainmini.c liborkagd.c liborkagd.h tcpipclient.c tiny-json.h stringhelper.h stringhelper.c vector.h vector.c database.c database.h mmgmt.c mmgmt.h
        #-std=gnu99
	echo "make 'mini.out'"
        # be sure to add path to source to get access to header file
	gcc -O2 -std=gnu99 -L./ -I -Wall -o $@ $< liborkagd.o tcpipclient.o tiny-json.o stringhelper.o vector.o database.o mmgmt.c

mini-intel.out: mini-intel.c liborkagd.c liborkagd.h tcpipclient.c tiny-json.h stringhelper.h stringhelper.c vector.h vector.c database.c database.h mmgmt.c mmgmt.h
        #-std=gnu99
	echo "make 'mini-intel.out'"
        # be sure to add path to source to get access to header file
	gcc -O2 -std=gnu99 -L./ -I -Wall -o $@ $< liborkagd.o tcpipclient.o tiny-json.o stringhelper.o vector.o database.o mmgmt.c

sysmgmt.out: mainsysmgmt.c liborkagd.c liborkagd.h tcpipclient.c tiny-json.h stringhelper.h stringhelper.c vector.h vector.c database.c database.h
        #-std=gnu99
	echo "make 'sysmgmt.out'"
        # be sure to add path to source to get access to header file
	gcc -O2 -std=gnu99 -L./ -I -Wall -o $@ $< liborkagd.o tcpipclient.o tiny-json.o stringhelper.o vector.o database.o

tiny-json.o: tiny-json.c tiny-json.h
	echo "make 'tiny-json.o'"
	gcc -g -O0 -c -std=gnu99 -Wall -Werror -fPIC liborkagd.c tiny-json.c

liborkagd.o: liborkagd.c liborkagd.h tcpipclient.c tcpipclient.h tiny-json.h stringhelper.h stringhelper.c vector.h vector.c database.c database.h mmgmt.c
	echo "make 'liborkagd.o'"
	gcc -g -O0 -c -std=gnu99 -Wall -fPIC liborkagd.c tcpipclient.c tiny-json.c database.c stringhelper.c vector.c mmgmt.c

clean:
	-@rm -f *.o *.so *.a *.out 2>/dev/null >/dev/null

run:
	export LD_LIBRARY_PATH=/home/jschwarzer/ORKA/git_fraun/viframe/Dev/sw/orka/OrkaGenericDriver/src:$LD_LIBRARY_PATH && ./mini.out
