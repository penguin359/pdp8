interface iot_if(input logic clk, nrst);
    logic ready;
    logic clear;
    logic clearacc;
    logic [7:0] dataout;
    logic [7:0] datain;
    logic load;

    clocking driver_cb @(posedge clk);
        output ready;
        input clear;
        output clearacc;
        input dataout;
        output datain;
        input load;
    endclocking: driver_cb

    clocking monitor_cb @(posedge clk);
        input ready;
        input clear;
        input clearacc;
        input dataout;
        input datain;
        input load;
    endclocking: monitor_cb

    modport DRIVER (clocking driver_cb, input clk, nrst);
    modport MONITOR (clocking monitor_cb, input clk, nrst);
endinterface: iot_if
