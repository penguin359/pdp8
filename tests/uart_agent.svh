class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    typedef uvm_sequencer #(uart_transaction) uart_sequencer;

    uart_config uconfig;

    uart_driver driver;
    uart_sequencer seq;
    uart_monitor monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_fatal("UART_AGENT", "agent failed to get uart configuration");
        end

        if(uconfig.active == UVM_ACTIVE) begin
            driver = uart_driver::type_id::create("driver", this);
            seq = uart_sequencer::type_id::create("sequencer", this);
	    `uvm_info("UART_AGENT", "UART Agent Active", UVM_MEDIUM);
        end else begin
	    `uvm_info("UART_AGENT", "UART Agent Passive", UVM_MEDIUM);
        end
        monitor = uart_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(uconfig.active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(seq.seq_item_export);
        end
    endfunction
endclass: uart_agent
