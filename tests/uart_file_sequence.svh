class uart_file_sequence extends uart_sequence;
    `uvm_object_utils(uart_file_sequence);

    string filename = "hello-serial.txt";

    function new(string name = "uart_file_sequence");
        super.new(name);
    endfunction

    task body();
        uart_transaction trans;
        integer file, char;
        file = $fopen(filename, "rb");
        char = $fgetc(file);
        while(char >= 0) begin
            trans = new;
            start_item(trans);
            trans.data = char[7:0];
            finish_item(trans);
            char = $fgetc(file);
        end
    endtask: body
endclass: uart_file_sequence
