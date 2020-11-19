module InstructionRegister(clock, reset, PC, fetch, data, out, modified_opcode);
	inout [31:0] data;
	input [15:0] PC;
	output reg[31:0]out;
	input clock, fetch, reset;
	input[3:0] modified_opcode;

	always @ (data, posedge clock, PC)
	begin
		if (fetch == 1)
			out = data;
	end
	always @ (posedge reset)
	begin
		//Initialize with No-Op
		out = 32'b00001111000000000000000000000000;
	end
endmodule
