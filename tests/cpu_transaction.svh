class cpu_transaction extends uvm_sequence_item;
    `include "pdp8.vh"

    rand bit [11:0] addr;
    rand bit [11:0] read_data;
    rand bit [11:0] write_data;

    enum { TXN_INSTR, TXN_ADDRESS, TXN_READ, TXN_WRITE } value_type;

    typedef logic [2:0] opcode_bits_t;
    typedef enum opcode_bits_t {
        AND=OPCODE_AND,
        TAD=OPCODE_TAD,
        ISZ=OPCODE_ISZ,
        DCA=OPCODE_DCA,
        JMS=OPCODE_JMS,
        JMP=OPCODE_JMP,
        IOT=OPCODE_IOT,
        OPR=OPCODE_OPR
    } opcode_t;

    function new(string name="cpu_transaction");
        super.new();
        set_zero_page(1);
        set_indirect(0);
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
            TXN_ADDRESS: return $sformatf("ADDRESS: addr=0x%03h value=0x%03h", addr, read_data);
            TXN_READ: return $sformatf("READ: addr=0x%03h value=0x%03h", addr, read_data);
            TXN_WRITE: return $sformatf("WRITE: addr=0x%03h value=0x%03h", addr, read_data);
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
        // Z_BIT is set if accessing current page
        return read_data[Z_BIT] == 1 ? 1'b0 : 1'b1;
    endfunction

    function void set_zero_page(bit zero_page);
        value_type = TXN_INSTR;
        read_data[Z_BIT] = zero_page ? 1'b0 : 1'b1;
    endfunction

    function bit is_indirect();
        return read_data[I_BIT] == 1 ? 1'b1 : 1'b0;
    endfunction

    function void set_indirect(bit indirect);
        value_type = TXN_INSTR;
        read_data[I_BIT] = indirect;
    endfunction

    function opcode_t get_opcode();
        return opcode_t'(read_data[11:9]);
    endfunction

    function void set_opcode(opcode_t opcode);
        value_type = TXN_INSTR;
        read_data[11:9] = opcode_bits_t'(opcode);
    endfunction

    function void set_address(logic [11:0] value);
        value_type = TXN_ADDRESS;
        read_data[11:0] = value;
    endfunction

    function void set_read_data(logic [11:0] value);
        value_type = TXN_READ;
        read_data[11:0] = value;
    endfunction

    function bit is_write();
        return (value_type == TXN_WRITE) ? 1'b1 : 1'b0;
    endfunction

    function void set_write_data(logic [11:0] value);
        value_type = TXN_WRITE;
        write_data[11:0] = value;
    endfunction
endclass: cpu_transaction
