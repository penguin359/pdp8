class uarttx_sequencer extends uvm_sequencer #(uarttx_transaction);
    `uvm_component_utils(uarttx_sequencer);

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: uarttx_sequencer
