module setflags(clk, reset, S,opcode,in1,in2,result,flags);

input [31:0]in1,in2;
input [32:0]result;
input [3:0]opcode;
input clk,S, reset;
output reg [3:0] flags;

always @ (posedge reset)
begin
	flags = 0;
end

always @ (*)
begin
	//Only update flag if not no-op, and S or CMP
	if (opcode != 4'b1111 && (S || (opcode==4'b1011)))
	begin
		flags[3] = result[31]; 	//Calculate negative flag
		if (result[31:0] != 0)	//Calculate zero flag
		begin
			flags[2] = 0;
		end
		else
		begin
			flags[2] = 1;
		end
		
		//Carry flag for most operations
		flags[1] = result[32];

		//Addition
		if (opcode == 0)
		begin
			flags[0] = (!in1[31]&&!in2[31]&&result[31] || in1[31]&&in2[31]&&result[31]);
		end
		//Subtraction
		else if (opcode == 1 || opcode == 4'b1011)
		begin
			flags[0] = (in1[31]&&!in2[31]&&!result[31] || !in1[31]&&in2[31]&&result[31]);
			//ARM's inverted borrow flag means carry must be inverted during subtraction
			//flags[1] = ~result[32];
		end
	end 	
end
endmodule
