class uarttx_bus_sequencer extends uvm_sequencer #(uart_transaction);
    `uvm_component_utils(uarttx_bus_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: uarttx_bus_sequencer
