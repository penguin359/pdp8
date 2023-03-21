class uart_config extends uvm_object;
    `uvm_object_utils(uart_config)

    int baud = 9600;
    virtual uartrx_bus_if uartrx_if;
    virtual uarttx_bus_if uarttx_if;
    virtual uart_if serial_if;
    uvm_active_passive_enum active = UVM_ACTIVE;

    function new(string name = "uart_config");
        super.new(name);
    endfunction
endclass: uart_config
