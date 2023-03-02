class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor);

    virtual uart_if vif;

    uart_config uconfig;

    uvm_analysis_port #(uarttx_transaction_out) port;

    function new(string name = "uart_monitor", uvm_component parent = null);
        super.new(name, parent);
        port = new("analysis_port_out", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_error("UART_MONITOR", "driver failed to get uart configuration");
        end
        vif = uconfig.serial_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            logic [7:0] rx_reg;
            uarttx_transaction_out trans;

            @(negedge vif.tx);
            phase.raise_objection(this, "Receiving byte over UART");
            #(1s/uconfig.baud/2);
            repeat(8)
            begin
                #(1s/uconfig.baud) rx_reg = {vif.tx, rx_reg[7:1]};
                `uvm_info("UART_MONITOR", $sformatf("Bit shift time=%0t bit=0x%02h", $time, vif.tx), UVM_HIGH);
            end
            #(1s/uconfig.baud)
            `uvm_info("UART_MONITOR", $sformatf("Received char time=%0t char=%c value=0x%02h", $time, rx_reg, rx_reg), UVM_MEDIUM);
            trans = new;
            trans.data = rx_reg;
            port.write(trans);
            phase.drop_objection(this);
        end
    endtask: run_phase
endclass: uart_monitor
