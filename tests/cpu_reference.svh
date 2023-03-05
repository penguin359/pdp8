class cpu_reference;
    `include "pdp8.vh"

    bit link = 1'b0;
    //bit [D_WIDTH-1:0] acc = D_WIDTH'b0;
    //bit [D_WIDTH-1:0] pc  = A_WIDTH'b0;
    bit [D_WIDTH-1:0] acc       = 12'b0;
    bit [D_WIDTH-1:0] mq        = 12'b0;
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
            OPCODE_OPR: begin
                if(trans.read_data[UC_GROUP1_BIT] == 1'b0) begin
                    logic [2:0] rotate_bits;
                    // Group 1 microcoded instruction
                    if(trans.read_data[CLA_BIT] == 1'b1)
                        acc = 0;
                    if(trans.read_data[CLL_BIT] == 1'b1)
                        link = 0;
                    if(trans.read_data[CMA_BIT] == 1'b1)
                        acc = ~acc;
                    if(trans.read_data[CML_BIT] == 1'b1)
                        link = ~link;
                    if(trans.read_data[IAC_BIT] == 1'b1) begin
                        logic [12:0] link_acc = {link, acc} + 13'b1;
                        link = link_acc[12];
                        acc = link_acc[11:0];
                    end
                    rotate_bits = {trans.read_data[RAL_BIT], trans.read_data[RAR_BIT], trans.read_data[BSW_BIT]};
                    case(rotate_bits)
                        3'b000: ;  // Nothing to do
                        3'b100: begin  // RAL (rotate left)
                            logic [12:0] link_acc = {acc, link};
                            link = link_acc[12];
                            acc = link_acc[11:0];
                        end
                        3'b101: begin  // RTL (rotate twice left)
                            logic [12:0] link_acc = {acc[10:0], link, acc[11]};
                            link = link_acc[12];
                            acc = link_acc[11:0];
                        end
                        3'b010: begin  // RAR (rotate right)
                            logic [12:0] link_acc = {acc[0], link, acc[11:1]};
                            link = link_acc[12];
                            acc = link_acc[11:0];
                        end
                        3'b011: begin  // RTR (rotate twice right)
                            logic [12:0] link_acc = {acc[9:0], link, acc[11:10]};
                            link = link_acc[12];
                            acc = link_acc[11:0];
                        end
                        3'b001: begin  // BSW (byte swap)
                            acc = {acc[5:0], acc[11:6]};
                        end
                        default:
                            // This is a warning since these combinations
                            // are completely unspecified in any document.
                            `uvm_warning("CPU_REFERENCE", "Invalid microcode instruction")
                    endcase
                end else if(trans.read_data[UC_GROUP2_BIT] == 1'b0) begin
                    // Group 2 microcoded instruction
                    bit skip = 0;
                    if(trans.read_data[AND_BIT] == 1'b0) begin
                        // OR sub-group
                        if(trans.read_data[SMA_BIT] == 1'b1 && acc[11] == 1'b1)
                            skip = 1'b1;
                        if(trans.read_data[SZA_BIT] == 1'b1 && acc == 12'b0)
                            skip = 1'b1;
                        if(trans.read_data[SNL_BIT] == 1'b1 && link == 1'b1)
                            skip = 1'b1;
                    end else begin
                        // AND sub-group
                        // TODO This has to have a cleaner way to write it.
                        skip = 1'b1;
                        if(trans.read_data[SMA_BIT] == 1'b1) begin  // SPA
                            if(acc[11] == 1'b1)
                                skip = 0'b1;
                        end
                        if(trans.read_data[SZA_BIT] == 1'b1) begin  // SNA
                            if(acc[11] == 12'b0)
                                skip = 0'b1;
                        end
                        if(trans.read_data[SNL_BIT] == 1'b1) begin  // SZL
                            if(link == 1'b1)
                                skip = 0'b1;
                        end
                    end
                    if(skip)
                        pc = pc + 1;
                    if(trans.read_data[CLA_BIT] == 1'b1)
                        acc = 0;
                    if(trans.read_data[OSR_BIT] == 1'b1 ||
                       trans.read_data[HLT_BIT] == 1'b1)
                        cpu_error("Unimplemented OPR!");
                end else begin
                    // Group 3 microcoded instruction
                    if(trans.read_data[CLA_BIT] == 1'b1)
                        acc = 0;
                    if(trans.read_data[MQA_BIT] == 1'b1)
                        acc = acc | mq;
                    if(trans.read_data[MQL_BIT] == 1'b1) begin
                        mq = acc;
                        acc = 0;
                    end
                    if({trans.read_data[SCA_BIT], trans.read_data[3:1]} != 4'b0)
                        cpu_error("Unimplemented OPR!");
                end
                pc = pc + 1;
                state = READ_INSTR;
            end
            OPCODE_IOT: begin
                cpu_error("Unimplemented IOT!");
            end
        endcase
    endfunction
endclass: cpu_reference
