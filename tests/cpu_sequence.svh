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
            trans.set_opcode(trans.JMP);
            trans.set_zero_page(1);
            trans.set_indirect(0);
            trans.set_offset($urandom_range(0, 127));
            finish_item(trans);

            trans = new;
            start_item(trans);
            trans.set_opcode(trans.TAD);
            trans.set_zero_page(1);
            trans.set_indirect(0);
            trans.set_offset($urandom_range(0, 127));
            finish_item(trans);

            trans = new;
            start_item(trans);
            trans.set_read_data($urandom_range(0, 4095));
            finish_item(trans);

            trans = new;
            start_item(trans);
            trans.set_opcode(trans.DCA);
            trans.set_zero_page(1);
            trans.set_indirect(0);
            trans.set_offset($urandom_range(0, 127));
            finish_item(trans);

            trans = new;
            start_item(trans);
            trans.set_read_data($urandom_range(0, 4095));
            finish_item(trans);
        end

        // Generate a series of no-ops at the end to ensure that
        // all the results from the previous instructions including
        // effects to the PC make it through the monitor and CPU
        // reference model.
        repeat(5) begin
            trans = new;
            start_item(trans);
            trans.set_opcode(trans.OPR);
            finish_item(trans);
        end
    endtask: body
endclass: cpu_sequence
