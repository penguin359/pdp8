class iot_driver extends uvm_driver #(iot_transaction);
    `uvm_component_utils(iot_driver)

    iot_config bus_config;

    virtual iot_if.DRIVER vif;

    function new(string name = "iot_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(iot_config)::get(this, "", "iot_config", bus_config)) begin
            `uvm_fatal("IOT_DRIVER", "failed to get iot configuration");
        end
        vif = bus_config.iot_if;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

	vif.driver_cb.ready <= 1'b0;
	vif.driver_cb.clearacc <= 1'b0;
	vif.driver_cb.datain <= 12'b0;

        wait(vif.nrst == 1);
        #1
        forever begin
            iot_transaction txn;
            seq_item_port.get_next_item(txn);
            //`uvm_info("IOT_DRIVER", $sformatf("Bus read time=%0t value=0x%03h", $time, txn.read_data), UVM_HIGH);
            `uvm_info("IOT_DRIVER", $sformatf("I/O TXN: %s", txn.convert2string()), UVM_MEDIUM);

            wait(vif.driver_cb.clear == 1'b1 ||
                 vif.driver_cb.load == 1'b1);
            vif.driver_cb.ready <= txn.ready;
            vif.driver_cb.clearacc <= txn.clearacc;
            vif.driver_cb.datain <= txn.data_in;
            wait(vif.driver_cb.clear == 1'b0 &&
                 vif.driver_cb.load == 1'b0);
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: iot_driver
