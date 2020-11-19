module MemoryControl 
(
clock,
opcode, 
databus, 
source1, 
source2, 
LDR_select, 
LDR_out,
RAM_RW,
ADR_select,
ADR_out
);
	inout[31:0] databus;
	input[3:0] opcode;
	input[31:0] source1, source2;
	output reg[31:0] LDR_out;
	output reg[15:0] ADR_out;
	output LDR_select, RAM_RW, ADR_select;	
	reg ADR_select, RAM_RW;

	input clock;
	
	//These can just be assigned as the MUX controls when they're active.
	assign LDR_out = databus;
	assign ADR_out = source1;

	//Enable LDR select if instruction is a LDR
	assign LDR_select = opcode == 4'b1101;

	//Enable ADR select if instruction is an LDR or STR
	assign ADR_select = (opcode == 4'b1101 || opcode == 4'b1110)? 1 : 0;
	
	//Set RAM to write if STR
	assign RAM_RW = (opcode == 4'b1110);

	//Reset address select on falling edge as the the RAM output would have been clocked on the rising edge anyways. This allows the next instruction to be fetched at next rising edge
	always @ (negedge clock)
	begin
		ADR_select = 0;
		RAM_RW = 0;
	end
	
	//Drive the RAM databus if STR instruction and RAM_RW has already been set.
	assign databus = (opcode == 4'b1110 && RAM_RW)? source2 : 32'bz;
endmodule
