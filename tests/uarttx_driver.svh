class uarttx_driver extends uvm_driver #(uarttx_transaction);
    `uvm_component_utils(uarttx_driver);

    virtual uarttx_if.DRIVER vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uarttx_if.DRIVER)::get(this, "", "vif", vif)) begin
            `uvm_error("build_phase", "driver failed to get virtual interface");
        end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            uarttx_transaction trans;
            seq_item_port.get_next_item(trans);
            uvm_report_info("UARTTX_DRIVER", "Sending char...");
            //vif.print();
            uvm_report_info("UARTTX_DRIVER", $psprintf("Is missing? %d", vif == null));
            assert(vif != null);
            @(posedge vif.clk);
            vif.driver_cb.tx_load <= 1;
            vif.driver_cb.tx_data <= 8'h21;
            @(posedge vif.clk);
            vif.driver_cb.tx_load <= 0;
            vif.driver_cb.tx_data <= 0;
            @(posedge vif.clk && vif.driver_cb.tx_ready == 1);
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: uarttx_driver
