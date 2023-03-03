class uart_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uart_driver);

    uart_config uconfig;

    virtual uart_if.DRIVER vif;

    uvm_analysis_port #(uart_transaction) port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_error("UARTTX_BUS_DRIVER", "driver failed to get uart configuration");
        end
        vif = uconfig.serial_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

	vif.rx = 1'b1;
        //wait(vif.nrst == 1);
        #1

        forever begin
            uart_transaction trans;
	    logic [7:0] shift_reg;

            seq_item_port.get_next_item(trans);
            `uvm_info("UART_DRIVER", $sformatf("RX Sent char time=%0t char=%c value=0x%02h", $time, trans.data, trans.data), UVM_MEDIUM);
            port.write(trans);
            shift_reg = trans.data;
            vif.rx = 1'b0;
            #(1s/uconfig.baud);
            repeat(8) begin
                vif.rx = shift_reg[0];
                shift_reg = {1'b0, shift_reg[7:1]};
                #(1s/uconfig.baud);
            end
            vif.rx = 1'b1;
            #(1s/uconfig.baud);
            #(1s/uconfig.baud);
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: uart_driver
