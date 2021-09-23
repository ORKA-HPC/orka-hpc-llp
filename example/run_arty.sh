#!/bin/bash
curr=$PWD
root="`dirname \"$BASH_SOURCE\"`"
root="`( cd \"$root\" && pwd )`"
if [ -z "$root" ] ; then
    exit 1
fi

## BUILD HW TOOLS AND DEPENDENCIES #############################################
echo "$(cd ${root}/.. && make hw-dep)"


## GENERATE IP FROM SOURCE CODE ################################################
target_board="arty-a7-100"
export_dir="./generated_files_arty"
src_dir="./exampleip"
tlf="top"
clock="10ns"
cflags=""
sourcefiles="types.h mm.h mm.cpp"

${root}/../hw/build_ip/build_ip.sh $target_board \
    "$export_dir" \
    "$src_dir" \
    "$tlf" \
    "$clock" \
    "$cflags" \
    "$sourcefiles"

## GENERATE BITSTREAM ##########################################################
# Run ORKA HW Configurator
${root}/../hw/orka_hw_configurator/configurator \
    -config ${root}/../hw/orka_hw_configurator/default_configs/arty-a7-100.json \
    -o ${export_dir} \
    -design_dir ${export_dir} \
    -bitstream_export_dir ${export_dir} \
    -ip ${export_dir}:Ecki:100

${root}/../hw/generate_bitstream.sh "${export_dir}/"
BITSTREAM_FILENAME="$(python3 -c "import sys, json; print(json.load(open('${export_dir}/settings.json'))['bitstream_filename'])")"
LAST_UUID=${BITSTREAM_FILENAME%.bit}


## UPLOAD BITSTREAM (VIA JTAG) #################################################
BITSTREAM_EXPORT_DIR="$(python3 -c "import sys, json; print(json.load(open('${export_dir}/settings.json'))['bitstream_export_dir'])")"
source ${root}/../hw/xilinx/configure_fpga "${BITSTREAM_EXPORT_DIR}/${BITSTREAM_FILENAME}"


## BUILD SW TOOLS AND DEPENDENCIES #############################################
(cd ${root}/.. && make sw-dep)


## RUN HOST PROGRAM ############################################################
cd "${root}/../sw/orkagd/src"
JSON_FILENAME="$(python3 -c "import sys, json; print(json.load(open('${export_dir}/settings.json'))['json_filename'])")"
LD_LIBRARY_PATH="$PWD" ./test.out -c "${JSON_FILENAME}" -p "${BITSTREAM_EXPORT_DIR}"

# Expected result: The host program will copy 0 to ddr memory and lauch
# the HLS IP which in turn will read and increment the value. Finally
# the memory is read back by host and printed to console.
# As we write from host side zeroes into the memory, our little IP
# increments the zero into 0x00000001.

LD_LIBRARY_PATH="$PWD" ./test.out -c ${LAST_UUID}.json -p "${BITSTREAM_EXPORT_DIR}" -n

# Expected result: By using parameter '-n' we omit the upload of memory
# from the host. Therefore the memory contents are still the same from
# the first call. 
# Our little IP increments now the 0x00000001 into 0x00000002.
# Voilá.

# done
cd "${curr}"
exit 0
