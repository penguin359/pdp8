class uarttx_test extends uvm_test;
    `uvm_component_utils(uarttx_test);

    uarttx_env env;

    //virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uarttx_env::type_id::create("env", this);
        //uvm_config_db #(virtual uarttx_if)::set(this, "env", "vif", vif);

        //if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
        //    `uvm_fatal("UARTTX_TEST", "driver failed to get virtual interface");
        //end
    endfunction

    task run_phase(uvm_phase phase);
`ifdef USE_FILE_SOURCE
        uart_sequence seq = uart_file_sequence::type_id::create("uart_file_sequence", this);
`else
        uart_sequence seq = uart_sequence::type_id::create("uart_sequence", this);
`endif
        phase.raise_objection(this, "Starting the main TX sequence");
        seq.start(env.bus_agent.seq);
        phase.drop_objection(this);
    endtask: run_phase
endclass: uarttx_test
