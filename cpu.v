module cpu(
    input clk,
    input nrst,

    // UI Bus
    //   Panel to external interfaces
    //ld : out STD_LOGIC_VECTOR(7 downto 0);
    //anodes : out STD_LOGIC_VECTOR(3 downto 0);
    //cathodes : out STD_LOGIC_VECTOR(7 downto 0);

    // Panel Bus
    //   Panel to CPU
    input [11:0] swreg,
    input [1:0] dispsel,
    input run,
    input loadpc,
    input step,
    input deposit,

    //   CPU to Panel
    output [11:0] dispout,
    output linkout,
    output halt,

    // IO Bus
    //   CPU to IOT Distributor
    output bit1_cp2,
    output bit2_cp3,
    output [2:0] io_address,
    output [7:0] dataout,

    //   IOT Distributor to CPU
    input skip_flag,
    input clearacc,
    input [7:0] datain,

    // UART Bus
    //   IOT Distributor to UART
    //clear_3 : STD_LOGIC;
    //load_3 : STD_LOGIC;
    //dataout_3 : STD_LOGIC_VECTOR(7 downto 0);

    //    UART to IOT Distributor
    //ready_3 : STD_LOGIC;
    //clearacc_3 : STD_LOGIC;
    //datain_3 : STD_LOGIC_VECTOR(7 downto 0);

    // Memory Bus
    //   CPU to RAM
    output reg [11:0] address,
    output reg [11:0] write_data,
    output write_enable,
    output mem_load,

    //   RAM to CPU
    input [11:0] read_data,
    input mem_ready
);

`define USE_WIRE
`include "control.vh"
`undef USE_WIRE

//type word is std_logic_vector(11 downto 0);
//wire ac : word = 0;
//wire ir : word = 0;
//wire ea : word = 0;
//wire [11:0] ac = 0;
//wire link = 1'b0;
reg [12:0] link_ac = 0;
wire [11:0] ac;
wire link;
reg [11:0] ir = 0;
reg [11:0] ma = 0;
reg [11:0] md = 0;
//wire [11:0] ea = 0;
reg [11:0] ea;
reg [11:0] pc = 0;
reg skip;

localparam integer ZBit = 7;
localparam integer IBit = 8;

// OPR (111) uC bits
localparam integer UcGroup1Bit = 8;
localparam integer UcGroup2Bit = 0;

localparam integer Group1 = 2'd0;
localparam integer Group2 = 2'd1;
localparam integer Group3 = 2'd2;
`define UC_GROUP_T wire [1:0]
`UC_GROUP_T uc_group;

// uC Group 1 bits
localparam integer ClaBit = 7;
localparam integer CllBit = 6;
localparam integer CmaBit = 5;
localparam integer CmlBit = 4;
localparam integer RarBit = 3;
localparam integer RalBit = 2;
localparam integer BswBit = 1;
localparam integer IacBit = 0;

// uC Group 2 bits
//localparam integer ClaBit = 7;
localparam integer SmaBit = 6;
localparam integer SzaBit = 5;
localparam integer SnlBit = 4;
localparam integer AndBit = 3;
localparam integer OsrBit = 2;
localparam integer HltBit = 1;

// uC Group 3 bits
//localparam integer ClaBit = 7;
localparam integer MqaBit = 6;
localparam integer ScaBit = 5;
localparam integer MqlBit = 4;
// 3:1 Code bits

// uC decoded signals
wire en_cla;
wire en_cll;
wire en_cma;
wire en_cml;
reg en_rar;
reg en_ral;
reg en_rtr;
reg en_rtl;
reg en_bsw;
wire en_iac;
wire en_sma;
wire en_sza;
wire en_snl;
wire en_and;

wire [12:0] uc1_stage1;
wire [12:0] uc1_stage2;
wire [12:0] uc1_stage3;
wire [12:0] uc1_stage4;

wire [12:0] uc2_stage1;
wire uc2_skip;

reg [12:0] uc_link_ac;
reg uc_skip;

`sel_ac_t sel_ac;
`sel_pc_t sel_pc;
`sel_skip_t sel_skip;
`sel_addr_t sel_addr;
`sel_data_t sel_data;
`sel_iot_t sel_iot;
`sel_ir_t sel_ir;
`sel_ma_t sel_ma;
`sel_md_t sel_md;

