class cpu_env extends uvm_env;
    `uvm_component_utils(cpu_env)

    cpu_agent agent;
    iot_agent io3_agent;
    iot_agent io4_agent;
    cpu_scoreboard sb;

    function new(string name = "cpu_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = cpu_agent::type_id::create("agent", this);
        io3_agent = iot_agent::type_id::create("io3_agent", this);
        io4_agent = iot_agent::type_id::create("io4_agent", this);
        sb = cpu_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.port.connect(sb.mon_imp);
    endfunction
endclass: cpu_env
