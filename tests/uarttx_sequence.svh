class uarttx_sequence extends uvm_sequence #(uarttx_transaction);
    `uvm_object_utils(uarttx_sequence);

    function new(string name = "uarttx_sequence");
        super.new(name);
    endfunction

    task body();
        uarttx_transaction trans;
        repeat(10) begin
            trans = new;
            start_item(trans);
            //assert(trans.randomize());
            trans.data = $urandom_range(0, 255);
            finish_item(trans);
        end
    endtask: body
endclass: uarttx_sequence
