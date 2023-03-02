`timescale 10ns / 1ns

`include "uvm_macros.svh"

`include "uarttx_if.svh"
package testbench_pkg;
    import uvm_pkg::*;

    `include "uarttx_transaction.svh"
    `include "uarttx_sequence.svh"
    `include "uarttx_sequencer.svh"
    `include "uarttx_driver.svh"
    `include "uarttx_monitor.svh"
    `include "uarttx_agent.svh"
    `include "uarttx_scoreboard.svh"
    `include "uarttx_env.svh"
    `include "uarttx_test.svh"
endpackage: testbench_pkg

module top;
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

    uarttx_if vif(clk, nrst);
    uarttx #(.clock_rate(clock_rate), .baud(115200))
    dut (
        .clk(vif.clk),
        .nrst(vif.nrst),
        .tx_load(vif.tx_load),
        .tx_data(vif.tx_data),
        .tx_ready(vif.tx_ready),
        .tx(vif.tx));

    initial begin
        uvm_config_db #(virtual uarttx_if)::set(uvm_root::get(), "*", "vif", vif);
        uvm_config_db #(virtual uarttx_if.DRIVER)::set(uvm_root::get(), "*", "vif", vif.DRIVER);
        $dumpfile("uarttx.vcd");
        $dumpvars;
    end

    initial begin
        uvm_root root = uvm_root::get();
        root.print_topology();
        run_test("uarttx_test");
    end
endmodule: top
