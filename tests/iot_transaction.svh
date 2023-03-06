class iot_transaction extends uvm_sequence_item;
    // I/O device configuration
    bit [5:0] io_address;

    // Signals to CPU
    rand bit ready;
    rand bit clearacc;
    rand bit [7:0] data_in;

    // Signals from CPU
    bit clear;
    bit load;
    bit [7:0] data_out;

    function new(string name="iot_transaction");
        super.new();
    endfunction

    function string convert2string();
        return $sformatf("IO: addr=0x%02h din=%02h dout=%02h",
            io_address, data_in, data_out);
    endfunction
endclass: iot_transaction
