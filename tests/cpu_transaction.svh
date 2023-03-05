class cpu_transaction extends uvm_sequence_item;
    rand bit [11:0] addr;
    rand bit [11:0] read_data;
    rand bit [11:0] write_data;

    bit write_access;

    enum { TXN_INSTR, TXN_DATA, TXN_ADDRESS } value_type;

    typedef logic [2:0] opcode_bits_t;
    typedef enum opcode_bits_t {
        AND=3'b000,
        TAD=3'b001,
        ISZ=3'b010,
        DCA=3'b011,
        JMS=3'b100,
        JMP=3'b101,
        IOT=3'b110,
        OPR=3'b111
    } opcode_t;

    function new(string name="cpu_transaction");
        super.new();
    endfunction

    function string convert2string();
        case(value_type)
            TXN_INSTR: begin
                string opcode;
                case(this.get_opcode())
                    AND: opcode = "AND";
                    TAD: opcode = "TAD";
                    ISZ: opcode = "ISZ";
                    DCA: opcode = "DCA";
                    JMS: opcode = "JMS";
                    JMP: opcode = "JMP";
                    IOT: opcode = "IOT";
                    OPR: opcode = "OPR";
                endcase

                return $sformatf("OP: addr=0x%03h %s i=%d z=%d offset=0x%02h", addr, opcode,
                    this.is_indirect(), this.is_zero_page(), this.get_offset());
            end
            TXN_DATA: return $sformatf("DATA: addr=0x%03h value=0x%03h", addr, read_data);
            TXN_ADDRESS: return $sformatf("ADDRESS: addr=0x%03h value=0x%03h", addr, read_data);
        endcase
    endfunction

    function logic [6:0] get_offset();
        return read_data[6:0];
    endfunction

    function void set_offset(logic [6:0] offset);
        value_type = TXN_INSTR;
        read_data[6:0] = offset;
    endfunction

    function bit is_zero_page();
        return read_data[7] == 1 ? 1'b1 : 1'b0;
    endfunction

    function void set_zero_page(bit zero_page);
        value_type = TXN_INSTR;
        read_data[7] = zero_page;
    endfunction

    function bit is_indirect();
        return read_data[8] == 1 ? 1'b1 : 1'b0;
    endfunction

    function void set_indirect(bit indirect);
        value_type = TXN_INSTR;
        read_data[8] = indirect;
    endfunction

    function opcode_t get_opcode();
        return opcode_t'(read_data[11:9]);
    endfunction

    function void set_opcode(opcode_t opcode);
        value_type = TXN_INSTR;
        read_data[11:9] = opcode_bits_t'(opcode);
    endfunction

    function void set_data(logic [11:0] value);
        value_type = TXN_DATA;
        read_data[11:0] = value;
    endfunction

    function void set_address(logic [11:0] value);
        value_type = TXN_ADDRESS;
        read_data[11:0] = value;
    endfunction
endclass: cpu_transaction
