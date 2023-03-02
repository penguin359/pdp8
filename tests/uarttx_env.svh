class uarttx_env extends uvm_env;
    `uvm_component_utils(uarttx_env);

    uarttx_bus_agent bus_agent;
    uart_agent external_agent;
    uarttx_scoreboard sb;

    //virtual uarttx_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        bus_agent = uarttx_bus_agent::type_id::create("bus_agent", this);
        external_agent = uart_agent::type_id::create("external_agent", this);
        sb = uarttx_scoreboard::type_id::create("scoreboard", this);
        //uvm_config_db #(virtual uarttx_if)::set(this, "agent", "vif", vif);

        //if(!uvm_config_db #(virtual uarttx_if)::get(this, "", "vif", vif)) begin
        //    `uvm_error("build_phase", "driver failed to get virtual interface");
        //end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        bus_agent.monitor.port.connect(sb.mon_imp);
        external_agent.monitor.port.connect(sb.mon_imp_out);
    endfunction
endclass: uarttx_env
