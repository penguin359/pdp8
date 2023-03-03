`uvm_analysis_imp_decl(_out)

class uarttx_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uarttx_scoreboard);

    uvm_analysis_imp #(uart_transaction, uarttx_scoreboard) mon_imp;
    uvm_analysis_imp_out #(uart_transaction, uarttx_scoreboard) mon_imp_out;

    uvm_queue #(uart_transaction) queue_in;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
        mon_imp_out = new("mon_imp_out", this);
        queue_in = new;
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if(queue_in.size() == 0)
            `uvm_info("UART_SCOREBOARD", "All bytes were transmitted", UVM_LOW)
        else begin
            `uvm_error("UART_SCOREBOARD", $sformatf("ERROR: %d byte(s) were not seen in transmit", queue_in.size()));
        end
    endfunction

    function void write(uart_transaction trans);
        `uvm_info("UART_SCOREBOARD", $sformatf("Scoreboard in: char=%c value=0x%02h", trans.data, trans.data), UVM_LOW)
        queue_in.push_back(trans);
        //if(trans.data == trans.actual)
        //    `uvm_info("UART_SCOREBOARD", "Success!", UVM_LOW)
        //else
        //    `uvm_error("UART_SCOREBOARD", "Failure!")
    endfunction

    function void write_out(uart_transaction trans_out);
        uart_transaction trans;
        `uvm_info("UART_SCOREBOARD", "Scoreboard out!", UVM_LOW)
        if(queue_in.size() == 0) begin
            `uvm_error("UART_SCOREBOARD", "Unexpected byte transmitted!")
            return;
        end
        trans = queue_in.pop_front();
        if(trans.data == trans_out.data)
            `uvm_info("UART_SCOREBOARD", "Success!", UVM_LOW)
        else
            `uvm_error("UART_SCOREBOARD", $sformatf("Failure: 0x%02h != 0x%02h", trans.data, trans_out.data))
    endfunction
endclass: uarttx_scoreboard
