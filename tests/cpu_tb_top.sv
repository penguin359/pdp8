`timescale 10ns / 1ns

`include "uvm_macros.svh"

`include "cpu_if.svh"
package cpu_testbench;
    import uvm_pkg::*;

    //`include "cpu_config.svh"
    `include "cpu_transaction.svh"
    `include "cpu_sequence.svh"
    //`include "cpu_sequencer.svh"
    `include "cpu_driver.svh"
    `include "cpu_monitor.svh"
    `include "cpu_agent.svh"
    `include "cpu_scoreboard.svh"
    `include "cpu_env.svh"
    `include "cpu_test.svh"
endpackage: cpu_testbench

module cpu_tb_top;
    import uvm_pkg::*;
    import cpu_testbench::*;

    bit clk, nrst;

    localparam time period = 20ns;
    localparam longint clock_rate = 1s / period;

    always #(period/2) clk = ~clk;

    initial begin
        nrst = 0;
        #(100ns) nrst = 1;
    end

    cpu_if vif(clk, nrst);

    cpu //#(.clock_rate(clock_rate), .baud(baud))
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
        .bit1_cp2(vif.bit1_cp2),
        .bit2_cp3(vif.bit2_cp3),
        .io_address(vif.io_address),
        .dataout(vif.dataout),

        //   IOT Distributor to CPU
        .skip_flag(vif.skip_flag),
        .clearacc(vif.clearacc),
        .datain(vif.datain),

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

    //cpu_config uconfig;

    initial begin
        //uconfig = new;
        //uconfig.baud = baud;
        //uconfig.cpu_if = cpu_if;
        //uconfig.serial_if = serial_if;
        //uconfig.active = UVM_ACTIVE;

        //uvm_config_db #(cpu_config)::set(uvm_root::get(), "", "cpu_config", uconfig);
        uvm_config_db #(virtual cpu_if)::set(uvm_root::get(), "", "cpu_if", vif);

        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
        uvm_root root = uvm_root::get();
        root.enable_print_topology = 1;
        run_test("cpu_test");
    end
endmodule: cpu_tb_top
