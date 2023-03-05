class cpu_sequence extends uvm_sequence #(cpu_transaction);
    `uvm_object_utils(cpu_sequence);

    // Disable indirect-addressing test until bug is fixed
    localparam EnableIndirect = 1;

    function new(string name = "cpu_sequence");
        super.new(name);
    endfunction

    task body();
        cpu_transaction txn;

        if(!EnableIndirect)
            `uvm_warning("CPU_SEQUENCE", "Indirect addressing test disabled")

        repeat(10) begin
            // Jump first so later instructions operate from an arbitrary
            // address.
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
                // Skip over the auto-index memory locations
                txn.set_address($urandom_range(16, 4095));
                finish_item(txn);
            end

            txn = new;
            start_item(txn);
            txn.set_opcode(txn.JMS);
            txn.set_zero_page($urandom_range(0, 1));
            txn.set_indirect($urandom_range(0, EnableIndirect));
            txn.set_offset($urandom_range(0, 127));
            finish_item(txn);

            if(txn.is_indirect()) begin
                txn = new;
                start_item(txn);
                // Skip over the auto-index memory locations
                txn.set_address($urandom_range(16, 4095));
                finish_item(txn);
            end

            // Data write for JMS
            txn = new;
            start_item(txn);
            txn.set_write_data($urandom_range(0, 4095));
            finish_item(txn);

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
                    txn.set_address($urandom_range(16, 4095));
                    finish_item(txn);
                end

                // Data read for TAD
                txn = new;
                start_item(txn);
                txn.set_read_data($urandom_range(0, 4095));
                finish_item(txn);
            end

            // Attempt ISZ in-between TAD and AND to confirm AC is not
            // being modified.
            txn = new;
            start_item(txn);
            txn.set_opcode(txn.ISZ);
            txn.set_zero_page($urandom_range(0, 1));
            txn.set_indirect($urandom_range(0, EnableIndirect));
            txn.set_offset($urandom_range(0, 127));
            finish_item(txn);

            if(txn.is_indirect()) begin
                txn = new;
                start_item(txn);
                txn.set_address($urandom_range(16, 4095));
                finish_item(txn);
            end

            // Data read for ISZ
            txn = new;
            start_item(txn);
            txn.set_read_data($urandom_range(0, 4095));
            finish_item(txn);

            // Data write of incremented value for ISZ
            txn = new;
            start_item(txn);
            txn.set_write_data($urandom_range(0, 4095));
            finish_item(txn);

            txn = new;
            start_item(txn);
            txn.set_opcode(txn.AND);
            txn.set_zero_page($urandom_range(0, 1));
            txn.set_indirect($urandom_range(0, EnableIndirect));
            txn.set_offset($urandom_range(0, 127));
            finish_item(txn);

            if(txn.is_indirect()) begin
                txn = new;
                start_item(txn);
                txn.set_address($urandom_range(16, 4095));
                finish_item(txn);
            end

            // Data read for AND
            txn = new;
            start_item(txn);
            txn.set_read_data($urandom_range(0, 4095));
            finish_item(txn);

            // Testing DCA ensures that above TAD/AND instructions
            // saved the correct value to the accumulator in addition
            // to testing DCA itself. Calling DCA twice verifies that
            // it is clearing the accumulator.
            repeat(2) begin
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
                    txn.set_address($urandom_range(16, 4095));
                    finish_item(txn);
                end

                // Data write for DCA
                txn = new;
                start_item(txn);
                txn.set_write_data($urandom_range(0, 4095));
                finish_item(txn);
            end
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