wire md_clear;
wire iot_skip2;

wire [2:0] iot_bits;

wire mem_read, mem_write;

    state inst_state(
        .clk(clk),
        .run(1'b1),
        .opcode(ir[11:9]),
        .indirect(ir[IBit]),
        .sel_ac(sel_ac),
        .sel_pc(sel_pc),
        .sel_skip(sel_skip),
        .sel_addr(sel_addr),
        .sel_data(sel_data),
        .sel_iot(sel_iot),
        .sel_ir(sel_ir),
        .sel_ma(sel_ma),
        .sel_md(sel_md),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_valid(mem_ready),
        .halted(halt)
    );

    always @* case(sel_addr)
        addr_ea:  address = ea;
        addr_ma:  address = ma;
        addr_pc:  address = pc;
        default:  address = ea;
    endcase

    always @* case(sel_data)
        data_ac:  write_data = ac;
        data_md:  write_data = md;
        //data_pc:  write_data = pc;
        data_pc1:  write_data = pc+1;
        default:  write_data = ea;
    endcase

    // Address calculation
    //process(posedge clk)
    //variable page : std_logic_vector(11 downto 7);
    //begin
    //  if rising_edge(clk) then
    //      if ir(ZBit) == 1'b1 then
    //          page := pc(11 downto 7);
    //      else
    //          page := (others => 1'b0);
    //      end if;
    //      ea <= page & ir(6 downto 0);
    //  end if;
    //end process;
    //always @(pc[11:7], ir[ZBit], ir[6:0])
    // TODO Is this the best way to emulate a VHDL variable?
    reg [11:7] page;
    always @*
    begin
        if(ir[ZBit] == 1'b1)
            page = pc[11:7];
        else
            page = 5'b0;
        ea <= {page, ir[6:0]};
    end

    // Program Counter
    always @(posedge clk)
    begin
        if(sel_pc == pc_data)
            pc <= read_data;
        else if(sel_pc == pc_ma)
            pc <= ma;
        else if(sel_pc == pc_ma1)
            pc <= ma + 1;
        else if(sel_pc == pc_incr) begin
            if(skip == 1'b1)
                pc <= pc + 12'd2;
            else
                pc <= pc + 12'd1;
        end
    end

    // Accumulator and Link
    always @(posedge clk)
    begin
        if(sel_ac == ac_and_md)
            link_ac <= link_ac & {1'b1, md};
        else if(sel_ac == ac_add_md)
            link_ac <= link_ac + {1'b0, md};
        else if(sel_ac == ac_zero)
            link_ac <= {link, 12'b000000000000};
        else if(sel_ac == ac_uc)
            link_ac <= uc_link_ac;
        else if(sel_ac == ac_iot) begin
            if(clearacc)
                link_ac <= {link, 4'b0000, datain};
            else
                link_ac <= {link, ac | {4'b0000, datain}};
        end
    end

    // Instruction Register
    always @(posedge clk)
    begin
        if(sel_ir == ir_data)
            ir <= read_data;
    end

    // Memory Address
    always @(posedge clk)
    begin
        if(sel_ma == ma_data)
            ma <= read_data;
        else if(sel_ma == ma_ea)
            ma <= ea;
    end

    // Memory Data
    always @(posedge clk)
    begin
        if(sel_md == md_data)
            md <= read_data;
        else if(sel_md == md_data1)
            md <= read_data + 1;
    end
    assign md_clear = (md == 12'b0) ? 1'b1 : 1'b0;

    assign iot_skip2 = (skip_flag && ir[0] == 1'b1) ? 1'b1 : 1'b0;
    always @* case(sel_skip)
        skip_md_clear:  skip = md_clear;
        skip_uc:        skip = uc_skip;
        skip_iot:       skip = iot_skip2;
        default:        skip = 1'b0;
    endcase

    // Decoding OPR instructions
    assign uc_group = (ir[UcGroup1Bit] == 1'b0) ? Group1 :
                      (ir[UcGroup2Bit] == 1'b0) ? Group2 :
                      Group3;

    assign en_cla = ir[ClaBit];
    assign en_cll = ir[CllBit];
    assign en_cma = ir[CmaBit];
    assign en_cml = ir[CmlBit];
    assign en_iac = ir[IacBit];
    assign en_sma = ir[SmaBit];
    assign en_sza = ir[SzaBit];
    assign en_snl = ir[SnlBit];
    assign en_and = ir[AndBit];

    always @(ir[RarBit:BswBit])
    begin
        en_rar <= 1'b0;
        en_rtr <= 1'b0;
        en_ral <= 1'b0;
        en_rtl <= 1'b0;
        en_bsw <= 1'b0;
        case(ir[RarBit:BswBit])
            3'b100: en_rar <= 1'b1;
            3'b101: en_rtr <= 1'b1;
            3'b010: en_ral <= 1'b1;
            3'b011: en_rtl <= 1'b1;
            3'b001: en_bsw <= 1'b1;
            default: ;
        endcase
    end

    // uC Group 1 processing
    assign uc1_stage1[11:0] = en_cla ? 12'b0 : ac;
    assign uc1_stage1[12]   = en_cll ?  1'b0 : link;
    assign uc1_stage2[11:0] = en_cma ? ~uc1_stage1[11:0] : uc1_stage1[11:0];
    assign uc1_stage2[12]   = en_cml ? ~uc1_stage1[12]   : uc1_stage1[12];
    assign uc1_stage3 = en_iac ? uc1_stage2 + 1 : uc1_stage2;
    assign uc1_stage4 = en_ral ? {uc1_stage3[11:00], uc1_stage3[12:12]} :
                        en_rtl ? {uc1_stage3[10:00], uc1_stage3[12:11]} :
                        en_rar ? {uc1_stage3[00:00], uc1_stage3[12:01]} :
                        en_rtr ? {uc1_stage3[01:00], uc1_stage3[12:02]} :
                        en_bsw ? {uc1_stage3[12]   , uc1_stage3[5:0], uc1_stage3[11:6]} :
                        uc1_stage3;

    // uC Group 2 processing
    assign uc2_stage1[11:0] = en_cla ? 12'b0 : ac;
    assign uc2_stage1[12] = link;

    assign uc2_skip = ((en_sma && ac[11] == 1'b1) ||
                       (en_sza && ac == 12'b0) ||
                       (en_snl && link)) ^
                      en_and ? 1'b1 : 1'b0;

    always @(uc_group, uc1_stage4, uc2_stage1, uc2_skip, link_ac)
    begin
        case(uc_group)
            Group1: begin
                uc_link_ac <= uc1_stage4;
                uc_skip <= 1'b0;
            end
            Group2: begin
                uc_link_ac <= uc2_stage1;
                uc_skip <= uc2_skip;
            end
            Group3: begin
                uc_link_ac <= link_ac;
                uc_skip <= 1'b0;
            end
            default: begin
                uc_link_ac <= link_ac;
                uc_skip <= 1'b0;
            end
        endcase
    end

    assign ac = link_ac[11:0];
    assign link = link_ac[12];

    // TODO Should all ac bits be supported?
    //dataout <= ac;
    assign dataout = ac[7:0];
    // TODO Support all address bits
    //io_address <= ir[8:3] when sel_iot == iot_en else 6'b000000;
    assign io_address = (sel_iot == iot_en) ? ir[8:6] : 6'b000000;
    assign iot_bits = ir[2:0];

    assign bit1_cp2 = iot_bits[1];
    assign bit2_cp3 = iot_bits[2];

    assign mem_load = mem_write | mem_read;
    assign write_enable = mem_write;
endmodule

//10 ... 02 01 00 12 11 RTL
//11 10 ... 02 01 00 12 RAL
//12 11 10 ... 02 01 00
//00 12 11 10 ... 02 01 RAR
//01 00 12 11 10 ... 02 RTR
