interface uarttx_if(input logic clk, nrst);
    logic tx_load;
    logic [7:0] tx_data;
    logic tx_ready;
    logic tx;

    clocking driver_cb @(posedge clk);
        output tx_load;
        output tx_data;
        input tx_ready;
    endclocking

    clocking monitor_cb @(posedge clk);
        input tx_load;
        input tx_data;
        input tx_ready;
    endclocking

    modport DRIVER (clocking driver_cb, input clk, nrst);
    modport MONITOR (clocking monitor_cb, input clk, nrst, tx);
endinterface
