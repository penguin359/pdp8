class uartrx_test extends uvm_test;
    `uvm_component_utils(uartrx_test)

    uartrx_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uartrx_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        uart_sequence seq = uart_sequence::type_id::create("uart_sequence", this);
        phase.raise_objection(this, "Starting the main RX sequence");
        seq.start(env.external_agent.seq);
        phase.drop_objection(this);
    endtask: run_phase
endclass: uartrx_test
