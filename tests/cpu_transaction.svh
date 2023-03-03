class cpu_transaction extends uvm_sequence_item;
    rand bit [11:0] addr;
    rand bit [11:0] data;

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

    enum { DATA, CODE } value_type = DATA;

    function new(string name="cpu_transaction");
        super.new();
    endfunction

    function string convert2string();
        return $sformatf("char=%c", data);
    endfunction

    function logic [6:0] get_offset();
        return data[6:0];
    endfunction

    function void set_offset(logic [6:0] offset);
        data[6:0] = offset;
    endfunction

    function bit is_zero_page();
        return data[7] == 1 ? 1'b1 : 1'b0;
    endfunction

    function void set_zero_page(bit zero_page);
        data[7] = zero_page;
    endfunction

    function bit is_indirect();
        return data[8] == 1 ? 1'b1 : 1'b0;
    endfunction

    function void set_indirect(bit indirect);
        data[8] = indirect;
    endfunction

    function opcode_t get_opcode();
        return opcode_t'(data[11:9]);
    endfunction

    function void set_opcode(opcode_t opcode);
        data[11:9] = opcode_bits_t'(opcode);
    endfunction
endclass: cpu_transaction
