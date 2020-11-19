module register (Q, D, enable, reset, clk);
	parameter PC = 0;

	input enable, reset, clk;
	input [31:0] D;
	output reg [31:0] Q;


	//Reset to 0
	always @ (posedge reset)
	begin
		Q = 0;
	end 

	always @ (posedge clk)
	begin
		if (enable)
  			Q = D;
	end

	//If this is the PC, increment every neg clock
	always @ (negedge clk)
	begin
		if (PC == 1)
			Q = Q + 1;
	end
endmodule


 