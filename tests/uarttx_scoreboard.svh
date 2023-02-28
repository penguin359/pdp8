class uarttx_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uarttx_scoreboard);

    uvm_analysis_imp #(uarttx_transaction, uarttx_scoreboard) mon_imp;

    uarttx_transaction trans;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
    endfunction

    function void write(uarttx_transaction trans);
        `uvm_info("UART_SCOREBOARD", "Scoreboard!", UVM_LOW)
        if(trans.data == trans.actual)
            `uvm_info("UART_SCOREBOARD", "Success!", UVM_LOW)
        else
            `uvm_error("UART_SCOREBOARD", "Failure!")
    endfunction
endclass: uarttx_scoreboard
