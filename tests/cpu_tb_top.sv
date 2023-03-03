`timescale 10ns / 1ns

`include "uvm_macros.svh"

`include "cpu_if.svh"
package testbench_pkg;
    import uvm_pkg::*;

    //`include "cpu_config.svh"
    `include "cpu_transaction.svh"
    `include "cpu_sequence.svh"
    //`include "cpu_sequencer.svh"
    //`include "cpu_driver.svh"
    //`include "cpu_monitor.svh"
    //`include "cpu_agent.svh"
    //`include "cpu_scoreboard.svh"
    //`include "cpu_env.svh"
    //`include "cpu_test.svh"
endpackage: testbench_pkg

module cpu_tb_top;
    import uvm_pkg::*;
    import testbench_pkg::*;

    bit clk, nrst;

    localparam time period = 20ns;
    localparam longint clock_rate = 1s / period;

    always #(period/2) clk = ~clk;

    initial begin
        nrst = 0;
        #(100ns) nrst = 1;
    end

    cpu_if cpu(clk, nrst);

    cpu //#(.clock_rate(clock_rate), .baud(baud))
    dut (
        .clk(cpu_if.clk),
        .nrst(cpu_if.nrst),
        .tx_load(cpu_if.tx_load),
        .tx_data(cpu_if.tx_data),
        .tx_ready(cpu_if.tx_ready),
        .tx(serial_if.tx));

    //cpu_config uconfig;

    initial begin
        //uconfig = new;
        //uconfig.baud = baud;
        //uconfig.cpu_if = cpu_if;
        //uconfig.serial_if = serial_if;
        //uconfig.active = UVM_ACTIVE;

        //uvm_config_db #(cpu_config)::set(uvm_root::get(), "", "cpu_config", uconfig);

        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
        uvm_root root = uvm_root::get();
        root.enable_print_topology = 1;
        run_test("cpurx_test");
    end
endmodule: cpu_tb_top
