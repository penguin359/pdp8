interface uartrx_bus_if(input logic clk, nrst);
    logic rx_load;
    logic [7:0] rx_data;
    logic rx_ready;

    clocking driver_cb @(posedge clk);
        input rx_load;
        output rx_ready;
    endclocking

    clocking monitor_cb @(posedge clk);
        input rx_load;
        input rx_data;
        input rx_ready;
    endclocking

    modport DRIVER (clocking driver_cb, input clk, nrst);
    modport MONITOR (clocking monitor_cb, input clk, nrst);
endinterface

interface uarttx_bus_if(input logic clk, nrst);
    logic tx_load;
    logic [7:0] tx_data;
    logic tx_ready;

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
    modport MONITOR (clocking monitor_cb, input clk, nrst);
endinterface

interface uart_if;
    logic rx;
    logic tx;

    modport DRIVER (output rx);
    modport MONITOR (input rx, tx);
endinterface
