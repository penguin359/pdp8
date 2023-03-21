class iot_sequence extends uvm_sequence #(iot_transaction);
    `uvm_object_utils(iot_sequence)

    function new(string name = "iot_sequence");
        super.new(name);
    endfunction

    task body();
        iot_transaction txn;

        repeat(10) begin
            txn = new;
            start_item(txn);
            txn.ready = $urandom_range(0, 1);
            txn.clearacc = $urandom_range(0, 1);
            txn.data_in = $urandom_range(8'h21, 8'h7e);  // ASCII graphic characters
            finish_item(txn);
        end
    endtask: body
endclass: iot_sequence
