#!/bin/bash

design_dir="${1:-"."}"
elf_binary_file="${2:-"firmware.elf"}"
bitstream_file="${3:-"./bitstream.bit"}"
out_bitstream_file="${4:-"${bitstream_file//.bit}_injected.bit"}"

 updatemem -force -meminfo "${design_dir}/mem_info.mmi" \
           -data "${elf_binary_file}" \
           -bit "${bitstream_file}" \
           -proc axi_pcie_mig_i/microblaze_0 \
           -out "${out_bitstream_file}"
