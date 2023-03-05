class cpu_sequence extends uvm_sequence #(cpu_transaction);
    `uvm_object_utils(cpu_sequence);

    // Disable indirect-addressing test until bug is fixed
    localparam EnableIndirect = 0;

    function new(string name = "cpu_sequence");
        super.new(name);
    endfunction

    task body();
        cpu_transaction txn;

        if(!EnableIndirect)
            `uvm_warning("CPU_SEQUENCE", "Indirect addressing test disabled")

        repeat(5) begin
            txn = new;
            start_item(txn);
            txn.set_opcode(txn.JMP);
            txn.set_zero_page($urandom_range(0, 1));
            txn.set_indirect($urandom_range(0, EnableIndirect));
            txn.set_offset($urandom_range(0, 127));
            finish_item(txn);

            if(txn.is_indirect()) begin
                txn = new;
                start_item(txn);
                txn.set_address($urandom_range(0, 4095));
                finish_item(txn);
            end

            repeat(3) begin
                txn = new;
                start_item(txn);
                txn.set_opcode(txn.TAD);
                txn.set_zero_page($urandom_range(0, 1));
                txn.set_indirect($urandom_range(0, EnableIndirect));
                txn.set_offset($urandom_range(0, 127));
                finish_item(txn);

                if(txn.is_indirect()) begin
                    txn = new;
                    start_item(txn);
                    txn.set_address($urandom_range(0, 4095));
                    finish_item(txn);
                end

                txn = new;
                start_item(txn);
                txn.set_read_data($urandom_range(0, 4095));
                finish_item(txn);
            end

            txn = new;
            start_item(txn);
            txn.set_opcode(txn.DCA);
            txn.set_zero_page($urandom_range(0, 1));
            txn.set_indirect($urandom_range(0, EnableIndirect));
            txn.set_offset($urandom_range(0, 127));
            finish_item(txn);

            if(txn.is_indirect()) begin
                txn = new;
                start_item(txn);
                txn.set_address($urandom_range(0, 4095));
                finish_item(txn);
            end

            txn = new;
            start_item(txn);
            txn.set_write_data($urandom_range(0, 4095));
            finish_item(txn);
        end

        // Generate a series of no-ops at the end to ensure that
        // all the results from the previous instructions including
        // effects to the PC make it through the monitor and CPU
        // reference model.
        repeat(5) begin
            txn = new;
            start_item(txn);
            txn.set_opcode(txn.OPR);
            finish_item(txn);
        end
    endtask: body
endclass: cpu_sequence
