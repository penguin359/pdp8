class uarttx_bus_sequencer extends uvm_sequencer #(uart_transaction);
    `uvm_component_utils(uarttx_bus_sequencer)

    function new(string name = "uarttx_bus_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass: uarttx_bus_sequencer
