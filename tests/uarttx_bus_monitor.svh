class uarttx_bus_monitor extends uvm_monitor;
    `uvm_component_utils(uarttx_bus_monitor)

    virtual uarttx_bus_if.MONITOR vif;

    uart_config uconfig;

    uvm_analysis_port #(uart_transaction) port;

    function new(string name = "uarttx_bus_monitor", uvm_component parent = null);
        super.new(name, parent);
        port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_fatal("UARTTX_BUS_MONITOR", "driver failed to get uart configuration")
        end
        vif = uconfig.uarttx_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            uart_transaction trans;
            wait(vif.monitor_cb.tx_load == 1);
            trans = new;
            trans.data = vif.monitor_cb.tx_data;
            port.write(trans);
            wait(vif.monitor_cb.tx_load == 0);
        end
    endtask: run_phase
endclass: uarttx_bus_monitor
