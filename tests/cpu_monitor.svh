class cpu_monitor extends uvm_monitor;
    `uvm_component_utils(cpu_monitor)

    virtual cpu_if.MONITOR vif;

    //cpu_config uconfig;

    uvm_analysis_port #(cpu_transaction) port;

    function new(string name = "cpu_monitor", uvm_component parent = null);
        super.new(name, parent);
        port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        virtual cpu_if vif_actual;
        super.build_phase(phase);
        //if(!uvm_config_db #(cpu_config)::get(this, "", "cpu_config", uconfig)) begin
        //    `uvm_fatal("UART_MONITOR", "driver failed to get cpu configuration");
        //end
        //vif = uconfig.serial_if;
        if(!uvm_config_db #(virtual cpu_if)::get(this, "", "cpu_if", vif_actual)) begin
            `uvm_fatal("CPU_MONITOR", "failed to get cpu interface");
        end
        vif = vif_actual;
        assert(vif != null);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(vif.nrst == 1);
        #1;
        //#100;
        forever begin
            cpu_transaction trans;

            //@(posedge vif.clk && vif.monitor_cb.mem_load && vif.monitor_cb.mem_ready);
            @(posedge vif.clk);
            //wait(vif.monitor_cb.mem_load == 1'b1 && vif.monitor_cb.mem_ready == 1'b1);
            while(vif.monitor_cb.mem_load !== 1'b1 || vif.monitor_cb.mem_ready !== 1'b1) begin
                @(posedge vif.clk);
            end
            trans = new;
            trans.addr = vif.monitor_cb.address;
            trans.read_data = vif.monitor_cb.read_data;
            if(vif.monitor_cb.write_enable)
                trans.set_write_data(vif.monitor_cb.write_data);
            `uvm_info("CPU_MONITOR", $sformatf("Bus TXN: %s", trans.convert2string()), UVM_MEDIUM);
            port.write(trans);
            //`uvm_info("CPU_MONITOR", $sformatf("Bus TXN: %p", trans), UVM_MEDIUM);
            //trans.print();
        end
    endtask: run_phase
endclass: cpu_monitor
