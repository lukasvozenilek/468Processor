module Test_Controller;

//32 bit signals
wire[31:0] LDR_out, REG_IN, databus, instruction, source1, source2, ALU_result;

//16 bit signals
wire[15:0] ADR_out, PC_Addr, RAM_ADDR;

//4 bit signals
wire[3:0] flags, modified_opcode;

//1 bit signals
wire LDR_select, RAM_RW, ADR_select;
reg reset, clk;

//Modules
MemoryControl mem(clk, instruction[27:24], databus, source1, source2, LDR_select, LDR_out, RAM_RW, ADR_select, ADR_out);

RAM ram (databus, clk, RAM_RW, RAM_ADDR, reset);

InstructionRegister IR(clk, reset, PC_Addr, (!LDR_select && !RAM_RW), databus, instruction, modified_opcode);

alu mainALU(clk, reset, ALU_result, source1, source2, instruction, flags, modified_opcode);

regbank registors(modified_opcode, source2, source1, reset, clk, instruction[22:19], REG_IN, instruction[18:15], instruction[14:11], PC_Addr);

mux #(32) LDRMUX(ALU_result, LDR_out, REG_IN, LDR_select);

mux #(16) ADRMUX(PC_Addr, ADR_out, RAM_ADDR, ADR_select);

initial
begin
$display("Simulating CPU");
end

initial
begin
$monitor($time, "ps, clk: %d, instruction: %b, source1: %d, source2: %d, alu_result: %d, PC: %d, RAM_databus: %d, RAM_RW: %d, REG_IN: %d, RAM_ADDR: %d, ADR_select: %d, LDR_select: %d, Flags: %b", clk, instruction, source1, source2, ALU_result, PC_Addr, databus,RAM_RW, REG_IN, RAM_ADDR, ADR_select, LDR_select, flags);

//Load data.txt into memory
$readmemb("startram.txt", ram.Memory);

//Reset process
reset = 0;
clk = 0;
#1 reset = 1;
#1 reset = 0;
end

always
begin
#10 clk = ~clk;

//Stop simulation and save memory to file when we reach a no-op
if (instruction == 32'b00001111000000000000000000000000 && clk) 
begin
	$writememb("endram.txt", ram.Memory);
	$stop;
end
end
endmodule 