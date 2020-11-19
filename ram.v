
module RAM(databus, clk, rw, address, reset);
	input rw, clk, reset;
	input [15:0] address;
	inout [31:0] databus;
	reg[31:0] Memory[0:31];
	reg[31:0] temp_output;

	assign databus = (rw == 0)? temp_output : 32'bz;

	always @ (clk)
	begin
   		if (rw == 1)
			//Write
       			Memory[address] = databus;
   		else if (rw == 0)
       			//Read
			temp_output = Memory[address];
	end
	
	//Initialization memory
	always @ (posedge reset)
	begin	
		//Set initial output
		temp_output = Memory[0];
	end	
endmodule 
