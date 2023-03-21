class iot_monitor extends uvm_monitor;
    `uvm_component_utils(iot_monitor)

    virtual iot_if.MONITOR vif;

    iot_config bus_config;

    uvm_analysis_port #(iot_transaction) port;

    function new(string name = "iot_monitor", uvm_component parent = null);
        super.new(name, parent);
        port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(iot_config)::get(this, "", "iot_config", bus_config)) begin
            `uvm_fatal("UART_MONITOR", "failed to get iot configuration");
        end
        vif = bus_config.iot_if;
	assert(vif != null);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            iot_transaction txn;

            @(posedge vif.clk && (vif.monitor_cb.clear || vif.monitor_cb.load));
            txn = new;
            txn.ready = vif.monitor_cb.ready;
            txn.clear = vif.monitor_cb.clear;
            txn.clearacc = vif.monitor_cb.clearacc;
            txn.data_out = vif.monitor_cb.dataout;
            txn.data_in = vif.monitor_cb.datain;
            txn.load = vif.monitor_cb.load;
            port.write(txn);
            `uvm_info("IOT_MONITOR", $sformatf("I/O TXN: %s", txn.convert2string()), UVM_MEDIUM);
        end
    endtask: run_phase
endclass: iot_monitor
