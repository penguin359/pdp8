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
    //    Shalt, Sread_instr, Sdecode_instr, Sread_indirect, Sexec_instr, Sexec_instr2
    //} cpu_state_t;
    localparam Shalt = 3'd0;
    localparam Sread_instr = 3'd1;
    localparam Sdecode_instr = 3'd2;
    localparam Sread_indirect = 3'd3;
    localparam Sexec_instr = 3'd4;
    localparam Sexec_instr2 = 3'd5;
    `define cpu_state_t reg [3:0]
    `cpu_state_t current_state = Shalt;
    `cpu_state_t next_state;
    //typedef wire [11:0] word;
    //word ac = 12'b0;
    //word ir = 12'b0;
    //word ea = 12'b0;
    wire [11:0] ac = 12'b0;
    wire [11:0] ir = 12'b0;
    wire [11:0] ea = 12'b0;
    wire [11:0] pc = 12'b0;

    localparam integer opcode_and = 3'b000;
    localparam integer opcode_tad = 3'b001;
    localparam integer opcode_isz = 3'b010;
    localparam integer opcode_dca = 3'b011;
    localparam integer opcode_jms = 3'b100;
    localparam integer opcode_jmp = 3'b101;
    localparam integer opcode_iot = 3'b110;
    localparam integer opcode_opr = 3'b111;

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
                    next_state <= Sread_instr;
            end
            Sread_instr: begin
                // Read memory at address PC and load into IR
                sel_addr <= addr_pc;
                sel_ir <= ir_data;
                mem_read <= 1'b1;
                if(mem_valid)
                    next_state <= Sdecode_instr;
            end
            Sdecode_instr: begin
                if(opcode == opcode_opr)
                    next_state <= Sexec_instr;
                else if(opcode == opcode_iot)
                    next_state <= Sexec_instr;
                else if(indirect)
                    // Let mem_read drop to 1'b0
                    next_state <= Sread_indirect;
                else begin
                    sel_ma <= ma_ea;
                    next_state <= Sexec_instr;
                end
            end
            Sread_indirect: begin
                sel_addr <= addr_ea;
                sel_ma <= ma_data;
                mem_read <= 1'b1;
                if(mem_valid)
                    next_state <= Sexec_instr;
            end
            Sexec_instr: begin
                case(opcode)
                    opcode_and: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= Sexec_instr2;
                    end
                    opcode_tad: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= Sexec_instr2;
                    end
                    opcode_isz: begin
                        sel_addr <= addr_ma;
                        sel_md <= md_data1;
                        mem_read <= 1'b1;
                        if(mem_valid)
                                next_state <= Sexec_instr2;
                    end
                    opcode_dca: begin
                        sel_addr <= addr_ma;
                        sel_data <= data_ac;
                        mem_write <= 1'b1;
                        if(mem_valid)
                                next_state <= Sexec_instr2;
                    end
                    opcode_jms: begin
                        sel_addr <= addr_ma;
                        sel_data <= data_pc1;
                        mem_write <= 1'b1;
                        if(mem_valid)
                                next_state <= Sexec_instr2;
                    end
                    opcode_jmp: begin
                        sel_pc <= pc_ma;
                        next_state <= Sread_instr;
                    end
                    opcode_iot: begin
                        sel_ac <= ac_iot;
                        sel_pc <= pc_incr;
                        sel_skip <= skip_iot;
                        sel_iot <= iot_en;
                        next_state <= Sread_instr;
                    end
                    opcode_opr: begin
                        sel_ac <= ac_uc;
                        sel_pc <= pc_incr;
                        sel_skip <= skip_uc;
                        next_state <= Sread_instr;
                    end
                    //default:
                endcase
            end
            Sexec_instr2: begin
                sel_pc <= pc_incr;
                next_state <= Sread_instr;
                case(opcode)
                    opcode_and:
                        sel_ac <= ac_and_md;
                    opcode_tad:
                        sel_ac <= ac_add_md;
                    opcode_isz: begin
                        sel_pc <= pc_none;
                        next_state <= current_state;
                        sel_addr <= addr_ma;
                        sel_data <= data_md;
                        mem_write <= 1'b1;
                        if(mem_valid) begin
                            sel_pc <= pc_incr;
                            sel_skip <= skip_md_clear;
                            next_state <= Sread_instr;
                        end
                    end
                    opcode_dca:
                        sel_ac <= ac_zero;
                    opcode_jms:
                        sel_pc <= pc_ma1;
                    //default:
                endcase
            end
            default:
                next_state <= Shalt;
        endcase
    end
endmodule
