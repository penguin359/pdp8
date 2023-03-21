`timescale 10ns / 1ns

`include "uvm_macros.svh"

`include "uart_if.svh"
`include "uart_testbench_pkg.svh"

module uart_tb_top;
    import uvm_pkg::*;
    import uart_testbench::*;

    bit clk, nrst;

    localparam time Period = 20ns;
    localparam longint ClockRate = 1s / Period;

    localparam int Baud = 115200;

    always #(Period/2) clk = ~clk;

    initial begin
        nrst = 0;
        #(100ns) nrst = 1;
    end

    uartrx_bus_if uartrx_if(.clk(clk), .nrst(nrst));
    uarttx_bus_if uarttx_if(.clk(clk), .nrst(nrst));
    uart_if serial_if();

    uarttx #(.clock_rate(ClockRate), .baud(Baud))
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
        uconfig.baud = Baud;
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
`ifdef UART_TX_TEST
        run_test("uarttx_test");
`else
        uconfig.active = UVM_ACTIVE;
        run_test("uartrx_test");
`endif
    end
endmodule: uart_tb_top
