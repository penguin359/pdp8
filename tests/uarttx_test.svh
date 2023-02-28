class uarttx_test extends uvm_test;
    `uvm_component_utils(uarttx_test);

    uarttx_env env;

    virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uarttx_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #10;
        `uvm_warning("", "Hello, Uart!")
        phase.drop_objection(this);
    endtask: run_phase
endclass: uarttx_test
