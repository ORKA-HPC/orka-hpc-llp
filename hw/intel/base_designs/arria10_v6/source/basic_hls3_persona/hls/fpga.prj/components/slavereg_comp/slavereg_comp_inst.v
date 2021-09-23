// Example instance of the top level module for: 
//     slavereg_comp
// To include this component in your design, include: 
//     slavereg_comp.qsys
// in your Quartus project and follow the template 
// below to instantiate the IP.  Alternatively, the IP core 
// can be generated from a Qsys system.

slavereg_comp slavereg_comp_inst (
  // Interface: clock (clock end)
  .clock                  ( ), // 1-bit clk input
  // Interface: reset (reset end)
  .resetn                 ( ), // 1-bit reset_n input
  // Interface: irq (interrupt end)
  .done_irq               ( ), // 1-bit irq output
  // Interface: avmm_1_rw (avalon start)
  .avmm_1_rw_address      ( ), // 32-bit address output
  .avmm_1_rw_byteenable   ( ), // 64-bit byteenable output
  .avmm_1_rw_readdatavalid( ), // 1-bit readdatavalid input
  .avmm_1_rw_read         ( ), // 1-bit read output
  .avmm_1_rw_readdata     ( ), // 512-bit readdata input
  .avmm_1_rw_write        ( ), // 1-bit write output
  .avmm_1_rw_writedata    ( ), // 512-bit writedata output
  .avmm_1_rw_waitrequest  ( ), // 1-bit waitrequest input
  .avmm_1_rw_burstcount   ( ), // 5-bit burstcount output
  // Interface: avs_cra (avalon end)
  .avs_cra_read           ( ), // 1-bit read input
  .avs_cra_readdata       ( ), // 64-bit readdata output
  .avs_cra_write          ( ), // 1-bit write input
  .avs_cra_writedata      ( ), // 64-bit writedata input
  .avs_cra_address        ( ), // 4-bit address input
  .avs_cra_byteenable     ( )  // 8-bit byteenable input
);
