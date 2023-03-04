class cpu_sequence extends uvm_sequence #(cpu_transaction);
    `uvm_object_utils(cpu_sequence);

    function new(string name = "cpu_sequence");
        super.new(name);
    endfunction

    task body();
        cpu_transaction trans;
        repeat(5) begin
            trans = new;
            start_item(trans);
            //assert(trans.randomize());
            // Randomly generate only graphic ASCII characters
            trans.set_opcode(trans.JMP);
            trans.set_zero_page(1);
            trans.set_indirect(0);
            trans.set_offset($urandom_range(0, 127));
            finish_item(trans);
        end
    endtask: body
endclass: cpu_sequence
