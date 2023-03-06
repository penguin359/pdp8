class iot_config extends uvm_object;
    `uvm_object_utils(iot_config);

    int io_address;
    virtual iot_if iot_if;
    uvm_active_passive_enum active = UVM_ACTIVE;

    function new(string name = "iot_config");
        super.new(name);
    endfunction
endclass: iot_config
