class uarttx_monitor extends uvm_monitor;
    `uvm_component_utils(uarttx_monitor);

    virtual uarttx_if vif;

    uvm_analysis_port #(uarttx_transaction) port;
    uvm_analysis_port #(uarttx_transaction_out) port_out;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        port = new("analysis_port", this);
        port_out = new("analysis_port_out", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
            `uvm_error("build_phase", "driver failed to get virtual interface");
        end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_warning("run_phase", "Monitor");
        fork
        forever begin
            uarttx_transaction trans;
            uarttx_transaction_out trans_out;
            wait(vif.tx_load == 1);
            `uvm_warning("run_phase", "Saw neg edge");
            trans = new;
            trans.data = vif.tx_data;
            port.write(trans);
            wait(vif.tx_load == 0);
        end
        forever begin
            uarttx_transaction_out trans_out;
            wait(vif.tx == 0);
            #50;
            trans_out = new;
            trans_out.data = 8'h01;
            port_out.write(trans_out);
        end
        join
    endtask: run_phase
endclass: uarttx_monitor
