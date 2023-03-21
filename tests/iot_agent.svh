class iot_agent extends uvm_agent;
    `uvm_component_utils(iot_agent)

    typedef uvm_sequencer #(iot_transaction) iot_sequencer;

    iot_config bus_config;

    iot_driver driver;
    iot_sequencer seq;
    iot_monitor monitor;

    function new(string name = "iot_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(iot_config)::get(this, "", "iot_config", bus_config)) begin
            `uvm_fatal("IOT_AGENT", "failed to get iot configuration");
        end
        uvm_config_db #(iot_config)::set(this, "driver", "iot_config", bus_config);
        uvm_config_db #(iot_config)::set(this, "monitor", "iot_config", bus_config);
        if(bus_config.active == UVM_ACTIVE) begin
            driver = iot_driver::type_id::create("driver", this);
            seq = iot_sequencer::type_id::create("sequencer", this);
        end
        monitor = iot_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(bus_config.active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(seq.seq_item_export);
        end
    endfunction
endclass: iot_agent
