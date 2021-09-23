#!/bin/bash
curr=$PWD
root="`dirname \"$BASH_SOURCE\"`"
root="`( cd \"$root\" && pwd )`"
if [ -z "$root" ] ; then
    exit 1
fi

## BUILD TOOLS AND DEPENDENCIES ################################################
echo "$(cd ${root}/.. && make hw-dep)"

## GENERATE IP FROM SOURCE CODE ################################################
target_board="arria10"
export_dir="./generated_files_intel"
src_dir="./ip_example_intel"
tlf="slavereg_comp"
clock="10ns"
cflags=""
sourcefiles="hls1.cpp"

source ${root}/../hw/build_ip/prepare_intel_tools.sh

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
    -config ${root}/../hw/orka_hw_configurator/default_configs/arria10_dev_board.json \
    -o ${export_dir} \
    -design_dir ${export_dir} \
    -ip ${export_dir}:slavereg_comp:100

${root}/../hw/generate_bitstream.sh "${export_dir}/"

exit 0
