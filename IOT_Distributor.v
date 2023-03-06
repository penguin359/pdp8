module IOT_Distributor(
    // interface to device 3
    input ready_3,
    output clear_3,
    input clearacc_3,
    output [7:0] dataout_3,
    input [7:0] datain_3,
    output load_3,
    // interface to device 4
    input ready_4,
    output clear_4,
    input clearacc_4,
    output [7:0] dataout_4,
    input [7:0] datain_4,
    output load_4,
    // interface to CPU
    output skip_flag,
    input bit1_cp2,
    output clearacc,
    input [7:0] dataout,
    output [7:0] datain,
    input bit2_cp3,
    input [2:0] io_address
);

    // multiplexers
    assign skip_flag = (io_address == 3'b011) ? ready_3 :
                       (io_address == 3'b100) ? ready_4 :
                       1'b0;

    assign clearacc  = (io_address == 3'b011) ? clearacc_3 :
                       (io_address == 3'b100) ? clearacc_4 :
                       1'b0;

    assign datain    = (io_address == 3'b011) ? datain_3 :
                       (io_address == 3'b100) ? datain_4 :
                       8'b00000000;

    // pass through
    assign dataout_3 = dataout;
    assign dataout_4 = dataout;

    // demultiplexers
    assign clear_3 = (io_address == 3'b011) ? bit1_cp2 : 1'b0;
    assign clear_4 = (io_address == 3'b100) ? bit1_cp2 : 1'b0;

    assign load_3  = (io_address == 3'b011) ? bit2_cp3 : 1'b0;
    assign load_4  = (io_address == 3'b100) ? bit2_cp3 : 1'b0;
endmodule
