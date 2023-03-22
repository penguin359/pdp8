class uart_transaction extends uvm_sequence_item;
    rand bit [7:0] data;

    function new(string name = "uart_transaction");
        super.new();
    endfunction

    function string convert2string();
        return $sformatf("char=%c", data);
    endfunction
endclass: uart_transaction
