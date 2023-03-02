class uartrx_bus_monitor extends uvm_monitor;
    `uvm_component_utils(uartrx_bus_monitor);

    virtual uartrx_bus_if.MONITOR vif;

    uart_config uconfig;

    uvm_analysis_port #(uart_transaction) port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_fatal("UARTRX_BUS_MONITOR", "driver failed to get uart configuration");
        end
        vif = uconfig.uartrx_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            uart_transaction trans;
            wait(vif.monitor_cb.rx_load == 1);
            trans = new;
            trans.data = vif.monitor_cb.rx_data;
            port.write(trans);
            wait(vif.monitor_cb.rx_load == 0);
        end
    endtask: run_phase
endclass: uartrx_bus_monitor
