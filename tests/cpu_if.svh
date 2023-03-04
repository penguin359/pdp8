interface cpu_if(input logic clk, nrst);
    logic [11:0] swreg;
    logic [1:0] dispsel;
    logic run;
    logic loadpc;
    logic step;
    logic deposit;

    logic [11:0] dispout;
    logic linkout;
    logic halt;

    logic bit1_cp2;
    logic bit2_cp3;
    logic [2:0] io_address;
    logic [7:0] dataout;

    logic skip_flag;
    logic clearacc;
    logic [7:0] datain;

    logic [11:0] address;
    logic [11:0] write_data;
    logic write_enable;
    logic mem_load;

    logic [11:0] read_data;
    logic mem_ready;

    clocking driver_cb @(posedge clk);
        output swreg;
        output dispsel;
        output run;
        output loadpc;
        output step;
        output deposit;

        //input dispout;
        //input linkout;
        //input halt;

        //input bit1_cp2;
        //input bit2_cp3;
        //input io_address;
        //input dataout;

        output skip_flag;
        output clearacc;
        output datain;

        input address;
        input write_data;
        input write_enable;
        input mem_load;

        output read_data;
        output mem_ready;
    endclocking: driver_cb

    clocking monitor_cb @(posedge clk);
        //input swreg;
        //input dispsel;
        //input run;
        //input loadpc;
        //input step;
        //input deposit;

        input dispout;
        input linkout;
        //input halt;

        //input bit1_cp2;
        //input bit2_cp3;
        //input io_address;
        //input dataout;

        //input skip_flag;
        //input clearacc;
        //input datain;

        input address;
        input write_data;
        input write_enable;
        input mem_load;

        input read_data;
        input mem_ready;
    endclocking: monitor_cb

    modport DRIVER (clocking driver_cb, input clk, nrst);
    modport MONITOR (clocking monitor_cb, input clk, nrst);
endinterface: cpu_if
