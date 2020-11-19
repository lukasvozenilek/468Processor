// Register Bank and Accompanying Modules
module regbank (opcode, source1, source2, reset, clk, destination, D, S1, S2, PC);
	input reset, clk;
	input [3:0] destination, S1, S2, opcode;
	input [31:0] D;

	wire [15:0] en;
	wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
	wire load;

	//Don't load register value if no-op or STR or CMP
	assign load = opcode != 4'b1111 && opcode != 4'b1110 && opcode != 4'b1011;

	output [31:0] source1, source2;
	output [15:0] PC;

	assign PC = Q15[15:0];

	// Instantiate Decoder 
	// fetch dest = IR[22:19] from instruction
	// enables designated register	
	Decoder4_16 dec(en,destination);

	// Instantiate Registers
	//Stores LDR data into designated register enabled by decoder
	register R0(Q0, D, en[0] & load, reset, clk),
         	 R1(Q1, D, en[1] & load, reset, clk),
         	 R2(Q2, D, en[2] & load, reset, clk),
         	 R3(Q3, D, en[3] & load, reset, clk),
         	 R4(Q4, D, en[4] & load, reset, clk),
         	 R5(Q5, D, en[5] & load, reset, clk),
         	 R6(Q6, D, en[6] & load, reset, clk),
         	 R7(Q7, D, en[7] & load, reset, clk), 
         	 R8(Q8, D, en[8] & load, reset, clk),
         	 R9(Q9, D, en[9] & load, reset, clk), 
         	 R10(Q10, D, en[10] & load, reset, clk),
         	 R11(Q11, D, en[11] & load, reset, clk),
         	 R12(Q12, D, en[12] & load, reset, clk),
         	 R13(Q13, D, en[13] & load, reset, clk),
         	 R14(Q14, D, en[14] & load, reset, clk);
	
	//R15 defined seperately to utilize parameter
	register #(1) R15(Q15, D, en[15] & load, reset, clk);
         

	// Instantiate Source1 and Source2 Muxes
	// fetch S1 = IR[14:11] and S2 = IR[18:15] from instruction
	// Selects an output from a register 
	MUX16_1  Mux1(source1, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, S1), 
         	 Mux2(source2, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, S2);
endmodule
