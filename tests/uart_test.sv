`include "uvm_macros.svh"

import uvm_pkg::*;

`include "uarttx_if.svh"
`include "uarttx_transaction.svh"
`include "uarttx_sequence.svh"
`include "uarttx_sequencer.svh"
`include "uarttx_driver.svh"
`include "uarttx_monitor.svh"
`include "uarttx_agent.svh"
`include "uarttx_scoreboard.svh"
`include "uarttx_env.svh"
`include "uarttx_test.svh"

module top;
    bit clk, nrst;

    always #5 clk = ~clk;

    initial begin
        nrst = 0;
        #10 nrst = 1;
    end

    uarttx_if vif(clk, nrst);
    uarttx dut(
        .clk(vif.clk),
        .rst(vif.nrst),
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
        run_test("uarttx_test");
    end
endmodule: top