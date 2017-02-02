module Pipeline1 (
	input clk,
	input stall,
	input rst,
	input [31:0] P_PC,
	input [31:0] inst, // instruction
	input [31:0] rd1,
	input [31:0] rd2,
	input [4:0] wa,
	input [31:0] i_rd2,
	input [31:0] s_rd2,
	input [31:0] sb_rd2,
	input [31:0] u_rd2,
	input [31:0] uj,
	input [31:0] shamt,
	input [3:0] ALUop,  // Control
	input regWrite,
	input rd1Sel,
	input [2:0] rd2Sel,
	input dramWrite,
	input memOrReg,
	input jump,
	input branch,
	input [2:0] size,
	output reg [31:0] out_P_PC,
	output reg [31:0] out_inst, // instruction
	output reg [31:0] out_rd1,
	output reg [31:0] out_rd2,
	output reg [4:0] out_wa,
	output reg [31:0] out_i_rd2,
	output reg [31:0] out_s_rd2,
	output reg [31:0] out_sb_rd2,
	output reg [31:0] out_u_rd2,
	output reg [31:0] out_uj,
	output reg [31:0] out_shamt,
	output reg [3:0] out_ALUop,  // Control
	output reg out_regWrite,
	output reg out_rd1Sel,
	output reg [2:0] out_rd2Sel,
	output reg out_dramWrite,
	output reg out_memOrReg,
	output reg out_jump,
	output reg out_branch,
	output reg [2:0] out_size
	);

	always@(posedge clk) begin
		if(stall) begin // do nothing
			out_P_PC <= out_P_PC;
			out_inst <= out_inst; // instruction
			out_rd1 <= out_rd1;
			out_rd2 <= out_rd2;
			out_wa <= out_wa;
			out_i_rd2 <= out_i_rd2;
			out_s_rd2 <= out_s_rd2;
			out_sb_rd2 <= out_sb_rd2;
			out_u_rd2 <= out_u_rd2;
			out_uj <= out_uj;
			out_shamt <= out_shamt;
			out_ALUop <= out_ALUop;  // Control
			out_regWrite <= out_regWrite;
			out_rd1Sel <= out_rd1Sel;
			out_rd2Sel <= out_rd2Sel;
			out_dramWrite <= out_dramWrite;
			out_memOrReg <= out_memOrReg;
			out_jump <= out_jump;
			out_branch <= out_branch;
			out_size <= out_size;
		end	
		else if (rst) begin // make instruction to be NOP or just don't do anything
			out_P_PC <= 32'b0;
			out_inst <= 32'b0000_0000_0000_0000_0000_0000_0001_0011; // instruction
			out_rd1 <= 32'b0;
			out_rd2 <= 32'b0;
			out_wa <= 5'b0;
			out_i_rd2 <= 32'b0;
			out_s_rd2 <= 32'b0;
			out_sb_rd2 <= 32'b0;
			out_u_rd2 <= 32'b0;
			out_uj <= 32'b0;
			out_shamt <= 32'b0;
			out_ALUop <= 4'd0;  // Control
			out_regWrite <= 1'b0;
			out_rd1Sel <= 1'b0;
			out_rd2Sel <= 3'b0;
			out_dramWrite <= 1'b0;
			out_memOrReg <= 1'b0;
			out_jump <= 1'b0;
			out_branch <= 1'b0;
			out_size <= 3'b0;
		end
		else begin
			out_P_PC <= P_PC;
			out_inst <= inst; // instruction
			out_rd1 <= rd1;
			out_rd2 <= rd2;
			out_wa <= wa;
			out_i_rd2 <= i_rd2;
			out_s_rd2 <= s_rd2;
			out_sb_rd2 <= sb_rd2;
			out_u_rd2 <= u_rd2;
			out_uj <= uj;
			out_shamt <= shamt;
			out_ALUop <= ALUop;  // Control
			out_regWrite <= regWrite;
			out_rd1Sel <= rd1Sel;
			out_rd2Sel <= rd2Sel;
			out_dramWrite <= dramWrite;
			out_memOrReg <= memOrReg;
			out_jump <= jump;
			out_branch <= branch;
			out_size <= size;
		end
	end
endmodule
