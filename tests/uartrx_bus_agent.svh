class uartrx_bus_agent extends uvm_agent;
    `uvm_component_utils(uartrx_bus_agent)

    uartrx_bus_driver driver;
    //uartrx_sequencer seq;
    uartrx_bus_monitor monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = uartrx_bus_driver::type_id::create("driver", this);
        //seq = uartrx_sequencer::type_id::create("sequencer", this);
        monitor = uartrx_bus_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
endclass: uartrx_bus_agent
