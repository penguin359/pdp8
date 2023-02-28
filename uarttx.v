module uarttx(
    input clk, input rst,

    input tx_load,
    input [7:0] tx_data,
    output tx_ready,
    output tx);

    wire [0:6] value;
    reg [31:0] counter = 0;

    reg [7:0] rxreg;

    always@(posedge clk)
        counter <= counter + 1;

    assign value = counter[31:25];

    localparam tx_divider = 4'd11;
    reg [$clog2(tx_divider)-1:0] tx_counter;
    reg [11:0] shift_reg;

    reg [3:0] bit_count;
    always @(posedge clk or posedge rst)
    begin
        if(rst) begin
            shift_reg <= 12'hfff;
            bit_count <= 0;
        end else if(tx_load) begin
            shift_reg <= {2'b11, tx_data, 2'b01};
            bit_count <= 12;
        end else if(tx_counter == 0 && bit_count != 0) begin
            shift_reg <= {1'b1, shift_reg[11:1]};
            bit_count <= bit_count - 1'b1;
        end
    end
    assign tx = shift_reg[0];
    assign tx_ready = bit_count == 0 ? 1'b1 : 1'b0;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            tx_counter <= tx_divider;
        else if(tx_counter == 0)
            tx_counter <= tx_divider;
        else
            tx_counter <= tx_counter - 4'd1;
    end
endmodule
