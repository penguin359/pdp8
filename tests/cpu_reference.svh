class cpu_reference;
    `include "pdp8.vh"

    localparam A_WIDTH = 12;
    localparam D_WIDTH = 12;

    bit link = 1'b0;
    //bit [D_WIDTH-1:0] acc = D_WIDTH'b0;
    //bit [D_WIDTH-1:0] pc  = A_WIDTH'b0;
    bit [D_WIDTH-1:0] acc       = 12'b0;
    bit [D_WIDTH-1:0] pc        = 12'b0;

    bit [D_WIDTH-1:0] mem [0:2**A_WIDTH-1];

    enum { READ_INSTR, READ_INDIRECT, READ_DATA, WRITE_DATA } state;

    logic [2:0] last_opcode;
    bit [D_WIDTH-1:0] data_addr = 12'b0;
    bit [D_WIDTH-1:0] isz_data = 12'b0;

    // Index count of instructions processed
    int index = 0;

    function new();
    endfunction

    function void cpu_error(string error);
        `uvm_error("CPU_REFERENCE",
            $sformatf("[%08t:%3d] %s", $realtime, index, error))
    endfunction

    function void cpu_assert(logic [11:0] actual, logic [11:0] expected, string error);
        if(actual != expected)
            cpu_error($sformatf("%s (%03h != %03h)", error, actual, expected));
    endfunction

    function void handle_txn(cpu_transaction trans);
        // Verify that the address used for this read or write transaction
        // is correct
        if(state == READ_INSTR) begin
            index++;
            last_opcode = trans.get_opcode();
            cpu_assert(trans.addr, pc, "Incorrect instruction address");
        end else begin
            cpu_assert(trans.addr, data_addr, "Incorrect read address");
        end

        // Verify the bus transaction type
        if(state == WRITE_DATA) begin
            if(!trans.is_write())
                cpu_error("Read executed when write expected");
        end else begin
            if(trans.is_write())
                cpu_error("Write executed when read expected");
        end

        // Handle address calculation for memory-reference instructions
        // This might require waiting for an indirection look-up
        if(state == READ_INSTR &&
           last_opcode != 3'b110 &&
           last_opcode != 3'b111) begin
            data_addr[6:0] = trans.get_offset();
            if(trans.is_zero_page())
                data_addr[11:7] = 5'b0;
            else
                data_addr[11:7] = pc[11:7];

            if(trans.is_indirect()) begin
                state = READ_INDIRECT;
                return;
            end
        end else if(state == READ_INDIRECT) begin
            data_addr = trans.read_data;
        end

        // Execute the opcode now
        case(last_opcode)
            OPCODE_AND: begin
                if(state == READ_DATA) begin
                    acc = acc & trans.read_data;
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = READ_DATA;
                end
            end
            OPCODE_TAD: begin
                if(state == READ_DATA) begin
                    logic [12:0] link_acc = {link, acc} + {1'b0, trans.read_data};
                    link = link_acc[12];
                    acc = link_acc[11:0];
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = READ_DATA;
                end
            end
            OPCODE_ISZ: begin
                if(state == READ_DATA) begin
                    isz_data = trans.read_data + 1;
                    state = WRITE_DATA;
                end else if(state == WRITE_DATA) begin
                    cpu_assert(trans.write_data, isz_data, "Incorrect data written back for ISZ");
                    if(isz_data == 12'b0)
                        pc = pc + 2;
                    else
                        pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = READ_DATA;
                end
            end
            OPCODE_DCA: begin
                if(state == WRITE_DATA) begin
                    cpu_assert(trans.write_data, acc, "Incorrect data written in DCA");
                    acc = 0;
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = WRITE_DATA;
                end
            end
            OPCODE_JMS: begin
                if(state == WRITE_DATA) begin
                    cpu_assert(trans.write_data, pc+1, "Incorrect data written in JMS");
                    pc = data_addr+1;
                    state = READ_INSTR;
                end else begin
                    state = WRITE_DATA;
                end
            end
            OPCODE_JMP: begin
                pc = data_addr;
                state = READ_INSTR;
                return;
            end
            default: begin
                if(trans.read_data != 12'b111_000_000_000)
                    cpu_error("Unimplemented OPR or IOT!");
                pc = pc + 1;
                state = READ_INSTR;
            end
        endcase
    endfunction
endclass: cpu_reference
