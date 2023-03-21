`ifdef TYPE
`undef TYPE
`undef sel_ac_t
`undef sel_pc_t
`undef sel_skip_t
`undef sel_addr_t
`undef sel_data_t
`undef sel_iot_t
`undef sel_ir_t
`undef sel_ma_t
`undef sel_md_t
`endif

`ifdef USE_WIRE
`define TYPE wire
`else
`define TYPE reg
`endif

`define sel_ac_t `TYPE [2:0]
localparam ac_none       = 3'd0;
localparam ac_and_md     = 3'd1;
localparam ac_add_md     = 3'd2;
localparam ac_zero       = 3'd3;
localparam ac_uc         = 3'd4;
localparam ac_iot        = 3'd5;

`define sel_pc_t `TYPE [2:0]
localparam pc_none       = 3'd0;
localparam pc_data       = 3'd1;
localparam pc_ma         = 3'd2;
localparam pc_ma1        = 3'd3;
localparam pc_incr       = 3'd4;

`define sel_skip_t `TYPE [1:0]
localparam skip_none     = 2'd0;
localparam skip_md_clear = 2'd1;
localparam skip_uc       = 2'd2;
localparam skip_iot      = 2'd3;

`define sel_addr_t `TYPE [1:0]
localparam addr_none     = 2'd0;
localparam addr_ma       = 2'd1;
localparam addr_pc       = 2'd2;
localparam addr_ea       = 2'd3;

`define sel_data_t `TYPE [2:0]
localparam data_none     = 3'd0;
localparam data_ac       = 3'd1;
localparam data_md       = 3'd2;
localparam data_pc       = 3'd3;
localparam data_pc1      = 3'd4;

`define sel_iot_t `TYPE [0:0]
localparam iot_none      = 1'd0;
localparam iot_en        = 1'd1;

`define sel_ir_t `TYPE [0:0]
localparam ir_none       = 1'd0;
localparam ir_data       = 1'd1;

`define sel_ma_t `TYPE [1:0]
localparam ma_none       = 2'd0;
localparam ma_data       = 2'd1;
localparam ma_ea         = 2'd2;

`define sel_md_t `TYPE [1:0]
localparam md_none       = 2'd0;
localparam md_data       = 2'd1;
localparam md_data1      = 2'd2;

//`undef TYPE
