class cpu_reference;
	localparam A_WIDTH = 12;
	localparam D_WIDTH = 12;

	bit link = 1'b0;
	bit [D_WIDTH-1:0] acc = D_WIDTH'b0;
	bit [D_WIDTH-1:0] pc; = A_WIDTH'b0;

	bit [D_WIDTH-1:0] mem [0:2**A_WIDTH-1];
endclass: cpu_reference
