class uarttx_driver extends uvm_driver #(uarttx_transaction);
    `uvm_component_utils(uarttx_driver);

    virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
            `uvm_error("build_phase", "driver failed to get virtual interface");
        end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass: uarttx_driver
