module state(
    clk,
    run,
    opcode,
    indirect,
    sel_ac,
    sel_pc,
    sel_skip,
    sel_addr,
    sel_data,
    sel_iot,
    sel_ir,
    sel_ma,
    sel_md,
    mem_read,
    mem_write,
    mem_valid,
    halted
);
`include "control.vh"
    input clk;
    input run;
    input [2:0] opcode;
    input indirect;
    output `sel_ac_t sel_ac;
    output `sel_pc_t sel_pc;
    output `sel_skip_t sel_skip;
    output `sel_addr_t sel_addr;
    output `sel_data_t sel_data;
    output `sel_iot_t sel_iot;
    output `sel_ir_t sel_ir;
    output `sel_ma_t sel_ma;
    output `sel_md_t sel_md;
    output reg mem_read;
    output reg mem_write;
    input mem_valid;
    output reg halted;

    // 13 inputs + IR
    // 33 outputs
    // 22 states
    //typedef enum {
    //    Shalt, SreadInstr, SdecodeInstr, SreadIndirect, SexecInstr, SexecInstr2
    //} CPU_STATE_T;
    localparam integer Shalt = 3'd0;
    localparam integer SreadInstr = 3'd1;
    localparam integer SdecodeInstr = 3'd2;
    localparam integer SreadIndirect = 3'd3;
    localparam integer SexecInstr = 3'd4;
    localparam integer SexecInstr2 = 3'd5;
    `define CPU_STATE_T reg [3:0]
    `CPU_STATE_T current_state = Shalt;
    `CPU_STATE_T next_state;
    //typedef wire [11:0] word;
    //word ac = 12'b0;
    //word ir = 12'b0;
    //word ea = 12'b0;
    wire [11:0] ac = 12'b0;
    wire [11:0] ir = 12'b0;
    wire [11:0] ea = 12'b0;
    wire [11:0] pc = 12'b0;

    localparam integer OpcodeAnd = 3'b000;
    localparam integer OpcodeTad = 3'b001;
    localparam integer OpcodeIsz = 3'b010;
    localparam integer OpcodeDca = 3'b011;
    localparam integer OpcodeJms = 3'b100;
    localparam integer OpcodeJmp = 3'b101;
    localparam integer OpcodeIot = 3'b110;
    localparam integer OpcodeOpr = 3'b111;

    always @(posedge clk)
    begin
        current_state <= next_state;
    end

    always @*
    begin
        halted <= 1'b0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        sel_ac <= ac_none;
        sel_pc <= pc_none;
        sel_skip <= skip_none;
        sel_addr <= addr_none;
        sel_data <= data_none;
        sel_iot <= iot_none;
        sel_ir <= ir_none;
        sel_ma <= ma_none;
        sel_md <= md_none;
        next_state <= current_state;
        case(current_state)
            Shalt: begin
                halted <= 1'b1;
                if(run)
                    next_state <= SreadInstr;
            end
            SreadInstr: begin
                // Read memory at address PC and load into IR
                sel_addr <= addr_pc;
                sel_ir <= ir_data;
                mem_read <= 1'b1;
                if(mem_valid)
                    next_state <= SdecodeInstr;
            end
            SdecodeInstr: begin
                if(opcode == OpcodeOpr)
                    next_state <= SexecInstr;
                else if(opcode == OpcodeIot)
                    next_state <= SexecInstr;
                else if(indirect)
                    // Let mem_read drop to 1'b0
                    next_state <= SreadIndirect;
                else begin
                    sel_ma <= ma_ea;
                    next_state <= SexecInstr;
                end
            end
            SreadIndirect: begin
                sel_addr <= addr_ea;
                sel_ma <= ma_data;
                mem_read <= 1'b1;
                if(mem_valid)
                    next_state <= SexecInstr;
            end
            SexecInstr: begin
                case(opcode)
                    OpcodeAnd: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= SexecInstr2;
                    end
                    OpcodeTad: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= SexecInstr2;
                    end
                    OpcodeIsz: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data1;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= SexecInstr2;
                    end
                    OpcodeDca: begin
                        sel_addr <= addr_ma;
                        sel_data <= data_ac;
                        mem_write <= 1'b1;
                        if(mem_valid)
                                next_state <= SexecInstr2;
                    end
                    OpcodeJms: begin
                        sel_addr <= addr_ma;
                        sel_data <= data_pc1;
                        mem_write <= 1'b1;
                        if(mem_valid)
                                next_state <= SexecInstr2;
                    end
                    OpcodeJmp: begin
                        sel_pc <= pc_ma;
                        next_state <= SreadInstr;
                    end
                    OpcodeIot: begin
                        sel_ac <= ac_iot;
                        sel_pc <= pc_incr;
                        sel_skip <= skip_iot;
                        sel_iot <= iot_en;
                        next_state <= SreadInstr;
                    end
                    OpcodeOpr: begin
                        sel_ac <= ac_uc;
                        sel_pc <= pc_incr;
                        sel_skip <= skip_uc;
                        next_state <= SreadInstr;
                    end
                    default: begin
                        next_state <= Shalt;
                    end
                endcase
            end
            SexecInstr2: begin
                sel_pc <= pc_incr;
                next_state <= SreadInstr;
                case(opcode)
                    OpcodeAnd:
                        sel_ac <= ac_and_md;
                    OpcodeTad:
                        sel_ac <= ac_add_md;
                    OpcodeIsz: begin
                        sel_pc <= pc_none;
                        next_state <= current_state;
                        sel_addr <= addr_ma;
                        sel_data <= data_md;
                        mem_write <= 1'b1;
                        if(mem_valid) begin
                            sel_pc <= pc_incr;
                            sel_skip <= skip_md_clear;
                            next_state <= SreadInstr;
                        end
                    end
                    OpcodeDca:
                        sel_ac <= ac_zero;
                    OpcodeJms:
                        sel_pc <= pc_ma1;
                    default: ;
                endcase
            end
            default:
                next_state <= Shalt;
        endcase
    end
endmodule
