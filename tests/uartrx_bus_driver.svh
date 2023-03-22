class uartrx_bus_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uartrx_bus_driver)

    uart_config uconfig;

    virtual uartrx_bus_if.DRIVER vif;

    function new(string name = "uartrx_bus_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(uart_config)::get(this, "", "uart_config", uconfig)) begin
            `uvm_fatal("UARTRX_BUS_DRIVER", "driver failed to get uart configuration")
        end
        vif = uconfig.uartrx_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(vif.nrst == 1);
        #1
        forever begin
            //`uvm_info("UARTRX_BUS_DRIVER", $sformatf("Received char time=%0t char=%c value=0x%02h", $time, trans.data, trans.data), UVM_MEDIUM)
            @(posedge vif.clk);
	    wait(vif.driver_cb.rx_load == 1);
            vif.driver_cb.rx_ready <= 1;
            @(posedge vif.clk);
            vif.driver_cb.rx_ready <= 0;
        end
    endtask: run_phase
endclass: uartrx_bus_driver
