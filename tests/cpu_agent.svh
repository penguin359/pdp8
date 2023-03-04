class cpu_agent extends uvm_agent;
    `uvm_component_utils(cpu_agent);

    typedef uvm_sequencer #(cpu_transaction) cpu_sequencer;

    cpu_driver driver;
    cpu_sequencer seq;
    cpu_monitor monitor;

    function new(string name = "cpu_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = cpu_driver::type_id::create("driver", this);
        seq = cpu_sequencer::type_id::create("sequencer", this);
        monitor = cpu_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
endclass: cpu_agent
