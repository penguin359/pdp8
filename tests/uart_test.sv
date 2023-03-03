`timescale 10ns / 1ns

`include "uvm_macros.svh"

`include "uart_if.svh"
package testbench_pkg;
    import uvm_pkg::*;

    `include "uart_config.svh"
    `include "uart_transaction.svh"
    `include "uarttx_sequence.svh"
    `include "uartrx_bus_driver.svh"
    `include "uartrx_bus_monitor.svh"
    `include "uartrx_bus_agent.svh"
    `include "uarttx_bus_sequencer.svh"
    `include "uarttx_bus_driver.svh"
    `include "uarttx_bus_monitor.svh"
    `include "uarttx_bus_agent.svh"
    `include "uart_driver.svh"
    `include "uart_monitor.svh"
    `include "uart_agent.svh"
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

    localparam int baud = 115200;

    always #(period/2) clk = ~clk;

    initial begin
        nrst = 0;
        #(100ns) nrst = 1;
    end

    uartrx_bus_if uartrx_if(clk, nrst);
    uarttx_bus_if uarttx_if(clk, nrst);
    uart_if serial_if();

    uarttx #(.clock_rate(clock_rate), .baud(baud))
    dut (
        .clk(uarttx_if.clk),
        .nrst(uarttx_if.nrst),
        .tx_load(uarttx_if.tx_load),
        .tx_data(uarttx_if.tx_data),
        .tx_ready(uarttx_if.tx_ready),
        .tx(serial_if.tx));

    uart_config uconfig;

    initial begin
        uconfig = new;
        uconfig.baud = baud;
        uconfig.uartrx_if = uartrx_if;
        uconfig.uarttx_if = uarttx_if;
        uconfig.serial_if = serial_if;
        uconfig.active = UVM_PASSIVE;

        uvm_config_db #(uart_config)::set(uvm_root::get(), "", "uart_config", uconfig);

        $dumpfile("uarttx.vcd");
        $dumpvars;
    end

    initial begin
        uvm_root root = uvm_root::get();
        root.enable_print_topology = 1;
        root.finish_on_completion = 0;
        run_test("uarttx_test");
    end
endmodule: top
