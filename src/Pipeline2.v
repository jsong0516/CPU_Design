module Pipeline2 (
	input clk,
	input stall,
	input rst,
	input [31:0] inst, // instruction
	input [4:0] wa,
	input [31:0] alu_result,
	input regWrite,
	input memOrReg,
	input [2:0] size,
	input in_jump,
	input [31:0] PC,
	input [31:0] UARTOut,
	input isUARTLoad,
	input take_branch,
	output reg out2_take_branch,
	output reg OUT_isUARTLoad,
	output reg [31:0] pip2_UARTOut,
	output reg [31:0] OUT_PC,
	output reg out_jump,
	output reg [31:0] out2_inst, // instruction
	output reg [4:0] out2_wa,
	output reg [31:0] out2_alu_result,  // Control
	output reg out2_regWrite,
	output reg out2_memOrReg,
	output reg [2:0] out2_size
	);



	always@(posedge clk) begin
		if(stall) begin // do nothing
			out_jump <= out_jump;
			pip2_UARTOut <= pip2_UARTOut;
			OUT_PC <= OUT_PC;
			out2_inst <= out2_inst; // instruction
			out2_alu_result <= out2_alu_result;  // Control
			out2_regWrite <= out2_regWrite; 
			out2_memOrReg <= out2_memOrReg;
			out2_size <= out2_size;
			out2_wa <= out2_wa;
			OUT_isUARTLoad <= OUT_isUARTLoad;
			out2_take_branch <= out2_take_branch;
		end
		else if (rst) begin // make instruction to be NOP or just don't do anything
			out_jump <= 1'b0;
			pip2_UARTOut <= 32'b0;
			out2_inst <= 32'b0000_0000_0000_0000_0000_0000_0001_0011; // instruction
			out2_alu_result <= 32'b0;  // Control
			out2_regWrite <= 1'b0; 
			out2_memOrReg <= 1'b0;
			out2_size <= 3'b0;
			out2_wa <= 5'b0;
			OUT_PC <= 32'b0;
			OUT_isUARTLoad <= 1'b0;
			out2_take_branch <= 1'b0;
		end
		else begin
			pip2_UARTOut <= UARTOut;
			OUT_PC <= PC;
			out_jump <= in_jump;
			out2_inst <= inst; // instruction
			out2_alu_result <= alu_result;  // Control
			out2_regWrite <= regWrite; 
			out2_memOrReg <= memOrReg;
			out2_size <= size;
			out2_wa <= wa;
			OUT_isUARTLoad <= isUARTLoad;
			out2_take_branch <= take_branch;
		end
	end
endmodule
