class cpu_reference;
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

    function void handle_txn(cpu_transaction trans);
        // Verify that the address used for this read or write transaction
        // is correct
        if(state == READ_INSTR) begin
            index++;
            last_opcode = trans.get_opcode();
            if(trans.addr != pc)
                `uvm_error("CPU_REFERENCE",
                    $sformatf("[%08t:%3d] Incorrect instruction address (%03h != %03h)",
                    $realtime, index, trans.addr, pc))
        end else begin
            if(trans.addr != data_addr)
                `uvm_error("CPU_REFERENCE",
                    $sformatf("[%08t:%3d] Incorrect read address (%03h != %03h)",
                    $realtime, index, trans.addr, data_addr))
        end

        // Verify the bus transaction type
        if(state == WRITE_DATA) begin
            if(!trans.write_access)
                `uvm_error("CPU_REFERENCE",
                    $sformatf("[%08t:%3d] Read executed when write expected",
                    $realtime, index))
        end else begin
            if(trans.write_access)
                `uvm_error("CPU_REFERENCE",
                    $sformatf("[%08t:%3d] Write executed when read expected",
                    $realtime, index))
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

        case(last_opcode)
            3'b000: begin // AND
                if(state == READ_DATA) begin
                    acc = acc & trans.read_data;
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = READ_DATA;
                end
            end
            3'b001: begin // TAD
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
            3'b010: begin // ISZ
                if(state == READ_DATA) begin
                    isz_data = trans.read_data + 1;
                    state = WRITE_DATA;
                end else if(state == WRITE_DATA) begin
                    if(trans.write_data != isz_data)
                        `uvm_error("CPU_REFERENCE",
                            $sformatf("[%08t:%3d] Write executed when read expected",
                            $realtime, index))
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = READ_DATA;
                end
            end
            3'b011: begin // DCA
                if(state == WRITE_DATA) begin
                    if(trans.write_data != acc)
                        cpu_error($sformatf("Incorrect data written in DCA (%03h != %03h)",
                            trans.write_data, acc));
                    acc = 0;
                    pc = pc + 1;
                    state = READ_INSTR;
                end else begin
                    state = WRITE_DATA;
                end
            end
            3'b100: begin // JMS
                if(state == WRITE_DATA) begin
                    if(trans.write_data != data_addr)
                        cpu_error($sformatf("Incorrect data written in JMS (%03h != %03h)",
                            trans.write_data, data_addr));
                    pc = data_addr+1;
                    state = READ_INSTR;
                end else begin
                    state = WRITE_DATA;
                end
            end
            3'b101: begin // JMP
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
