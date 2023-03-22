class cpu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(cpu_scoreboard)

    uvm_analysis_imp #(cpu_transaction, cpu_scoreboard) mon_imp;

    //uvm_queue #(cpu_transaction) queue_in;

    cpu_reference cpu_ref;

    function new(string name = "cpu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        cpu_ref = new;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
        //queue_in = new;
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        //if(queue_in.size() == 0)
        //    `uvm_info("CPU_SCOREBOARD", "All bytes were transmitted", UVM_LOW)
        //else begin
        //    `uvm_error("CPU_SCOREBOARD", $sformatf("ERROR: %d byte(s) were not seen in transmit", queue_in.size()))
        //end
    endfunction

    function void write(cpu_transaction trans);
        `uvm_info("CPU_SCOREBOARD", $sformatf("Scoreboard in: value=0x%03h", trans.read_data), UVM_LOW)
        cpu_ref.handle_txn(trans);
        //queue_in.push_back(trans);
    endfunction
endclass: cpu_scoreboard
