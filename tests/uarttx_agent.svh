class uarttx_agent extends uvm_agent;
    `uvm_component_utils(uarttx_agent);

    uarttx_driver driver;

    virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = uarttx_driver::type_id::create("driver", this);
        uvm_config_db #(virtual uarttx_if)::set(this, "driver", "vif", vif);
    endfunction
endclass: uarttx_agent
