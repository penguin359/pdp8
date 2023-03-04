class cpu_test extends uvm_test;
    `uvm_component_utils(cpu_test);

    cpu_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cpu_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        cpu_sequence seq = cpu_sequence::type_id::create("cpu_sequence", this);
        phase.raise_objection(this, "Starting the main CPU sequence");
        seq.start(env.agent.seq);
        `uvm_info("CPU_TEST", "Sequence complete", UVM_MEDIUM);
        phase.drop_objection(this);
    endtask: run_phase
endclass: cpu_test
