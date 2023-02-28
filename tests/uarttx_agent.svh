class uarttx_agent extends uvm_agent;
    `uvm_component_utils(uarttx_agent);

    uarttx_driver driver;
    uarttx_sequencer seq;

    virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = uarttx_driver::type_id::create("driver", this);
        seq = uarttx_sequencer::type_id::create("sequencer", this);
        uvm_config_db #(virtual uarttx_if.DRIVER)::set(this, "driver", "vif", vif);

        if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
            `uvm_error("build_phase", "driver failed to get virtual interface");
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
endclass: uarttx_agent
