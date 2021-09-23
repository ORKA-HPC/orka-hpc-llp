	local_qsys_sld_jtag_bridge_host_0 u0 (
		.tck     (_connected_to_tck_),     //   input,  width = 1, connect_to_bridge_host.tck
		.tms     (_connected_to_tms_),     //   input,  width = 1,                       .tms
		.tdi     (_connected_to_tdi_),     //   input,  width = 1,                       .tdi
		.vir_tdi (_connected_to_vir_tdi_), //   input,  width = 1,                       .vir_tdi
		.ena     (_connected_to_ena_),     //   input,  width = 1,                       .ena
		.tdo     (_connected_to_tdo_)      //  output,  width = 1,                       .tdo
	);

