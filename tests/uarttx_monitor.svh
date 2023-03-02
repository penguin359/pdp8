class uarttx_monitor extends uvm_monitor;
    `uvm_component_utils(uarttx_monitor);

    //localparam baud = 115200;
    localparam baud = 10000000;
    //localparam bit_time = 1s / baud;

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
            wait(vif.tx_load == 1);
            `uvm_warning("run_phase", "Saw neg edge");
            trans = new;
            trans.data = vif.tx_data;
            port.write(trans);
            wait(vif.tx_load == 0);
        end
        forever begin
            logic [7:0] rx_reg;
            uarttx_transaction_out trans_out;

            @(negedge vif.tx);
            phase.raise_objection(this, "Receiving byte over UART");
            #(1s/baud/2);
            repeat(8)
            begin
                #(1s/baud) rx_reg = {vif.tx, rx_reg[7:1]};
                `uvm_info("UARTTX_MONITOR", $sformatf("Bit shift time=%0t bit=0x%0h", $time, vif.tx), UVM_HIGH);
            end
            #(1s/baud)
            `uvm_info("UARTTX_MONITOR", $sformatf("Received char time=%0t char=0x%0h", $time, rx_reg), UVM_MEDIUM);
            trans_out = new;
            trans_out.data = rx_reg;
            port_out.write(trans_out);
            phase.drop_objection(this);
        end
        join
    endtask: run_phase
endclass: uarttx_monitor
