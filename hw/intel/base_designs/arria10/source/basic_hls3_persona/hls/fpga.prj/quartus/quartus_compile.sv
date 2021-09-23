module quartus_compile (
	  input logic resetn
	, input logic clock
	, output logic [0:0] slavereg_comp_done_irq
	, output logic [31:0] slavereg_comp_avmm_1_rw_address
	, output logic [63:0] slavereg_comp_avmm_1_rw_byteenable
	, input logic [0:0] slavereg_comp_avmm_1_rw_readdatavalid
	, output logic [0:0] slavereg_comp_avmm_1_rw_read
	, input logic [511:0] slavereg_comp_avmm_1_rw_readdata
	, output logic [0:0] slavereg_comp_avmm_1_rw_write
	, output logic [511:0] slavereg_comp_avmm_1_rw_writedata
	, input logic [0:0] slavereg_comp_avmm_1_rw_waitrequest
	, output logic [4:0] slavereg_comp_avmm_1_rw_burstcount
	, input logic [0:0] slavereg_comp_avs_cra_read
	, output logic [63:0] slavereg_comp_avs_cra_readdata
	, input logic [0:0] slavereg_comp_avs_cra_write
	, input logic [63:0] slavereg_comp_avs_cra_writedata
	, input logic [3:0] slavereg_comp_avs_cra_address
	, input logic [7:0] slavereg_comp_avs_cra_byteenable
	);

	logic [0:0] slavereg_comp_done_irq_reg;
	logic [31:0] slavereg_comp_avmm_1_rw_address_reg;
	logic [63:0] slavereg_comp_avmm_1_rw_byteenable_reg;
	logic [0:0] slavereg_comp_avmm_1_rw_readdatavalid_reg;
	logic [0:0] slavereg_comp_avmm_1_rw_read_reg;
	logic [511:0] slavereg_comp_avmm_1_rw_readdata_reg;
	logic [0:0] slavereg_comp_avmm_1_rw_write_reg;
	logic [511:0] slavereg_comp_avmm_1_rw_writedata_reg;
	logic [0:0] slavereg_comp_avmm_1_rw_waitrequest_reg;
	logic [4:0] slavereg_comp_avmm_1_rw_burstcount_reg;
	logic [0:0] slavereg_comp_avs_cra_read_reg;
	logic [63:0] slavereg_comp_avs_cra_readdata_reg;
	logic [0:0] slavereg_comp_avs_cra_write_reg;
	logic [63:0] slavereg_comp_avs_cra_writedata_reg;
	logic [3:0] slavereg_comp_avs_cra_address_reg;
	logic [7:0] slavereg_comp_avs_cra_byteenable_reg;


	always @(posedge clock) begin
		slavereg_comp_done_irq <= slavereg_comp_done_irq_reg;
		slavereg_comp_avmm_1_rw_address <= slavereg_comp_avmm_1_rw_address_reg;
		slavereg_comp_avmm_1_rw_byteenable <= slavereg_comp_avmm_1_rw_byteenable_reg;
		slavereg_comp_avmm_1_rw_readdatavalid_reg <= slavereg_comp_avmm_1_rw_readdatavalid;
		slavereg_comp_avmm_1_rw_read <= slavereg_comp_avmm_1_rw_read_reg;
		slavereg_comp_avmm_1_rw_readdata_reg <= slavereg_comp_avmm_1_rw_readdata;
		slavereg_comp_avmm_1_rw_write <= slavereg_comp_avmm_1_rw_write_reg;
		slavereg_comp_avmm_1_rw_writedata <= slavereg_comp_avmm_1_rw_writedata_reg;
		slavereg_comp_avmm_1_rw_waitrequest_reg <= slavereg_comp_avmm_1_rw_waitrequest;
		slavereg_comp_avmm_1_rw_burstcount <= slavereg_comp_avmm_1_rw_burstcount_reg;
		slavereg_comp_avs_cra_read_reg <= slavereg_comp_avs_cra_read;
		slavereg_comp_avs_cra_readdata <= slavereg_comp_avs_cra_readdata_reg;
		slavereg_comp_avs_cra_write_reg <= slavereg_comp_avs_cra_write;
		slavereg_comp_avs_cra_writedata_reg <= slavereg_comp_avs_cra_writedata;
		slavereg_comp_avs_cra_address_reg <= slavereg_comp_avs_cra_address;
		slavereg_comp_avs_cra_byteenable_reg <= slavereg_comp_avs_cra_byteenable;
	end


	reg [2:0] sync_resetn;
	always @(posedge clock or negedge resetn) begin
		if (!resetn) begin
			sync_resetn <= 3'b0;
		end else begin
			sync_resetn <= {sync_resetn[1:0], 1'b1};
		end
	end


	slavereg_comp slavereg_comp_inst (
		  .resetn(sync_resetn[2])
		, .clock(clock)
		, .done_irq(slavereg_comp_done_irq_reg)
		, .avmm_1_rw_address(slavereg_comp_avmm_1_rw_address_reg)
		, .avmm_1_rw_byteenable(slavereg_comp_avmm_1_rw_byteenable_reg)
		, .avmm_1_rw_readdatavalid(slavereg_comp_avmm_1_rw_readdatavalid_reg)
		, .avmm_1_rw_read(slavereg_comp_avmm_1_rw_read_reg)
		, .avmm_1_rw_readdata(slavereg_comp_avmm_1_rw_readdata_reg)
		, .avmm_1_rw_write(slavereg_comp_avmm_1_rw_write_reg)
		, .avmm_1_rw_writedata(slavereg_comp_avmm_1_rw_writedata_reg)
		, .avmm_1_rw_waitrequest(slavereg_comp_avmm_1_rw_waitrequest_reg)
		, .avmm_1_rw_burstcount(slavereg_comp_avmm_1_rw_burstcount_reg)
		, .avs_cra_read(slavereg_comp_avs_cra_read_reg)
		, .avs_cra_readdata(slavereg_comp_avs_cra_readdata_reg)
		, .avs_cra_write(slavereg_comp_avs_cra_write_reg)
		, .avs_cra_writedata(slavereg_comp_avs_cra_writedata_reg)
		, .avs_cra_address(slavereg_comp_avs_cra_address_reg)
		, .avs_cra_byteenable(slavereg_comp_avs_cra_byteenable_reg)
	);



endmodule
