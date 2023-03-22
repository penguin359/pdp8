`timescale 10ns / 1ns

`include "uvm_macros.svh"

//`default net_type none
`include "cpu_if.svh"
`include "iot_if.svh"
`include "cpu_testbench_pkg.svh"

module cpu_tb_top;
    import uvm_pkg::*;
    import cpu_testbench::*;

    bit clk, nrst;

    localparam time Period = 20ns;
    localparam longint ClockRate = 1s / Period;

    always #(Period/2) clk = ~clk;

    initial begin
        nrst = 0;
        #(100ns) nrst = 1;
    end

    logic bit1_cp2;
    logic bit2_cp3;
    logic [2:0] io_address;
    logic [7:0] dataout;
    logic skip_flag;
    logic clearacc;
    logic [7:0] datain;

    cpu_if vif(.clk(clk), .nrst(nrst));
    iot_if io3(.clk(clk), .nrst(nrst));
    iot_if io4(.clk(clk), .nrst(nrst));

    cpu //#(.ClockRate(ClockRate), .Baud(Baud))
    dut (
        .clk(vif.clk),
        .nrst(vif.nrst),

        // Panel Bus
        //   Panel to CPU
        .swreg(vif.swreg),
        .dispsel(vif.dispsel),
        .run(vif.run),
        .loadpc(vif.loadpc),
        .step(vif.step),
        .deposit(vif.deposit),

        //   CPU to Panel
        .dispout(vif.dispout),
        .linkout(vif.linkout),
        .halt(vif.halt),

        // IO Bus
        //   CPU to IOT Distributor
        .bit1_cp2(bit1_cp2),
        .bit2_cp3(bit2_cp3),
        .io_address(io_address),
        .dataout(dataout),

        //   IOT Distributor to CPU
        .skip_flag(skip_flag),
        .clearacc(clearacc),
        .datain(datain),

        // Memory Bus
        //   CPU to RAM
        .address(vif.address),
        .write_data(vif.write_data),
        .write_enable(vif.write_enable),
        .mem_load(vif.mem_load),

        //   RAM to CPU
        .read_data(vif.read_data),
        .mem_ready(vif.mem_ready)
    );

    IOT_Distributor io_bus(
        // interface to CPU
        .bit1_cp2(bit1_cp2),
        .bit2_cp3(bit2_cp3),
        .io_address(io_address),
        .dataout(dataout),

        .skip_flag(skip_flag),
        .clearacc(clearacc),
        .datain(datain),

        // interface to device 3
        .ready_3(io3.ready),
        .clear_3(io3.clear),
        .clearacc_3(io3.clearacc),
        .dataout_3(io3.dataout),
        .datain_3(io3.datain),
        .load_3(io3.load),

        // interface to device 4
        .ready_4(io4.ready),
        .clear_4(io4.clear),
        .clearacc_4(io4.clearacc),
        .dataout_4(io4.dataout),
        .datain_4(io4.datain),
        .load_4(io4.load)
    );

    iot_config io3_config;
    iot_config io4_config;

    initial begin
        io3_config = new;
        io3_config.io_address = 3'h3;
        io3_config.iot_if = io3;
        io3_config.active = UVM_ACTIVE;
        io4_config = new;
        io4_config.io_address = 3'h4;
        io4_config.iot_if = io4;
        io4_config.active = UVM_ACTIVE;

        uvm_config_db #(virtual cpu_if)::set(uvm_root::get(), "", "cpu_if", vif);
        uvm_config_db #(iot_config)::set(uvm_root::get(),
            "uvm_test_top.env.io3_agent", "iot_config", io3_config);
        uvm_config_db #(iot_config)::set(uvm_root::get(),
            "uvm_test_top.env.io4_agent", "iot_config", io4_config);

        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
        automatic uvm_root root = uvm_root::get();
        root.enable_print_topology = 1;
        run_test("cpu_test");
    end
endmodule: cpu_tb_top
