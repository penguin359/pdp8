`include "uvm_macros.svh"

import uvm_pkg::*;

`include "uarttx_if.svh"
`include "uarttx_transaction.svh"
`include "uarttx_driver.svh"

module top;
    bit clk, nrst;

    always #5 clk = ~clk;

    initial begin
        nrst = 0;
        #10 nrst = 1;
    end

    uarttx_if vif(clk, nrst);
endmodule
