class uart_sequence extends uvm_sequence #(uart_transaction);
    `uvm_object_utils(uart_sequence)

    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    task body();
        uart_transaction trans;
        repeat(10) begin
            trans = new;
            start_item(trans);
            //assert(trans.randomize());
            // Randomly generate only graphic ASCII characters
            trans.data = $urandom_range(8'h21, 8'h7e);
            finish_item(trans);
        end
    endtask: body
endclass: uart_sequence
