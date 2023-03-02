class uarttx_bus_agent extends uvm_agent;
    `uvm_component_utils(uarttx_bus_agent);

    uarttx_bus_driver driver;
    uarttx_sequencer seq;
    uarttx_bus_monitor monitor;

    //virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = uarttx_bus_driver::type_id::create("driver", this);
        seq = uarttx_sequencer::type_id::create("sequencer", this);
        monitor = uarttx_bus_monitor::type_id::create("monitor", this);
        //uvm_config_db #(virtual uarttx_if.DRIVER)::set(this, "driver", "vif", vif);

        //if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
        //    `uvm_error("build_phase", "driver failed to get virtual interface");
        //end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
endclass: uarttx_bus_agent
