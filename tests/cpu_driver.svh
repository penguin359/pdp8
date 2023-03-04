class cpu_driver extends uvm_driver #(cpu_transaction);
    `uvm_component_utils(cpu_driver);

    //cpu_config uconfig;

    virtual cpu_if.DRIVER vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        virtual cpu_if vif_actual;
        super.build_phase(phase);
        //if(!uvm_config_db #(cpu_config)::get(this, "", "cpu_config", uconfig)) begin
        //    `uvm_fatal("CPU_DRIVER", "driver failed to get cpu configuration");
        //end
        //vif = uconfig.cpu_if;
        if(!uvm_config_db #(virtual cpu_if)::get(this, "", "cpu_if", vif_actual)) begin
            `uvm_fatal("CPU_DRIVER", "failed to get cpu interface");
        end
        vif = vif_actual;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

	vif.driver_cb.swreg <= 12'b0;
	vif.driver_cb.dispsel <= 2'b0;
	vif.driver_cb.run <= 1'b1;
	vif.driver_cb.loadpc <= 1'b0;
	vif.driver_cb.step <= 1'b0;
	vif.driver_cb.deposit <= 1'b0;

	vif.driver_cb.skip_flag <= 1'b0;
	vif.driver_cb.clearacc <= 1'b0;
	vif.driver_cb.datain <= 12'b0;

	vif.driver_cb.read_data <= 12'b0;
	vif.driver_cb.mem_ready <= 1'b0;

        wait(vif.nrst == 1);
        #1
        forever begin
            cpu_transaction trans;
            seq_item_port.get_next_item(trans);
            `uvm_info("CPU_DRIVER", $sformatf("Bus read time=%0t value=0x%03h", $time, trans.data), UVM_HIGH);

            wait(vif.driver_cb.mem_load == 1'b1);
            vif.driver_cb.read_data <= trans.data;
	    vif.driver_cb.mem_ready <= 1'b1;
            @(posedge vif.clk)
	    vif.driver_cb.mem_ready <= 1'b0;
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: cpu_driver
