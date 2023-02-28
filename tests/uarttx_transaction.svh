class uarttx_transaction extends uvm_sequence_item;
    rand bit [7:0] data;
    logic [7:0] actual;

    function new(string name="uarttx_transaction");
        super.new();
    endfunction

    function string convert2string();
        string s;
        $sformat(s, "char=%c", data);
        return s;
    endfunction
endclass: uarttx_transaction
