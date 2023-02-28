class uarttx_env extends uvm_env;
    `uvm_component_utils(uarttx_env);

    uarttx_agent agent;

    virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = uarttx_agent::type_id::create("agent", this);
        uvm_config_db #(virtual uarttx_if)::set(this, "agent", "vif", vif);
    endfunction
endclass: uarttx_env
