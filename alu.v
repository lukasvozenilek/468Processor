module alu (clk, reset, result, register1, register2, instruction, flags, modified_opcode);
input clk, reset;
input [31:0] register1, register2, instruction;

//Instruction decoding
wire s;
wire [3:0] opcode, cond;
wire [15:0] im_val;
assign opcode = instruction[27:24];
assign cond = instruction[31:28];
assign im_val = instruction[18:3];
assign s = instruction[23];

output reg [3:0] modified_opcode;
reg [32:0] arithmetic_result;

output reg[31:0] result;
output reg[3:0] flags;

wire [3:0] flags_from_module;

always @ (*)
begin
	flags = flags_from_module;
	modified_opcode = opcode;
	case(cond)
		4'h1: begin //execute if equal
			if(~flags[2])
				modified_opcode = 4'hF; //NOP
			end
		4'h2: begin //execute if greater than
			if(flags[2] | ~(flags[3] == flags[0]))
				modified_opcode = 4'hF; // NOP
			end

		4'h3: begin //execute if less than
			if(flags[3] == flags[0]) 
				modified_opcode = 4'hF; // NOP
			end
		 
		4'h4: begin //execute if greater than or equal to
			if(flags[3] != flags[0])
				modified_opcode = 4'hF; // NOP
			end
		
		4'h5: begin //execute if less than or equal to
			if(~flags[2] & (flags[3] == flags[0]))
				modified_opcode = 4'hF; // NOP
			end
		
		4'h6: begin //execute if unsigned higher
			if(~flags[1] | flags[2]) 
				modified_opcode = 4'hF; // NOP
			end

		4'h7: begin //execute if unsigned higher
			if(flags[1]) 
				modified_opcode = 4'hF; // NOP
			end

		4'h8: begin //execute if unsigned higher
			if(~flags[1]) 
				modified_opcode = 4'hF; // NOP
			end

		default: modified_opcode = opcode;
	endcase	
		
	arithmetic_result = arithmetic_result;

	case (modified_opcode)
	
		4'h0: begin //r2+r3
			arithmetic_result = register1 + register2;
			end
		
		4'h1: begin //r2-r3
			arithmetic_result = register1 - register2;
			end
		
		4'h2: begin // r2*r3
			arithmetic_result = register1 * register2;
			end

		4'h3: begin //r2 OR r3
			arithmetic_result = register1 | register2;
			end

		4'h4: begin //r2 AND r3
			arithmetic_result = register1 & register2;
			end

		4'h5: begin //r2 XOR r3
			arithmetic_result = register1 ^ register2;
			end

		4'h6: begin //Load immediate	
			arithmetic_result = im_val;
			end

		4'h7: begin //copy r2 to r1, mostly a memory bank operation, but I need to move whatever is in source 2 directly to the output
			arithmetic_result = register2;
			end

		4'h8: begin //r2 right shift by r2 
			arithmetic_result[31:0] = register2 >> {im_val[7:3]}; //only shift up to 32 positions otherwise it would be zero anyway
			arithmetic_result[32] = arithmetic_result[31];
			end

		4'h9: begin //r2 left shift by r2
			arithmetic_result[31:0] = register2 << {im_val[7:3]}; //only shift down by 32 positions 
			arithmetic_result[32] = arithmetic_result[31];
			end

		4'hA: begin //r2 rotate right by literal im_val
			case (im_val[7:3])
				5'd0: begin arithmetic_result = register2; end
				5'd1: begin arithmetic_result = {register2[0],register2[31:1]}; end
				5'd2: begin arithmetic_result = {register2[1:0], register2[31:2]}; end
				5'd3: begin arithmetic_result = {register2[2:0], register2[31:3]}; end
				5'd4: begin arithmetic_result = {register2[3:0], register2[31:4]}; end
				5'd5: begin arithmetic_result = {register2[4:0], register2[31:5]}; end
				5'd6: begin arithmetic_result = {register2[5:0], register2[31:6]}; end
				5'd7: begin arithmetic_result = {register2[6:0], register2[31:7]}; end
				5'd8: begin arithmetic_result = {register2[7:0], register2[31:8]}; end
				5'd9: begin arithmetic_result = {register2[8:0], register2[31:9]}; end
				5'd10: begin arithmetic_result = {register2[9:0], register2[31:10]}; end
				5'd11: begin arithmetic_result = {register2[10:0], register2[31:11]}; end
				5'd12: begin arithmetic_result = {register2[11:0], register2[31:12]}; end
				5'd13: begin arithmetic_result = {register2[12:0], register2[31:13]}; end
				5'd14: begin arithmetic_result = {register2[13:0], register2[31:14]}; end
				5'd15: begin arithmetic_result = {register2[14:0], register2[31:15]}; end
				5'd16: begin arithmetic_result = {register2[15:0], register2[31:16]}; end
				5'd17: begin arithmetic_result = {register2[16:0], register2[31:17]}; end
				5'd18: begin arithmetic_result = {register2[17:0], register2[31:18]}; end
				5'd19: begin arithmetic_result = {register2[18:0], register2[31:19]}; end
				5'd20: begin arithmetic_result = {register2[19:0], register2[31:20]}; end
				5'd21: begin arithmetic_result = {register2[20:0], register2[31:21]}; end
				5'd22: begin arithmetic_result = {register2[21:0], register2[31:22]}; end
				5'd23: begin arithmetic_result = {register2[22:0], register2[31:23]}; end
				5'd24: begin arithmetic_result = {register2[23:0], register2[31:24]}; end
				5'd25: begin arithmetic_result = {register2[24:0], register2[31:25]}; end
				5'd26: begin arithmetic_result = {register2[25:0], register2[31:26]}; end
				5'd27: begin arithmetic_result = {register2[26:0], register2[31:27]}; end
				5'd28: begin arithmetic_result = {register2[27:0], register2[31:28]}; end
				5'd29: begin arithmetic_result = {register2[28:0], register2[31:29]}; end
				5'd30: begin arithmetic_result = {register2[29:0], register2[31:30]}; end
				5'd31: begin arithmetic_result = {register2[30:0], register2[31]}; end
				default: begin
					arithmetic_result = register2;
				end
			endcase
			end

		4'hB: begin //compare r1 and r2, set flags, needs to use comp bits now
			arithmetic_result = register1 - register2;
			end

		4'hC: begin arithmetic_result = im_val; //load r1 with a 16 bit memory address (literal)
			end

		4'hD: begin arithmetic_result = arithmetic_result;
			end

		4'hE: begin arithmetic_result = arithmetic_result;
			end

		default: begin arithmetic_result = 0; 
			end
	endcase
	
assign result = arithmetic_result[31:0];
end

setflags flagmodule (clk, reset, s, opcode, register1, register2, arithmetic_result, flags_from_module);

endmodule


