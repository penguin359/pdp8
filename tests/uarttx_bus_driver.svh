class uarttx_bus_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uarttx_bus_driver)

    uart_config uconfig;

    virtual uarttx_bus_if.DRIVER vif;

    function new(string name = "uarttx_bus_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_fatal("UARTTX_BUS_DRIVER", "driver failed to get uart configuration")
        end
        vif = uconfig.uarttx_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(vif.nrst === 1);
        #1
        forever begin
            uart_transaction trans;
            seq_item_port.get_next_item(trans);
            `uvm_info("UARTTX_BUS_DRIVER", $sformatf("Sent char time=%0t char=%c value=0x%02h", $time, trans.data, trans.data), UVM_MEDIUM)
            assert(vif != null);
            @(posedge vif.clk);
            vif.driver_cb.tx_load <= 1;
            vif.driver_cb.tx_data <= trans.data;
            @(posedge vif.clk);
            if(vif.driver_cb.tx_ready === 1)
                `uvm_warning("UARTTX_BUS_DRIVER", "TX still ready after load")
            vif.driver_cb.tx_load <= 0;
            vif.driver_cb.tx_data <= 0;
            @(posedge vif.clk);
            wait(vif.driver_cb.tx_ready === 0);
            wait(vif.driver_cb.tx_ready === 1);
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: uarttx_bus_driver
