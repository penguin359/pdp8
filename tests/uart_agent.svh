class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent);

    //uart_driver driver;
    //uart_sequencer seq;
    uart_monitor monitor;

    //virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //driver = uart_driver::type_id::create("driver", this);
        //seq = uart_sequencer::type_id::create("sequencer", this);
        monitor = uart_monitor::type_id::create("monitor", this);
        //uvm_config_db #(virtual uarttx_if.DRIVER)::set(this, "driver", "vif", vif);

        //if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
        //    `uvm_error("UART_AGENT", "driver failed to get virtual interface");
        //end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //driver.seq_item_port.connect(seq.seq_item_export);
    endfunction
endclass: uart_agent
