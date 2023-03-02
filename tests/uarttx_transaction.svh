class uarttx_transaction extends uvm_sequence_item;
    rand bit [7:0] data;

    function new(string name="uarttx_transaction");
        super.new();
    endfunction

    function string convert2string();
        return $sformatf("char=%c", data);
    endfunction
endclass: uarttx_transaction

class uarttx_transaction_out extends uvm_sequence_item;
    logic [7:0] data;

    function new(string name="uarttx_transaction_out");
        super.new();
    endfunction

    function string convert2string();
        return $sformatf("char=%c", data);
    endfunction
endclass: uarttx_transaction_out
