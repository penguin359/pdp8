class uartrx_env extends uvm_env;
    `uvm_component_utils(uartrx_env);

    uartrx_bus_agent bus_agent;
    uart_agent external_agent;
    uarttx_scoreboard sb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        bus_agent = uartrx_bus_agent::type_id::create("bus_agent", this);
        external_agent = uart_agent::type_id::create("external_agent", this);
        sb = uarttx_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        bus_agent.monitor.port.connect(sb.mon_imp_out);
        external_agent.monitor.port.connect(sb.mon_imp);
    endfunction
endclass: uartrx_env
